import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Service for playing short UI feedback sounds
class UISoundService {
  static final UISoundService _instance = UISoundService._internal();
  factory UISoundService() => _instance;
  UISoundService._internal();

  AudioPlayer? _clickPlayer;
  bool _isInitialized = false;

  /// Initialize the sound service (call once at app start)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _clickPlayer = AudioPlayer();
      await _clickPlayer?.setAsset('assets/audio/walkman-button-272973.mp3');
      await _clickPlayer?.setVolume(0.6); // Audible but not loud
      _isInitialized = true;
      debugPrint('✅ UI Sound Service initialized with click sound');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize UI sounds: $e');
      _isInitialized = false;
    }
  }

  /// Play the navigation click sound
  void playClick() {
    if (!_isInitialized || _clickPlayer == null) {
      debugPrint('⚠️ Click sound not initialized');
      return;
    }

    // Don't await - fire and forget for responsive UI
    _clickPlayer!.stop().then((_) {
      return _clickPlayer!.seek(Duration.zero);
    }).then((_) {
      return _clickPlayer!.play();
    }).then((_) {
      debugPrint('🔊 Click sound played');
    }).catchError((e) {
      debugPrint('⚠️ Failed to play click sound: $e');
    });
  }

  /// Dispose resources
  void dispose() {
    _clickPlayer?.dispose();
    _clickPlayer = null;
    _isInitialized = false;
  }
}

