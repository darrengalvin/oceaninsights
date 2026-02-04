import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../theme/app_theme.dart';

/// Mood levels for self-assessment
/// Uses simple tap selection - no typing required (OPSEC safe)
enum MoodLevel {
  excellent,
  good,
  okay,
  low,
  struggling,
}

/// Extension for mood level properties
extension MoodLevelExtension on MoodLevel {
  String get label {
    switch (this) {
      case MoodLevel.excellent:
        return 'Great';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.low:
        return 'Low';
      case MoodLevel.struggling:
        return 'Rough';
    }
  }
  
  String get emoji {
    switch (this) {
      case MoodLevel.excellent:
        return '😊';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.low:
        return '😔';
      case MoodLevel.struggling:
        return '😢';
    }
  }
  
  Color get color {
    switch (this) {
      case MoodLevel.excellent:
        return AppTheme.seaGreen;
      case MoodLevel.good:
        return AppTheme.aquaGlow;
      case MoodLevel.okay:
        return AppTheme.warmAmber;
      case MoodLevel.low:
        return const Color(0xFFFB923C);
      case MoodLevel.struggling:
        return AppTheme.coralPink;
    }
  }
  
  int get value {
    switch (this) {
      case MoodLevel.excellent:
        return 5;
      case MoodLevel.good:
        return 4;
      case MoodLevel.okay:
        return 3;
      case MoodLevel.low:
        return 2;
      case MoodLevel.struggling:
        return 1;
    }
  }
}

/// Mood entry data structure
class MoodEntry {
  final String id;
  final MoodLevel mood;
  final DateTime timestamp;
  
  MoodEntry({
    required this.id,
    required this.mood,
    required this.timestamp,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood.index,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      mood: MoodLevel.values[map['mood'] as int],
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

/// Mood Provider
/// 
/// Manages mood tracking and self-assessment data
class MoodProvider extends ChangeNotifier {
  final Box _moodBox = Hive.box('mood_entries');
  final Uuid _uuid = const Uuid();
  
  List<MoodEntry> _entries = [];
  List<MoodEntry> get entries => List.unmodifiable(_entries);
  
  MoodProvider() {
    _loadEntries();
  }
  
  /// Load entries from local storage
  void _loadEntries() {
    final entriesData = _moodBox.get('entries', defaultValue: <dynamic>[]);
    _entries = (entriesData as List)
        .map((e) => MoodEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  /// Add a new mood entry
  Future<void> addMoodEntry(MoodLevel mood) async {
    final entry = MoodEntry(
      id: _uuid.v4(),
      mood: mood,
      timestamp: DateTime.now(),
    );
    
    _entries.insert(0, entry);
    await _saveEntries();
    notifyListeners();
  }
  
  /// Save entries to local storage
  Future<void> _saveEntries() async {
    await _moodBox.put(
      'entries',
      _entries.map((e) => e.toMap()).toList(),
    );
  }
  
  /// Get today's mood entry if exists
  MoodEntry? getTodaysMood() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      return _entries.firstWhere((entry) {
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        return entryDate == today;
      });
    } catch (_) {
      return null;
    }
  }
  
  /// Check if user has logged mood today
  bool hasLoggedToday() {
    return getTodaysMood() != null;
  }
  
  /// Get entries for the last N days
  List<MoodEntry> getRecentEntries(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _entries.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }
  
  /// Calculate average mood over last N days
  double? getAverageMood(int days) {
    final recent = getRecentEntries(days);
    if (recent.isEmpty) return null;
    
    final total = recent.fold<int>(0, (sum, e) => sum + e.mood.value);
    return total / recent.length;
  }
  
  /// Get today's entries count
  int getTodayCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _entries.where((entry) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return entryDate == today;
    }).length;
  }
  
  /// Get all entries from today
  List<MoodEntry> getTodaysEntries() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _entries.where((entry) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return entryDate == today;
    }).toList();
  }
}

