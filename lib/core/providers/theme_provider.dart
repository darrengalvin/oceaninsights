import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/theme_options.dart';

/// Provider for managing app theme selection
class ThemeProvider extends ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');
  
  late ThemeOption _currentTheme;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  /// Current theme
  ThemeOption get currentTheme => _currentTheme;
  
  /// Current theme data for MaterialApp
  ThemeData get themeData => _currentTheme.themeData;
  
  /// Load theme from storage
  void _loadTheme() {
    final savedThemeId = _settingsBox.get('theme_id', defaultValue: 'below_the_surface');
    _currentTheme = ThemeOptions.getById(savedThemeId);
  }
  
  /// Set a new theme
  Future<void> setTheme(ThemeOption theme) async {
    _currentTheme = theme;
    await _settingsBox.put('theme_id', theme.id);
    notifyListeners();
  }
  
  /// Set theme by ID
  Future<void> setThemeById(String themeId) async {
    final theme = ThemeOptions.getById(themeId);
    await setTheme(theme);
  }
}

