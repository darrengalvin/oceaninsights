import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ritual_topic_models.dart';

/// Service to manage ritual topics from Supabase
class RitualTopicsService {
  static final RitualTopicsService _instance = RitualTopicsService._internal();
  factory RitualTopicsService() => _instance;
  RitualTopicsService._internal();

  static const String _boxName = 'ritual_topics_data';
  static const String _categoriesKey = 'categories';
  static const String _topicsKey = 'topics';
  static const String _subscriptionsKey = 'subscriptions';
  static const String _completionsKey = 'completions';
  static const String _lastSyncKey = 'last_sync';

  Box? _box;
  bool _isInitialized = false;

  List<RitualCategory> _categories = [];
  List<RitualTopic> _topics = [];
  List<UserTopicSubscription> _subscriptions = [];
  Map<String, DateTime> _completions = {}; // itemId -> lastCompletedDate

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _box = await Hive.openBox(_boxName);
    _loadFromCache();
    _isInitialized = true;

    // Sync in background
    syncFromSupabase();
  }

  /// Load cached data from Hive
  void _loadFromCache() {
    // Load categories
    final cachedCategories = _box!.get(_categoriesKey) as List?;
    if (cachedCategories != null) {
      _categories = cachedCategories
          .map((c) => RitualCategory.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    // Load topics
    final cachedTopics = _box!.get(_topicsKey) as List?;
    if (cachedTopics != null) {
      _topics = cachedTopics
          .map((t) => RitualTopic.fromJson(Map<String, dynamic>.from(t)))
          .toList();
    }

    // Load subscriptions
    final cachedSubs = _box!.get(_subscriptionsKey) as List?;
    if (cachedSubs != null) {
      _subscriptions = cachedSubs
          .map((s) => UserTopicSubscription.fromJson(Map<String, dynamic>.from(s)))
          .toList();
    }

    // Load completions
    final cachedCompletions = _box!.get(_completionsKey) as Map?;
    if (cachedCompletions != null) {
      _completions = Map<String, DateTime>.from(
        cachedCompletions.map((k, v) => MapEntry(k as String, DateTime.parse(v as String))),
      );
    }
  }

  /// Save to cache
  Future<void> _saveToCache() async {
    await _box!.put(_categoriesKey, _categories.map((c) => c.toJson()).toList());
    await _box!.put(_topicsKey, _topics.map((t) => t.toJson()).toList());
    await _box!.put(_subscriptionsKey, _subscriptions.map((s) => s.toJson()).toList());
    await _box!.put(_completionsKey, 
        _completions.map((k, v) => MapEntry(k, v.toIso8601String())));
    await _box!.put(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Sync data from Supabase
  Future<bool> syncFromSupabase() async {
    try {
      debugPrint('Syncing ritual topics from Supabase...');

      // Fetch categories
      final categoriesResponse = await _supabase
          .from('ritual_categories')
          .select()
          .eq('is_active', true)
          .order('display_order');

      _categories = (categoriesResponse as List)
          .map((c) => RitualCategory.fromJson(c))
          .toList();

      // Fetch topics with their items and affirmations
      final topicsResponse = await _supabase
          .from('ritual_topics')
          .select('''
            *,
            category:ritual_categories(id, slug, name, icon, color)
          ''')
          .eq('is_published', true)
          .order('display_order');

      _topics = (topicsResponse as List)
          .map((t) => RitualTopic.fromJson(t))
          .toList();

      // Fetch items for all topics
      final itemsResponse = await _supabase
          .from('ritual_items')
          .select()
          .eq('is_active', true)
          .order('display_order');

      final allItems = (itemsResponse as List)
          .map((i) => RitualTopicItem.fromJson(i))
          .toList();

      // Fetch affirmations
      final affirmationsResponse = await _supabase
          .from('ritual_affirmations')
          .select()
          .eq('is_active', true)
          .order('display_order');

      final allAffirmations = (affirmationsResponse as List)
          .map((a) => RitualAffirmation.fromJson(a))
          .toList();

      // Fetch milestones
      final milestonesResponse = await _supabase
          .from('ritual_milestones')
          .select()
          .order('day_threshold');

      final allMilestones = (milestonesResponse as List)
          .map((m) => RitualMilestone.fromJson(m))
          .toList();

      // Associate items, affirmations, milestones with topics
      for (int i = 0; i < _topics.length; i++) {
        final topic = _topics[i];
        _topics[i] = RitualTopic(
          id: topic.id,
          categoryId: topic.categoryId,
          slug: topic.slug,
          name: topic.name,
          tagline: topic.tagline,
          description: topic.description,
          icon: topic.icon,
          coverImageUrl: topic.coverImageUrl,
          difficulty: topic.difficulty,
          estimatedDays: topic.estimatedDays,
          isFeatured: topic.isFeatured,
          isPublished: topic.isPublished,
          subscriberCount: topic.subscriberCount,
          category: topic.category,
          items: allItems.where((item) => item.topicId == topic.id).toList(),
          affirmations: allAffirmations.where((a) => a.topicId == topic.id).toList(),
          milestones: allMilestones.where((m) => m.topicId == topic.id).toList(),
        );
      }

      await _saveToCache();

      debugPrint('Synced ${_categories.length} categories and ${_topics.length} topics');
      return true;
    } catch (e) {
      debugPrint('Failed to sync ritual topics: $e');
      return false;
    }
  }

  /// Get all categories
  List<RitualCategory> getCategories() {
    return List.from(_categories)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Get all topics
  List<RitualTopic> getAllTopics() {
    return List.from(_topics);
  }

  /// Get topics for a category
  List<RitualTopic> getTopicsForCategory(String categoryId) {
    return _topics.where((t) => t.categoryId == categoryId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get featured topics
  List<RitualTopic> getFeaturedTopics() {
    return _topics.where((t) => t.isFeatured).toList();
  }

  /// Get topic by ID
  RitualTopic? getTopicById(String id) {
    try {
      return _topics.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get topic by slug
  RitualTopic? getTopicBySlug(String slug) {
    try {
      return _topics.firstWhere((t) => t.slug == slug);
    } catch (e) {
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topicId) async {
    // Check if already subscribed
    final existing = _subscriptions.where((s) => s.topicId == topicId && s.isActive).toList();
    if (existing.isNotEmpty) return;

    final subscription = UserTopicSubscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topicId: topicId,
      startedAt: DateTime.now(),
      currentDay: 1,
      isActive: true,
      lastActivityAt: DateTime.now(),
    );

    _subscriptions.add(subscription);
    await _saveToCache();
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topicId) async {
    final index = _subscriptions.indexWhere((s) => s.topicId == topicId && s.isActive);
    if (index >= 0) {
      _subscriptions[index].isActive = false;
      await _saveToCache();
    }
  }

  /// Check if subscribed to a topic
  bool isSubscribedToTopic(String topicId) {
    return _subscriptions.any((s) => s.topicId == topicId && s.isActive);
  }

  /// Get user's subscribed topics
  List<RitualTopic> getSubscribedTopics() {
    final subscribedIds = _subscriptions
        .where((s) => s.isActive)
        .map((s) => s.topicId)
        .toSet();

    return _topics.where((t) => subscribedIds.contains(t.id)).toList();
  }

  /// Get subscription for a topic
  UserTopicSubscription? getSubscription(String topicId) {
    try {
      return _subscriptions.firstWhere((s) => s.topicId == topicId && s.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Get all subscriptions
  List<UserTopicSubscription> getAllSubscriptions() {
    return _subscriptions.where((s) => s.isActive).toList();
  }

  /// Get daily rituals for subscribed topics (filtered by time of day)
  List<RitualTopicItem> getDailyRituals({String? timeOfDay}) {
    final subscribedTopics = getSubscribedTopics();
    final items = <RitualTopicItem>[];

    for (final topic in subscribedTopics) {
      for (final item in topic.items) {
        // Apply completion status from local storage
        final completedAt = _completions[item.id];
        item.lastCompletedDate = completedAt;
        item.isCompleted = item.isCompletedToday;

        // Filter by time of day if specified
        if (timeOfDay != null && timeOfDay != 'all') {
          if (item.timeOfDay != timeOfDay && item.timeOfDay != 'anytime') {
            continue;
          }
        }

        // Only add daily or as_needed items (not weekly unless it's their day)
        if (item.frequency == 'daily' || 
            item.frequency == 'as_needed' ||
            (item.frequency == 'weekdays' && DateTime.now().weekday <= 5) ||
            (item.frequency == 'weekends' && DateTime.now().weekday > 5)) {
          items.add(item);
        }
      }
    }

    // Sort: incomplete first, then by time of day priority
    items.sort((a, b) {
      if (a.isCompletedToday != b.isCompletedToday) {
        return a.isCompletedToday ? 1 : -1;
      }
      return _timeOfDayPriority(a.timeOfDay).compareTo(_timeOfDayPriority(b.timeOfDay));
    });

    return items;
  }

  int _timeOfDayPriority(String timeOfDay) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      // Morning: morning first, then anytime, then afternoon, then evening
      switch (timeOfDay) {
        case 'morning': return 0;
        case 'anytime': return 1;
        case 'afternoon': return 2;
        case 'evening': return 3;
        default: return 4;
      }
    } else if (hour < 17) {
      // Afternoon
      switch (timeOfDay) {
        case 'afternoon': return 0;
        case 'anytime': return 1;
        case 'evening': return 2;
        case 'morning': return 3;
        default: return 4;
      }
    } else {
      // Evening
      switch (timeOfDay) {
        case 'evening': return 0;
        case 'anytime': return 1;
        case 'morning': return 2;
        case 'afternoon': return 3;
        default: return 4;
      }
    }
  }

  /// Mark a ritual item as completed
  Future<void> completeRitualItem(String itemId) async {
    _completions[itemId] = DateTime.now();
    await _saveToCache();
  }

  /// Mark a ritual item as incomplete
  Future<void> uncompleteRitualItem(String itemId) async {
    _completions.remove(itemId);
    await _saveToCache();
  }

  /// Toggle ritual item completion
  Future<void> toggleRitualItem(String itemId) async {
    final completedAt = _completions[itemId];
    if (completedAt != null) {
      final today = DateTime.now();
      final isToday = completedAt.year == today.year &&
                      completedAt.month == today.month &&
                      completedAt.day == today.day;
      if (isToday) {
        await uncompleteRitualItem(itemId);
        return;
      }
    }
    await completeRitualItem(itemId);
  }

  /// Get completion progress for today
  Map<String, int> getTodayProgress() {
    final dailyRituals = getDailyRituals();
    final completed = dailyRituals.where((r) => r.isCompletedToday).length;
    return {
      'completed': completed,
      'total': dailyRituals.length,
    };
  }

  /// Get a random affirmation from subscribed topics
  String? getRandomAffirmation() {
    final subscribedTopics = getSubscribedTopics();
    if (subscribedTopics.isEmpty) return null;

    final allAffirmations = <RitualAffirmation>[];
    for (final topic in subscribedTopics) {
      allAffirmations.addAll(topic.affirmations);
    }

    if (allAffirmations.isEmpty) return null;

    final random = DateTime.now().millisecondsSinceEpoch % allAffirmations.length;
    return allAffirmations[random].text;
  }

  /// Get current time of day
  String getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    return 'evening';
  }

  /// Search topics
  List<RitualTopic> searchTopics(String query) {
    final lowerQuery = query.toLowerCase();
    return _topics.where((t) {
      return t.name.toLowerCase().contains(lowerQuery) ||
             (t.tagline?.toLowerCase().contains(lowerQuery) ?? false) ||
             (t.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Check if we have any data
  bool hasData() {
    return _categories.isNotEmpty && _topics.isNotEmpty;
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final stored = _box?.get(_lastSyncKey) as String?;
    if (stored == null) return null;
    return DateTime.tryParse(stored);
  }
}
