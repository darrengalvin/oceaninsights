import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/ritual_item.dart';

/// Service to manage daily rituals and routines
class RitualService {
  static final RitualService _instance = RitualService._internal();
  factory RitualService() => _instance;
  RitualService._internal();

  static const String _boxName = 'ritual_data';
  static const String _ritualsKey = 'rituals_list';
  
  Box? _box;
  List<RitualItem> _rituals = [];
  
  /// Initialize the service
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    
    // Load rituals from storage
    _loadRituals();
    
    // Add default rituals if first time
    if (_rituals.isEmpty) {
      await _addDefaultRituals();
    }
    
    // Reset daily completion status
    _resetDailyCompletions();
  }
  
  /// Load rituals from Hive storage
  void _loadRituals() {
    final ritualsJson = _box!.get(_ritualsKey, defaultValue: []) as List;
    _rituals = ritualsJson
        .map((json) => RitualItem.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
  
  /// Save rituals to Hive storage
  Future<void> _saveRituals() async {
    final ritualsJson = _rituals.map((r) => r.toJson()).toList();
    await _box!.put(_ritualsKey, ritualsJson);
  }
  
  /// Add default ritual items
  Future<void> _addDefaultRituals() async {
    _rituals = [
      // Morning rituals
      RitualItem(
        id: 'morning_1',
        title: 'Make bed',
        type: RitualType.morning,
        isDefault: true,
        order: 0,
      ),
      RitualItem(
        id: 'morning_2',
        title: 'Brush teeth',
        type: RitualType.morning,
        isDefault: true,
        order: 1,
      ),
      RitualItem(
        id: 'morning_3',
        title: 'Drink water',
        type: RitualType.morning,
        isDefault: true,
        order: 2,
      ),
      RitualItem(
        id: 'morning_4',
        title: 'Stretch or move',
        type: RitualType.morning,
        isDefault: true,
        order: 3,
      ),
      
      // Evening rituals
      RitualItem(
        id: 'evening_1',
        title: 'Clean space',
        type: RitualType.evening,
        isDefault: true,
        order: 0,
      ),
      RitualItem(
        id: 'evening_2',
        title: 'Clear mind (journal/reflect)',
        type: RitualType.evening,
        isDefault: true,
        order: 1,
      ),
      RitualItem(
        id: 'evening_3',
        title: 'Prepare for tomorrow',
        type: RitualType.evening,
        isDefault: true,
        order: 2,
      ),
      RitualItem(
        id: 'evening_4',
        title: 'Device-free time',
        type: RitualType.evening,
        isDefault: true,
        order: 3,
      ),
      
      // Productivity rituals
      RitualItem(
        id: 'productivity_1',
        title: 'Set 1-3 main goals for today',
        type: RitualType.productivity,
        isDefault: true,
        order: 0,
      ),
      RitualItem(
        id: 'productivity_2',
        title: 'Remember: It\'s ok to not be productive',
        type: RitualType.productivity,
        isDefault: true,
        order: 1,
      ),
    ];
    
    await _saveRituals();
  }
  
  /// Reset daily completions if it's a new day
  void _resetDailyCompletions() {
    final lastResetDate = _box!.get('last_reset_date', defaultValue: '');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastResetDate != today) {
      for (final item in _rituals) {
        item.resetDaily();
      }
      _box!.put('last_reset_date', today);
      _saveRituals();
    }
  }
  
  /// Get all rituals of a specific type
  List<RitualItem> getRitualsByType(RitualType type) {
    final rituals = _rituals
        .where((item) => item.type == type)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return rituals;
  }
  
  /// Get all morning rituals
  List<RitualItem> getMorningRituals() => getRitualsByType(RitualType.morning);
  
  /// Get all evening rituals
  List<RitualItem> getEveningRituals() => getRitualsByType(RitualType.evening);
  
  /// Get all productivity rituals
  List<RitualItem> getProductivityRituals() => getRitualsByType(RitualType.productivity);
  
  /// Get current ritual type based on time of day
  RitualType getCurrentRitualType() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return RitualType.morning;
    } else if (hour >= 20 || hour < 5) {
      return RitualType.evening;
    } else {
      return RitualType.productivity;
    }
  }
  
  /// Get progress for a ritual type (completed / total)
  Map<String, int> getProgress(RitualType type) {
    final rituals = getRitualsByType(type);
    final completed = rituals.where((r) => r.isCompleted).length;
    return {'completed': completed, 'total': rituals.length};
  }
  
  /// Get overall progress (all types combined)
  Map<String, int> getOverallProgress() {
    final completed = _rituals.where((r) => r.isCompleted).length;
    return {'completed': completed, 'total': _rituals.length};
  }
  
  /// Toggle ritual completion
  Future<void> toggleRitual(String id) async {
    final item = _rituals.firstWhere((r) => r.id == id);
    if (item.isCompleted) {
      item.markIncomplete();
    } else {
      item.markCompleted();
      _updateStreak();
    }
    await _saveRituals();
  }
  
  /// Add a custom ritual
  Future<void> addCustomRitual({
    required String title,
    required RitualType type,
  }) async {
    final rituals = getRitualsByType(type);
    final maxOrder = rituals.isEmpty ? 0 : rituals.map((r) => r.order).reduce((a, b) => a > b ? a : b);
    
    final item = RitualItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      isDefault: false,
      order: maxOrder + 1,
    );
    
    _rituals.add(item);
    await _saveRituals();
  }
  
  /// Delete a custom ritual
  Future<void> deleteRitual(String id) async {
    _rituals.removeWhere((r) => r.id == id && !r.isDefault);
    await _saveRituals();
  }
  
  /// Update streak tracking
  void _updateStreak() {
    // Check if all rituals for current type are completed
    final currentType = getCurrentRitualType();
    final progress = getProgress(currentType);
    
    if (progress['completed'] == progress['total'] && progress['total']! > 0) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastStreakDate = _box!.get('last_streak_date', defaultValue: '');
      final currentStreak = _box!.get('current_streak', defaultValue: 0) as int;
      
      if (lastStreakDate != today) {
        // Check if yesterday was completed
        final yesterday = DateTime.now().subtract(const Duration(days: 1))
            .toIso8601String().substring(0, 10);
        
        if (lastStreakDate == yesterday) {
          // Continue streak
          _box!.put('current_streak', currentStreak + 1);
        } else {
          // Start new streak
          _box!.put('current_streak', 1);
        }
        
        _box!.put('last_streak_date', today);
        
        // Update max streak
        final maxStreak = _box!.get('max_streak', defaultValue: 0) as int;
        final newStreak = _box!.get('current_streak', defaultValue: 0) as int;
        if (newStreak > maxStreak) {
          _box!.put('max_streak', newStreak);
        }
      }
    }
  }
  
  /// Get current streak
  int getCurrentStreak() {
    return _box!.get('current_streak', defaultValue: 0) as int;
  }
  
  /// Get max streak
  int getMaxStreak() {
    return _box!.get('max_streak', defaultValue: 0) as int;
  }
  
  /// Get completion rate for last 7 days
  double getWeeklyCompletionRate() {
    // This would require storing daily completion data
    // For now, return today's rate
    final progress = getOverallProgress();
    if (progress['total']! == 0) return 0.0;
    return progress['completed']! / progress['total']!;
  }
}
