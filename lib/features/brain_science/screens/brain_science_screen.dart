import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

class BrainScienceScreen extends StatefulWidget {
  const BrainScienceScreen({super.key});

  @override
  State<BrainScienceScreen> createState() => _BrainScienceScreenState();
}

class _BrainScienceScreenState extends State<BrainScienceScreen>
    with TickerProviderStateMixin, TeaseMixin {
  int _currentTab = 0;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Brain Science');

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
                  _MythBusterTab(onAnswer: () {
                    recordTeaseAction();
                    return checkTeaseAndContinue();
                  }),
                  _BiasSpotterTab(onAnswer: () {
                    recordTeaseAction();
                    return checkTeaseAndContinue();
                  }),
                  _ExperimentsTab(onProgress: () {
                    recordTeaseAction();
                    return checkTeaseAndContinue();
                  }),
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
      child: Row(children: [
        GestureDetector(
            onTap: () => Navigator.pop(context),
            child:
                Icon(Icons.arrow_back_rounded, color: colours.textBright)),
        const SizedBox(width: 12),
        Expanded(
            child: Text('Brain Science',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colours = context.colours;
    final tabs = ['Myth Buster', 'Bias Spotter', 'Experiments'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = _currentTab == i;
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
                    right: i < 2 ? 4 : 0, left: i > 0 ? 4 : 0),
                decoration: BoxDecoration(
                  color: sel
                      ? colours.accent.withOpacity(0.15)
                      : colours.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel
                          ? colours.accent.withOpacity(0.4)
                          : colours.border.withOpacity(0.3)),
                ),
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? colours.accent : colours.textMuted,
                        fontSize: 12)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 1 — Myth Buster
// ═══════════════════════════════════════════════════════════════════

class _MythBusterTab extends StatefulWidget {
  final bool Function() onAnswer;
  const _MythBusterTab({required this.onAnswer});

  @override
  State<_MythBusterTab> createState() => _MythBusterTabState();
}

class _MythBusterTabState extends State<_MythBusterTab> {
  int _current = 0;
  bool? _answered;
  int _score = 0;
  int _total = 0;

  static const List<Map<String, dynamic>> _myths = [
    {'statement': 'We only use 10% of our brain.', 'answer': false, 'explanation': 'Brain scans show activity across the entire brain, even during sleep. Every region has a known function.'},
    {'statement': 'People are either left-brained or right-brained.', 'answer': false, 'explanation': 'Both hemispheres work together for virtually all tasks. The idea of dominant sides is a myth.'},
    {'statement': 'Stress can physically shrink your brain.', 'answer': true, 'explanation': 'Chronic stress releases cortisol which can reduce the size of the prefrontal cortex and hippocampus.'},
    {'statement': 'Your brain uses 20% of your body\'s energy.', 'answer': true, 'explanation': 'Despite being only 2% of body weight, the brain consumes roughly 20% of your oxygen and calories.'},
    {'statement': 'Memories are stored in a single location in the brain.', 'answer': false, 'explanation': 'Memories are distributed across networks of neurons. Different aspects (visual, emotional, factual) are stored in different regions.'},
    {'statement': 'Sleep deprivation can cause hallucinations.', 'answer': true, 'explanation': 'After 48-72 hours without sleep, many people experience visual and auditory hallucinations as the brain struggles to function.'},
    {'statement': 'Adults cannot grow new brain cells.', 'answer': false, 'explanation': 'Neurogenesis — the growth of new neurons — continues in the hippocampus throughout adulthood, especially with exercise.'},
    {'statement': 'Listening to Mozart makes you smarter.', 'answer': false, 'explanation': 'The "Mozart Effect" was based on a small, unreplicated study. Music can improve mood and focus, but doesn\'t increase IQ.'},
    {'statement': 'Exercise is as effective as medication for mild depression.', 'answer': true, 'explanation': 'Multiple studies show regular exercise can be as effective as antidepressants for mild to moderate depression.'},
    {'statement': 'Your brain processes rejection like physical pain.', 'answer': true, 'explanation': 'fMRI studies show social rejection activates the same brain regions (anterior insula, anterior cingulate cortex) as physical pain.'},
  ];

  void _answer(bool val) {
    if (_answered != null) return;
    if (!widget.onAnswer()) return;
    HapticFeedback.mediumImpact();
    final correct = _myths[_current]['answer'] as bool;
    setState(() {
      _answered = val;
      _total++;
      if (val == correct) _score++;
    });
  }

  void _next() {
    if (_current < _myths.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _current++;
        _answered = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final myth = _myths[_current];
    final correctAnswer = myth['answer'] as bool;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        const SizedBox(height: 8),
        if (_total > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Score: $_score / $_total',
                style: const TextStyle(
                    color: Color(0xFF00B894),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        const SizedBox(height: 4),
        Text('${_current + 1} of ${_myths.length}',
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colours.border.withOpacity(0.3)),
          ),
          child: Column(children: [
            const Icon(Icons.psychology_rounded,
                size: 36, color: Color(0xFF6C5CE7)),
            const SizedBox(height: 16),
            Text('"${myth['statement']}"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colours.textBright,
                    fontStyle: FontStyle.italic,
                    height: 1.4)),
          ]),
        ),
        const SizedBox(height: 20),
        if (_answered == null)
          Row(children: [
            Expanded(
              child: _BigButton(
                  label: 'TRUE',
                  color: const Color(0xFF00B894),
                  onTap: () => _answer(true)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigButton(
                  label: 'FALSE',
                  color: Colors.red.shade400,
                  onTap: () => _answer(false)),
            ),
          ])
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_answered == correctAnswer)
                  ? const Color(0xFF00B894).withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: (_answered == correctAnswer)
                      ? const Color(0xFF00B894).withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3)),
            ),
            child: Column(children: [
              Text(
                  _answered == correctAnswer
                      ? 'Correct!'
                      : 'Not quite — the answer is ${correctAnswer ? "TRUE" : "FALSE"}',
                  style: TextStyle(
                      color: _answered == correctAnswer
                          ? const Color(0xFF00B894)
                          : Colors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 10),
              Text(myth['explanation'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colours.textBright, height: 1.4, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 16),
          if (_current < _myths.length - 1)
            GestureDetector(
              onTap: _next,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('Next Question',
                    style: TextStyle(
                        color: colours.accent, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BigButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 2 — Bias Spotter
// ═══════════════════════════════════════════════════════════════════

class _BiasSpotterTab extends StatefulWidget {
  final bool Function() onAnswer;
  const _BiasSpotterTab({required this.onAnswer});

  @override
  State<_BiasSpotterTab> createState() => _BiasSpotterTabState();
}

class _BiasSpotterTabState extends State<_BiasSpotterTab> {
  int _current = 0;
  int? _selected;
  bool _revealed = false;
  int _score = 0;
  int _total = 0;

  static const List<Map<String, dynamic>> _scenarios = [
    {'scenario': 'You bought something because it was "50% off" even though you didn\'t need it.', 'answer': 0, 'options': ['Anchoring Bias', 'Sunk Cost Fallacy', 'Bandwagon Effect', 'Confirmation Bias'], 'explanation': 'Anchoring Bias — the original price "anchored" your perception of value, making the discount feel like a deal.'},
    {'scenario': 'You keep watching a terrible film because you already paid for the ticket.', 'answer': 1, 'options': ['Negativity Bias', 'Sunk Cost Fallacy', 'Halo Effect', 'Hindsight Bias'], 'explanation': 'Sunk Cost Fallacy — you\'re factoring in money already spent (which you can\'t recover) instead of judging the present value.'},
    {'scenario': 'You remember the one negative comment from your annual review but forget 20 positive ones.', 'answer': 0, 'options': ['Negativity Bias', 'Confirmation Bias', 'Anchoring Bias', 'Frequency Illusion'], 'explanation': 'Negativity Bias — our brains are wired to give more weight to negative experiences than positive ones for survival reasons.'},
    {'scenario': 'Everyone at work is doing a sponsored run, so you sign up too even though you hate running.', 'answer': 2, 'options': ['Halo Effect', 'Hindsight Bias', 'Bandwagon Effect', 'Sunk Cost Fallacy'], 'explanation': 'Bandwagon Effect — the tendency to do something primarily because others are doing it, regardless of your own beliefs.'},
    {'scenario': 'After a football match, you say "I knew they\'d win" even though you were unsure beforehand.', 'answer': 1, 'options': ['Confirmation Bias', 'Hindsight Bias', 'Negativity Bias', 'Anchoring Bias'], 'explanation': 'Hindsight Bias — the tendency to believe, after an event, that you predicted or expected the outcome all along.'},
    {'scenario': 'After buying a red car, you suddenly notice red cars everywhere on the road.', 'answer': 2, 'options': ['Confirmation Bias', 'Bandwagon Effect', 'Frequency Illusion', 'Halo Effect'], 'explanation': 'Frequency Illusion (Baader-Meinhof Phenomenon) — once something is on your radar, you notice it far more often.'},
    {'scenario': 'You trust a colleague\'s financial advice more because they\'re good-looking.', 'answer': 3, 'options': ['Bandwagon Effect', 'Anchoring Bias', 'Confirmation Bias', 'Halo Effect'], 'explanation': 'Halo Effect — the tendency to let one positive trait (attractiveness) influence your judgement of their other qualities.'},
    {'scenario': 'You only read news articles that agree with your political views.', 'answer': 2, 'options': ['Negativity Bias', 'Hindsight Bias', 'Confirmation Bias', 'Frequency Illusion'], 'explanation': 'Confirmation Bias — the tendency to search for, interpret, and recall information that confirms your pre-existing beliefs.'},
  ];

  void _select(int i) {
    if (_revealed) return;
    if (!widget.onAnswer()) return;
    HapticFeedback.mediumImpact();
    final correct = _scenarios[_current]['answer'] as int;
    setState(() {
      _selected = i;
      _revealed = true;
      _total++;
      if (i == correct) _score++;
    });
  }

  void _next() {
    if (_current < _scenarios.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _current++;
        _selected = null;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final s = _scenarios[_current];
    final correct = s['answer'] as int;
    final options = s['options'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        const SizedBox(height: 8),
        if (_total > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFF00B894).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Score: $_score / $_total',
                style: const TextStyle(
                    color: Color(0xFF00B894),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        const SizedBox(height: 4),
        Text('${_current + 1} of ${_scenarios.length}',
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colours.border.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text('SPOT THE BIAS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: const Color(0xFF6C5CE7))),
            const SizedBox(height: 12),
            Text(s['scenario'] as String,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colours.textBright,
                    height: 1.4)),
          ]),
        ),
        const SizedBox(height: 16),
        ...List.generate(options.length, (i) {
          final isSel = _selected == i;
          final isCorrect = i == correct;
          Color bg, border;
          if (!_revealed) {
            bg = colours.cardLight;
            border = colours.border.withOpacity(0.3);
          } else if (isSel && isCorrect) {
            bg = const Color(0xFF00B894).withOpacity(0.15);
            border = const Color(0xFF00B894).withOpacity(0.5);
          } else if (isSel) {
            bg = Colors.red.withOpacity(0.1);
            border = Colors.red.withOpacity(0.4);
          } else if (isCorrect) {
            bg = const Color(0xFF00B894).withOpacity(0.08);
            border = const Color(0xFF00B894).withOpacity(0.3);
          } else {
            bg = colours.cardLight.withOpacity(0.5);
            border = colours.border.withOpacity(0.15);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _select(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border)),
                child: Row(children: [
                  Expanded(
                      child: Text(options[i],
                          style: TextStyle(
                              color: colours.textBright,
                              fontWeight: isSel
                                  ? FontWeight.w600
                                  : FontWeight.w400))),
                  if (_revealed && isCorrect)
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF00B894), size: 20),
                ]),
              ),
            ),
          );
        }),
        if (_revealed) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
            ),
            child: Text(s['explanation'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colours.textBright,
                    fontWeight: FontWeight.w500,
                    height: 1.4)),
          ),
          const SizedBox(height: 12),
          if (_current < _scenarios.length - 1)
            GestureDetector(
              onTap: _next,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('Next Scenario',
                    style: TextStyle(
                        color: colours.accent, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 3 — Famous Experiments
// ═══════════════════════════════════════════════════════════════════

class _ExperimentsTab extends StatefulWidget {
  final bool Function() onProgress;
  const _ExperimentsTab({required this.onProgress});

  @override
  State<_ExperimentsTab> createState() => _ExperimentsTabState();
}

class _ExperimentsTabState extends State<_ExperimentsTab> {
  int _expIndex = 0;
  int _step = 0;
  int? _choice;

  static const List<Map<String, dynamic>> _experiments = [
    {
      'title': 'The Milgram Experiment',
      'year': '1961',
      'researcher': 'Stanley Milgram',
      'steps': [
        {'text': 'You\'re told by a scientist in a lab coat to administer electric shocks to a stranger in another room every time they answer a question wrong. The shocks increase in voltage.', 'type': 'info'},
        {'text': 'The stranger screams in pain and begs you to stop. The scientist calmly says "Please continue, the experiment requires it." What do you do?', 'type': 'choice', 'options': ['I would refuse to continue', 'I would keep going if told to']},
        {'text': '65% of participants delivered the maximum 450-volt shock — enough to kill. Most people obey authority figures even when it conflicts with their conscience. The stranger was an actor and no real shocks were given.', 'type': 'reveal'},
      ],
    },
    {
      'title': 'Stanford Prison Experiment',
      'year': '1971',
      'researcher': 'Philip Zimbardo',
      'steps': [
        {'text': 'College students are randomly assigned to be either guards or prisoners in a mock prison. It\'s meant to last two weeks.', 'type': 'info'},
        {'text': 'Within days, "guards" become cruel and authoritarian, and "prisoners" become passive and distressed. If you were assigned as a guard, what do you think you would do?', 'type': 'choice', 'options': ['I\'d stay fair and kind', 'I might get caught up in the role']},
        {'text': 'The experiment was stopped after just 6 days because the abuse became so severe. It showed how quickly ordinary people adopt roles of power and how situations shape behaviour more than personality.', 'type': 'reveal'},
      ],
    },
    {
      'title': 'The Marshmallow Test',
      'year': '1972',
      'researcher': 'Walter Mischel',
      'steps': [
        {'text': 'A child is placed in a room with a single marshmallow. They\'re told: "You can eat it now, or if you wait 15 minutes, you\'ll get two marshmallows."', 'type': 'info'},
        {'text': 'Imagine you\'re that child. What would you do?', 'type': 'choice', 'options': ['Eat it immediately', 'Wait for two']},
        {'text': 'About one-third of children waited the full 15 minutes. Follow-up studies found those who waited tended to have better life outcomes — higher test scores, lower substance abuse, better stress management. Delayed gratification is a powerful predictor of success.', 'type': 'reveal'},
      ],
    },
    {
      'title': 'Bystander Effect',
      'year': '1968',
      'researcher': 'Darley & Latané',
      'steps': [
        {'text': 'Inspired by the Kitty Genovese case, researchers tested whether people help in emergencies. A participant hears someone having a seizure over an intercom.', 'type': 'info'},
        {'text': 'You hear someone choking and calling for help. You believe others can hear too. Do you act immediately?', 'type': 'choice', 'options': ['Yes, I\'d help right away', 'I\'d probably wait for someone else']},
        {'text': 'When people believed they were the only listener, 85% helped. When they thought 4 others were listening, only 31% helped. The more people present, the less likely any individual is to act. This is called "diffusion of responsibility."', 'type': 'reveal'},
      ],
    },
    {
      'title': 'Asch Conformity',
      'year': '1951',
      'researcher': 'Solomon Asch',
      'steps': [
        {'text': 'You\'re in a room with 7 others (all secretly actors). You\'re shown a line and asked which of three comparison lines matches it. The answer is obvious.', 'type': 'info'},
        {'text': 'Every other person in the room gives the same clearly wrong answer. It\'s now your turn. What do you do?', 'type': 'choice', 'options': ['Give the correct answer', 'Go with the group\'s wrong answer']},
        {'text': '75% of participants conformed at least once, giving a clearly wrong answer just to match the group. On average, people conformed on 1 in 3 trials. We are far more influenced by social pressure than we like to believe.', 'type': 'reveal'},
      ],
    },
  ];

  void _advance() {
    final exp = _experiments[_expIndex];
    final steps = exp['steps'] as List<Map<String, dynamic>>;
    if (_step < steps.length - 1) {
      if (_step > 0 && !widget.onProgress()) return;
      HapticFeedback.lightImpact();
      setState(() {
        _step++;
        _choice = null;
      });
    }
  }

  void _nextExperiment() {
    if (_expIndex < _experiments.length - 1) {
      HapticFeedback.mediumImpact();
      setState(() {
        _expIndex++;
        _step = 0;
        _choice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final exp = _experiments[_expIndex];
    final steps = exp['steps'] as List<Map<String, dynamic>>;
    final currentStep = steps[_step];
    final stepType = currentStep['type'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        const SizedBox(height: 12),
        Text('${_expIndex + 1} of ${_experiments.length}',
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colours.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colours.accent.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text(exp['title'] as String,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700, color: colours.textBright)),
            const SizedBox(height: 4),
            Text('${exp['researcher']}, ${exp['year']}',
                style: TextStyle(color: colours.textMuted, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              steps.length,
              (i) => Container(
                    width: i == _step ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? colours.accent
                          : colours.border.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: stepType == 'reveal'
                ? const Color(0xFF00B894).withOpacity(0.08)
                : colours.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: stepType == 'reveal'
                    ? const Color(0xFF00B894).withOpacity(0.3)
                    : colours.border.withOpacity(0.3)),
          ),
          child: Column(children: [
            if (stepType == 'reveal')
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Icon(Icons.visibility_rounded,
                    color: Color(0xFF00B894), size: 28),
              ),
            Text(currentStep['text'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colours.textBright,
                    height: 1.5,
                    fontSize: 15,
                    fontWeight: stepType == 'reveal'
                        ? FontWeight.w500
                        : FontWeight.w400)),
          ]),
        ),
        const SizedBox(height: 16),
        if (stepType == 'choice') ...[
          ...(currentStep['options'] as List<String>)
              .asMap()
              .entries
              .map((e) {
            final sel = _choice == e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _choice = e.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: sel
                        ? colours.accent.withOpacity(0.15)
                        : colours.cardLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel
                            ? colours.accent.withOpacity(0.4)
                            : colours.border.withOpacity(0.3)),
                  ),
                  child: Text(e.value,
                      style: TextStyle(
                          color: colours.textBright,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.w400)),
                ),
              ),
            );
          }),
          if (_choice != null)
            GestureDetector(
              onTap: _advance,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text('See What Happened',
                    style: TextStyle(
                        color: colours.accent, fontWeight: FontWeight.w600)),
              ),
            ),
        ] else if (stepType == 'info')
          GestureDetector(
            onTap: _advance,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('Continue',
                  style: TextStyle(
                      color: colours.accent, fontWeight: FontWeight.w600)),
            ),
          )
        else if (stepType == 'reveal' &&
            _expIndex < _experiments.length - 1)
          GestureDetector(
            onTap: _nextExperiment,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('Next Experiment',
                  style: TextStyle(
                      color: colours.accent, fontWeight: FontWeight.w600)),
            ),
          ),
        const SizedBox(height: 32),
      ]),
    );
  }
}
