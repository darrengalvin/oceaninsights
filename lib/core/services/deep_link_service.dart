import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../features/access_code/screens/redeem_code_screen.dart';

/// Listens for incoming sponsorship invite links and routes them to the
/// redeem screen with the code pre-filled.
///
/// Supports:
///   * Universal Links: https://<host>/r/<CODE>
///   * Custom URL scheme: belowthesurface://r/<CODE>
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  /// Wire the service up. Call this after [runApp] with the global navigator
  /// key so we can push routes from outside the widget tree.
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) return;
    _initialized = true;
    _navigatorKey = navigatorKey;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handle(initialUri, fromCold: true);
      }
    } catch (e) {
      debugPrint('🔗 DeepLink: failed to read initial link: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handle(uri, fromCold: false),
      onError: (Object e) => debugPrint('🔗 DeepLink stream error: $e'),
    );
  }

  void _handle(Uri uri, {required bool fromCold}) {
    debugPrint('🔗 DeepLink received: $uri (fromCold=$fromCold)');
    final code = _extractCode(uri);
    if (code == null) return;

    if (fromCold) {
      Future.delayed(const Duration(milliseconds: 1500), () => _pushRedeem(code));
    } else {
      _pushRedeem(code);
    }
  }

  String? _extractCode(Uri uri) {
    final segments = uri.pathSegments;
    final idx = segments.indexOf('r');
    if (idx >= 0 && idx + 1 < segments.length) {
      final raw = segments[idx + 1];
      final code = Uri.decodeComponent(raw).trim().toUpperCase();
      if (code.isNotEmpty) return code;
    }
    if (uri.scheme == 'belowthesurface' && uri.host == 'r' && segments.isNotEmpty) {
      return Uri.decodeComponent(segments.first).trim().toUpperCase();
    }
    return null;
  }

  void _pushRedeem(String code) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      debugPrint('🔗 DeepLink: navigator not ready, dropping code');
      return;
    }
    navigator.push(
      MaterialPageRoute(
        builder: (_) => RedeemCodeScreen(initialCode: code, autoSubmit: true),
      ),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _initialized = false;
  }
}
