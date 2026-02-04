import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/content_sync_service.dart';

/// Confidence Builder - tools for self-esteem and self-expression (no typing)
/// Uses synced content from admin panel - works offline with cached data
class ConfidenceBuilderScreen extends StatefulWidget {
  const ConfidenceBuilderScreen({super.key});

  @override
  State<ConfidenceBuilderScreen> createState() => _ConfidenceBuilderScreenState();
}

class _ConfidenceBuilderScreenState extends State<ConfidenceBuilderScreen> {
  int _currentStep = 0;
  String? _selectedChallenge;
  final List<String> _selectedAffirmations = [];
  String? _selectedAction;
  
  // Challenges from admin
  List<Map<String, dynamic>> get _challenges {
    final challenges = ContentSyncService().getConfidenceChallenges();
    return challenges.map((c) => {
      'id': c,
      'title': c,
      'icon': Icons.psychology_outlined,
    }).toList();
  }
  
  // Affirmations from admin
  List<String> get _affirmations => ContentSyncService().getAffirmations();
  
  // Actions from admin
  List<Map<String, dynamic>> get _actions {
    final actions = ContentSyncService().getConfidenceActions();
    return actions.map((a) => {
      'title': a.text,
      'description': 'Try this today',
      'icon': _getIconForDifficulty(a.difficulty),
      'difficulty': a.difficulty,
    }).toList();
  }
  
  IconData _getIconForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy': return Icons.favorite_outline;
      case 'medium': return Icons.explore_outlined;
      case 'hard': return Icons.star_outline;
      default: return Icons.lightbulb_outline;
    }
  }
  
  // Fallback if no actions from admin
  List<Map<String, dynamic>> get _fallbackActions => [
    {
      'title': 'Give myself a compliment',
      'description': 'Say one thing you like about yourself',
      'icon': Icons.favorite_outline,
    },
    {
      'title': 'Try something small and new',
      'description': 'A tiny step outside your comfort zone',
      'icon': Icons.explore_outlined,
    },
    {
      'title': 'Ask for help once today',
      'description': "It's a strength, not a weakness",
      'icon': Icons.support_agent_outlined,
    },
    {
      'title': 'Speak up in one conversation',
      'description': 'Share one thought or opinion',
      'icon': Icons.chat_outlined,
    },
    {
      'title': 'Celebrate a small win',
      'description': 'Notice something you did well',
      'icon': Icons.celebration_outlined,
    },
  ];

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
          'Confidence Builder',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: colours.border,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
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
        return _buildChallengeStep();
      case 1:
        return _buildAffirmationsStep();
      case 2:
        return _buildActionStep();
      default:
        return const SizedBox.shrink();
    }
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
            "What's your biggest challenge right now?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be honest - this helps us personalize your tools.",
            style: TextStyle(color: colours.textMuted),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                final isSelected = _selectedChallenge == challenge['id'];
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    UISoundService().playClick();
                    setState(() => _selectedChallenge = challenge['id']);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.withOpacity(0.15)
                          : colours.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.purple : colours.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          challenge['icon'] as IconData,
                          color: isSelected ? Colors.purple : colours.textMuted,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          challenge['title'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.purple : colours.textBright,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedChallenge != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      setState(() => _currentStep = 1);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAffirmationsStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('affirmations'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Pick affirmations that resonate",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select 3 or more to build your daily practice.",
            style: TextStyle(color: colours.textMuted),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _affirmations.map((affirmation) {
                  final isSelected = _selectedAffirmations.contains(affirmation);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() {
                        if (isSelected) {
                          _selectedAffirmations.remove(affirmation);
                        } else {
                          _selectedAffirmations.add(affirmation);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple.withOpacity(0.15)
                            : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.purple : colours.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check_rounded, color: Colors.purple, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            affirmation,
                            style: TextStyle(
                              color: isSelected ? Colors.purple : colours.textBright,
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
          
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: Text('Back', style: TextStyle(color: colours.textMuted)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedAffirmations.length >= 3
                    ? () {
                        HapticFeedback.mediumImpact();
                        setState(() => _currentStep = 2);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue (${_selectedAffirmations.length}/3+)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('action'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Choose one action for today",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Small steps build lasting confidence.",
            style: TextStyle(color: colours.textMuted),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: _actions.length,
              itemBuilder: (context, index) {
                final action = _actions[index];
                final isSelected = _selectedAction == action['title'];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedAction = action['title']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple.withOpacity(0.15)
                            : colours.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.purple : colours.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.purple.withOpacity(0.2)
                                  : colours.cardLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              action['icon'] as IconData,
                              color: isSelected ? Colors.purple : colours.textMuted,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  action['title'] as String,
                                  style: TextStyle(
                                    color: colours.textBright,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  action['description'] as String,
                                  style: TextStyle(
                                    color: colours.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.purple),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: Text('Back', style: TextStyle(color: colours.textMuted)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedAction != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        _showSummary();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete',
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
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Colors.purple,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'You\'re Ready!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You have your affirmations and today's action. You've got this.",
              style: TextStyle(color: colours.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Action:",
                    style: TextStyle(
                      color: colours.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedAction ?? '',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go Be Confident',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
