import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Goal category with branching options
class GoalCategory {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final List<String> goalTypes;
  final List<String> challenges;
  final List<String> values;
  
  const GoalCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.goalTypes,
    required this.challenges,
    required this.values,
  });
}

/// Saved goal with user selections
class SavedGoal {
  final String id;
  final String categoryId;
  final String goalType;
  final String timeframe;
  final List<String> challenges;
  final List<String> values;
  final DateTime createdAt;
  
  SavedGoal({
    required this.id,
    required this.categoryId,
    required this.goalType,
    required this.timeframe,
    required this.challenges,
    required this.values,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'goalType': goalType,
      'timeframe': timeframe,
      'challenges': challenges,
      'values': values,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory SavedGoal.fromMap(Map<String, dynamic> map) {
    return SavedGoal(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      goalType: map['goalType'] as String,
      timeframe: map['timeframe'] as String,
      challenges: List<String>.from(map['challenges'] as List),
      values: List<String>.from(map['values'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

/// Pre-defined goal data
class GoalsData {
  GoalsData._();
  
  static const List<String> timeframes = [
    'Within 1 month',
    'Within 3 months',
    'Within 6 months',
    'Within 1 year',
    'After this deployment',
    'When I feel ready',
    'Ongoing / No deadline',
  ];
  
  static final List<GoalCategory> categories = [
    // RELATIONSHIPS
    GoalCategory(
      id: 'relationships',
      name: 'Relationships',
      description: 'Love, family, and connections',
      emoji: '💕',
      color: AppTheme.coralPink,
      goalTypes: [
        'Get into a new relationship',
        'Strengthen my current relationship',
        'Move on from a past relationship',
        'Build better friendships',
        'Reconnect with family',
        'Improve communication with partner',
        'Set healthier boundaries',
        'Find a supportive community',
      ],
      challenges: [
        'Confidence',
        'Limited opportunity to meet people',
        'Past experiences holding me back',
        'Trust issues',
        'Time / availability',
        'Long-distance difficulties',
        'Communication struggles',
        'Fear of rejection',
        'Not sure what I want',
        'Emotional baggage',
      ],
      values: [
        'Honesty',
        'Loyalty',
        'Sense of humour',
        'Intelligence',
        'Kindness',
        'Independence',
        'Shared interests',
        'Ambition',
        'Family-oriented',
        'Emotional maturity',
        'Physical attraction',
        'Financial stability',
        'Good communication',
        'Supportive nature',
      ],
    ),
    
    // MENTAL WELLBEING
    GoalCategory(
      id: 'mental_wellbeing',
      name: 'Mental Wellbeing',
      description: 'Peace, clarity, and balance',
      emoji: '🧠',
      color: AppTheme.aquaGlow,
      goalTypes: [
        'Reduce stress and anxiety',
        'Build better daily habits',
        'Improve sleep quality',
        'Manage difficult emotions',
        'Build self-confidence',
        'Develop a positive mindset',
        'Understand trauma responses',
        'Find more joy in daily life',
        'Reduce negative self-talk',
      ],
      challenges: [
        'Lack of time',
        'Overwhelming workload',
        'Difficulty switching off',
        'Racing thoughts',
        'Lack of support',
        'Isolation',
        'Past experiences',
        'Physical symptoms',
        'Not knowing where to start',
        'Feeling stuck',
      ],
      values: [
        'Inner peace',
        'Emotional stability',
        'Self-acceptance',
        'Resilience',
        'Mental clarity',
        'Balance',
        'Mindfulness',
        'Self-compassion',
        'Authenticity',
        'Personal growth',
      ],
    ),
    
    // HEALTH & FITNESS
    GoalCategory(
      id: 'health_fitness',
      name: 'Health & Fitness',
      description: 'Physical strength and wellness',
      emoji: '💪',
      color: AppTheme.seaGreen,
      goalTypes: [
        'Lose weight',
        'Build muscle / strength',
        'Improve cardiovascular fitness',
        'Maintain fitness while deployed',
        'Recover from injury',
        'Improve nutrition',
        'Quit smoking',
        'Reduce alcohol',
        'Get better sleep',
        'Increase energy levels',
      ],
      challenges: [
        'Lack of motivation',
        'Limited equipment / facilities',
        'Time constraints',
        'Injuries or pain',
        'Inconsistent routine',
        'Unhealthy food options',
        'Stress eating',
        'Fatigue',
        'Lack of knowledge',
        'All-or-nothing thinking',
      ],
      values: [
        'Physical strength',
        'Endurance',
        'Discipline',
        'Energy',
        'Longevity',
        'Appearance',
        'Mental clarity',
        'Self-respect',
        'Performance',
        'Health for family',
      ],
    ),
    
    // FINANCIAL
    GoalCategory(
      id: 'financial',
      name: 'Financial',
      description: 'Money, savings, and security',
      emoji: '💰',
      color: AppTheme.warmAmber,
      goalTypes: [
        'Build an emergency fund',
        'Get out of debt',
        'Save for a house',
        'Save for a major purchase',
        'Build long-term investments',
        'Create a budget and stick to it',
        'Support my family financially',
        'Plan for retirement',
        'Increase my income',
      ],
      challenges: [
        'Living payday to payday',
        'Existing debts',
        'Impulsive spending',
        'Lack of financial knowledge',
        'Supporting others',
        'Unexpected expenses',
        'Low income',
        'No clear plan',
        'Difficulty saying no',
        'Keeping up appearances',
      ],
      values: [
        'Financial security',
        'Freedom',
        'Family stability',
        'Independence',
        'Peace of mind',
        'Future planning',
        'Home ownership',
        'Experiences over things',
        'Generosity',
        'Early retirement',
      ],
    ),
    
    // CAREER & SKILLS
    GoalCategory(
      id: 'career',
      name: 'Career & Skills',
      description: 'Growth, learning, and advancement',
      emoji: '📈',
      color: AppTheme.deepTeal,
      goalTypes: [
        'Get promoted',
        'Learn a new skill',
        'Prepare for civilian career',
        'Complete a qualification',
        'Improve leadership abilities',
        'Build professional network',
        'Find more meaning in work',
        'Achieve better work-life balance',
        'Start a side project',
      ],
      challenges: [
        'Limited opportunities',
        'Lack of time to study',
        'Unclear career path',
        'Imposter syndrome',
        'Fear of change',
        'Competitive environment',
        'Lack of mentors',
        'Work demands',
        'Financial constraints',
        'Uncertainty about the future',
      ],
      values: [
        'Achievement',
        'Learning',
        'Recognition',
        'Leadership',
        'Security',
        'Flexibility',
        'Purpose',
        'Creativity',
        'Helping others',
        'Financial reward',
        'Work-life balance',
        'Independence',
      ],
    ),
    
    // LIFE & LIFESTYLE
    GoalCategory(
      id: 'lifestyle',
      name: 'Life & Lifestyle',
      description: 'Home, hobbies, and daily life',
      emoji: '🏠',
      color: AppTheme.softCyan,
      goalTypes: [
        'Buy a home',
        'Move to a new area',
        'Start a family',
        'Find a new hobby',
        'Travel more',
        'Simplify my life',
        'Improve living situation',
        'Create better daily routines',
        'Spend more quality time with family',
      ],
      challenges: [
        'Financial constraints',
        'Time limitations',
        'Deployment schedule',
        'Partner\'s needs',
        'Uncertainty',
        'Location restrictions',
        'Decision fatigue',
        'Overwhelm',
        'Lack of stability',
        'Distance from family',
      ],
      values: [
        'Stability',
        'Adventure',
        'Family time',
        'Personal space',
        'Community',
        'Nature',
        'Creativity',
        'Simplicity',
        'Security',
        'Experiences',
        'Quality of life',
      ],
    ),
  ];
}

