import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/content_sync_service.dart';

/// Interactive Daily Brief - Set your focus for the day (tap-only, no typing)
/// Uses synced content from admin panel - works offline with cached data
class DailyBriefScreen extends StatefulWidget {
  final String userType; // 'military', 'veteran', 'youth'
  
  const DailyBriefScreen({
    super.key,
    this.userType = 'military',
  });

  @override
  State<DailyBriefScreen> createState() => _DailyBriefScreenState();
}

class _DailyBriefScreenState extends State<DailyBriefScreen> {
  int _currentStep = 0;
  String? _selectedMindset;
  String? _selectedObjective;
  String? _selectedChallenge;
  
  // Energy levels from admin (with fallback icons)
  List<Map<String, dynamic>> get _mindsetOptions {
    final levels = ContentSyncService().getEnergyLevels();
    return levels.map((l) => {
      'label': l.label,
      'icon': _getIconForEnergy(l.emoji),
      'energy': l.label.toLowerCase(),
      'description': l.description,
    }).toList();
  }
  
  IconData _getIconForEnergy(String emoji) {
    switch (emoji) {
      case '⚡': return Icons.flash_on_rounded;
      case '✓': return Icons.check_circle_rounded;
      case '~': return Icons.remove_rounded;
      case '↓': return Icons.arrow_downward_rounded;
      case '○': return Icons.circle_outlined;
      default: return Icons.circle_rounded;
    }
  }
  
  // Objectives from admin
  List<String> get _objectiveOptions {
    final objectives = ContentSyncService().getDailyBriefObjectives();
    return objectives.map((o) => o.text).toList();
  }
  
  // Challenges from admin
  List<String> get _challengeOptions {
    final challenges = ContentSyncService().getDailyBriefChallenges();
    return challenges.map((c) => c.text).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Brief',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/3',
                style: TextStyle(
                  color: colours.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: colours.border,
                valueColor: AlwaysStoppedAnimation<Color>(colours.accent),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildMindsetStep();
      case 1:
        return _buildObjectiveStep();
      case 2:
        return _buildChallengeStep();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildMindsetStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('mindset'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "How's your energy today?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be honest - this helps calibrate your day.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          
          // Mindset options
          ...List.generate(_mindsetOptions.length, (index) {
            final option = _mindsetOptions[index];
            final isSelected = _selectedMindset == option['label'];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  UISoundService().playClick();
                  setState(() {
                    _selectedMindset = option['label'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? colours.accent.withOpacity(0.15) 
                        : colours.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? colours.accent : colours.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        option['icon'] as IconData,
                        color: isSelected ? colours.accent : colours.textMuted,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option['label'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: colours.textBright,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: colours.accent,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          
          const Spacer(),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMindset != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      setState(() => _currentStep = 1);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colours.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildObjectiveStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('objective'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "What's your #1 objective today?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "One clear target. Everything else is secondary.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          // Objective options - scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _objectiveOptions.map((objective) {
                  final isSelected = _selectedObjective == objective;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedObjective = objective);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? colours.accent.withOpacity(0.15)
                            : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? colours.accent : colours.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check_rounded, color: colours.accent, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            objective,
                            style: TextStyle(
                              color: isSelected ? colours.accent : colours.textBright,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation buttons
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _currentStep = 0);
                },
                child: Text(
                  'Back',
                  style: TextStyle(color: colours.textMuted),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedObjective != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        setState(() => _currentStep = 2);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('challenge'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "What might get in your way?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Naming it helps you prepare for it.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          // Challenge options - scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _challengeOptions.map((challenge) {
                  final isSelected = _selectedChallenge == challenge;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedChallenge = challenge);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? colours.accent.withOpacity(0.15)
                            : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? colours.accent : colours.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check_rounded, color: colours.accent, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            challenge,
                            style: TextStyle(
                              color: isSelected ? colours.accent : colours.textBright,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation buttons
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _currentStep = 1);
                },
                child: Text(
                  'Back',
                  style: TextStyle(color: colours.textMuted),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedChallenge != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        _showSummary();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Brief',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showSummary() {
    final colours = context.colours;
    
    // Get motivational message based on energy level
    final energyLevel = _mindsetOptions
        .firstWhere((o) => o['label'] == _selectedMindset)['energy'] as String;
    
    final motivationMessages = {
      'high': [
        "You've got the energy - channel it well.",
        "High energy day. Make it count.",
        "Ready to crush it. Stay focused on what matters.",
      ],
      'medium': [
        "Steady wins the race. You've got this.",
        "Focused and calm. Perfect for deep work.",
        "A balanced approach will serve you well today.",
      ],
      'low': [
        "Low energy is okay. Protect it for what matters most.",
        "Easy does it. One thing at a time.",
        "Sometimes slow and steady is the move.",
      ],
      'recovery': [
        "Recovery is productive. You're rebuilding.",
        "Rest is part of the mission. Honor it.",
        "Today's about restoration. That's valid work.",
      ],
    };
    
    final messages = motivationMessages[energyLevel] ?? motivationMessages['medium']!;
    final randomMessage = messages[Random().nextInt(messages.length)];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colours.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Checkmark icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Brief Complete',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow('Energy', _selectedMindset ?? ''),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Objective', _selectedObjective ?? ''),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Watch for', _selectedChallenge ?? 'None'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Motivational message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                randomMessage,
                style: TextStyle(
                  color: colours.accent,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pop(context); // Close brief screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Your Day',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    final colours = context.colours;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: colours.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colours.textBright,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
