import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/theme/theme_options.dart';

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
    await _userBox.put('aboutYouAnswers', {
      'personality': _selectedPersonality.toList(),
      'challenges': _selectedChallenges.toList(),
      'interests': _selectedInterests.toList(),
      'goals': _selectedGoals.toList(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your profile has been saved')),
      );
      Navigator.pop(context);
    }
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
                onPressed: _saveAnswers,
                child: const Text('Save Profile'),
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

