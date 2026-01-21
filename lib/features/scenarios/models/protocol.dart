/// Protocol data models for step-by-step communication guides

enum ProtocolCategory {
  communication,
  conflict,
  selfRegulation,
  trust,
  recovery;

  String get displayName {
    switch (this) {
      case ProtocolCategory.communication:
        return 'Communication';
      case ProtocolCategory.conflict:
        return 'Conflict Management';
      case ProtocolCategory.selfRegulation:
        return 'Self-Regulation';
      case ProtocolCategory.trust:
        return 'Trust Building';
      case ProtocolCategory.recovery:
        return 'Recovery & Repair';
    }
  }

  String toJson() => name;

  static ProtocolCategory fromJson(String json) {
    return ProtocolCategory.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ProtocolCategory.communication,
    );
  }
}

/// Individual step in a protocol
class ProtocolStep {
  final int step;
  final String title;
  final String description;

  ProtocolStep({
    required this.step,
    required this.title,
    required this.description,
  });

  factory ProtocolStep.fromJson(Map<String, dynamic> json) {
    return ProtocolStep(
      step: json['step'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'title': title,
      'description': description,
    };
  }
}

/// Communication Protocol - step-by-step guide
class Protocol {
  final String id;
  final String title;
  final ProtocolCategory category;
  final String? description;
  final List<ProtocolStep> steps;
  final String? whenToUse;
  final String? whenNotToUse;
  final List<String> commonFailures;
  final List<String> relatedScenarioIds;
  final String? contentPackId;
  final bool published;

  Protocol({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.steps,
    this.whenToUse,
    this.whenNotToUse,
    this.commonFailures = const [],
    this.relatedScenarioIds = const [],
    this.contentPackId,
    this.published = true,
  });

  factory Protocol.fromJson(Map<String, dynamic> json) {
    // Parse steps from JSONB
    final stepsJson = json['steps'] as List<dynamic>?;
    final steps = stepsJson
            ?.map((e) => ProtocolStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return Protocol(
      id: json['id'].toString(),
      title: json['title'].toString(),
      category: ProtocolCategory.fromJson(json['category'].toString()),
      description: json['description']?.toString(),
      steps: steps,
      whenToUse: json['when_to_use']?.toString(),
      whenNotToUse: json['when_not_to_use']?.toString(),
      commonFailures: (json['common_failures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      relatedScenarioIds: (json['related_scenario_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contentPackId: json['content_pack_id']?.toString(),
      published: json['published'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.toJson(),
      'description': description,
      'steps': steps.map((e) => e.toJson()).toList(),
      'when_to_use': whenToUse,
      'when_not_to_use': whenNotToUse,
      'common_failures': commonFailures,
      'related_scenario_ids': relatedScenarioIds,
      'content_pack_id': contentPackId,
      'published': published,
    };
  }

  /// Get total step count
  int get stepCount => steps.length;

  /// Get steps sorted by step number
  List<ProtocolStep> get sortedSteps {
    final sorted = List<ProtocolStep>.from(steps);
    sorted.sort((a, b) => a.step.compareTo(b.step));
    return sorted;
  }
}

