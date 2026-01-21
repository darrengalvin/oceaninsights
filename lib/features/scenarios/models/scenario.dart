/// Scenario data models for decision training system
/// These represent situations with multiple response options

enum ScenarioContext {
  hierarchy,
  peer,
  highPressure,
  closeQuarters,
  leadership;

  String get displayName {
    switch (this) {
      case ScenarioContext.hierarchy:
        return 'Hierarchy & Authority';
      case ScenarioContext.peer:
        return 'Peer Dynamics';
      case ScenarioContext.highPressure:
        return 'High Pressure';
      case ScenarioContext.closeQuarters:
        return 'Close Quarters';
      case ScenarioContext.leadership:
        return 'Leadership';
    }
  }

  String toJson() => name;

  static ScenarioContext fromJson(String json) {
    return ScenarioContext.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ScenarioContext.peer,
    );
  }
}

enum RiskLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  String toJson() => name;

  static RiskLevel fromJson(String json) {
    return RiskLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => RiskLevel.medium,
    );
  }
}

enum PerspectiveViewpoint {
  command,
  peer,
  subordinate,
  external;

  String get displayName {
    switch (this) {
      case PerspectiveViewpoint.command:
        return 'From Command';
      case PerspectiveViewpoint.peer:
        return 'From Peer';
      case PerspectiveViewpoint.subordinate:
        return 'From Subordinate';
      case PerspectiveViewpoint.external:
        return 'From External Observer';
    }
  }

  String toJson() => name;

  static PerspectiveViewpoint fromJson(String json) {
    return PerspectiveViewpoint.values.firstWhere(
      (e) => e.name == json,
      orElse: () => PerspectiveViewpoint.peer,
    );
  }
}

/// Perspective shift - how a choice lands from different viewpoints
class PerspectiveShift {
  final String id;
  final String optionId;
  final PerspectiveViewpoint viewpoint;
  final String interpretation;

  PerspectiveShift({
    required this.id,
    required this.optionId,
    required this.viewpoint,
    required this.interpretation,
  });

  factory PerspectiveShift.fromJson(Map<String, dynamic> json) {
    return PerspectiveShift(
      id: json['id'].toString(),
      optionId: json['option_id'].toString(),
      viewpoint: PerspectiveViewpoint.fromJson(json['viewpoint'].toString()),
      interpretation: json['interpretation'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_id': optionId,
      'viewpoint': viewpoint.toJson(),
      'interpretation': interpretation,
    };
  }
}

/// Outcome of a scenario choice
class ScenarioOutcome {
  final String immediate; // What happens right away
  final String longTerm; // Potential long-term effects
  final RiskLevel riskLevel;

  ScenarioOutcome({
    required this.immediate,
    required this.longTerm,
    required this.riskLevel,
  });

  factory ScenarioOutcome.fromJson(Map<String, dynamic> json) {
    return ScenarioOutcome(
      immediate: json['immediate'] as String,
      longTerm: json['longTerm'] as String,
      riskLevel: RiskLevel.fromJson(json['riskLevel'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'immediate': immediate,
      'longTerm': longTerm,
      'riskLevel': riskLevel.toJson(),
    };
  }
}

/// Scenario option - a response choice
class ScenarioOption {
  final String id;
  final String scenarioId;
  final String text;
  final List<String> tags; // e.g. ['direct', 'assertive', 'delayed']
  final String immediateOutcome;
  final String longtermOutcome;
  final RiskLevel riskLevel;
  final int sortOrder;
  final List<PerspectiveShift> perspectiveShifts;

  ScenarioOption({
    required this.id,
    required this.scenarioId,
    required this.text,
    required this.tags,
    required this.immediateOutcome,
    required this.longtermOutcome,
    required this.riskLevel,
    this.sortOrder = 0,
    this.perspectiveShifts = const [],
  });

  ScenarioOutcome get outcome => ScenarioOutcome(
        immediate: immediateOutcome,
        longTerm: longtermOutcome,
        riskLevel: riskLevel,
      );

  factory ScenarioOption.fromJson(Map<String, dynamic> json) {
    return ScenarioOption(
      id: json['id'].toString(),
      scenarioId: json['scenario_id'].toString(),
      text: json['text'].toString(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      immediateOutcome: json['immediate_outcome'].toString(),
      longtermOutcome: json['longterm_outcome'].toString(),
      riskLevel: RiskLevel.fromJson(json['risk_level'].toString()),
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      perspectiveShifts: (json['perspective_shifts'] as List<dynamic>?)
              ?.map((e) => PerspectiveShift.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario_id': scenarioId,
      'text': text,
      'tags': tags,
      'immediate_outcome': immediateOutcome,
      'longterm_outcome': longtermOutcome,
      'risk_level': riskLevel.toJson(),
      'sort_order': sortOrder,
      'perspective_shifts':
          perspectiveShifts.map((e) => e.toJson()).toList(),
    };
  }
}

/// Scenario - a decision training situation
class Scenario {
  final String id;
  final String title;
  final String situation;
  final ScenarioContext context;
  final int difficulty; // 1-3
  final String? contentPackId;
  final List<String> tags;
  final bool published;
  final List<ScenarioOption> options;

  Scenario({
    required this.id,
    required this.title,
    required this.situation,
    required this.context,
    required this.difficulty,
    this.contentPackId,
    this.tags = const [],
    this.published = true,
    this.options = const [],
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'].toString(),
      title: json['title'].toString(),
      situation: json['situation'].toString(),
      context: ScenarioContext.fromJson(json['context'].toString()),
      difficulty: json['difficulty'] is int
          ? json['difficulty'] as int
          : int.tryParse(json['difficulty'].toString()) ?? 1,
      contentPackId: json['content_pack_id']?.toString(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      published: json['published'] as bool? ?? true,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => ScenarioOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'situation': situation,
      'context': context.toJson(),
      'difficulty': difficulty,
      'content_pack_id': contentPackId,
      'tags': tags,
      'published': published,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  /// Get options sorted by sort_order
  List<ScenarioOption> get sortedOptions {
    final sorted = List<ScenarioOption>.from(options);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// Get difficulty display string
  String get difficultyDisplay {
    switch (difficulty) {
      case 1:
        return 'Foundational';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Intermediate';
    }
  }
}

/// Content Pack - organizes scenarios and protocols
class ContentPack {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final Map<String, dynamic>? unlockCriteria;
  final int sortOrder;
  final bool published;

  ContentPack({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.unlockCriteria,
    this.sortOrder = 0,
    this.published = true,
  });

  factory ContentPack.fromJson(Map<String, dynamic> json) {
    return ContentPack(
      id: json['id'].toString(),
      name: json['name'].toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      unlockCriteria: json['unlock_criteria'] as Map<String, dynamic>?,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      published: json['published'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'unlock_criteria': unlockCriteria,
      'sort_order': sortOrder,
      'published': published,
    };
  }

  /// Check if this pack is unlocked based on user progress
  bool isUnlocked(int totalDecisions, Map<String, int> tagCounts) {
    if (unlockCriteria == null) return true;

    final requiredDecisions = unlockCriteria!['totalDecisions'] as int?;
    if (requiredDecisions != null && totalDecisions < requiredDecisions) {
      return false;
    }

    final requiredTags = unlockCriteria!['tags'] as List<dynamic>?;
    if (requiredTags != null) {
      for (final tag in requiredTags) {
        final count = tagCounts[tag as String] ?? 0;
        final minCount = unlockCriteria!['minCount'] as int? ?? 5;
        if (count < minCount) return false;
      }
    }

    return true;
  }
}

