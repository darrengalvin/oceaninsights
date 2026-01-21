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
      await _clickPlayer?.setVolume(0.3); // Subtle volume
      _isInitialized = true;
      debugPrint('✅ UI Sound Service initialized');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize UI sounds: $e');
    }
  }

  /// Play the navigation click sound
  Future<void> playClick() async {
    if (!_isInitialized || _clickPlayer == null) return;

    try {
      // Seek to start and play (don't await to avoid blocking UI)
      _clickPlayer!.seek(Duration.zero);
      _clickPlayer!.play();
    } catch (e) {
      debugPrint('⚠️ Failed to play click sound: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _clickPlayer?.dispose();
    _clickPlayer = null;
    _isInitialized = false;
  }
}

