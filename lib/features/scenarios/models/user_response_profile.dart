import 'package:hive/hive.dart';

part 'user_response_profile.g.dart';

/// User's response profile based on their scenario choices
/// Stored locally only - never synced to server
/// Tracks aggregate patterns, not specific decisions
@HiveType(typeId: 10)
class UserResponseProfile extends HiveObject {
  @HiveField(0)
  Map<String, int> communicationStyle;

  @HiveField(1)
  Map<String, int> riskTolerance;

  @HiveField(2)
  Map<String, int> conflictApproach;

  @HiveField(3)
  int totalDecisions;

  @HiveField(4)
  String profileVersion;

  @HiveField(5)
  DateTime lastUpdated;

  @HiveField(6)
  List<String> completedScenarioIds;

  @HiveField(7)
  Map<String, int> contextCounts; // hierarchy, peer, etc.

  @HiveField(8)
  Map<String, int> tagCounts; // All choice tags aggregated

  UserResponseProfile({
    Map<String, int>? communicationStyle,
    Map<String, int>? riskTolerance,
    Map<String, int>? conflictApproach,
    this.totalDecisions = 0,
    this.profileVersion = '1.0',
    DateTime? lastUpdated,
    List<String>? completedScenarioIds,
    Map<String, int>? contextCounts,
    Map<String, int>? tagCounts,
  })  : communicationStyle = communicationStyle ?? {},
        riskTolerance = riskTolerance ?? {},
        conflictApproach = conflictApproach ?? {},
        lastUpdated = lastUpdated ?? DateTime.now(),
        completedScenarioIds = completedScenarioIds ?? [],
        contextCounts = contextCounts ?? {},
        tagCounts = tagCounts ?? {};

  /// Record a choice made by the user
  void recordChoice({
    required String scenarioId,
    required String context,
    required List<String> tags,
    required String riskLevel,
  }) {
    // Add scenario to completed list (avoid duplicates)
    if (!completedScenarioIds.contains(scenarioId)) {
      completedScenarioIds.add(scenarioId);
    }

    // Increment total decisions
    totalDecisions++;

    // Update context counts
    contextCounts[context] = (contextCounts[context] ?? 0) + 1;

    // Update tag counts
    for (final tag in tags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;

      // Also categorize into high-level style buckets
      if (_isDirectTag(tag)) {
        communicationStyle['direct'] = (communicationStyle['direct'] ?? 0) + 1;
      }
      if (_isIndirectTag(tag)) {
        communicationStyle['indirect'] =
            (communicationStyle['indirect'] ?? 0) + 1;
      }
      if (_isAdaptiveTag(tag)) {
        communicationStyle['adaptive'] =
            (communicationStyle['adaptive'] ?? 0) + 1;
      }
      if (_isAvoidantTag(tag)) {
        communicationStyle['avoidant'] =
            (communicationStyle['avoidant'] ?? 0) + 1;
      }
      if (_isAssertiveTag(tag)) {
        communicationStyle['assertive'] =
            (communicationStyle['assertive'] ?? 0) + 1;
      }
      if (_isCollaborativeTag(tag)) {
        communicationStyle['collaborative'] =
            (communicationStyle['collaborative'] ?? 0) + 1;
      }

      // Conflict approach patterns
      if (_isImmediateTag(tag)) {
        conflictApproach['immediate'] =
            (conflictApproach['immediate'] ?? 0) + 1;
      }
      if (_isDelayedTag(tag)) {
        conflictApproach['delayed'] = (conflictApproach['delayed'] ?? 0) + 1;
      }
      if (_isEscalatingTag(tag)) {
        conflictApproach['escalated'] =
            (conflictApproach['escalated'] ?? 0) + 1;
      }
      if (_isDeescalatingTag(tag)) {
        conflictApproach['deescalated'] =
            (conflictApproach['deescalated'] ?? 0) + 1;
      }
    }

    // Update risk tolerance
    riskTolerance[riskLevel] = (riskTolerance[riskLevel] ?? 0) + 1;

    lastUpdated = DateTime.now();
    save(); // Save to Hive
  }

  /// Reset the entire profile
  void reset() {
    communicationStyle.clear();
    riskTolerance.clear();
    conflictApproach.clear();
    contextCounts.clear();
    tagCounts.clear();
    completedScenarioIds.clear();
    totalDecisions = 0;
    lastUpdated = DateTime.now();
    save();
  }

  /// Get primary communication style
  String get primaryCommunicationStyle {
    if (communicationStyle.isEmpty) return 'building';
    return communicationStyle.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get primary conflict approach
  String get primaryConflictApproach {
    if (conflictApproach.isEmpty) return 'exploring';
    return conflictApproach.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get risk preference
  String get riskPreference {
    if (riskTolerance.isEmpty) return 'balanced';
    final sortedRisks = riskTolerance.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedRisks.first.key;
  }

  /// Get summary insights for user-facing display
  List<String> get insights {
    final insights = <String>[];

    if (totalDecisions == 0) {
      return [
        'Complete scenarios to build your response profile',
        'Your patterns will emerge over time',
      ];
    }

    // Communication style insights
    final commStyle = primaryCommunicationStyle;
    if (commStyle != 'building') {
      insights.add(_getCommunicationStyleInsight(commStyle));
    }

    // Conflict approach insights
    final conflictStyle = primaryConflictApproach;
    if (conflictStyle != 'exploring') {
      insights.add(_getConflictApproachInsight(conflictStyle));
    }

    // Risk tolerance insights
    final risk = riskPreference;
    if (risk != 'balanced') {
      insights.add(_getRiskToleranceInsight(risk));
    }

    return insights;
  }

  String _getCommunicationStyleInsight(String style) {
    switch (style) {
      case 'direct':
        return 'You tend to communicate directly and clearly';
      case 'indirect':
        return 'You often choose subtle or indirect approaches';
      case 'adaptive':
        return 'You adapt your communication style to the situation';
      case 'avoidant':
        return 'You sometimes prefer to avoid direct confrontation';
      case 'assertive':
        return 'You consistently maintain firm boundaries';
      case 'collaborative':
        return 'You prioritize collaborative problem-solving';
      default:
        return 'Your communication style is developing';
    }
  }

  String _getConflictApproachInsight(String approach) {
    switch (approach) {
      case 'immediate':
        return 'You tend to address issues as they arise';
      case 'delayed':
        return 'You often choose to address concerns later privately';
      case 'escalated':
        return 'You bring issues up the chain when needed';
      case 'deescalated':
        return 'You focus on calming situations down';
      default:
        return 'Your conflict approach is emerging';
    }
  }

  String _getRiskToleranceInsight(String risk) {
    switch (risk) {
      case 'low':
        return 'You generally prefer low-risk options';
      case 'medium':
        return 'You balance risk and reward thoughtfully';
      case 'high':
        return 'You\'re willing to take calculated risks';
      default:
        return 'Your risk tolerance is balanced';
    }
  }

  // Tag classification helpers
  bool _isDirectTag(String tag) =>
      tag.contains('direct') || tag.contains('clear') || tag.contains('frank');
  bool _isIndirectTag(String tag) =>
      tag.contains('indirect') ||
      tag.contains('subtle') ||
      tag.contains('hint');
  bool _isAdaptiveTag(String tag) =>
      tag.contains('adaptive') ||
      tag.contains('flexible') ||
      tag.contains('context');
  bool _isAvoidantTag(String tag) =>
      tag.contains('avoid') || tag.contains('withdraw') || tag.contains('skip');
  bool _isAssertiveTag(String tag) =>
      tag.contains('assertive') || tag.contains('firm') || tag.contains('stand');
  bool _isCollaborativeTag(String tag) =>
      tag.contains('collaborative') ||
      tag.contains('together') ||
      tag.contains('joint');
  bool _isImmediateTag(String tag) =>
      tag.contains('immediate') ||
      tag.contains('now') ||
      tag.contains('instant');
  bool _isDelayedTag(String tag) =>
      tag.contains('delayed') ||
      tag.contains('later') ||
      tag.contains('private');
  bool _isEscalatingTag(String tag) =>
      tag.contains('escalate') ||
      tag.contains('upchain') ||
      tag.contains('command');
  bool _isDeescalatingTag(String tag) =>
      tag.contains('deescalate') ||
      tag.contains('calm') ||
      tag.contains('defuse');
}

