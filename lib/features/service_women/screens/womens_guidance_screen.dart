import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../navigate/data/navigate_content.dart';

/// Routes to the correct interactive experience based on topic ID.
class WomensGuidanceScreen extends StatelessWidget {
  final NavigateTopic topic;

  const WomensGuidanceScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    switch (topic.id) {
      case 'what_women_want':
        return _FlipCardScreen(topic: topic);
      case 'menstrual_cycle':
        return _CyclePhaseScreen(topic: topic);
      case 'cycle_training':
        return _TrainingPhaseScreen(topic: topic);
      case 'perimenopause':
        return _SymptomCheckerScreen(topic: topic);
      case 'pmdd':
        return _PMDDQuizScreen(topic: topic);
      case 'endometriosis':
        return _PainAssessmentScreen(topic: topic);
      case 'iron_deficiency':
        return _IronCheckerScreen(topic: topic);
      case 'period_ops':
        return _KitBuilderScreen(topic: topic);
      default:
        return _FallbackScreen(topic: topic);
    }
  }
}

// ================================================================
// 1. FLIP CARDS — What Women Want
// ================================================================

class _FlipCardScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _FlipCardScreen({required this.topic});

  @override
  State<_FlipCardScreen> createState() => _FlipCardScreenState();
}

class _FlipCardScreenState extends State<_FlipCardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final cards = widget.topic.cards;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Tap the card to flip it',
              style: TextStyle(color: colours.textMuted, fontSize: 14),
            ),
          ),
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cards.length, (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentIndex
                      ? const Color(0xFFE879A0)
                      : colours.border,
                ),
              )),
            ),
          ),
          const SizedBox(height: 16),
          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SingleFlipCard(
                key: ValueKey(_currentIndex),
                card: cards[_currentIndex],
                colours: colours,
              ),
            ),
          ),
          // Nav buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  label: 'Previous',
                  icon: Icons.arrow_back_rounded,
                  enabled: _currentIndex > 0,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _currentIndex--);
                  },
                ),
                Text(
                  '${_currentIndex + 1} of ${cards.length}',
                  style: TextStyle(color: colours.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                _NavButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  enabled: _currentIndex < cards.length - 1,
                  trailing: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _currentIndex++);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleFlipCard extends StatefulWidget {
  final GuidanceCard card;
  final AppColours colours;

  const _SingleFlipCard({super.key, required this.card, required this.colours});

  @override
  State<_SingleFlipCard> createState() => _SingleFlipCardState();
}

class _SingleFlipCardState extends State<_SingleFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE879A0), Color(0xFFAB5C8A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE879A0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 24),
          Text(
            widget.card.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tap to read more',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.colours.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE879A0).withOpacity(0.3)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.card.title,
                style: TextStyle(
                  color: widget.colours.textBright,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.card.content,
                style: TextStyle(
                  color: widget.colours.textLight,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              if (widget.card.affirmation != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE879A0).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.card.affirmation!,
                    style: const TextStyle(
                      color: Color(0xFFE879A0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tap to flip back',
                  style: TextStyle(color: widget.colours.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// 2. CYCLE PHASES — Interactive swipeable phases with hormone bar
// ================================================================

class _CyclePhaseScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _CyclePhaseScreen({required this.topic});

  @override
  State<_CyclePhaseScreen> createState() => _CyclePhaseScreenState();
}

class _CyclePhaseScreenState extends State<_CyclePhaseScreen> {
  int _selectedPhase = 0;

  static const _phaseColours = [
    Color(0xFFE879A0), // Menstrual
    Color(0xFF60A5FA), // Follicular
    Color(0xFF34D399), // Ovulation
    Color(0xFFF59E0B), // Luteal
  ];

  static const _phaseEmojis = ['🩸', '🌱', '☀️', '🌙'];

  static const _hormoneLevels = [
    {'oestrogen': 0.15, 'progesterone': 0.1},
    {'oestrogen': 0.65, 'progesterone': 0.15},
    {'oestrogen': 1.0, 'progesterone': 0.3},
    {'oestrogen': 0.4, 'progesterone': 0.8},
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final cards = widget.topic.cards;
    final card = cards[_selectedPhase];
    final phaseColour = _phaseColours[_selectedPhase];

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase selector chips
            Row(
              children: List.generate(cards.length, (i) {
                final selected = i == _selectedPhase;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedPhase = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(right: i < cards.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? _phaseColours[i].withOpacity(0.15) : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? _phaseColours[i] : colours.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(_phaseEmojis[i], style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            ['Period', 'Follicular', 'Ovulation', 'Luteal'][i],
                            style: TextStyle(
                              color: selected ? _phaseColours[i] : colours.textMuted,
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Hormone bars
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colours.border.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hormone Levels', style: TextStyle(color: colours.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _HormoneBar(label: 'Oestrogen', value: _hormoneLevels[_selectedPhase]['oestrogen']!, colour: const Color(0xFFE879A0)),
                  const SizedBox(height: 10),
                  _HormoneBar(label: 'Progesterone', value: _hormoneLevels[_selectedPhase]['progesterone']!, colour: const Color(0xFF818CF8)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phase info card
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_selectedPhase),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colours.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: phaseColour.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_phaseEmojis[_selectedPhase], style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            card.title,
                            style: TextStyle(
                              color: colours.textBright,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(card.content,
                        style: TextStyle(color: colours.textLight, fontSize: 14, height: 1.6)),
                    if (card.actionSteps != null && card.actionSteps!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...card.actionSteps!.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, color: phaseColour, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(s, style: TextStyle(color: colours.textLight, fontSize: 13, height: 1.4))),
                              ],
                            ),
                          )),
                    ],
                    if (card.affirmation != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: phaseColour.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(card.affirmation!,
                            style: TextStyle(color: phaseColour, fontSize: 14, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HormoneBar extends StatelessWidget {
  final String label;
  final double value;
  final Color colour;

  const _HormoneBar({required this.label, required this.value, required this.colour});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(color: colours.textLight, fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor: colours.border,
                color: colour,
                minHeight: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// 3. CYCLE & TRAINING — Phase selector → training plan
// ================================================================

class _TrainingPhaseScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _TrainingPhaseScreen({required this.topic});

  @override
  State<_TrainingPhaseScreen> createState() => _TrainingPhaseScreenState();
}

class _TrainingPhaseScreenState extends State<_TrainingPhaseScreen> {
  int? _selectedPhase;

  static const _phaseIcons = [Icons.self_improvement_rounded, Icons.fitness_center_rounded, Icons.bolt_rounded, Icons.directions_walk_rounded];
  static const _phaseColours = [Color(0xFFE879A0), Color(0xFF60A5FA), Color(0xFF34D399), Color(0xFFF59E0B)];
  static const _phaseLabels = ['Menstrual', 'Follicular', 'Ovulation', 'Luteal'];
  static const _intensityLabels = ['Low', 'High', 'Peak', 'Moderate'];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final cards = widget.topic.cards;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where are you in your cycle?',
              style: TextStyle(color: colours.textBright, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to see your training plan for this phase',
              style: TextStyle(color: colours.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Phase grid
            ...List.generate(cards.length, (i) {
              final selected = _selectedPhase == i;
              final colour = _phaseColours[i];

              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  UISoundService().playClick();
                  setState(() => _selectedPhase = selected ? null : i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? colour.withOpacity(0.1) : colours.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? colour : colours.border.withOpacity(0.5),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colour.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_phaseIcons[i], color: colour, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_phaseLabels[i],
                                    style: TextStyle(color: colours.textBright, fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('Intensity: ${_intensityLabels[i]}',
                                    style: TextStyle(color: colour, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: selected ? 0.25 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(Icons.chevron_right_rounded, color: colours.textMuted),
                          ),
                        ],
                      ),
                      if (selected) ...[
                        const SizedBox(height: 16),
                        Container(height: 1, color: colours.border.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(cards[i].content,
                            style: TextStyle(color: colours.textLight, fontSize: 14, height: 1.6)),
                        if (cards[i].actionSteps != null) ...[
                          const SizedBox(height: 14),
                          ...cards[i].actionSteps!.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.fitness_center_rounded, color: colour, size: 14),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(s, style: TextStyle(color: colours.textLight, fontSize: 13, height: 1.4))),
                                  ],
                                ),
                              )),
                        ],
                        if (cards[i].affirmation != null) ...[
                          const SizedBox(height: 12),
                          Text(cards[i].affirmation!,
                              style: TextStyle(color: colour, fontSize: 14, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// 4. PERIMENOPAUSE — Symptom Checker
// ================================================================

class _SymptomCheckerScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _SymptomCheckerScreen({required this.topic});

  @override
  State<_SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<_SymptomCheckerScreen> {
  final Set<String> _selected = {};
  bool _showResults = false;

  static const _symptoms = [
    _CheckSymptom('Irregular periods', '🩸'),
    _CheckSymptom('Hot flushes', '🔥'),
    _CheckSymptom('Night sweats', '💦'),
    _CheckSymptom('Brain fog', '🌫️'),
    _CheckSymptom('Sudden anxiety', '😰'),
    _CheckSymptom('Joint pain', '🦴'),
    _CheckSymptom('Fatigue', '😴'),
    _CheckSymptom('Sleep disruption', '🌙'),
    _CheckSymptom('Mood swings / rage', '🎭'),
    _CheckSymptom('Low libido', '💔'),
    _CheckSymptom('Weight changes', '⚖️'),
    _CheckSymptom('Heart palpitations', '💓'),
    _CheckSymptom('Difficulty concentrating', '🧠'),
    _CheckSymptom('Feeling not like yourself', '🪞'),
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final cards = widget.topic.cards;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showResults) ...[
              Text('Do any of these apply to you?',
                  style: TextStyle(color: colours.textBright, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Tap all that apply — this stays on your device only',
                  style: TextStyle(color: colours.textMuted, fontSize: 14)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((s) {
                  final selected = _selected.contains(s.label);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() {
                        if (selected) {
                          _selected.remove(s.label);
                        } else {
                          _selected.add(s.label);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFE879A0).withOpacity(0.15) : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? const Color(0xFFE879A0) : colours.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(s.label,
                              style: TextStyle(
                                color: selected ? colours.textBright : colours.textLight,
                                fontSize: 13,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              if (_selected.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _showResults = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE879A0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('See what this might mean (${_selected.length} selected)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
            ] else ...[
              // Results
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE879A0).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE879A0).withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text('You selected ${_selected.length} of ${_symptoms.length} common symptoms',
                        style: TextStyle(color: colours.textBright, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      _selected.length >= 5
                          ? 'This pattern is consistent with perimenopause. Consider speaking to your GP or MO.'
                          : _selected.length >= 3
                              ? 'Some of these symptoms could be hormonal changes. Worth monitoring and discussing with your doctor.'
                              : 'A few symptoms alone don\'t confirm anything, but awareness is valuable. Keep tracking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colours.textLight, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Wrap of selected symptoms
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selected.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE879A0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s, style: TextStyle(color: colours.textBright, fontSize: 12)),
                    )).toList(),
              ),
              const SizedBox(height: 24),
              // Show guidance cards
              ...cards.map((card) => _InfoExpandable(card: card, colours: colours)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => setState(() {
                  _showResults = false;
                  _selected.clear();
                }),
                icon: Icon(Icons.refresh_rounded, color: colours.textMuted, size: 18),
                label: Text('Start over', style: TextStyle(color: colours.textMuted)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckSymptom {
  final String label;
  final String emoji;
  const _CheckSymptom(this.label, this.emoji);
}

// ================================================================
// 5. PMDD — Step-by-step pattern quiz
// ================================================================

class _PMDDQuizScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _PMDDQuizScreen({required this.topic});

  @override
  State<_PMDDQuizScreen> createState() => _PMDDQuizScreenState();
}

class _PMDDQuizScreenState extends State<_PMDDQuizScreen> {
  int _step = 0;
  int _yesCount = 0;

  static const _questions = [
    'Do you experience severe mood changes (depression, rage, or anxiety) in the 1-2 weeks before your period?',
    'Do these symptoms lift within a few days of your period starting?',
    'Does this pattern repeat most months — not just occasionally?',
    'Do you feel like a completely different person in the second half of your cycle?',
    'Have you had thoughts of hopelessness or not wanting to be here during this time?',
    'Do friends, family, or colleagues notice the change in you?',
    'Have you been told it\'s "just PMS" but it feels much worse than that?',
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final cards = widget.topic.cards;
    final showResult = _step >= _questions.length;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: showResult ? _buildResult(colours, cards) : _buildQuestion(colours),
      ),
    );
  }

  Widget _buildQuestion(AppColours colours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        LinearProgressIndicator(
          value: (_step + 1) / _questions.length,
          backgroundColor: colours.border,
          color: const Color(0xFF818CF8),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 8),
        Text('Question ${_step + 1} of ${_questions.length}',
            style: TextStyle(color: colours.textMuted, fontSize: 12)),
        const SizedBox(height: 32),

        Text(_questions[_step],
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600, height: 1.4)),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: _BigChoiceButton(
                label: 'Yes',
                colour: const Color(0xFFE879A0),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  UISoundService().playClick();
                  setState(() {
                    _yesCount++;
                    _step++;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigChoiceButton(
                label: 'No',
                colour: const Color(0xFF60A5FA),
                onTap: () {
                  HapticFeedback.lightImpact();
                  UISoundService().playClick();
                  setState(() => _step++);
                },
              ),
            ),
          ],
        ),
        if (_step > 0) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _step = 0;
                _yesCount = 0;
              }),
              child: Text('Start over', style: TextStyle(color: colours.textMuted)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResult(AppColours colours, List<GuidanceCard> cards) {
    final high = _yesCount >= 5;
    final moderate = _yesCount >= 3;
    final resultColour = high ? const Color(0xFFE879A0) : moderate ? const Color(0xFFF59E0B) : const Color(0xFF34D399);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: resultColour.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: resultColour.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text('$_yesCount of ${_questions.length}',
                  style: TextStyle(color: resultColour, fontSize: 36, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                high
                    ? 'This pattern is strongly consistent with PMDD. Please speak to your doctor.'
                    : moderate
                        ? 'Some patterns match. Track your mood against your cycle for 2-3 months and show your doctor.'
                        : 'This doesn\'t strongly suggest PMDD, but awareness is always valuable.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colours.textBright, fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
        if (high) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If you\'re having thoughts of harming yourself, please reach out now. Samaritans: 116 123 (free, 24/7)',
                    style: TextStyle(color: colours.textBright, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        ...cards.map((card) => _InfoExpandable(card: card, colours: colours)),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() {
              _step = 0;
              _yesCount = 0;
            }),
            icon: Icon(Icons.refresh_rounded, color: colours.textMuted, size: 18),
            label: Text('Take again', style: TextStyle(color: colours.textMuted)),
          ),
        ),
      ],
    );
  }
}

class _BigChoiceButton extends StatelessWidget {
  final String label;
  final Color colour;
  final VoidCallback onTap;

  const _BigChoiceButton({required this.label, required this.colour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colour.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colour.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(color: colour, fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// 6. ENDOMETRIOSIS — Pain Assessment
// ================================================================

class _PainAssessmentScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _PainAssessmentScreen({required this.topic});

  @override
  State<_PainAssessmentScreen> createState() => _PainAssessmentScreenState();
}

class _PainAssessmentScreenState extends State<_PainAssessmentScreen> {
  int _step = 0;
  final Map<int, int> _answers = {};

  static const _questions = [
    _PainQ('How severe is your period pain?', ['Mild — manageable', 'Moderate — affects my day', 'Severe — can\'t function', 'I regularly need time off']),
    _PainQ('How long does the pain last?', ['Just day 1-2', 'Throughout my period', 'Before AND during my period', 'Pain throughout the month']),
    _PainQ('Do you experience pain during or after sex?', ['No', 'Occasionally', 'Often', 'Almost always']),
    _PainQ('Do you experience any of these?', ['None of these', 'Pain when using the toilet during periods', 'Heavy bleeding or clots', 'Fatigue that doesn\'t improve with rest']),
    _PainQ('Have you ever been told your pain is "normal"?', ['No', 'Once or twice', 'Regularly', 'I\'ve stopped mentioning it']),
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final showResult = _step >= _questions.length;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: showResult ? _buildResult(colours) : _buildQuestion(colours),
      ),
    );
  }

  Widget _buildQuestion(AppColours colours) {
    final q = _questions[_step];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (_step + 1) / _questions.length,
          backgroundColor: colours.border,
          color: const Color(0xFFE879A0),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 8),
        Text('Question ${_step + 1} of ${_questions.length}',
            style: TextStyle(color: colours.textMuted, fontSize: 12)),
        const SizedBox(height: 24),
        Text(q.question,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600, height: 1.3)),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          final selected = _answers[_step] == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              UISoundService().playClick();
              setState(() => _answers[_step] = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE879A0).withOpacity(0.12) : colours.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? const Color(0xFFE879A0) : colours.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Text(q.options[i],
                  style: TextStyle(
                    color: selected ? colours.textBright : colours.textLight,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  )),
            ),
          );
        }),
        if (_answers.containsKey(_step)) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() => _step++);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE879A0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_step < _questions.length - 1 ? 'Continue' : 'See results',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        if (_step > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _step--),
              child: Text('Back', style: TextStyle(color: colours.textMuted)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResult(AppColours colours) {
    final score = _answers.values.fold(0, (sum, v) => sum + v);
    final maxScore = _questions.length * 3;
    final severity = score / maxScore;
    final resultColour = severity > 0.6
        ? const Color(0xFFE879A0)
        : severity > 0.3
            ? const Color(0xFFF59E0B)
            : const Color(0xFF34D399);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: resultColour.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: resultColour.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                severity > 0.6
                    ? 'Your responses suggest significant pain'
                    : severity > 0.3
                        ? 'Your responses suggest moderate concerns'
                        : 'Your responses suggest manageable symptoms',
                textAlign: TextAlign.center,
                style: TextStyle(color: colours.textBright, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                severity > 0.6
                    ? 'This level of pain is NOT normal. You deserve investigation. Ask your MO for a gynaecology referral and mention endometriosis specifically.'
                    : severity > 0.3
                        ? 'Some of your experiences go beyond typical period pain. Consider keeping a pain diary and discussing with your doctor.'
                        : 'Your symptoms are within a common range, but any pain that concerns you is worth mentioning to your doctor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colours.textLight, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...widget.topic.cards.map((card) => _InfoExpandable(card: card, colours: colours)),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() {
              _step = 0;
              _answers.clear();
            }),
            icon: Icon(Icons.refresh_rounded, color: colours.textMuted, size: 18),
            label: Text('Start over', style: TextStyle(color: colours.textMuted)),
          ),
        ),
      ],
    );
  }
}

class _PainQ {
  final String question;
  final List<String> options;
  const _PainQ(this.question, this.options);
}

// ================================================================
// 7. IRON & ENERGY — Quick symptom checklist with score
// ================================================================

class _IronCheckerScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _IronCheckerScreen({required this.topic});

  @override
  State<_IronCheckerScreen> createState() => _IronCheckerScreenState();
}

class _IronCheckerScreenState extends State<_IronCheckerScreen> {
  final Set<int> _checked = {};
  bool _showResults = false;

  static const _items = [
    _CheckItem('Persistent tiredness that rest doesn\'t fix', '😴'),
    _CheckItem('Breathlessness during exercise that used to be fine', '😮‍💨'),
    _CheckItem('Pale skin, lips, or inside of lower eyelids', '🪞'),
    _CheckItem('Brittle nails or hair loss', '💅'),
    _CheckItem('Feeling unusually cold', '🥶'),
    _CheckItem('Difficulty concentrating', '🧠'),
    _CheckItem('Headaches or dizziness', '💫'),
    _CheckItem('Heavy periods', '🩸'),
    _CheckItem('Craving ice or non-food items', '🧊'),
    _CheckItem('Restless legs', '🦵'),
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
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _showResults ? _buildResults(colours) : _buildChecklist(colours),
      ),
    );
  }

  Widget _buildChecklist(AppColours colours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Iron Check', style: TextStyle(color: colours.textBright, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Tick any that apply to you', style: TextStyle(color: colours.textMuted, fontSize: 14)),
        const SizedBox(height: 20),
        ...List.generate(_items.length, (i) {
          final checked = _checked.contains(i);
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              UISoundService().playClick();
              setState(() {
                if (checked) {
                  _checked.remove(i);
                } else {
                  _checked.add(i);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: checked ? const Color(0xFFF59E0B).withOpacity(0.1) : colours.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: checked ? const Color(0xFFF59E0B) : colours.border,
                  width: checked ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: checked ? const Color(0xFFF59E0B) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: checked ? const Color(0xFFF59E0B) : colours.border, width: 2),
                    ),
                    child: checked ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                  ),
                  const SizedBox(width: 12),
                  Text(_items[i].emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_items[i].label,
                        style: TextStyle(
                          color: checked ? colours.textBright : colours.textLight,
                          fontSize: 14,
                          fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _showResults = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Check results (${_checked.length} selected)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(AppColours colours) {
    final count = _checked.length;
    final resultColour = count >= 5
        ? const Color(0xFFE879A0)
        : count >= 3
            ? const Color(0xFFF59E0B)
            : const Color(0xFF34D399);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: resultColour.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: resultColour.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text('$count of ${_items.length}',
                  style: TextStyle(color: resultColour, fontSize: 36, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                count >= 5
                    ? 'Multiple signs of possible iron deficiency. Ask your doctor for a ferritin blood test — not just haemoglobin.'
                    : count >= 3
                        ? 'Some signs worth investigating. Mention these to your doctor at your next appointment.'
                        : 'Few signs currently, but stay aware — especially if you have heavy periods.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colours.textBright, fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...widget.topic.cards.map((card) => _InfoExpandable(card: card, colours: colours)),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() {
              _showResults = false;
              _checked.clear();
            }),
            icon: Icon(Icons.refresh_rounded, color: colours.textMuted, size: 18),
            label: Text('Start over', style: TextStyle(color: colours.textMuted)),
          ),
        ),
      ],
    );
  }
}

class _CheckItem {
  final String label;
  final String emoji;
  const _CheckItem(this.label, this.emoji);
}

// ================================================================
// 8. PERIODS ON OPS — Kit Builder Checklist
// ================================================================

class _KitBuilderScreen extends StatefulWidget {
  final NavigateTopic topic;
  const _KitBuilderScreen({required this.topic});

  @override
  State<_KitBuilderScreen> createState() => _KitBuilderScreenState();
}

class _KitBuilderScreenState extends State<_KitBuilderScreen> {
  final Set<String> _packed = {};
  late Box _box;
  bool _loaded = false;

  static const _kitCategories = [
    _KitCategory('Essentials', '🎒', [
      'Menstrual cup',
      'Spare pads / tampons',
      'Period pants (backup)',
      'Disposal bags (opaque, sealable)',
      'Baby wipes',
      'Hand sanitiser',
    ]),
    _KitCategory('Comfort', '💊', [
      'Ibuprofen / paracetamol',
      'Heat patches (stick-on)',
      'Dark-coloured underwear',
      'Spare knickers in grab bag',
    ]),
    _KitCategory('Extras', '🛡️', [
      'Imodium (for bowel changes)',
      'Zip-lock bags for storage',
      'Small towel',
      'Electrolyte sachets',
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _box = await Hive.openBox('kit_builder');
    final saved = _box.get('packed_items', defaultValue: <String>[]);
    _packed.addAll(List<String>.from(saved as List));
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    await _box.put('packed_items', _packed.toList());
  }

  int get _totalItems => _kitCategories.fold(0, (sum, c) => sum + c.items.length);

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    if (!_loaded) {
      return Scaffold(
        backgroundColor: colours.background,
        body: Center(child: CircularProgressIndicator(color: colours.accent)),
      );
    }

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Field Kit Builder',
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colours.border.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kit packed', style: TextStyle(color: colours.textBright, fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('${_packed.length} / $_totalItems',
                          style: TextStyle(color: const Color(0xFF34D399), fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _totalItems > 0 ? _packed.length / _totalItems : 0,
                      backgroundColor: colours.border,
                      color: const Color(0xFF34D399),
                      minHeight: 8,
                    ),
                  ),
                  if (_packed.length == _totalItems) ...[
                    const SizedBox(height: 10),
                    const Text('Kit complete — you\'re ready! 💪',
                        style: TextStyle(color: Color(0xFF34D399), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            ..._kitCategories.map((cat) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(cat.title,
                            style: TextStyle(color: colours.textBright, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...cat.items.map((item) {
                      final packed = _packed.contains(item);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          UISoundService().playClick();
                          setState(() {
                            if (packed) {
                              _packed.remove(item);
                            } else {
                              _packed.add(item);
                            }
                          });
                          _save();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: packed ? const Color(0xFF34D399).withOpacity(0.1) : colours.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: packed ? const Color(0xFF34D399) : colours.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: packed ? const Color(0xFF34D399) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: packed ? const Color(0xFF34D399) : colours.border, width: 2),
                                ),
                                child: packed ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(item,
                                    style: TextStyle(
                                      color: packed ? colours.textBright : colours.textLight,
                                      fontSize: 14,
                                      fontWeight: packed ? FontWeight.w600 : FontWeight.w400,
                                      decoration: packed ? TextDecoration.lineThrough : null,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                )),

            // Tips from content
            const SizedBox(height: 8),
            ...widget.topic.cards.map((card) => _InfoExpandable(card: card, colours: colours)),

            if (_packed.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _packed.clear());
                    _save();
                  },
                  icon: Icon(Icons.refresh_rounded, color: colours.textMuted, size: 18),
                  label: Text('Reset kit', style: TextStyle(color: colours.textMuted)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KitCategory {
  final String title;
  final String emoji;
  final List<String> items;
  const _KitCategory(this.title, this.emoji, this.items);
}

// ================================================================
// SHARED WIDGETS
// ================================================================

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final bool trailing;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.trailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Row(
          children: [
            if (!trailing) Icon(icon, color: colours.textMuted, size: 18),
            if (!trailing) const SizedBox(width: 4),
            Text(label, style: TextStyle(color: colours.textMuted, fontSize: 14)),
            if (trailing) const SizedBox(width: 4),
            if (trailing) Icon(icon, color: colours.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _InfoExpandable extends StatefulWidget {
  final GuidanceCard card;
  final AppColours colours;
  const _InfoExpandable({required this.card, required this.colours});

  @override
  State<_InfoExpandable> createState() => _InfoExpandableState();
}

class _InfoExpandableState extends State<_InfoExpandable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.colours.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.colours.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.card.title,
                      style: TextStyle(color: widget.colours.textBright, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.chevron_right_rounded, color: widget.colours.textMuted, size: 20),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(widget.card.content,
                  style: TextStyle(color: widget.colours.textLight, fontSize: 14, height: 1.6)),
              if (widget.card.actionSteps != null && widget.card.actionSteps!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...widget.card.actionSteps!.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: widget.colours.accent, size: 14),
                          const SizedBox(width: 6),
                          Expanded(child: Text(s, style: TextStyle(color: widget.colours.textLight, fontSize: 13, height: 1.4))),
                        ],
                      ),
                    )),
              ],
              if (widget.card.affirmation != null) ...[
                const SizedBox(height: 12),
                Text(widget.card.affirmation!,
                    style: const TextStyle(color: Color(0xFFE879A0), fontSize: 13, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================
// FALLBACK — for any unrecognised topic
// ================================================================

class _FallbackScreen extends StatelessWidget {
  final NavigateTopic topic;
  const _FallbackScreen({required this.topic});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(topic.title,
            style: TextStyle(color: colours.textBright, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...topic.cards.map((card) => _InfoExpandable(card: card, colours: colours)),
          ],
        ),
      ),
    );
  }
}
