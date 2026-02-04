/// Models for the ritual topics system from Supabase

/// Ritual category (high-level grouping)
class RitualCategory {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final int displayOrder;
  final bool isActive;

  RitualCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.displayOrder,
    this.isActive = true,
  });

  factory RitualCategory.fromJson(Map<String, dynamic> json) {
    return RitualCategory(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'] ?? 'spa_outlined',
      color: json['color'] ?? '#00D9C4',
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'description': description,
    'icon': icon,
    'color': color,
    'display_order': displayOrder,
    'is_active': isActive,
  };
}

/// Ritual topic (user-selectable focus area)
class RitualTopic {
  final String id;
  final String categoryId;
  final String slug;
  final String name;
  final String? tagline;
  final String? description;
  final String icon;
  final String? coverImageUrl;
  final String difficulty;
  final int estimatedDays;
  final bool isFeatured;
  final bool isPublished;
  final bool isSubmarineCompatible;
  final int subscriberCount;
  final RitualCategory? category;
  final List<RitualTopicItem> items;
  final List<RitualAffirmation> affirmations;
  final List<RitualMilestone> milestones;

  RitualTopic({
    required this.id,
    required this.categoryId,
    required this.slug,
    required this.name,
    this.tagline,
    this.description,
    required this.icon,
    this.coverImageUrl,
    this.difficulty = 'beginner',
    this.estimatedDays = 21,
    this.isFeatured = false,
    this.isPublished = false,
    this.isSubmarineCompatible = false,
    this.subscriberCount = 0,
    this.category,
    this.items = const [],
    this.affirmations = const [],
    this.milestones = const [],
  });

  factory RitualTopic.fromJson(Map<String, dynamic> json) {
    return RitualTopic(
      id: json['id'] ?? '',
      categoryId: json['category_id'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      tagline: json['tagline'],
      description: json['description'],
      icon: json['icon'] ?? 'check_circle_outline',
      coverImageUrl: json['cover_image_url'],
      difficulty: json['difficulty'] ?? 'beginner',
      estimatedDays: json['estimated_days'] ?? 21,
      isFeatured: json['is_featured'] ?? false,
      isPublished: json['is_published'] ?? false,
      isSubmarineCompatible: json['is_submarine_compatible'] ?? false,
      subscriberCount: json['subscriber_count'] ?? 0,
      category: json['category'] != null 
          ? RitualCategory.fromJson(json['category']) 
          : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => RitualTopicItem.fromJson(i)).toList()
          : [],
      affirmations: json['affirmations'] != null
          ? (json['affirmations'] as List).map((a) => RitualAffirmation.fromJson(a)).toList()
          : [],
      milestones: json['milestones'] != null
          ? (json['milestones'] as List).map((m) => RitualMilestone.fromJson(m)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'slug': slug,
    'name': name,
    'tagline': tagline,
    'description': description,
    'icon': icon,
    'cover_image_url': coverImageUrl,
    'difficulty': difficulty,
    'estimated_days': estimatedDays,
    'is_featured': isFeatured,
    'is_published': isPublished,
    'is_submarine_compatible': isSubmarineCompatible,
    'subscriber_count': subscriberCount,
  };
}

/// Individual ritual item within a topic
class RitualTopicItem {
  final String id;
  final String topicId;
  final String title;
  final String? description;
  final String? whyItHelps;
  final String? howTo;
  final int durationMinutes;
  final String timeOfDay; // morning, afternoon, evening, anytime
  final String frequency; // daily, weekdays, weekends, weekly, as_needed
  final int displayOrder;
  final bool isCore;
  final bool isActive;
  
  // Local state (not from database)
  bool isCompleted;
  DateTime? lastCompletedDate;

  RitualTopicItem({
    required this.id,
    required this.topicId,
    required this.title,
    this.description,
    this.whyItHelps,
    this.howTo,
    this.durationMinutes = 5,
    this.timeOfDay = 'anytime',
    this.frequency = 'daily',
    this.displayOrder = 0,
    this.isCore = true,
    this.isActive = true,
    this.isCompleted = false,
    this.lastCompletedDate,
  });

  factory RitualTopicItem.fromJson(Map<String, dynamic> json) {
    return RitualTopicItem(
      id: json['id'] ?? '',
      topicId: json['topic_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      whyItHelps: json['why_it_helps'],
      howTo: json['how_to'],
      durationMinutes: json['duration_minutes'] ?? 5,
      timeOfDay: json['time_of_day'] ?? 'anytime',
      frequency: json['frequency'] ?? 'daily',
      displayOrder: json['display_order'] ?? 0,
      isCore: json['is_core'] ?? true,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic_id': topicId,
    'title': title,
    'description': description,
    'why_it_helps': whyItHelps,
    'how_to': howTo,
    'duration_minutes': durationMinutes,
    'time_of_day': timeOfDay,
    'frequency': frequency,
    'display_order': displayOrder,
    'is_core': isCore,
    'is_active': isActive,
  };

  /// Check if this should be shown based on time of day
  bool shouldShowNow() {
    if (timeOfDay == 'anytime') return true;
    
    final hour = DateTime.now().hour;
    switch (timeOfDay) {
      case 'morning':
        return hour >= 5 && hour < 12;
      case 'afternoon':
        return hour >= 12 && hour < 17;
      case 'evening':
        return hour >= 17 || hour < 5;
      default:
        return true;
    }
  }

  /// Check if completed today
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final today = DateTime.now();
    return lastCompletedDate!.year == today.year &&
           lastCompletedDate!.month == today.month &&
           lastCompletedDate!.day == today.day;
  }

  /// Get time of day display string
  String get timeOfDayDisplay {
    switch (timeOfDay) {
      case 'morning':
        return '🌅 Morning';
      case 'afternoon':
        return '☀️ Afternoon';
      case 'evening':
        return '🌙 Evening';
      default:
        return '⏰ Anytime';
    }
  }

  /// Get frequency display string
  String get frequencyDisplay {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekdays':
        return 'Weekdays';
      case 'weekends':
        return 'Weekends';
      case 'weekly':
        return 'Weekly';
      case 'as_needed':
        return 'As needed';
      default:
        return frequency;
    }
  }
}

/// Affirmation for a topic
class RitualAffirmation {
  final String id;
  final String topicId;
  final String text;
  final String? attribution;
  final int displayOrder;
  final bool isActive;

  RitualAffirmation({
    required this.id,
    required this.topicId,
    required this.text,
    this.attribution,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory RitualAffirmation.fromJson(Map<String, dynamic> json) {
    return RitualAffirmation(
      id: json['id'] ?? '',
      topicId: json['topic_id'] ?? '',
      text: json['text'] ?? '',
      attribution: json['attribution'],
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic_id': topicId,
    'text': text,
    'attribution': attribution,
    'display_order': displayOrder,
    'is_active': isActive,
  };
}

/// Milestone achievement for a topic
class RitualMilestone {
  final String id;
  final String topicId;
  final String title;
  final String? description;
  final int dayThreshold;
  final String icon;
  final String? celebrationMessage;

  RitualMilestone({
    required this.id,
    required this.topicId,
    required this.title,
    this.description,
    required this.dayThreshold,
    this.icon = 'emoji_events',
    this.celebrationMessage,
  });

  factory RitualMilestone.fromJson(Map<String, dynamic> json) {
    return RitualMilestone(
      id: json['id'] ?? '',
      topicId: json['topic_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dayThreshold: json['day_threshold'] ?? 7,
      icon: json['icon'] ?? 'emoji_events',
      celebrationMessage: json['celebration_message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic_id': topicId,
    'title': title,
    'description': description,
    'day_threshold': dayThreshold,
    'icon': icon,
    'celebration_message': celebrationMessage,
  };
}

/// User's subscription to a topic
class UserTopicSubscription {
  final String id;
  final String topicId;
  final DateTime startedAt;
  int currentDay;
  bool isActive;
  DateTime lastActivityAt;
  DateTime? completedAt;

  UserTopicSubscription({
    required this.id,
    required this.topicId,
    required this.startedAt,
    this.currentDay = 1,
    this.isActive = true,
    required this.lastActivityAt,
    this.completedAt,
  });

  factory UserTopicSubscription.fromJson(Map<String, dynamic> json) {
    return UserTopicSubscription(
      id: json['id'] ?? '',
      topicId: json['topic_id'] ?? '',
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      currentDay: json['current_day'] ?? 1,
      isActive: json['is_active'] ?? true,
      lastActivityAt: DateTime.parse(json['last_activity_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic_id': topicId,
    'started_at': startedAt.toIso8601String(),
    'current_day': currentDay,
    'is_active': isActive,
    'last_activity_at': lastActivityAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };
}
