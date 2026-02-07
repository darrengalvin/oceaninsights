import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Interactive Who Am I Quiz - Discover values and strengths
class WhoAmIQuizScreen extends StatefulWidget {
  const WhoAmIQuizScreen({super.key});

  @override
  State<WhoAmIQuizScreen> createState() => _WhoAmIQuizScreenState();
}

class _WhoAmIQuizScreenState extends State<WhoAmIQuizScreen> {
  int _currentQuestion = 0;
  final Map<String, int> _scores = {
    'helper': 0,
    'achiever': 0,
    'creative': 0,
    'thinker': 0,
    'leader': 0,
    'connector': 0,
  };
  
  final List<_QuizQuestion> _questions = [
    _QuizQuestion(
      question: "When you have free time, you usually...",
      options: [
        _QuizOption("Help someone with their problems", {'helper': 3}),
        _QuizOption("Work on a goal or project", {'achiever': 3}),
        _QuizOption("Create or make something", {'creative': 3}),
        _QuizOption("Learn something new or read", {'thinker': 3}),
      ],
    ),
    _QuizQuestion(
      question: "In a group project, you naturally...",
      options: [
        _QuizOption("Make sure everyone feels included", {'helper': 2, 'connector': 1}),
        _QuizOption("Take charge and organize things", {'leader': 3}),
        _QuizOption("Come up with creative ideas", {'creative': 3}),
        _QuizOption("Research and plan the details", {'thinker': 3}),
      ],
    ),
    _QuizQuestion(
      question: "You feel most proud when you...",
      options: [
        _QuizOption("Made someone's day better", {'helper': 3}),
        _QuizOption("Won or accomplished something", {'achiever': 3}),
        _QuizOption("Made people laugh or inspired them", {'creative': 2, 'connector': 1}),
        _QuizOption("Figured out a hard problem", {'thinker': 3}),
      ],
    ),
    _QuizQuestion(
      question: "What stresses you out most?",
      options: [
        _QuizOption("Seeing others hurt or struggling", {'helper': 3}),
        _QuizOption("Feeling like you're falling behind", {'achiever': 3}),
        _QuizOption("Being bored or stuck in routine", {'creative': 3}),
        _QuizOption("Not understanding something", {'thinker': 3}),
      ],
    ),
    _QuizQuestion(
      question: "Your friends would describe you as...",
      options: [
        _QuizOption("Caring and supportive", {'helper': 3}),
        _QuizOption("Ambitious and driven", {'achiever': 2, 'leader': 1}),
        _QuizOption("Fun and imaginative", {'creative': 3}),
        _QuizOption("Smart and thoughtful", {'thinker': 3}),
      ],
    ),
    _QuizQuestion(
      question: "If you could have any superpower...",
      options: [
        _QuizOption("Healing - fix people's pain", {'helper': 3}),
        _QuizOption("Speed - get everything done", {'achiever': 3}),
        _QuizOption("Shapeshifting - become anything", {'creative': 3}),
        _QuizOption("Mind reading - understand everyone", {'thinker': 2, 'connector': 1}),
      ],
    ),
    _QuizQuestion(
      question: "The perfect weekend involves...",
      options: [
        _QuizOption("Quality time with people I care about", {'connector': 3}),
        _QuizOption("Accomplishing things on my list", {'achiever': 3}),
        _QuizOption("Exploring somewhere new", {'creative': 2, 'thinker': 1}),
        _QuizOption("Relaxing and recharging alone", {'thinker': 2}),
      ],
    ),
    _QuizQuestion(
      question: "When facing a problem, you first...",
      options: [
        _QuizOption("Talk it through with someone", {'connector': 2, 'helper': 1}),
        _QuizOption("Make a plan and take action", {'achiever': 2, 'leader': 1}),
        _QuizOption("Think outside the box", {'creative': 3}),
        _QuizOption("Analyze all the options carefully", {'thinker': 3}),
      ],
    ),
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
          'Who Am I?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestion + 1}/${_questions.length}',
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
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: colours.border,
                valueColor: AlwaysStoppedAnimation<Color>(colours.accent),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Question
            Expanded(
              child: _buildQuestion(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuestion() {
    final colours = context.colours;
    final question = _questions[_currentQuestion];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          
          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectOption(option),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colours.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colours.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colours.accent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: colours.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            color: colours.textBright,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  void _selectOption(_QuizOption option) {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    
    // Add scores
    option.scores.forEach((type, score) {
      _scores[type] = (_scores[type] ?? 0) + score;
    });
    
    // Move to next question or show results
    if (_currentQuestion < _questions.length - 1) {
      // Gate after first question for free users
      if (_currentQuestion >= 1 && !SubscriptionService().isPremium) {
        checkPremiumAccess(context, featureName: 'Who Am I Quiz');
        return;
      }
      setState(() => _currentQuestion++);
    } else {
      _showResults();
    }
  }
  
  void _showResults() {
    // Find top personality types
    final sortedTypes = _scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final primaryType = sortedTypes[0].key;
    final secondaryType = sortedTypes[1].key;
    
    final typeInfo = _getTypeInfo(primaryType);
    final secondaryInfo = _getTypeInfo(secondaryType);
    
    final colours = context.colours;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _ResultsScreen(
          primaryType: typeInfo,
          secondaryType: secondaryInfo,
        ),
      ),
    );
  }
  
  _PersonalityType _getTypeInfo(String type) {
    switch (type) {
      case 'helper':
        return _PersonalityType(
          name: 'The Helper',
          icon: Icons.favorite_rounded,
          color: Colors.pink,
          description: 'You care deeply about others. You find meaning in supporting people and making their lives better.',
          strengths: ['Empathy', 'Kindness', 'Patience', 'Reliability'],
          growthAreas: ['Setting boundaries', 'Self-care', 'Saying no'],
          careers: ['Healthcare', 'Teaching', 'Counseling', 'Social Work'],
        );
      case 'achiever':
        return _PersonalityType(
          name: 'The Achiever',
          icon: Icons.emoji_events_rounded,
          color: Colors.amber,
          description: 'You thrive on goals and accomplishments. Success matters to you, and you work hard to reach it.',
          strengths: ['Drive', 'Focus', 'Efficiency', 'Resilience'],
          growthAreas: ['Slowing down', 'Enjoying the journey', 'Self-worth beyond success'],
          careers: ['Business', 'Sales', 'Athletics', 'Entrepreneurship'],
        );
      case 'creative':
        return _PersonalityType(
          name: 'The Creative',
          icon: Icons.palette_rounded,
          color: Colors.purple,
          description: 'You see the world differently. You love to imagine, create, and express yourself in unique ways.',
          strengths: ['Imagination', 'Innovation', 'Adaptability', 'Vision'],
          growthAreas: ['Following through', 'Structure', 'Practical planning'],
          careers: ['Art & Design', 'Writing', 'Entertainment', 'Marketing'],
        );
      case 'thinker':
        return _PersonalityType(
          name: 'The Thinker',
          icon: Icons.psychology_rounded,
          color: Colors.blue,
          description: 'You love to understand how things work. Knowledge and insight drive you forward.',
          strengths: ['Analysis', 'Problem-solving', 'Objectivity', 'Expertise'],
          growthAreas: ['Taking action', 'Emotional connection', 'Simplifying'],
          careers: ['Science', 'Technology', 'Research', 'Strategy'],
        );
      case 'leader':
        return _PersonalityType(
          name: 'The Leader',
          icon: Icons.flag_rounded,
          color: Colors.red,
          description: 'You naturally take charge. You see what needs to be done and inspire others to follow.',
          strengths: ['Confidence', 'Decisiveness', 'Vision', 'Charisma'],
          growthAreas: ['Listening', 'Collaboration', 'Patience'],
          careers: ['Management', 'Politics', 'Military', 'Coaching'],
        );
      case 'connector':
        return _PersonalityType(
          name: 'The Connector',
          icon: Icons.people_rounded,
          color: Colors.teal,
          description: 'You bring people together. Relationships and community are at the heart of who you are.',
          strengths: ['Communication', 'Networking', 'Harmony', 'Inclusivity'],
          growthAreas: ['Independence', 'Conflict tolerance', 'Personal boundaries'],
          careers: ['HR', 'Events', 'PR', 'Community Building'],
        );
      default:
        return _PersonalityType(
          name: 'The Explorer',
          icon: Icons.explore_rounded,
          color: Colors.green,
          description: 'You are curious and open-minded, always seeking new experiences and understanding.',
          strengths: ['Curiosity', 'Openness', 'Flexibility', 'Wonder'],
          growthAreas: ['Focus', 'Commitment', 'Depth'],
          careers: ['Travel', 'Journalism', 'Research', 'Consulting'],
        );
    }
  }
}

class _ResultsScreen extends StatelessWidget {
  final _PersonalityType primaryType;
  final _PersonalityType secondaryType;
  
  const _ResultsScreen({
    required this.primaryType,
    required this.secondaryType,
  });

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
          'Your Results',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary type card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryType.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryType.color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryType.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      primaryType.icon,
                      color: primaryType.color,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You are...',
                    style: TextStyle(
                      color: colours.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    primaryType.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primaryType.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    primaryType.description,
                    style: TextStyle(
                      color: colours.textBright,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Secondary type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: secondaryType.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      secondaryType.icon,
                      color: secondaryType.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'With a touch of...',
                          style: TextStyle(
                            color: colours.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          secondaryType.name,
                          style: TextStyle(
                            color: colours.textBright,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Strengths
            Text(
              'Your Strengths',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: primaryType.strengths.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      s,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            
            // Growth areas
            Text(
              'Growth Areas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...primaryType.growthAreas.map((area) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: colours.accent, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    area,
                    style: TextStyle(color: colours.textBright),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            
            // Suggested careers
            Text(
              'Careers to Explore',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: primaryType.careers.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    color: primaryType.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
            
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WhoAmIQuizScreen()),
                  );
                },
                child: Text(
                  'Take Quiz Again',
                  style: TextStyle(color: colours.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String question;
  final List<_QuizOption> options;
  
  const _QuizQuestion({required this.question, required this.options});
}

class _QuizOption {
  final String text;
  final Map<String, int> scores;
  
  const _QuizOption(this.text, this.scores);
}

class _PersonalityType {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> strengths;
  final List<String> growthAreas;
  final List<String> careers;
  
  const _PersonalityType({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.strengths,
    required this.growthAreas,
    required this.careers,
  });
}
