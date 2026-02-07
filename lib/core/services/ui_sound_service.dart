import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'ui_preferences_service.dart';

/// Service for playing UI feedback sounds and game audio
class UISoundService {
  static final UISoundService _instance = UISoundService._internal();
  factory UISoundService() => _instance;
  UISoundService._internal();

  AudioPlayer? _clickPlayer;
  AudioPlayer? _perfectPlayer;
  AudioPlayer? _comboPlayer;
  AudioPlayer? _gameOverPlayer;
  bool _isInitialized = false;

  /// Initialize the sound service (call once at app start)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _clickPlayer = AudioPlayer();
      await _clickPlayer?.setAsset('assets/audio/walkman-button-272973.mp3');
      await _clickPlayer?.setVolume(0.6); // Audible but not loud
      
      // Initialize game sound players with custom sounds
      _perfectPlayer = AudioPlayer();
      await _perfectPlayer?.setAsset('assets/audio/games/chime-sound-7143.mp3');
      await _perfectPlayer?.setVolume(0.7);
      
      _comboPlayer = AudioPlayer();
      await _comboPlayer?.setAsset('assets/audio/games/crowd-cheers-314919.mp3');
      await _comboPlayer?.setVolume(0.6);
      
      _gameOverPlayer = AudioPlayer();
      await _gameOverPlayer?.setAsset('assets/audio/games/game-over-classic-206486.mp3');
      await _gameOverPlayer?.setVolume(0.7);
      
      _isInitialized = true;
      debugPrint('✅ UI Sound Service initialized with game sounds');
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

    // Check if sounds are enabled
    if (!UIPreferencesService().soundsEnabled) {
      return;
    }

    // Don't await - fire and forget for responsive UI
    _clickPlayer!.stop().then((_) {
      return _clickPlayer!.seek(Duration.zero);
    }).then((_) {
      return _clickPlayer!.play();
    }).catchError((e) {
      // Only log errors, not every click
      debugPrint('⚠️ Failed to play click sound: $e');
    });
  }

  /// Play perfect placement sound
  void playPerfect() {
    if (!_isInitialized || _perfectPlayer == null) return;
    if (!UIPreferencesService().soundsEnabled) return;

    _perfectPlayer!.stop().then((_) {
      return _perfectPlayer!.seek(Duration.zero);
    }).then((_) {
      return _perfectPlayer!.play();
    }).catchError((e) {
      debugPrint('⚠️ Failed to play perfect sound: $e');
    });
  }

  /// Play combo sound (for streaks)
  void playCombo(int comboCount) {
    if (!_isInitialized || _comboPlayer == null) return;
    if (!UIPreferencesService().soundsEnabled) return;

    _comboPlayer!.stop().then((_) {
      return _comboPlayer!.seek(Duration.zero);
    }).then((_) {
      // Slightly faster for higher combos
      final speed = (1.0 + (comboCount * 0.03)).clamp(1.0, 1.3);
      return _comboPlayer!.setSpeed(speed);
    }).then((_) {
      return _comboPlayer!.play();
    }).then((_) {
      return _comboPlayer!.setSpeed(1.0);
    }).catchError((e) {
      debugPrint('⚠️ Failed to play combo sound: $e');
    });
  }

  /// Play game over sound
  void playGameOver() {
    if (!_isInitialized || _gameOverPlayer == null) return;
    if (!UIPreferencesService().soundsEnabled) return;

    _gameOverPlayer!.stop().then((_) {
      return _gameOverPlayer!.seek(Duration.zero);
    }).then((_) {
      return _gameOverPlayer!.play();
    }).catchError((e) {
      debugPrint('⚠️ Failed to play game over sound: $e');
    });
  }

  /// Dispose resources
  void dispose() {
    _clickPlayer?.dispose();
    _perfectPlayer?.dispose();
    _comboPlayer?.dispose();
    _gameOverPlayer?.dispose();
    _clickPlayer = null;
    _perfectPlayer = null;
    _comboPlayer = null;
    _gameOverPlayer = null;
    _isInitialized = false;
  }
}


