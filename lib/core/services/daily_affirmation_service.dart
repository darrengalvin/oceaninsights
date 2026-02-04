import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/affirmations/data/affirmations_data.dart';

/// Service to manage daily affirmations with category preferences
class DailyAffirmationService {
  static final DailyAffirmationService _instance = DailyAffirmationService._internal();
  factory DailyAffirmationService() => _instance;
  DailyAffirmationService._internal();

  static const String _boxName = 'settings';
  static const String _categoryKey = 'affirmation_category';
  static const String _lastDateKey = 'affirmation_last_date';
  static const String _lastAffirmationKey = 'affirmation_last_text';
  
  final Random _random = Random();
  
  /// Get available categories
  List<String> getCategories() {
    final categories = <String>{};
    for (final affirmation in AffirmationsData.affirmations) {
      categories.add(affirmation.category);
    }
    final sortedCategories = categories.toList()..sort();
    // Put "All" at the top
    return ['All', ...sortedCategories];
  }
  
  /// Get selected category preference
  String getSelectedCategory() {
    final box = Hive.box(_boxName);
    return box.get(_categoryKey, defaultValue: 'All') as String;
  }
  
  /// Set category preference
  Future<void> setSelectedCategory(String category) async {
    final box = Hive.box(_boxName);
    await box.put(_categoryKey, category);
  }
  
  /// Get today's affirmation
  Affirmation getTodaysAffirmation() {
    final box = Hive.box(_boxName);
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final lastDate = box.get(_lastDateKey, defaultValue: '') as String;
    
    // If it's a new day, pick a new affirmation
    if (lastDate != today) {
      final affirmation = _pickNewAffirmation();
      box.put(_lastDateKey, today);
      box.put(_lastAffirmationKey, affirmation.text);
      return affirmation;
    }
    
    // Return stored affirmation for today
    final storedText = box.get(_lastAffirmationKey, defaultValue: '') as String;
    if (storedText.isNotEmpty) {
      final affirmation = AffirmationsData.affirmations.firstWhere(
        (a) => a.text == storedText,
        orElse: () => _pickNewAffirmation(),
      );
      return affirmation;
    }
    
    return _pickNewAffirmation();
  }
  
  /// Pick a new random affirmation based on category preference
  Affirmation _pickNewAffirmation() {
    final category = getSelectedCategory();
    
    List<Affirmation> filtered;
    if (category == 'All') {
      filtered = AffirmationsData.affirmations;
    } else {
      filtered = AffirmationsData.affirmations
          .where((a) => a.category == category)
          .toList();
    }
    
    if (filtered.isEmpty) {
      filtered = AffirmationsData.affirmations;
    }
    
    return filtered[_random.nextInt(filtered.length)];
  }
  
  /// Force refresh to get a new affirmation
  Affirmation refreshAffirmation() {
    final box = Hive.box(_boxName);
    final affirmation = _pickNewAffirmation();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    box.put(_lastDateKey, today);
    box.put(_lastAffirmationKey, affirmation.text);
    return affirmation;
  }
}
