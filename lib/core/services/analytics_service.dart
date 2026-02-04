import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Anonymous analytics service for tracking app usage
/// Privacy-compliant: no personal data, anonymous device ID only
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _boxName = 'analytics';
  static const String _deviceIdKey = 'device_id';
  static const String _sessionIdKey = 'session_id';
  static const String _optOutKey = 'analytics_opt_out';
  static const String _sessionStartKey = 'session_start';

  late Box _box;
  String? _deviceId;
  String? _currentSessionId;
  DateTime? _sessionStart;
  bool _isInitialized = false;
  bool _optedOut = false;
  int _screenViewCount = 0;
  int _eventCount = 0;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _box = await Hive.openBox(_boxName);
      _optedOut = _box.get(_optOutKey, defaultValue: false);
      
      if (_optedOut) {
        debugPrint('📊 Analytics: User opted out');
        _isInitialized = true;
        return;
      }

      // Get or create anonymous device ID
      _deviceId = _box.get(_deviceIdKey);
      if (_deviceId == null) {
        _deviceId = const Uuid().v4();
        await _box.put(_deviceIdKey, _deviceId);
        await _registerDevice();
      } else {
        await _updateDeviceLastSeen();
      }

      // Start a new session
      await _startSession();

      _isInitialized = true;
      debugPrint('📊 Analytics initialized: $_deviceId');
    } catch (e) {
      debugPrint('📊 Analytics init error: $e');
    }
  }

  /// Check if user has opted out
  bool get isOptedOut => _optedOut;

  /// Opt out of analytics
  Future<void> optOut() async {
    _optedOut = true;
    await _box.put(_optOutKey, true);
    debugPrint('📊 Analytics: Opted out');
  }

  /// Opt back in to analytics
  Future<void> optIn() async {
    _optedOut = false;
    await _box.put(_optOutKey, false);
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await _box.put(_deviceIdKey, _deviceId);
      await _registerDevice();
    }
    await _startSession();
    debugPrint('📊 Analytics: Opted in');
  }

  /// Register a new device
  Future<void> _registerDevice() async {
    if (_deviceId == null) return;

    try {
      await _supabase.from('analytics_devices').insert({
        'device_id': _deviceId,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'os_version': Platform.operatingSystemVersion,
        'app_version': '1.0.0', // TODO: Get from package_info
        'device_model': _getDeviceModel(),
      });
      debugPrint('📊 Device registered');
    } catch (e) {
      debugPrint('📊 Device registration error: $e');
    }
  }

  /// Update device last seen timestamp
  Future<void> _updateDeviceLastSeen() async {
    if (_deviceId == null) return;

    try {
      await _supabase.from('analytics_devices').update({
        'last_seen_at': DateTime.now().toIso8601String(),
        'total_sessions': _supabase.rpc('increment_sessions', params: {'device': _deviceId}),
      }).eq('device_id', _deviceId!);
    } catch (e) {
      // If RPC fails, just update last_seen
      try {
        await _supabase.from('analytics_devices').update({
          'last_seen_at': DateTime.now().toIso8601String(),
        }).eq('device_id', _deviceId!);
      } catch (_) {}
    }
  }

  /// Start a new session
  Future<void> _startSession() async {
    if (_deviceId == null || _optedOut) return;

    _sessionStart = DateTime.now();
    _screenViewCount = 0;
    _eventCount = 0;

    try {
      final response = await _supabase.from('analytics_sessions').insert({
        'device_id': _deviceId,
        'started_at': _sessionStart!.toIso8601String(),
        'app_version': '1.0.0',
      }).select('id').single();

      _currentSessionId = response['id'];
      await _box.put(_sessionIdKey, _currentSessionId);
      await _box.put(_sessionStartKey, _sessionStart!.toIso8601String());
      debugPrint('📊 Session started: $_currentSessionId');
    } catch (e) {
      debugPrint('📊 Session start error: $e');
    }
  }

  /// End the current session
  Future<void> endSession() async {
    if (_currentSessionId == null || _sessionStart == null || _optedOut) return;

    final duration = DateTime.now().difference(_sessionStart!).inSeconds;

    try {
      await _supabase.from('analytics_sessions').update({
        'ended_at': DateTime.now().toIso8601String(),
        'duration_seconds': duration,
        'screens_viewed': _screenViewCount,
        'events_count': _eventCount,
      }).eq('id', _currentSessionId!);

      debugPrint('📊 Session ended: ${duration}s, $_screenViewCount screens, $_eventCount events');
    } catch (e) {
      debugPrint('📊 Session end error: $e');
    }

    _currentSessionId = null;
    _sessionStart = null;
  }

  /// Track a screen view
  Future<void> trackScreenView(String screenName) async {
    if (_optedOut || _deviceId == null) return;

    _screenViewCount++;
    await _trackEvent('screen_view', 'navigation', screenName: screenName);
  }

  /// Track a feature usage
  Future<void> trackFeatureUsed(String featureName, {String? category, Map<String, dynamic>? data}) async {
    if (_optedOut || _deviceId == null) return;

    await _trackEvent('feature_used', category ?? featureName, eventData: {
      'feature': featureName,
      ...?data,
    });
  }

  /// Track breathing exercise completed
  Future<void> trackBreathingCompleted(String exerciseType, int durationSeconds) async {
    await trackFeatureUsed('breathing', category: 'breathing', data: {
      'exercise_type': exerciseType,
      'duration_seconds': durationSeconds,
    });
  }

  /// Track mood logged
  Future<void> trackMoodLogged(String moodLevel) async {
    await trackFeatureUsed('mood_log', category: 'mood', data: {
      'mood_level': moodLevel,
    });
  }

  /// Track game played
  Future<void> trackGamePlayed(String gameName, int score, int durationSeconds) async {
    await trackFeatureUsed('game_played', category: 'games', data: {
      'game_name': gameName,
      'score': score,
      'duration_seconds': durationSeconds,
    });
  }

  /// Track ritual completed
  Future<void> trackRitualCompleted(String ritualId) async {
    await trackFeatureUsed('ritual_completed', category: 'rituals', data: {
      'ritual_id': ritualId,
    });
  }

  /// Track content viewed
  Future<void> trackContentViewed(String contentType, String contentId) async {
    await trackFeatureUsed('content_viewed', category: 'content', data: {
      'content_type': contentType,
      'content_id': contentId,
    });
  }

  /// Track goal created/completed
  Future<void> trackGoalAction(String action, String goalId) async {
    await trackFeatureUsed('goal_$action', category: 'goals', data: {
      'goal_id': goalId,
      'action': action,
    });
  }

  /// Track audio played
  Future<void> trackAudioPlayed(String audioType, String audioName) async {
    await trackFeatureUsed('audio_played', category: 'audio', data: {
      'audio_type': audioType,
      'audio_name': audioName,
    });
  }

  /// Track donation/purchase
  Future<void> trackPurchase(String productId, double amount) async {
    await trackFeatureUsed('purchase', category: 'monetization', data: {
      'product_id': productId,
      'amount': amount,
    });
  }

  /// Internal method to track events
  Future<void> _trackEvent(
    String eventName,
    String? category, {
    String? screenName,
    Map<String, dynamic>? eventData,
  }) async {
    if (_optedOut || _deviceId == null) return;

    _eventCount++;

    try {
      await _supabase.from('analytics_events').insert({
        'device_id': _deviceId,
        'session_id': _currentSessionId,
        'event_name': eventName,
        'event_category': category,
        'screen_name': screenName,
        'event_data': eventData,
      });
    } catch (e) {
      debugPrint('📊 Event tracking error: $e');
    }
  }

  /// Update user type (for segmentation)
  Future<void> updateUserType(String userType) async {
    if (_optedOut || _deviceId == null) return;

    try {
      await _supabase.from('analytics_devices').update({
        'user_type': userType,
      }).eq('device_id', _deviceId!);
    } catch (e) {
      debugPrint('📊 Update user type error: $e');
    }
  }

  /// Update age bracket (for segmentation)
  Future<void> updateAgeBracket(String ageBracket) async {
    if (_optedOut || _deviceId == null) return;

    try {
      await _supabase.from('analytics_devices').update({
        'age_bracket': ageBracket,
      }).eq('device_id', _deviceId!);
    } catch (e) {
      debugPrint('📊 Update age bracket error: $e');
    }
  }

  String _getDeviceModel() {
    // This is a simplified version - could use device_info_plus for more detail
    if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    }
    return 'Unknown';
  }

  /// Clear all analytics data (for data deletion)
  Future<void> clearAnalyticsData() async {
    if (_deviceId != null) {
      try {
        // Delete events first (foreign key)
        await _supabase.from('analytics_events').delete().eq('device_id', _deviceId!);
        // Delete sessions
        await _supabase.from('analytics_sessions').delete().eq('device_id', _deviceId!);
        // Delete device
        await _supabase.from('analytics_devices').delete().eq('device_id', _deviceId!);
      } catch (e) {
        debugPrint('📊 Clear analytics error: $e');
      }
    }

    // Clear local data
    await _box.clear();
    _deviceId = null;
    _currentSessionId = null;
    _sessionStart = null;

    debugPrint('📊 Analytics data cleared');
  }
}
