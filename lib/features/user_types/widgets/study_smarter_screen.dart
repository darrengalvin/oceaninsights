import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/content_sync_service.dart';

/// Study Smarter interactive screen - learning styles and focus tools (no typing)
/// Uses synced content from admin panel - works offline with cached data
class StudySmarterScreen extends StatefulWidget {
  const StudySmarterScreen({super.key});

  @override
  State<StudySmarterScreen> createState() => _StudySmarterScreenState();
}

class _StudySmarterScreenState extends State<StudySmarterScreen> {
  int _currentStep = 0;
  String? _selectedLearningStyle;
  final List<String> _selectedStrategies = [];
  
  // Learning styles from admin
  List<Map<String, dynamic>> get _learningStyles {
    final styles = ContentSyncService().getLearningStyles();
    if (styles.isEmpty) return _defaultLearningStyles;
    
    return styles.map((s) => {
      'id': s.id,
      'title': '${s.name} Learner',
      'icon': _getIconForStyle(s.emoji),
      'description': s.description,
      'strategies': s.tips,
    }).toList();
  }
  
  IconData _getIconForStyle(String emoji) {
    switch (emoji) {
      case '👁️': return Icons.visibility_rounded;
      case '👂': return Icons.hearing_rounded;
      case '📝': return Icons.menu_book_rounded;
      case '🤲': return Icons.sports_handball_rounded;
      default: return Icons.school_rounded;
    }
  }
  
  // Fallback defaults
  final List<Map<String, dynamic>> _defaultLearningStyles = [
    {
      'id': 'visual',
      'title': 'Visual Learner',
      'icon': Icons.visibility_rounded,
      'description': 'Learn best with diagrams, charts, and videos',
      'strategies': [
        'Use mind maps and flowcharts',
        'Watch educational videos',
        'Color-code your notes',
        'Draw diagrams to explain concepts',
        'Create visual flashcards',
      ],
    },
    {
      'id': 'auditory',
      'title': 'Auditory Learner',
      'icon': Icons.hearing_rounded,
      'description': 'Learn best through listening and discussion',
      'strategies': [
        'Record lectures and replay them',
        'Explain concepts out loud',
        'Join study groups for discussion',
        'Listen to podcasts on topics',
        'Use rhymes and songs to remember',
      ],
    },
    {
      'id': 'reading',
      'title': 'Reading/Writing Learner',
      'icon': Icons.menu_book_rounded,
      'description': 'Learn best through reading and writing',
      'strategies': [
        'Rewrite notes in your own words',
        'Read textbooks and articles',
        'Make lists and bullet points',
        'Write practice essays',
        'Keep a learning journal',
      ],
    },
    {
      'id': 'kinesthetic',
      'title': 'Kinesthetic Learner',
      'icon': Icons.sports_handball_rounded,
      'description': 'Learn best through hands-on practice',
      'strategies': [
        'Do practice problems',
        'Build models or prototypes',
        'Take breaks to move around',
        'Use flashcards actively',
        'Teach others what you learn',
      ],
    },
  ];
  
  final List<Map<String, dynamic>> _focusTips = [
    {'icon': Icons.timer_outlined, 'tip': 'Pomodoro Technique: 25 min work, 5 min break'},
    {'icon': Icons.phone_disabled, 'tip': 'Put phone in another room while studying'},
    {'icon': Icons.music_note, 'tip': 'Try focus music or white noise'},
    {'icon': Icons.wb_sunny_outlined, 'tip': 'Study in natural light when possible'},
    {'icon': Icons.water_drop_outlined, 'tip': 'Stay hydrated - keep water nearby'},
    {'icon': Icons.bedtime_outlined, 'tip': 'Get enough sleep before study sessions'},
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
          'Study Smarter',
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
        return _buildLearningStyleStep();
      case 1:
        return _buildStrategiesStep();
      case 2:
        return _buildFocusTipsStep();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildLearningStyleStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('style'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "What's your learning style?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select the one that feels most like you.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: _learningStyles.length,
              itemBuilder: (context, index) {
                final style = _learningStyles[index];
                final isSelected = _selectedLearningStyle == style['id'];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedLearningStyle = style['id']);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(18),
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colours.accent.withOpacity(0.2)
                                  : colours.cardLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              style['icon'] as IconData,
                              color: isSelected ? colours.accent : colours.textMuted,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style['title'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colours.textBright,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  style['description'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colours.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: colours.accent),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedLearningStyle != null
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
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStrategiesStep() {
    final colours = context.colours;
    final selectedStyle = _learningStyles.firstWhere(
      (s) => s['id'] == _selectedLearningStyle,
      orElse: () => _learningStyles[0],
    );
    final strategies = selectedStyle['strategies'] as List<String>;
    
    return Padding(
      key: const ValueKey('strategies'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  selectedStyle['icon'] as IconData,
                  color: colours.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedStyle['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Pick strategies you'll try:",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select at least 2 to build your study plan.",
            style: TextStyle(color: colours.textMuted),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: strategies.length,
              itemBuilder: (context, index) {
                final strategy = strategies[index];
                final isSelected = _selectedStrategies.contains(strategy);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() {
                        if (isSelected) {
                          _selectedStrategies.remove(strategy);
                        } else {
                          _selectedStrategies.add(strategy);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.withOpacity(0.1)
                            : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.green : colours.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.green : colours.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              strategy,
                              style: TextStyle(
                                color: colours.textBright,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
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
                onPressed: () => setState(() => _currentStep = 0),
                child: Text('Back', style: TextStyle(color: colours.textMuted)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedStrategies.length >= 2
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
                child: Text(
                  'Continue (${_selectedStrategies.length}/2+)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFocusTipsStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('focus'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Focus Tips",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Quick wins to boost your study sessions.",
            style: TextStyle(color: colours.textMuted),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: _focusTips.length,
              itemBuilder: (context, index) {
                final tip = _focusTips[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colours.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colours.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colours.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tip['icon'] as IconData,
                          color: colours.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          tip['tip'] as String,
                          style: TextStyle(
                            color: colours.textBright,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showSummary();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
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
    final selectedStyle = _learningStyles.firstWhere(
      (s) => s['id'] == _selectedLearningStyle,
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colours.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Center(
                child: Text(
                  'Your Study Plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Learning style
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colours.cardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedStyle['icon'] as IconData,
                      color: colours.accent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Style',
                          style: TextStyle(color: colours.textMuted, fontSize: 12),
                        ),
                        Text(
                          selectedStyle['title'] as String,
                          style: TextStyle(
                            color: colours.textBright,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Selected strategies
              Text(
                'Your Strategies',
                style: TextStyle(
                  color: colours.textBright,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ..._selectedStrategies.map((strategy) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        strategy,
                        style: TextStyle(color: colours.textBright),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
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
                    'Start Studying',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
