import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UIPreferencesService extends ChangeNotifier {
  static final UIPreferencesService _instance = UIPreferencesService._internal();
  factory UIPreferencesService() => _instance;
  UIPreferencesService._internal();

  static const String _boxName = 'ui_preferences';
  static const String _soundsEnabledKey = 'sounds_enabled';

  Box? _box;
  bool _soundsEnabled = true;

  bool get soundsEnabled => _soundsEnabled;

  Future<void> initialize() async {
    try {
      _box = await Hive.openBox(_boxName);
      _soundsEnabled = _box?.get(_soundsEnabledKey, defaultValue: true) ?? true;
      debugPrint('✅ UI Preferences initialized - Sounds: $_soundsEnabled');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize UI preferences: $e');
    }
  }

  Future<void> setSoundsEnabled(bool enabled) async {
    _soundsEnabled = enabled;
    await _box?.put(_soundsEnabledKey, enabled);
    notifyListeners();
    debugPrint('🔊 UI Sounds ${enabled ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleSounds() async {
    await setSoundsEnabled(!_soundsEnabled);
  }
}

