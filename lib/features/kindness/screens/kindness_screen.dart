import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

class KindnessScreen extends StatefulWidget {
  const KindnessScreen({super.key});

  @override
  State<KindnessScreen> createState() => _KindnessScreenState();
}

class _KindnessScreenState extends State<KindnessScreen>
    with TickerProviderStateMixin, TeaseMixin {
  int _currentTab = 0;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Learning to be Kind');

  // ── Flip the Story data ──
  static const List<Map<String, String>> _stories = [
    {
      'judgement': 'That car is driving so slowly… how annoying.',
      'reality': 'They have a newborn baby sleeping in the back seat.',
      'emoji': '🚗',
    },
    {
      'judgement': 'That woman keeps staring at me… what\'s her problem?',
      'reality': 'She just lost her child and you remind her of them.',
      'emoji': '👩',
    },
    {
      'judgement': 'She gets around… everyone talks about her.',
      'reality': 'She has no other way of feeling loved or valued.',
      'emoji': '💔',
    },
    {
      'judgement': '"It was only a joke" — why are they so sensitive?',
      'reality': 'That "joke" just ruined their entire week.',
      'emoji': '😶',
    },
    {
      'judgement': 'He never comes out anymore. What a loner.',
      'reality': 'He\'s caring for a parent with dementia every night.',
      'emoji': '🏠',
    },
    {
      'judgement': 'They\'re always late. So disrespectful.',
      'reality': 'They\'re working two jobs and barely sleeping.',
      'emoji': '⏰',
    },
    {
      'judgement': 'Why is that person crying in public? So embarrassing.',
      'reality': 'They just got a call that their best friend passed away.',
      'emoji': '😢',
    },
    {
      'judgement': 'That soldier is so quiet. Probably thinks he\'s better than us.',
      'reality': 'He\'s processing something he can\'t talk about yet.',
      'emoji': '🪖',
    },
    {
      'judgement': 'She never smiles. Miserable person.',
      'reality': 'She smiles at home, where her kids make her feel safe.',
      'emoji': '🙂',
    },
    {
      'judgement': 'He eats lunch alone every day. Weird.',
      'reality': 'It\'s the only peace he gets between two difficult shifts.',
      'emoji': '🍽️',
    },
    {
      'judgement': 'They snapped at me for no reason.',
      'reality': 'They just found out their partner is leaving them.',
      'emoji': '💬',
    },
    {
      'judgement': 'They\'re always on their phone. So rude.',
      'reality': 'They\'re checking on a sick family member back home.',
      'emoji': '📱',
    },
  ];

  // ── React or Reflect data ──
  static const List<Map<String, dynamic>> _quizScenarios = [
    {
      'scenario': 'A colleague bumps into you in the corridor and doesn\'t apologise.',
      'reactions': [
        'Rude. No manners.',
        'They probably didn\'t notice.',
        'They must be in a rush.',
      ],
      'reveal':
          'They just got called into a meeting about potential redundancies and their mind was racing.',
      'bestIndex': 2,
    },
    {
      'scenario':
          'Someone in your unit hasn\'t volunteered for anything in weeks.',
      'reactions': [
        'Lazy. Doesn\'t care about the team.',
        'Maybe they\'re going through something.',
        'Not my problem.',
      ],
      'reveal':
          'They\'ve been struggling with sleep and anxiety but are afraid to speak up.',
      'bestIndex': 1,
    },
    {
      'scenario': 'A friend cancels plans at the last minute — again.',
      'reactions': [
        'They clearly don\'t value my time.',
        'Something might be wrong.',
        'I\'m done making plans with them.',
      ],
      'reveal':
          'They had a panic attack in the car park and couldn\'t bring themselves to leave.',
      'bestIndex': 1,
    },
    {
      'scenario': 'Your neighbour plays music late at night.',
      'reactions': [
        'So inconsiderate. I\'ll complain tomorrow.',
        'Maybe they don\'t realise how loud it is.',
        'They\'re probably trying to drown out something.',
      ],
      'reveal':
          'They were alone on the anniversary of losing someone and the silence was unbearable.',
      'bestIndex': 2,
    },
    {
      'scenario':
          'Someone at the gym keeps hogging the equipment and won\'t let anyone work in.',
      'reactions': [
        'Selfish. No gym etiquette.',
        'They might not know the norm.',
        'They could be pushing through something personal.',
      ],
      'reveal':
          'It\'s the one hour a day they feel in control. Everything else is falling apart.',
      'bestIndex': 2,
    },
    {
      'scenario':
          'A young recruit keeps asking the same questions over and over.',
      'reactions': [
        'They should have listened the first time.',
        'They\'re probably nervous and want to get it right.',
        'Not my job to teach them.',
      ],
      'reveal':
          'They grew up in care and never had anyone patient enough to teach them things twice.',
      'bestIndex': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(context),
            Expanded(
              child: _currentTab == 0
                  ? _FlipTheStoryTab(
                      stories: _stories,
                      onFlip: () {
                        recordTeaseAction();
                        return checkTeaseAndContinue();
                      },
                    )
                  : _ReactOrReflectTab(
                      scenarios: _quizScenarios,
                      onAnswer: () {
                        recordTeaseAction();
                        return checkTeaseAndContinue();
                      },
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
              'Learning to be Kind',
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
    final tabs = ['Flip the Story', 'React or Reflect'];

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
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: EdgeInsets.only(right: i == 0 ? 6 : 0, left: i == 1 ? 6 : 0),
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
                    fontSize: 14,
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
// Flip the Story Tab
// ═══════════════════════════════════════════════════════════════════

class _FlipTheStoryTab extends StatefulWidget {
  final List<Map<String, String>> stories;
  final bool Function() onFlip;

  const _FlipTheStoryTab({required this.stories, required this.onFlip});

  @override
  State<_FlipTheStoryTab> createState() => _FlipTheStoryTabState();
}

class _FlipTheStoryTabState extends State<_FlipTheStoryTab> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final story = widget.stories[_currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Tap the card to flip and see the truth',
            style: TextStyle(color: colours.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentIndex + 1} of ${widget.stories.length}',
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _FlipCard(
              key: ValueKey(_currentIndex),
              emoji: story['emoji']!,
              judgement: story['judgement']!,
              reality: story['reality']!,
              onFlip: widget.onFlip,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.arrow_back_rounded,
                label: 'Previous',
                enabled: _currentIndex > 0,
                onTap: () => setState(() => _currentIndex--),
              ),
              _NavButton(
                icon: Icons.arrow_forward_rounded,
                label: 'Next',
                enabled: _currentIndex < widget.stories.length - 1,
                onTap: () => setState(() => _currentIndex++),
                trailing: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  final String emoji;
  final String judgement;
  final String reality;
  final bool Function() onFlip;

  const _FlipCard({
    super.key,
    required this.emoji,
    required this.judgement,
    required this.reality,
    required this.onFlip,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFront) {
      if (!widget.onFlip()) return;
    }
    HapticFeedback.mediumImpact();
    UISoundService().playClick();
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isBack = _animation.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(colours),
                  )
                : _buildFront(colours),
          );
        },
      ),
    );
  }

  Widget _buildFront(AppColours colours) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colours.card,
            colours.cardLight,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colours.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 24),
          Text(
            'SNAP JUDGEMENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${widget.judgement}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: colours.textBright,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded,
                  color: colours.textMuted.withOpacity(0.5), size: 18),
              const SizedBox(width: 6),
              Text(
                'Tap to flip',
                style: TextStyle(
                  color: colours.textMuted.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack(AppColours colours) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00B894).withOpacity(0.15),
            colours.card,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00B894).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B894).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_rounded,
              color: Color(0xFF00B894), size: 48),
          const SizedBox(height: 24),
          Text(
            'THE REALITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: const Color(0xFF00B894),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.reality,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colours.textBright,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 32),
          Text(
            'Everyone has a story you can\'t see.',
            style: TextStyle(
              color: colours.textMuted,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// React or Reflect Tab
// ═══════════════════════════════════════════════════════════════════

class _ReactOrReflectTab extends StatefulWidget {
  final List<Map<String, dynamic>> scenarios;
  final bool Function() onAnswer;

  const _ReactOrReflectTab({required this.scenarios, required this.onAnswer});

  @override
  State<_ReactOrReflectTab> createState() => _ReactOrReflectTabState();
}

class _ReactOrReflectTabState extends State<_ReactOrReflectTab> {
  int _currentIndex = 0;
  int? _selectedReaction;
  bool _revealed = false;
  int _empathyScore = 0;
  int _totalAnswered = 0;

  void _selectReaction(int index) {
    if (_revealed) return;
    if (!widget.onAnswer()) return;

    HapticFeedback.mediumImpact();
    UISoundService().playClick();
    final scenario = widget.scenarios[_currentIndex];
    final bestIndex = scenario['bestIndex'] as int;

    setState(() {
      _selectedReaction = index;
      _revealed = true;
      _totalAnswered++;
      if (index == bestIndex) _empathyScore++;
    });
  }

  void _next() {
    if (_currentIndex < widget.scenarios.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex++;
        _selectedReaction = null;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final scenario = widget.scenarios[_currentIndex];
    final reactions = scenario['reactions'] as List<String>;
    final bestIndex = scenario['bestIndex'] as int;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Empathy score
          if (_totalAnswered > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Empathy Score: $_empathyScore / $_totalAnswered',
                style: const TextStyle(
                  color: Color(0xFF00B894),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            '${_currentIndex + 1} of ${widget.scenarios.length}',
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Scenario card
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
                  'SITUATION',
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
            _revealed ? 'The reality:' : 'What\'s your gut reaction?',
            style: TextStyle(
              color: colours.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Reaction chips
          ...List.generate(reactions.length, (i) {
            final isSelected = _selectedReaction == i;
            final isBest = i == bestIndex;
            Color chipColor;
            Color borderColor;

            if (!_revealed) {
              chipColor = colours.cardLight;
              borderColor = colours.border.withOpacity(0.3);
            } else if (isSelected && isBest) {
              chipColor = const Color(0xFF00B894).withOpacity(0.15);
              borderColor = const Color(0xFF00B894).withOpacity(0.5);
            } else if (isSelected && !isBest) {
              chipColor = Colors.orange.withOpacity(0.1);
              borderColor = Colors.orange.withOpacity(0.4);
            } else if (isBest) {
              chipColor = const Color(0xFF00B894).withOpacity(0.08);
              borderColor = const Color(0xFF00B894).withOpacity(0.3);
            } else {
              chipColor = colours.cardLight.withOpacity(0.5);
              borderColor = colours.border.withOpacity(0.2);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _selectReaction(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          reactions[i],
                          style: TextStyle(
                            color: colours.textBright,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (_revealed && isBest)
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF00B894), size: 20),
                      if (_revealed && isSelected && !isBest)
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.orange, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Reveal
          if (_revealed) ...[
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF00B894).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.visibility_rounded,
                      color: Color(0xFF00B894), size: 22),
                  const SizedBox(height: 8),
                  Text(
                    scenario['reveal'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colours.textBright,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_currentIndex < widget.scenarios.length - 1)
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Nav Button helper
// ═══════════════════════════════════════════════════════════════════

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailing;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: Row(
          children: [
            if (!trailing) Icon(icon, color: colours.accent, size: 20),
            if (!trailing) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  color: colours.accent, fontWeight: FontWeight.w500),
            ),
            if (trailing) const SizedBox(width: 6),
            if (trailing) Icon(icon, color: colours.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
