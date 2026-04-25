import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Result of a code redemption or validation call.
class AccessCodeResult {
  final bool success;
  final String message;
  final DateTime? expiresAt;
  final String? organizationName;

  const AccessCodeResult({
    required this.success,
    required this.message,
    this.expiresAt,
    this.organizationName,
  });
}

/// Manages institutional/sponsor access codes that unlock premium without IAP.
///
/// Devices that have redeemed a valid sponsor code are treated as premium by
/// [SubscriptionService]. The redemption is anonymous - tied to an opaque
/// device id that is generated locally.
class AccessCodeService extends ChangeNotifier {
  static final AccessCodeService _instance = AccessCodeService._internal();
  factory AccessCodeService() => _instance;
  AccessCodeService._internal();

  static const String _boxName = 'access_code';
  static const String _keyCode = 'code';
  static const String _keyOrgName = 'org_name';
  static const String _keyExpiresAt = 'expires_at';
  static const String _keyDeviceId = 'device_id';
  static const String _keyRedeemedAt = 'redeemed_at';
  static const String _keyLastValidatedAt = 'last_validated_at';

  Box? _box;

  String? _code;
  String? _organizationName;
  DateTime? _expiresAt;
  DateTime? _redeemedAt;

  String? get code => _code;
  String? get organizationName => _organizationName;
  DateTime? get expiresAt => _expiresAt;
  DateTime? get redeemedAt => _redeemedAt;

  /// True if this device has a redeemed code that hasn't expired.
  bool get hasActiveCode {
    if (_code == null) return false;
    if (_expiresAt == null) return true;
    return _expiresAt!.isAfter(DateTime.now());
  }

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    _loadFromBox();
    debugPrint(
      '🎟️ AccessCodeService initialised - code=${_code != null} active=$hasActiveCode',
    );
  }

  void _loadFromBox() {
    _code = _box?.get(_keyCode) as String?;
    _organizationName = _box?.get(_keyOrgName) as String?;
    final expiryStr = _box?.get(_keyExpiresAt) as String?;
    final redeemedStr = _box?.get(_keyRedeemedAt) as String?;
    _expiresAt = expiryStr != null ? DateTime.tryParse(expiryStr) : null;
    _redeemedAt = redeemedStr != null ? DateTime.tryParse(redeemedStr) : null;
  }

  Future<String> _getOrCreateDeviceId() async {
    final box = _box;
    if (box == null) throw StateError('AccessCodeService not initialised');
    var id = box.get(_keyDeviceId) as String?;
    if (id == null) {
      id = const Uuid().v4();
      await box.put(_keyDeviceId, id);
    }
    return id;
  }

  /// Redeem a sponsor code. On success the device is marked as premium until
  /// the returned expiry.
  Future<AccessCodeResult> redeem(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      return const AccessCodeResult(
        success: false,
        message: 'Please enter a code',
      );
    }

    try {
      final deviceId = await _getOrCreateDeviceId();
      final supabase = Supabase.instance.client;

      final response = await supabase.rpc(
        'redeem_access_code',
        params: {'p_code': code, 'p_device_id': deviceId},
      );

      final row = _firstRow(response);
      if (row == null) {
        return const AccessCodeResult(
          success: false,
          message: 'No response from server. Please try again.',
        );
      }

      final success = row['success'] == true;
      final message = (row['message'] as String?) ?? '';
      final expiresAtStr = row['expires_at'] as String?;
      final orgName = row['organization_name'] as String?;
      final expiresAt =
          expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;

      if (success) {
        await _persist(
          code: code,
          organizationName: orgName,
          expiresAt: expiresAt,
        );
      }

      return AccessCodeResult(
        success: success,
        message: message.isEmpty ? (success ? 'Code redeemed' : 'Invalid code') : message,
        expiresAt: expiresAt,
        organizationName: orgName,
      );
    } catch (e) {
      debugPrint('🎟️ Redeem failed: $e');
      return const AccessCodeResult(
        success: false,
        message: 'Could not reach the server. Check your connection and try again.',
      );
    }
  }

  /// Re-validate the stored code against the server. Updates expiry; clears
  /// access if the code is no longer valid.
  Future<AccessCodeResult?> validateStored() async {
    if (_code == null) return null;
    try {
      final deviceId = await _getOrCreateDeviceId();
      final supabase = Supabase.instance.client;

      final response = await supabase.rpc(
        'validate_access_code',
        params: {'p_code': _code, 'p_device_id': deviceId},
      );

      final row = _firstRow(response);
      if (row == null) return null;

      final isValid = row['is_valid'] == true;
      final expiresAtStr = row['expires_at'] as String?;
      final orgName = row['organization_name'] as String?;
      final reason = (row['reason'] as String?) ?? '';
      final expiresAt =
          expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;

      await _box?.put(_keyLastValidatedAt, DateTime.now().toIso8601String());

      if (isValid) {
        await _persist(
          code: _code!,
          organizationName: orgName ?? _organizationName,
          expiresAt: expiresAt,
        );
        return AccessCodeResult(
          success: true,
          message: 'Code is active',
          expiresAt: expiresAt,
          organizationName: orgName,
        );
      } else {
        await clear();
        return AccessCodeResult(
          success: false,
          message: _reasonToMessage(reason),
        );
      }
    } catch (e) {
      debugPrint('🎟️ Validate failed (offline?): $e');
      return null;
    }
  }

  String _reasonToMessage(String reason) {
    switch (reason) {
      case 'expired':
        return 'Your sponsor code has expired';
      case 'deactivated':
        return 'Your sponsor code has been deactivated';
      case 'sponsor_inactive':
        return 'Your sponsor is no longer active';
      case 'wrong_device':
        return 'This code is registered to a different device';
      case 'invalid':
        return 'Code no longer exists';
      default:
        return 'Code is no longer valid';
    }
  }

  Future<void> _persist({
    required String code,
    String? organizationName,
    DateTime? expiresAt,
  }) async {
    _code = code;
    _organizationName = organizationName;
    _expiresAt = expiresAt;
    _redeemedAt ??= DateTime.now();

    await _box?.put(_keyCode, code);
    await _box?.put(_keyOrgName, organizationName ?? '');
    await _box?.put(
      _keyExpiresAt,
      expiresAt?.toIso8601String() ?? '',
    );
    await _box?.put(_keyRedeemedAt, _redeemedAt!.toIso8601String());

    notifyListeners();
  }

  /// Remove the stored access code from this device.
  Future<void> clear() async {
    _code = null;
    _organizationName = null;
    _expiresAt = null;
    _redeemedAt = null;

    await _box?.delete(_keyCode);
    await _box?.delete(_keyOrgName);
    await _box?.delete(_keyExpiresAt);
    await _box?.delete(_keyRedeemedAt);

    notifyListeners();
  }

  /// Supabase rpc returns either a List<dynamic> or a single Map depending on
  /// the function shape. Normalise to the first row.
  Map<String, dynamic>? _firstRow(dynamic response) {
    if (response is List) {
      if (response.isEmpty) return null;
      final first = response.first;
      if (first is Map) return Map<String, dynamic>.from(first);
      return null;
    }
    if (response is Map) return Map<String, dynamic>.from(response);
    return null;
  }
}
