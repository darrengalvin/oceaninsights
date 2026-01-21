import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/theme/theme_options.dart';
import 'ai_insight_screen.dart';

class TellMeAboutYouScreen extends StatefulWidget {
  const TellMeAboutYouScreen({super.key});

  @override
  State<TellMeAboutYouScreen> createState() => _TellMeAboutYouScreenState();
}

class _TellMeAboutYouScreenState extends State<TellMeAboutYouScreen> {
  final Box _userBox = Hive.box('user_data');
  
  // Selected answers for each category
  Set<String> _selectedPersonality = {};
  Set<String> _selectedChallenges = {};
  Set<String> _selectedInterests = {};
  Set<String> _selectedGoals = {};
  
  bool _isGeneratingInsight = false;
  
  @override
  void initState() {
    super.initState();
    _loadSavedAnswers();
  }
  
  void _loadSavedAnswers() {
    final saved = _userBox.get('aboutYouAnswers');
    if (saved != null) {
      setState(() {
        _selectedPersonality = Set<String>.from(saved['personality'] ?? []);
        _selectedChallenges = Set<String>.from(saved['challenges'] ?? []);
        _selectedInterests = Set<String>.from(saved['interests'] ?? []);
        _selectedGoals = Set<String>.from(saved['goals'] ?? []);
      });
    }
  }
  
  Future<void> _saveAnswers() async {
    // Save to local storage
    await _userBox.put('aboutYouAnswers', {
      'personality': _selectedPersonality.toList(),
      'challenges': _selectedChallenges.toList(),
      'interests': _selectedInterests.toList(),
      'goals': _selectedGoals.toList(),
    });
    
    // Get user type for audience context
    final userType = _userBox.get('userType', defaultValue: 'Serving') as String;
    
    // Build personalised profile - works online (AI) or offline (smart fallback)
    setState(() => _isGeneratingInsight = true);
    
    PersonalisedInsight insight;
    
    if (AIService.hasBuildTimeKey) {
      // Try to get AI-generated insight, fallback gracefully if offline
      try {
        final aiService = AIService.withBuildTimeKey();
        insight = await aiService.generateInsight(
          audience: userType,
          describeChips: _selectedPersonality.toList(),
          struggleChips: _selectedChallenges.toList(),
          interestChips: _selectedInterests.toList(),
          goalChips: _selectedGoals.toList(),
        );
      } catch (_) {
        // Offline or API error - use smart fallback (no error shown to user)
        insight = _buildOfflineInsight(
          userType,
          _selectedChallenges.toList(),
          _selectedGoals.toList(),
        );
      }
    } else {
      // No API key configured - use offline fallback
      insight = _buildOfflineInsight(
        userType,
        _selectedChallenges.toList(),
        _selectedGoals.toList(),
      );
    }
    
    // Save the insight for later reference
    await _userBox.put('lastInsight', insight.toMap());
    
    if (mounted) {
      setState(() => _isGeneratingInsight = false);
      
      // Navigate to insight screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AIInsightScreen(insight: insight),
        ),
      );
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
  
  /// Build a thoughtful offline insight based on user selections
  PersonalisedInsight _buildOfflineInsight(
    String audience,
    List<String> struggles,
    List<String> goals,
  ) {
    final mainStruggle = struggles.isNotEmpty ? struggles.first : 'daily challenges';
    final mainGoal = goals.isNotEmpty ? goals.first.toLowerCase() : 'wellbeing';
    
    // Audience-specific summaries
    String summary;
    switch (audience) {
      case 'Deployed':
        summary = 'Being deployed often means dealing with limited personal time and connection challenges. '
            'It sounds like ${mainStruggle.toLowerCase()} might be something to work on, '
            'while $mainGoal matters to you.';
        break;
      case 'Serving':
        summary = 'Balancing service life with personal wellbeing takes real effort. '
            'It sounds like ${mainStruggle.toLowerCase()} is on your mind, '
            'and $mainGoal is something you\'re working towards.';
        break;
      case 'Veteran':
        summary = 'Transitioning to civilian life brings its own set of challenges. '
            'It sounds like ${mainStruggle.toLowerCase()} might be something to work on, '
            'while $mainGoal is important to you.';
        break;
      case 'Alongside':
        summary = 'Supporting someone who serves takes strength and patience. '
            'It sounds like ${mainStruggle.toLowerCase()} is something you\'re navigating, '
            'while $mainGoal matters to you.';
        break;
      case 'Young Person':
        summary = 'It\'s not always easy to figure things out. '
            'Sounds like ${mainStruggle.toLowerCase()} is something you deal with sometimes, '
            'and $mainGoal is on your mind.';
        break;
      default:
        summary = 'Thanks for sharing a bit about yourself. '
            'It sounds like ${mainStruggle.toLowerCase()} might be something to work on, '
            'while $mainGoal is important to you.';
    }
    
    return PersonalisedInsight(
      summary: summary,
      mightBePartOfIt: [
        'Everyone\'s experience is different - there\'s no single right approach.',
        'Small, consistent steps often make the biggest difference over time.',
        'It can help to start with what feels most manageable right now.',
      ],
      quickQuestion: 'What would feel like a good first step for you?',
      nextSteps: [
        'Take a look around the app - there\'s no pressure to do everything at once.',
        'Try a short breathing exercise when you have a quiet moment.',
        'Come back whenever you need a moment for yourself.',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell Me About You'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us personalise your experience',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colours.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply to you. This information stays on your device.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colours.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildQuestionSection(
              context,
              'I would describe myself as...',
              [
                'Introvert',
                'Extrovert',
                'Analytical',
                'Creative',
                'Practical',
                'Emotional',
                'Logical',
                'Adventurous',
                'Cautious',
                'Optimistic',
                'Realistic',
              ],
              _selectedPersonality,
              (value) => setState(() {
                if (_selectedPersonality.contains(value)) {
                  _selectedPersonality.remove(value);
                } else {
                  _selectedPersonality.add(value);
                }
              }),
            ),
            
            _buildQuestionSection(
              context,
              'I sometimes struggle with...',
              [
                'Stress',
                'Anxiety',
                'Low mood',
                'Sleep',
                'Motivation',
                'Relationships',
                'Loneliness',
                'Anger',
                'Confidence',
                'Focus',
                'Work-life balance',
                'Being away from family',
              ],
              _selectedChallenges,
              (value) => setState(() {
                if (_selectedChallenges.contains(value)) {
                  _selectedChallenges.remove(value);
                } else {
                  _selectedChallenges.add(value);
                }
              }),
            ),
            
            _buildQuestionSection(
              context,
              'I\'m interested in learning about...',
              [
                'Relationships',
                'Purpose',
                'Physical Health',
                'Emotional Health',
                'Finance',
                'Education',
                'Psychology',
                'Brain Functions',
                'Stress Management',
                'Communication',
                'Leadership',
              ],
              _selectedInterests,
              (value) => setState(() {
                if (_selectedInterests.contains(value)) {
                  _selectedInterests.remove(value);
                } else {
                  _selectedInterests.add(value);
                }
              }),
            ),
            
            _buildQuestionSection(
              context,
              'My current goals include...',
              [
                'Better mental health',
                'Improved relationships',
                'Career development',
                'Physical fitness',
                'Financial stability',
                'Learning new skills',
                'Work-life balance',
                'Finding purpose',
                'Building confidence',
                'Managing stress',
              ],
              _selectedGoals,
              (value) => setState(() {
                if (_selectedGoals.contains(value)) {
                  _selectedGoals.remove(value);
                } else {
                  _selectedGoals.add(value);
                }
              }),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGeneratingInsight ? null : _saveAnswers,
                child: _isGeneratingInsight
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colours.background,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Building your profile...'),
                        ],
                      )
                    : const Text('Save Profile'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuestionSection(
    BuildContext context,
    String question,
    List<String> options,
    Set<String> selectedOptions,
    ValueChanged<String> onOptionTap,
  ) {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return GestureDetector(
                onTap: () => onOptionTap(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colours.accent : colours.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? colours.accent : colours.border,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? colours.background : colours.textBright,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

