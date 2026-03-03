import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

class ServiceCultureScreen extends StatefulWidget {
  const ServiceCultureScreen({super.key});

  @override
  State<ServiceCultureScreen> createState() => _ServiceCultureScreenState();
}

class _ServiceCultureScreenState extends State<ServiceCultureScreen>
    with TickerProviderStateMixin, TeaseMixin {
  int _currentTab = 0;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Service Culture');

  static const List<String> _valueNames = [
    'Courage',
    'Commitment',
    'Respect',
    'Discipline',
    'Integrity',
    'Loyalty',
  ];

  static const List<String> _valueEmojis = [
    '🦁', '💪', '🤝', '⚡', '🎯', '🛡️',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(context),
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _AssessmentTab(
                    valueNames: _valueNames,
                    valueEmojis: _valueEmojis,
                  ),
                  _ScenarioTab(
                    valueNames: _valueNames,
                    onAnswer: () {
                      recordTeaseAction();
                      return checkTeaseAndContinue();
                    },
                  ),
                  _DailyFocusTab(
                    valueNames: _valueNames,
                    valueEmojis: _valueEmojis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colours = context.colours;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Service Culture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colours = context.colours;
    final tabs = ['Assessment', 'Scenarios', 'Daily Focus'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _currentTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                UISoundService().playClick();
                setState(() => _currentTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.only(
                  right: i < 2 ? 4 : 0,
                  left: i > 0 ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colours.accent.withOpacity(0.15)
                      : colours.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? colours.accent.withOpacity(0.4)
                        : colours.border.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? colours.accent : colours.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 1: Values Self-Assessment with Radar Chart
// ═══════════════════════════════════════════════════════════════════

class _AssessmentTab extends StatefulWidget {
  final List<String> valueNames;
  final List<String> valueEmojis;

  const _AssessmentTab({required this.valueNames, required this.valueEmojis});

  @override
  State<_AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<_AssessmentTab> {
  late List<int> _scores;

  @override
  void initState() {
    super.initState();
    _scores = List.filled(6, 5);
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Rate yourself on each value',
            style: TextStyle(color: colours.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: CustomPaint(
              painter: _RadarChartPainter(
                scores: _scores.map((s) => s / 10.0).toList(),
                labels: widget.valueNames,
                accentColor: colours.accent,
                gridColor: colours.border.withOpacity(0.3),
                textColor: colours.textMuted,
              ),
              size: const Size(240, 240),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(6, (i) => _buildValueSlider(context, i)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildValueSlider(BuildContext context, int index) {
    final colours = context.colours;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.valueEmojis[index],
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                widget.valueNames[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_scores[index]}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colours.accent,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(10, (level) {
              final filled = level < _scores[index];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _scores[index] = level + 1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: filled
                          ? colours.accent.withOpacity(0.2 + (level * 0.08))
                          : colours.cardLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: filled
                            ? colours.accent.withOpacity(0.4)
                            : colours.border.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> scores;
  final List<String> labels;
  final Color accentColor;
  final Color gridColor;
  final Color textColor;

  _RadarChartPainter({
    required this.scores,
    required this.labels,
    required this.accentColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final sides = scores.length;
    final angleStep = (2 * math.pi) / sides;

    // Grid rings
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int ring = 1; ring <= 5; ring++) {
      final r = radius * (ring / 5);
      final path = Path();
      for (int i = 0; i <= sides; i++) {
        final angle = (i % sides) * angleStep - math.pi / 2;
        final p = Offset(center.dx + r * math.cos(angle),
            center.dy + r * math.sin(angle));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, gridPaint);
    }

    // Spokes
    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final end = Offset(center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle));
      canvas.drawLine(center, end, gridPaint);
    }

    // Data polygon fill
    final fillPaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final dataPath = Path();
    for (int i = 0; i <= sides; i++) {
      final idx = i % sides;
      final angle = idx * angleStep - math.pi / 2;
      final r = radius * scores[idx];
      final p = Offset(
          center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(dataPath, fillPaint);

    // Data polygon outline
    final outlinePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(dataPath, outlinePaint);

    // Data points
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final r = radius * scores[i];
      final p = Offset(
          center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      canvas.drawCircle(p, 4, dotPaint);
    }

    // Labels
    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final labelR = radius + 22;
      final p = Offset(center.dx + labelR * math.cos(angle),
          center.dy + labelR * math.sin(angle));

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter old) =>
      old.scores != scores;
}

// ═══════════════════════════════════════════════════════════════════
// Tab 2: Scenario Challenge
// ═══════════════════════════════════════════════════════════════════

class _ScenarioTab extends StatefulWidget {
  final List<String> valueNames;
  final bool Function() onAnswer;

  const _ScenarioTab({required this.valueNames, required this.onAnswer});

  @override
  State<_ScenarioTab> createState() => _ScenarioTabState();
}

class _ScenarioTabState extends State<_ScenarioTab> {
  int _currentIndex = 0;
  int? _selectedValue;
  bool _revealed = false;
  int _score = 0;
  int _total = 0;

  static const List<Map<String, dynamic>> _scenarios = [
    {
      'scenario': 'A colleague is being singled out by seniors. Nobody else speaks up. Do you?',
      'answer': 0, // Courage
      'explanation': 'Standing up when others stay silent requires Courage — even when it may cost you.',
    },
    {
      'scenario': 'You\'re exhausted after a long exercise but your section still has duties to complete.',
      'answer': 1, // Commitment
      'explanation': 'Pushing through when your body wants to quit is the essence of Commitment.',
    },
    {
      'scenario': 'A junior member makes a mistake that delays the whole team.',
      'answer': 2, // Respect
      'explanation': 'How you treat someone at their worst shows your Respect — for them and the team.',
    },
    {
      'scenario': 'You\'re off duty but spot a serious safety hazard on base.',
      'answer': 3, // Discipline
      'explanation': 'Doing what\'s right even when nobody is watching — that\'s Discipline.',
    },
    {
      'scenario': 'You discover a senior is falsifying equipment checks.',
      'answer': 4, // Integrity
      'explanation': 'Choosing truth over convenience, especially upward, demands Integrity.',
    },
    {
      'scenario': 'A friend is being posted to a difficult location and everyone else is avoiding them.',
      'answer': 5, // Loyalty
      'explanation': 'Standing by someone when the situation isn\'t easy — that\'s Loyalty.',
    },
    {
      'scenario': 'You\'re asked to lead a task you\'ve never done before in front of the whole platoon.',
      'answer': 0, // Courage
      'explanation': 'Accepting the risk of failure in front of others takes real Courage.',
    },
    {
      'scenario': 'Your unit has a boring but critical daily routine. Some people skip it.',
      'answer': 3, // Discipline
      'explanation': 'Maintaining standards in the mundane — that\'s where Discipline truly lives.',
    },
  ];

  void _select(int valueIndex) {
    if (_revealed) return;
    if (!widget.onAnswer()) return;

    HapticFeedback.mediumImpact();
    UISoundService().playClick();
    final correct = _scenarios[_currentIndex]['answer'] as int;

    setState(() {
      _selectedValue = valueIndex;
      _revealed = true;
      _total++;
      if (valueIndex == correct) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _scenarios.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex++;
        _selectedValue = null;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final scenario = _scenarios[_currentIndex];
    final correctAnswer = scenario['answer'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (_total > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $_score / $_total',
                style: const TextStyle(
                  color: Color(0xFF00B894),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            '${_currentIndex + 1} of ${_scenarios.length}',
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'SCENARIO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: colours.accent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  scenario['scenario'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colours.textBright,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _revealed
                ? 'The answer:'
                : 'Which value is being tested?',
            style: TextStyle(
              color: colours.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(6, (i) {
              final isSelected = _selectedValue == i;
              final isCorrect = i == correctAnswer;

              Color chipColor;
              Color borderColor;

              if (!_revealed) {
                chipColor = colours.cardLight;
                borderColor = colours.border.withOpacity(0.3);
              } else if (isSelected && isCorrect) {
                chipColor = const Color(0xFF00B894).withOpacity(0.15);
                borderColor = const Color(0xFF00B894).withOpacity(0.5);
              } else if (isSelected && !isCorrect) {
                chipColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red.withOpacity(0.4);
              } else if (isCorrect) {
                chipColor = const Color(0xFF00B894).withOpacity(0.08);
                borderColor = const Color(0xFF00B894).withOpacity(0.3);
              } else {
                chipColor = colours.cardLight.withOpacity(0.5);
                borderColor = colours.border.withOpacity(0.15);
              }

              return GestureDetector(
                onTap: () => _select(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    widget.valueNames[i],
                    style: TextStyle(
                      color: colours.textBright,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_revealed) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (_selectedValue == correctAnswer)
                    ? const Color(0xFF00B894).withOpacity(0.08)
                    : Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (_selectedValue == correctAnswer)
                      ? const Color(0xFF00B894).withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedValue == correctAnswer
                        ? Icons.check_circle_rounded
                        : Icons.lightbulb_rounded,
                    color: _selectedValue == correctAnswer
                        ? const Color(0xFF00B894)
                        : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scenario['explanation'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colours.textBright,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_currentIndex < _scenarios.length - 1)
              GestureDetector(
                onTap: _next,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Next Scenario',
                    style: TextStyle(
                      color: colours.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 3: Daily Value Focus
// ═══════════════════════════════════════════════════════════════════

class _DailyFocusTab extends StatefulWidget {
  final List<String> valueNames;
  final List<String> valueEmojis;

  const _DailyFocusTab({required this.valueNames, required this.valueEmojis});

  @override
  State<_DailyFocusTab> createState() => _DailyFocusTabState();
}

class _DailyFocusTabState extends State<_DailyFocusTab>
    with SingleTickerProviderStateMixin {
  bool _tapped = false;
  String _tapLabel = '';
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  static const List<String> _descriptions = [
    'The willingness to face fear, uncertainty, and danger. Speaking up when others stay silent.',
    'Giving your all, every day, even when no one is watching. Seeing things through to the end.',
    'Treating every person with dignity — regardless of rank, background, or situation.',
    'Doing the right thing consistently, maintaining standards, and holding yourself accountable.',
    'Being honest and truthful in all actions. Your word is your bond.',
    'Standing by your team, your unit, and your values — especially when it\'s hard.',
  ];

  static const List<String> _challenges = [
    'Today, speak up about something you\'d normally stay quiet about.',
    'Today, finish one task you\'ve been putting off — no matter how small.',
    'Today, go out of your way to acknowledge someone you normally wouldn\'t.',
    'Today, do one thing properly that you\'d normally cut corners on.',
    'Today, tell someone a truth you\'ve been avoiding — kindly.',
    'Today, check in on someone who might be struggling.',
  ];

  int get _todayIndex {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return dayOfYear % 6;
  }

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap(String label) {
    HapticFeedback.mediumImpact();
    UISoundService().playClick();
    setState(() {
      _tapped = true;
      _tapLabel = label;
    });
    _bounceController.forward().then((_) => _bounceController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final idx = _todayIndex;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'TODAY\'S FOCUS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: colours.accent,
            ),
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _bounceAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colours.accent.withOpacity(0.12),
                    colours.card,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: colours.accent.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(widget.valueEmojis[idx],
                      style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    widget.valueNames[idx],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colours.textBright,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _descriptions[idx],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colours.textLight,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'YOUR CHALLENGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.amber.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _challenges[idx],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colours.textBright,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!_tapped)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'I did this ✓',
                    color: const Color(0xFF00B894),
                    onTap: () => _handleTap('I did this ✓'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'I\'ll try tomorrow',
                    color: colours.accent,
                    onTap: () => _handleTap('I\'ll try tomorrow'),
                  ),
                ),
              ],
            )
          else
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF00B894).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF00B894), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _tapLabel == 'I did this ✓'
                        ? 'Well done. Small actions build strong character.'
                        : 'That\'s okay. Tomorrow is a fresh start.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colours.textBright,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
