import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Body Education — interactive, age-appropriate puberty & body education
///
/// ZERO free-text input. All tap-based. Nothing stored or transmitted.
/// Covers both male and female body changes during puberty.
class BodyEducationScreen extends StatefulWidget {
  const BodyEducationScreen({super.key});

  @override
  State<BodyEducationScreen> createState() => _BodyEducationScreenState();
}

class _BodyEducationScreenState extends State<BodyEducationScreen>
    with TickerProviderStateMixin, TeaseMixin {
  late TabController _tabController;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Body Education');

  // Myth or Fact quiz state
  int _quizIndex = 0;
  int _quizScore = 0;
  bool _quizAnswered = false;
  bool? _lastAnswerCorrect;

  bool _gateExpand() {
    recordTeaseAction();
    return checkTeaseAndContinue();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Body',
          style: TextStyle(
            color: colours.textBright,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF60A5FA),
          labelColor: colours.textBright,
          unselectedLabelColor: colours.textMuted,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Female Body'),
            Tab(text: 'Male Body'),
            Tab(text: 'Myth or Fact?'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Age-appropriate banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1A1A2E),
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: colours.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Educational content. Understanding your body is an important part of growing up.',
                    style: TextStyle(color: colours.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFemaleTab(colours),
                _buildMaleTab(colours),
                _buildQuizTab(colours),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: FEMALE BODY
  // ============================================================

  Widget _buildFemaleTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildIntroCard(
            colours,
            'Understanding the Female Body',
            'Your body goes through many changes during puberty — usually between ages 8 and 16. Every person develops at their own pace. There is no "normal" timeline.',
            const Color(0xFFE879A0),
            Icons.favorite_rounded,
          ),
          const SizedBox(height: 16),
          ..._femaleTopics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExpandableEducationCard(
                  colours: colours,
                  topic: t,
                  onExpandCheck: _gateExpand,
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: MALE BODY
  // ============================================================

  Widget _buildMaleTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildIntroCard(
            colours,
            'Understanding the Male Body',
            'Puberty for boys usually starts between ages 9 and 14. Changes happen gradually and everyone develops differently. There\'s no rush.',
            const Color(0xFF60A5FA),
            Icons.favorite_rounded,
          ),
          const SizedBox(height: 16),
          ..._maleTopics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExpandableEducationCard(
                  colours: colours,
                  topic: t,
                  onExpandCheck: _gateExpand,
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 3: MYTH OR FACT QUIZ
  // ============================================================

  Widget _buildQuizTab(AppColours colours) {
    if (_quizIndex >= _mythFactQuestions.length) {
      return _buildQuizResults(colours);
    }

    final question = _mythFactQuestions[_quizIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_quizIndex + 1} of ${_mythFactQuestions.length}',
                      style: TextStyle(
                        color: colours.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colours.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Score: $_quizScore',
                        style: TextStyle(
                          color: colours.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_quizIndex + 1) / _mythFactQuestions.length,
                    backgroundColor: colours.border,
                    valueColor: AlwaysStoppedAnimation<Color>(colours.accent),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colours.card,
                  colours.cardLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.quiz_rounded,
                  color: const Color(0xFFFBBF24),
                  size: 36,
                ),
                const SizedBox(height: 16),
                Text(
                  question.statement,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Answer buttons
          if (!_quizAnswered) ...[
            Row(
              children: [
                Expanded(
                  child: _buildQuizButton(
                    colours,
                    'FACT',
                    Icons.check_circle_rounded,
                    const Color(0xFF22C55E),
                    () => _answerQuiz(true, question.isFact),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuizButton(
                    colours,
                    'MYTH',
                    Icons.cancel_rounded,
                    const Color(0xFFEF4444),
                    () => _answerQuiz(false, question.isFact),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Result feedback
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lastAnswerCorrect!
                    ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                    : const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _lastAnswerCorrect!
                      ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                      : const Color(0xFFEF4444).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _lastAnswerCorrect!
                        ? Icons.check_circle_rounded
                        : Icons.info_rounded,
                    color: _lastAnswerCorrect!
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastAnswerCorrect! ? 'Correct!' : 'Not quite!',
                    style: TextStyle(
                      color: colours.textBright,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This is ${question.isFact ? "a FACT" : "a MYTH"}.',
                    style: TextStyle(
                      color: colours.textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question.explanation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colours.textLight,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _quizIndex + 1 >= _mythFactQuestions.length
                      ? 'See Results'
                      : 'Next Question',
                  style: const TextStyle(
                    fontSize: 15,
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

  Widget _buildQuizButton(
    AppColours colours,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResults(AppColours colours) {
    final total = _mythFactQuestions.length;
    final percentage = (_quizScore / total * 100).round();
    final String message;
    final Color resultColour;

    if (percentage >= 80) {
      message = 'Excellent! You really know your stuff.';
      resultColour = const Color(0xFF22C55E);
    } else if (percentage >= 60) {
      message = 'Good job! You know quite a lot already.';
      resultColour = const Color(0xFF60A5FA);
    } else if (percentage >= 40) {
      message = 'Not bad! Learning is what this is all about.';
      resultColour = const Color(0xFFFBBF24);
    } else {
      message =
          'Now you know more than before — and that\'s what matters!';
      resultColour = const Color(0xFFF472B6);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  resultColour.withValues(alpha: 0.15),
                  resultColour.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: resultColour.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$_quizScore / $total',
                  style: TextStyle(
                    color: resultColour,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _quizIndex = 0;
                        _quizScore = 0;
                        _quizAnswered = false;
                        _lastAnswerCorrect = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: resultColour,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              children: [
                Icon(Icons.lightbulb_rounded,
                    color: const Color(0xFFFBBF24), size: 24),
                const SizedBox(height: 8),
                Text(
                  'The more you learn about your body, the better you can look after yourself. Knowledge is power.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colours.textLight,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _answerQuiz(bool answeredFact, bool actuallyFact) {
    HapticFeedback.mediumImpact();
    UISoundService().playClick();
    final correct = answeredFact == actuallyFact;
    setState(() {
      _quizAnswered = true;
      _lastAnswerCorrect = correct;
      if (correct) _quizScore++;
    });
  }

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    setState(() {
      _quizIndex++;
      _quizAnswered = false;
      _lastAnswerCorrect = null;
    });
  }

  // ── Shared widgets ────────────────────────────────────────

  Widget _buildIntroCard(
    AppColours colours,
    String title,
    String body,
    Color accentColour,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColour.withValues(alpha: 0.12),
            accentColour.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColour.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColour, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              color: colours.textLight,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EXPANDABLE EDUCATION CARD
// ================================================================

class _ExpandableEducationCard extends StatefulWidget {
  final AppColours colours;
  final _BodyTopic topic;
  final bool Function()? onExpandCheck;

  const _ExpandableEducationCard({
    required this.colours,
    required this.topic,
    this.onExpandCheck,
  });

  @override
  State<_ExpandableEducationCard> createState() =>
      _ExpandableEducationCardState();
}

class _ExpandableEducationCardState extends State<_ExpandableEducationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.topic;
    final c = widget.colours;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        if (!_expanded && widget.onExpandCheck != null) {
          if (!widget.onExpandCheck!()) return;
        }
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _expanded ? t.colour.withValues(alpha: 0.08) : c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? t.colour.withValues(alpha: 0.3)
                : c.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: t.colour.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(t.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: TextStyle(
                          color: c.textBright,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        t.subtitle,
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 1,
                color: c.border,
              ),
              const SizedBox(height: 14),
              Text(
                t.content,
                style: TextStyle(
                  color: c.textLight,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              if (t.normalRange != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.cardLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: t.colour, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.normalRange!,
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================
// DATA MODELS
// ================================================================

class _BodyTopic {
  final String title;
  final String subtitle;
  final String emoji;
  final String content;
  final Color colour;
  final String? normalRange;

  const _BodyTopic({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.content,
    required this.colour,
    this.normalRange,
  });
}

class _MythFactQuestion {
  final String statement;
  final bool isFact;
  final String explanation;

  const _MythFactQuestion({
    required this.statement,
    required this.isFact,
    required this.explanation,
  });
}

// ================================================================
// STATIC DATA — Female body topics
// ================================================================

const _femaleTopics = [
  _BodyTopic(
    title: 'Periods (Menstruation)',
    subtitle: 'What they are and what to expect',
    emoji: '🩸',
    colour: Color(0xFFE879A0),
    content:
        'A period is the monthly shedding of the lining of the uterus (womb). It\'s a completely normal part of the female body\'s reproductive cycle.\n\n'
        '• Periods usually start between ages 10–16 (average is 12)\n'
        '• A typical period lasts 3–7 days\n'
        '• You may lose around 30–70ml of blood (less than you think)\n'
        '• Periods come roughly every 21–35 days\n'
        '• It\'s normal for periods to be irregular for the first couple of years\n'
        '• Products: pads, tampons, menstrual cups, period pants — all are valid choices\n\n'
        'Cramps, mood changes, and tiredness are common. Light exercise, a warm water bottle, and rest can help.',
    normalRange: 'Typical cycle: 21–35 days. First periods are often irregular — this is normal.',
  ),
  _BodyTopic(
    title: 'Breast Development',
    subtitle: 'Changes during puberty',
    emoji: '🌸',
    colour: Color(0xFFF472B6),
    content:
        'Breast development is usually one of the first signs of puberty in girls.\n\n'
        '• Development typically starts between ages 8–13\n'
        '• It\'s normal for breasts to develop at different rates (one may be slightly larger)\n'
        '• Development can take 3–5 years to complete\n'
        '• Breast size is genetic — it doesn\'t affect health or ability\n'
        '• Tenderness or soreness during development is normal\n'
        '• Wearing a supportive bra/sports bra can help with comfort during exercise\n\n'
        'Every body is different. Comparison to others is not helpful — your body is developing exactly as it should for you.',
    normalRange: 'Development starts age 8–13 and continues for several years.',
  ),
  _BodyTopic(
    title: 'Body Hair & Skin',
    subtitle: 'Hair growth and skin changes',
    emoji: '✨',
    colour: Color(0xFFA78BFA),
    content:
        'During puberty, hormonal changes cause new hair growth and skin changes.\n\n'
        '• Hair grows under arms, on legs, and in the pubic area\n'
        '• This is completely normal and natural\n'
        '• Shaving/not shaving is a personal choice — neither is "wrong"\n'
        '• Skin may become oilier — this can lead to spots or acne\n'
        '• Washing your face twice daily with a gentle cleanser can help\n'
        '• Sweating increases — deodorant/antiperspirant becomes useful\n\n'
        'Acne affects most teenagers to some degree. If it\'s severe or affecting your confidence, speak to a GP — treatments are available.',
    normalRange: 'Acne peaks between ages 14–17 for most people.',
  ),
  _BodyTopic(
    title: 'Growth & Body Shape',
    subtitle: 'How your body changes shape',
    emoji: '📏',
    colour: Color(0xFF60A5FA),
    content:
        'During puberty, your body goes through a growth spurt and changes shape.\n\n'
        '• Height increases — girls often have their growth spurt earlier than boys (around 10–14)\n'
        '• Hips may widen — this is part of normal female development\n'
        '• Body fat increases, particularly around hips, thighs, and buttocks\n'
        '• Weight gain during puberty is normal and healthy\n'
        '• Hands and feet may grow first, before the rest of the body catches up\n\n'
        'Your body shape is determined by genetics. "Healthy" looks different on everyone. Focus on how you feel, not how you compare to others or images on social media.',
  ),
  _BodyTopic(
    title: 'Emotions & Hormones',
    subtitle: 'Why feelings feel bigger',
    emoji: '🎭',
    colour: Color(0xFFFBBF24),
    content:
        'Hormonal changes during puberty don\'t just affect your body — they affect your brain and emotions too.\n\n'
        '• Mood swings are common and normal\n'
        '• You may feel more emotional, irritable, or sensitive\n'
        '• Crushes and new feelings about attraction are normal\n'
        '• Feeling self-conscious about your changing body is very common\n'
        '• Wanting more privacy and independence is a healthy sign of growing up\n\n'
        'These feelings are caused by hormones (mainly oestrogen and progesterone). They won\'t always feel this intense. Talking to someone you trust can help a lot.',
    normalRange: 'Hormonal mood changes typically settle as you move through your late teens.',
  ),
  _BodyTopic(
    title: 'Vaginal Health',
    subtitle: 'Discharge, hygiene & what\'s normal',
    emoji: '🫧',
    colour: Color(0xFF34D399),
    content:
        'Vaginal discharge is normal and a sign that your body is working properly.\n\n'
        '• Discharge usually starts 6–12 months before your first period\n'
        '• Normal discharge is clear or white and doesn\'t have a strong odour\n'
        '• The amount and texture changes throughout your cycle\n'
        '• The vagina is self-cleaning — you don\'t need special products inside it\n'
        '• Wash the external area (vulva) with warm water and mild, unperfumed soap\n'
        '• Wearing breathable cotton underwear helps\n\n'
        'See a doctor if discharge changes colour (green/grey), has a strong smell, or if you have itching or pain.',
    normalRange: 'Discharge starting around ages 10–12 is usually the first sign puberty has begun.',
  ),
];

// ================================================================
// STATIC DATA — Male body topics
// ================================================================

const _maleTopics = [
  _BodyTopic(
    title: 'Voice Changes',
    subtitle: 'Why your voice breaks',
    emoji: '🗣️',
    colour: Color(0xFF60A5FA),
    content:
        'During puberty, the larynx (voice box) grows larger, causing the voice to deepen.\n\n'
        '• Your voice may "crack" or squeak during the transition — this is normal\n'
        '• The Adam\'s apple (bump in the throat) becomes more noticeable\n'
        '• Voice deepening usually happens between ages 12–16\n'
        '• The transition can take several months to complete\n'
        '• Everyone\'s voice deepens at a different rate\n\n'
        'Voice cracking can feel embarrassing, but it happens to everyone. It\'s temporary and will settle.',
    normalRange: 'Voice typically finishes deepening by age 16–17.',
  ),
  _BodyTopic(
    title: 'Growth Spurt & Muscles',
    subtitle: 'Getting taller and stronger',
    emoji: '📏',
    colour: Color(0xFF34D399),
    content:
        'Boys typically have their main growth spurt between ages 12–16.\n\n'
        '• You may grow several inches in a short time\n'
        '• Shoulders broaden and muscles develop\n'
        '• Hands and feet often grow first — you may feel "clumsy" temporarily\n'
        '• Growing pains (aches in legs) are common during growth spurts\n'
        '• Good nutrition and sleep are essential for healthy growth\n'
        '• Muscle development continues into your early 20s\n\n'
        'Don\'t compare your growth to others. Some people develop earlier or later. Genetics play a major role in your final height and build.',
    normalRange: 'Most boys reach adult height between ages 16–18, some continue growing until 21.',
  ),
  _BodyTopic(
    title: 'Body Hair & Facial Hair',
    subtitle: 'New hair growth',
    emoji: '🧔',
    colour: Color(0xFFA78BFA),
    content:
        'Increased testosterone during puberty causes hair to grow in new places.\n\n'
        '• Pubic hair is usually the first new hair to appear\n'
        '• Underarm hair, leg hair, and chest hair follow\n'
        '• Facial hair (upper lip first, then chin and cheeks) often starts around 14–16\n'
        '• Full beard growth may not happen until your late teens or 20s\n'
        '• The amount and thickness of body hair is genetic\n'
        '• Shaving is a personal choice — there\'s no "right" time to start\n\n'
        'If you choose to shave, use a clean razor and shaving cream to avoid irritation.',
    normalRange: 'Facial hair can continue filling in well into your 20s.',
  ),
  _BodyTopic(
    title: 'Skin Changes & Spots',
    subtitle: 'Acne and oily skin',
    emoji: '✨',
    colour: Color(0xFFFBBF24),
    content:
        'Rising testosterone levels increase oil production in your skin.\n\n'
        '• Oily skin and acne (spots) are very common during puberty\n'
        '• Face, back, chest, and shoulders are most affected\n'
        '• Wash affected areas twice daily with a gentle cleanser\n'
        '• Don\'t squeeze spots — this can cause scarring and infection\n'
        '• Drinking water and eating well can help your skin\n'
        '• Sweating increases — daily showers and deodorant become important\n\n'
        'Acne is not caused by poor hygiene or diet alone — it\'s primarily hormonal. If it\'s severe, a GP can prescribe treatments.',
    normalRange: 'Acne typically peaks around ages 15–17 and improves in late teens.',
  ),
  _BodyTopic(
    title: 'Reproductive Changes',
    subtitle: 'Understanding your body',
    emoji: '🔄',
    colour: Color(0xFFE879A0),
    content:
        'During puberty, the reproductive system matures.\n\n'
        '• Testicles grow larger (usually the first sign of puberty)\n'
        '• The penis grows in both length and width\n'
        '• Erections happen more frequently — sometimes without reason (this is normal)\n'
        '• Wet dreams (nocturnal emissions) may occur — this is completely normal\n'
        '• These changes are driven by testosterone\n'
        '• Everyone develops at a different rate — size and development varies enormously\n\n'
        'These changes can feel awkward or embarrassing, but they are a normal part of growing up. Every male goes through them.',
    normalRange: 'Puberty typically begins between ages 9–14.',
  ),
  _BodyTopic(
    title: 'Emotions & Mental Health',
    subtitle: 'Hormones and how you feel',
    emoji: '🎭',
    colour: Color(0xFF818CF8),
    content:
        'Testosterone changes don\'t just affect your body — they affect your mood and emotions too.\n\n'
        '• You may feel more irritable or frustrated\n'
        '• Mood swings and sudden anger are common\n'
        '• New feelings about attraction and relationships emerge\n'
        '• Feeling self-conscious about your body is very normal\n'
        '• Pressure to "man up" or hide feelings is harmful — emotions are healthy\n'
        '• Risk-taking behaviour may increase — be aware of this\n\n'
        'It\'s okay to feel things strongly. Talking to someone — a parent, teacher, counsellor, or friend — is a sign of strength, not weakness.',
    normalRange: 'Hormonal mood changes typically stabilise in your late teens.',
  ),
];

// ================================================================
// STATIC DATA — Myth or Fact quiz
// ================================================================

const _mythFactQuestions = [
  _MythFactQuestion(
    statement: 'You can\'t get pregnant on your first time having sex.',
    isFact: false,
    explanation:
        'This is a myth. Pregnancy can occur any time unprotected sex happens, including the first time. Contraception should always be used to prevent unintended pregnancy.',
  ),
  _MythFactQuestion(
    statement: 'Periods can be irregular for the first few years after they start.',
    isFact: true,
    explanation:
        'This is a fact. It\'s very common for periods to be unpredictable in the first 1–2 years. The cycle usually becomes more regular as you get older.',
  ),
  _MythFactQuestion(
    statement: 'Shaving makes hair grow back thicker.',
    isFact: false,
    explanation:
        'This is a myth. Shaving cuts hair at the surface, creating a blunt edge that can feel stubbly. But the hair itself doesn\'t actually become thicker or darker.',
  ),
  _MythFactQuestion(
    statement: 'Boys go through puberty too — including mood swings and emotional changes.',
    isFact: true,
    explanation:
        'This is a fact. Testosterone causes significant emotional changes in boys during puberty, including mood swings, irritability, and new feelings. Boys are often told to hide these feelings, but that\'s not healthy.',
  ),
  _MythFactQuestion(
    statement: 'Acne is caused by not washing your face enough.',
    isFact: false,
    explanation:
        'This is a myth. Acne is primarily caused by hormonal changes during puberty, not dirt. Over-washing can actually make acne worse by irritating the skin. Gentle, twice-daily cleansing is recommended.',
  ),
  _MythFactQuestion(
    statement: 'Wet dreams are a normal part of male puberty.',
    isFact: true,
    explanation:
        'This is a fact. Nocturnal emissions (wet dreams) are a completely normal part of puberty. They happen because the body is producing more hormones. Nothing to be embarrassed about.',
  ),
  _MythFactQuestion(
    statement: 'Everyone goes through puberty at the same age.',
    isFact: false,
    explanation:
        'This is a myth. Puberty can start anywhere between ages 8–16 depending on genetics and other factors. Starting earlier or later than friends is completely normal.',
  ),
  _MythFactQuestion(
    statement: 'Vaginal discharge before periods start is normal.',
    isFact: true,
    explanation:
        'This is a fact. Clear or white discharge usually begins 6–12 months before the first period. It\'s a sign that puberty is progressing normally.',
  ),
  _MythFactQuestion(
    statement: 'You should use scented products to clean the vaginal area.',
    isFact: false,
    explanation:
        'This is a myth. The vagina is self-cleaning. Scented products can disrupt the natural pH balance and cause irritation or infections. Warm water and mild, unperfumed soap on the external area is best.',
  ),
  _MythFactQuestion(
    statement: 'Mood swings during puberty are caused by hormonal changes in the brain.',
    isFact: true,
    explanation:
        'This is a fact. Hormones like oestrogen, progesterone, and testosterone directly affect the brain during puberty, causing mood changes, stronger emotions, and shifts in how you feel day to day.',
  ),
  _MythFactQuestion(
    statement: 'If a boy hasn\'t started puberty by 14, something is wrong.',
    isFact: false,
    explanation:
        'This is a myth. While most boys start puberty between 9–14, some start later and that\'s still within the normal range. If concerned, a GP can check — but later development is usually just genetics.',
  ),
  _MythFactQuestion(
    statement: 'Exercise can help with period cramps.',
    isFact: true,
    explanation:
        'This is a fact. Light to moderate exercise releases endorphins (natural painkillers) that can help reduce menstrual cramps. Walking, yoga, and swimming are particularly helpful.',
  ),
];
