import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Bullying Support — comprehensive, tap-only anti-bullying module
///
/// Features:
/// - "What's Happening?" assessment wizard (tap-based scenario identifier)
/// - Bystander guide — what to do when you see bullying
/// - Coping & recovery tools
/// - Support resources
///
/// ZERO free-text input. Nothing stored or transmitted.
class BullyingSupportScreen extends StatefulWidget {
  const BullyingSupportScreen({super.key});

  @override
  State<BullyingSupportScreen> createState() => _BullyingSupportScreenState();
}

class _BullyingSupportScreenState extends State<BullyingSupportScreen>
    with TickerProviderStateMixin, TeaseMixin {
  late TabController _tabController;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Bullying Support');

  // Assessment wizard state
  int _assessmentStep = 0;
  bool _showAssessmentResults = false;
  final Map<int, String> _assessmentAnswers = {};

  bool _gateExpand() {
    recordTeaseAction();
    return checkTeaseAndContinue();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Assessment logic ──────────────────────────────────────

  List<String> get _selectedTags {
    final tags = <String>[];
    for (final answer in _assessmentAnswers.values) {
      tags.add(answer);
    }
    return tags;
  }

  List<_GuidanceCard> get _matchedGuidance {
    final tags = _selectedTags.toSet();
    return _allGuidanceCards.where((card) {
      if (card.matchTags.isEmpty) return true; // universal
      return card.matchTags.any((t) => tags.contains(t));
    }).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  void _selectAssessmentOption(int step, String tag) {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    setState(() {
      _assessmentAnswers[step] = tag;
    });
  }

  void _nextAssessmentStep() {
    HapticFeedback.mediumImpact();
    if (_assessmentStep + 1 >= _assessmentQuestions.length) {
      setState(() => _showAssessmentResults = true);
    } else {
      setState(() => _assessmentStep++);
    }
  }

  void _resetAssessment() {
    HapticFeedback.lightImpact();
    setState(() {
      _assessmentStep = 0;
      _showAssessmentResults = false;
      _assessmentAnswers.clear();
    });
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
          onPressed: () {
            if (_showAssessmentResults || _assessmentStep > 0) {
              _resetAssessment();
              _tabController.animateTo(0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Bullying Support',
          style: TextStyle(
            color: colours.textBright,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFF59E0B),
          labelColor: colours.textBright,
          unselectedLabelColor: colours.textMuted,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: "What's Happening?"),
            Tab(text: 'Bystander Guide'),
            Tab(text: 'Coping Tools'),
            Tab(text: 'Get Help'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Support banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1A1A2E),
            child: Row(
              children: [
                Icon(Icons.shield_rounded,
                    color: const Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are not alone. Bullying is never your fault. Help is available.',
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
                _buildAssessmentTab(colours),
                _buildBystanderTab(colours),
                _buildCopingTab(colours),
                _buildHelpTab(colours),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: WHAT'S HAPPENING? (Assessment Wizard)
  // ============================================================

  Widget _buildAssessmentTab(AppColours colours) {
    if (_showAssessmentResults) {
      return _buildAssessmentResults(colours);
    }

    final question = _assessmentQuestions[_assessmentStep];
    final selectedTag = _assessmentAnswers[_assessmentStep];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_assessmentStep + 1} of ${_assessmentQuestions.length}',
                      style: TextStyle(
                        color: colours.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_assessmentStep > 0)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _assessmentStep--);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: colours.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_assessmentStep + 1) / _assessmentQuestions.length,
                    backgroundColor: colours.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFF59E0B)),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha: 0.10),
                  const Color(0xFFF59E0B).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Text(
                  question.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 10),
                Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (question.subtext != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    question.subtext!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colours.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options
          ...question.options.map((option) {
            final isSelected = selectedTag == option.tag;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () =>
                    _selectAssessmentOption(_assessmentStep, option.tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                        : colours.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                          : colours.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(option.emoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.text,
                              style: TextStyle(
                                color: colours.textBright,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (option.subtext != null)
                              Text(
                                option.subtext!,
                                style: TextStyle(
                                  color: colours.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFFF59E0B), size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Continue button
          if (selectedTag != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextAssessmentStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _assessmentStep + 1 >= _assessmentQuestions.length
                      ? 'See My Guidance'
                      : 'Continue',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAssessmentResults(AppColours colours) {
    final guidance = _matchedGuidance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  const Color(0xFF22C55E).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: Color(0xFFF59E0B), size: 32),
                const SizedBox(height: 8),
                Text(
                  'Your Personalised Guidance',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on what you told us, here\'s what might help.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colours.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Guidance cards
          ...guidance.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildGuidanceCard(colours, card),
              )),

          const SizedBox(height: 16),

          // Remember card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE879A0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE879A0).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Color(0xFFE879A0), size: 24),
                const SizedBox(height: 8),
                Text(
                  'Remember',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bullying is NEVER your fault. You deserve to feel safe. Asking for help is brave, not weak.',
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
          const SizedBox(height: 14),

          // Start over
          TextButton.icon(
            onPressed: _resetAssessment,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Start Over'),
            style: TextButton.styleFrom(
              foregroundColor: colours.textMuted,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGuidanceCard(AppColours colours, _GuidanceCard card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card.colour.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: card.colour.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(card.icon, color: card.colour, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            card.content,
            style: TextStyle(
              color: colours.textLight,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (card.actionSteps.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...card.actionSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('→ ',
                          style: TextStyle(
                              color: card.colour,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            color: colours.textLight,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: BYSTANDER GUIDE
  // ============================================================

  Widget _buildBystanderTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF818CF8).withValues(alpha: 0.12),
                  const Color(0xFF818CF8).withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF818CF8).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_rounded,
                        color: Color(0xFF818CF8), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Seeing Someone Get Bullied?',
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
                  'You don\'t have to be the person being bullied to make a difference. Bystanders have more power than they realise.',
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

          // The 5 Ds
          ..._bystanderActions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BystanderCard(
                colours: colours,
                action: action,
                index: index + 1,
                onExpandCheck: _gateExpand,
              ),
            );
          }),

          const SizedBox(height: 16),

          // What NOT to do
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.block_rounded,
                        color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'What NOT to Do',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._bystanderDonts.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✗ ',
                              style: TextStyle(
                                  color: Color(0xFFEF4444), fontSize: 13)),
                          Expanded(
                            child: Text(
                              d,
                              style: TextStyle(
                                color: colours.textLight,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 3: COPING TOOLS
  // ============================================================

  Widget _buildCopingTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Intro
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF34D399).withValues(alpha: 0.12),
                  const Color(0xFF34D399).withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF34D399).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.healing_rounded,
                        color: Color(0xFF34D399), size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Tools for Right Now',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'When you\'re dealing with bullying, these strategies can help you cope in the moment and recover over time.',
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

          ..._copingStrategies.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExpandableTile(
                  colours: colours,
                  title: s.title,
                  subtitle: s.subtitle,
                  emoji: s.emoji,
                  colour: s.colour,
                  content: s.content,
                  onExpandCheck: _gateExpand,
                ),
              )),

          const SizedBox(height: 16),

          // Affirmation card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFA78BFA).withValues(alpha: 0.15),
                  const Color(0xFFE879A0).withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Text('💪', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text(
                  'Say This to Yourself',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._affirmations.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '"$a"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colours.textLight,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 4: GET HELP
  // ============================================================

  Widget _buildHelpTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Emergency card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.emergency_rounded,
                    color: Color(0xFFEF4444), size: 28),
                const SizedBox(height: 8),
                Text(
                  'If You Are in Immediate Danger',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'If someone is physically hurting you or you feel unsafe right now, call your local emergency number immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colours.textLight,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Who to tell
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.record_voice_over_rounded,
                        color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'People You Can Tell',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._peopleTotell.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.who,
                                  style: TextStyle(
                                    color: colours.textBright,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  p.how,
                                  style: TextStyle(
                                    color: colours.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // How to tell someone
          _ExpandableTile(
            colours: colours,
            title: 'How to Tell Someone',
            subtitle: 'It can feel hard — here\'s how to start',
            emoji: '💬',
            colour: const Color(0xFF60A5FA),
            content:
                'Starting the conversation is often the hardest part. Here are some ways to begin:\n\n'
                '• "Something has been happening that\'s making me feel bad"\n'
                '• "I need to talk to you about someone at school/work"\n'
                '• "I\'m being bullied and I need help"\n'
                '• "Can I show you some messages I\'ve been getting?"\n\n'
                'You don\'t have to have all the answers or details. Just telling someone is enough to start getting help.\n\n'
                'If the first person doesn\'t help or take you seriously, tell someone else. Keep going until someone listens.',
          ),
          const SizedBox(height: 10),

          // Support organisations
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF818CF8).withValues(alpha: 0.12),
                  const Color(0xFFA78BFA).withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF818CF8).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.support_rounded,
                        color: Color(0xFF818CF8), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Support Organisations',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._supportOrgs.map((org) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colours.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colours.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              org.name,
                              style: TextStyle(
                                color: colours.textBright,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              org.description,
                              style: TextStyle(
                                color: colours.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              org.access,
                              style: TextStyle(
                                color: const Color(0xFF818CF8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ================================================================
// EXPANDABLE TILE
// ================================================================

class _ExpandableTile extends StatefulWidget {
  final AppColours colours;
  final String title;
  final String subtitle;
  final String emoji;
  final Color colour;
  final String content;
  final bool Function()? onExpandCheck;

  const _ExpandableTile({
    required this.colours,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colour,
    required this.content,
    this.onExpandCheck,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
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
          color: _expanded
              ? widget.colour.withValues(alpha: 0.08)
              : widget.colours.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? widget.colour.withValues(alpha: 0.3)
                : widget.colours.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.colours.textBright,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: widget.colours.textMuted,
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
                    color: widget.colours.textMuted,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 1,
                color: widget.colours.border,
              ),
              const SizedBox(height: 14),
              Text(
                widget.content,
                style: TextStyle(
                  color: widget.colours.textLight,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================
// BYSTANDER CARD
// ================================================================

class _BystanderCard extends StatefulWidget {
  final AppColours colours;
  final _BystanderAction action;
  final int index;
  final bool Function()? onExpandCheck;

  const _BystanderCard({
    required this.colours,
    required this.action,
    required this.index,
    this.onExpandCheck,
  });

  @override
  State<_BystanderCard> createState() => _BystanderCardState();
}

class _BystanderCardState extends State<_BystanderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.colours;
    final a = widget.action;

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
          color: _expanded
              ? const Color(0xFF818CF8).withValues(alpha: 0.08)
              : c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? const Color(0xFF818CF8).withValues(alpha: 0.3)
                : c.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                        color: Color(0xFF818CF8),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: TextStyle(
                          color: c.textBright,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        a.subtitle,
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
                a.content,
                style: TextStyle(
                  color: c.textLight,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              if (a.examples.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...a.examples.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡 ',
                              style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Text(
                              e,
                              style: TextStyle(
                                color: c.textMuted,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================
// STATIC DATA — Assessment Questions
// ================================================================

class _AssessmentQuestion {
  final String question;
  final String emoji;
  final String? subtext;
  final List<_AssessmentOption> options;

  const _AssessmentQuestion({
    required this.question,
    required this.emoji,
    this.subtext,
    required this.options,
  });
}

class _AssessmentOption {
  final String text;
  final String emoji;
  final String tag;
  final String? subtext;

  const _AssessmentOption({
    required this.text,
    required this.emoji,
    required this.tag,
    this.subtext,
  });
}

const _assessmentQuestions = [
  _AssessmentQuestion(
    question: 'What kind of bullying are you experiencing?',
    emoji: '🤔',
    subtext: 'Tap the one that best describes your situation',
    options: [
      _AssessmentOption(
        text: 'Verbal',
        emoji: '🗣️',
        tag: 'verbal',
        subtext: 'Name-calling, insults, mockery, threats',
      ),
      _AssessmentOption(
        text: 'Physical',
        emoji: '👊',
        tag: 'physical',
        subtext: 'Hitting, pushing, damaging belongings',
      ),
      _AssessmentOption(
        text: 'Social / Exclusion',
        emoji: '🚫',
        tag: 'social',
        subtext: 'Being left out, rumours, turning people against you',
      ),
      _AssessmentOption(
        text: 'Cyberbullying',
        emoji: '📱',
        tag: 'cyber',
        subtext: 'Online harassment, social media, messaging',
      ),
      _AssessmentOption(
        text: 'I\'m not sure',
        emoji: '❓',
        tag: 'unsure',
        subtext: 'Something doesn\'t feel right',
      ),
    ],
  ),
  _AssessmentQuestion(
    question: 'Where is this happening?',
    emoji: '📍',
    options: [
      _AssessmentOption(
        text: 'At school / college',
        emoji: '🏫',
        tag: 'school',
      ),
      _AssessmentOption(
        text: 'At work / training',
        emoji: '💼',
        tag: 'work',
      ),
      _AssessmentOption(
        text: 'Online / social media',
        emoji: '📱',
        tag: 'online',
      ),
      _AssessmentOption(
        text: 'In my neighbourhood',
        emoji: '🏘️',
        tag: 'neighbourhood',
      ),
      _AssessmentOption(
        text: 'Multiple places',
        emoji: '📌',
        tag: 'multiple',
      ),
    ],
  ),
  _AssessmentQuestion(
    question: 'How often is this happening?',
    emoji: '📅',
    options: [
      _AssessmentOption(
        text: 'It happened once or twice',
        emoji: '1️⃣',
        tag: 'occasional',
      ),
      _AssessmentOption(
        text: 'It happens regularly (weekly+)',
        emoji: '🔄',
        tag: 'regular',
      ),
      _AssessmentOption(
        text: 'It\'s constant / daily',
        emoji: '⚠️',
        tag: 'constant',
      ),
      _AssessmentOption(
        text: 'It comes and goes',
        emoji: '🌊',
        tag: 'intermittent',
      ),
    ],
  ),
  _AssessmentQuestion(
    question: 'Have you told anyone about this?',
    emoji: '💬',
    options: [
      _AssessmentOption(
        text: 'Yes — and they helped',
        emoji: '✅',
        tag: 'told_helped',
      ),
      _AssessmentOption(
        text: 'Yes — but nothing changed',
        emoji: '😞',
        tag: 'told_no_help',
      ),
      _AssessmentOption(
        text: 'No — I haven\'t told anyone',
        emoji: '🤐',
        tag: 'not_told',
      ),
      _AssessmentOption(
        text: 'No — I\'m afraid to',
        emoji: '😰',
        tag: 'afraid_to_tell',
      ),
    ],
  ),
];

// ================================================================
// STATIC DATA — Guidance Cards
// ================================================================

class _GuidanceCard {
  final String title;
  final String content;
  final List<String> actionSteps;
  final List<String> matchTags;
  final IconData icon;
  final Color colour;
  final int priority;

  const _GuidanceCard({
    required this.title,
    required this.content,
    required this.actionSteps,
    required this.matchTags,
    required this.icon,
    required this.colour,
    this.priority = 5,
  });
}

const _allGuidanceCards = [
  // Universal
  _GuidanceCard(
    title: 'This Is Not Your Fault',
    content:
        'No matter what type of bullying you\'re experiencing, it is never your fault. Bullies choose to bully — nothing about you causes or deserves it.',
    actionSteps: [],
    matchTags: [],
    icon: Icons.favorite_rounded,
    colour: Color(0xFFE879A0),
    priority: 10,
  ),

  // Physical bullying
  _GuidanceCard(
    title: 'Physical Safety First',
    content:
        'If someone is physically hurting you, your safety is the top priority.',
    actionSteps: [
      'Remove yourself from the situation if you can',
      'Tell a trusted adult immediately — teacher, parent, manager',
      'If you are injured, seek medical help',
      'If it happens at work/training, report to your chain of command or HR',
      'Physical assault is a crime — police can be involved',
    ],
    matchTags: ['physical'],
    icon: Icons.shield_rounded,
    colour: Color(0xFFEF4444),
    priority: 9,
  ),

  // Cyberbullying
  _GuidanceCard(
    title: 'Dealing with Cyberbullying',
    content:
        'Online bullying can feel inescapable, but there are steps you can take.',
    actionSteps: [
      'Do NOT respond to the bully — this often encourages them',
      'Screenshot and save everything as evidence',
      'Block the person on all platforms',
      'Report the content to the platform (Instagram, TikTok, etc.)',
      'Tell a trusted adult and show them the evidence',
      'You can report online harassment to police (in serious cases)',
    ],
    matchTags: ['cyber', 'online'],
    icon: Icons.phone_android_rounded,
    colour: Color(0xFF60A5FA),
    priority: 8,
  ),

  // Verbal
  _GuidanceCard(
    title: 'Handling Verbal Bullying',
    content:
        'Words can hurt deeply. Name-calling, insults, and mockery are forms of bullying.',
    actionSteps: [
      'Try to stay calm and not show a visible reaction (bullies feed on reactions)',
      'Walk away if you can — this is strength, not weakness',
      'Tell a teacher, parent, or someone you trust what\'s being said',
      'Keep a record of what was said and when',
      'Remember: their words say everything about them and nothing about you',
    ],
    matchTags: ['verbal'],
    icon: Icons.chat_bubble_outline_rounded,
    colour: Color(0xFFFBBF24),
    priority: 7,
  ),

  // Social exclusion
  _GuidanceCard(
    title: 'Social Exclusion Is Real Bullying',
    content:
        'Being deliberately left out, having rumours spread about you, or having friends turned against you is a serious form of bullying.',
    actionSteps: [
      'Know that this says something about them, not you',
      'Try to build friendships outside the group that\'s excluding you',
      'Tell a trusted adult — social bullying is often invisible to adults',
      'Joining clubs, teams, or activities can help you find your people',
      'Focus on one or two genuine connections rather than large groups',
    ],
    matchTags: ['social'],
    icon: Icons.group_off_rounded,
    colour: Color(0xFFA78BFA),
    priority: 7,
  ),

  // Afraid to tell
  _GuidanceCard(
    title: 'It\'s Okay to Be Scared',
    content:
        'Being afraid to tell someone is completely understandable. Many people feel this way.',
    actionSteps: [
      'You can tell someone anonymously — many schools have report systems',
      'Write it down if speaking feels too hard',
      'Online services like Childline let you talk without giving your name',
      'Telling someone is the single most powerful thing you can do',
      'You will not get in trouble for reporting bullying',
      'If one person doesn\'t listen, try someone else — keep going',
    ],
    matchTags: ['afraid_to_tell', 'not_told'],
    icon: Icons.lock_open_rounded,
    colour: Color(0xFF34D399),
    priority: 8,
  ),

  // Told but no help
  _GuidanceCard(
    title: 'When Nobody Listened',
    content:
        'If you told someone and nothing changed, that\'s not okay — and it\'s not a reason to give up.',
    actionSteps: [
      'Tell someone else — go higher if needed (head teacher, HR, welfare officer)',
      'Put it in writing — emails and written reports create a record',
      'Ask a parent or another adult to advocate on your behalf',
      'Contact external support organisations who can advise you',
      'You have a right to feel safe — don\'t accept being ignored',
    ],
    matchTags: ['told_no_help'],
    icon: Icons.campaign_rounded,
    colour: Color(0xFFF59E0B),
    priority: 8,
  ),

  // Constant bullying
  _GuidanceCard(
    title: 'When It\'s Constant',
    content:
        'Daily or constant bullying takes a serious toll on mental health. This needs to be addressed urgently.',
    actionSteps: [
      'This level of bullying requires adult intervention — tell someone NOW',
      'Your mental health matters — it\'s okay to not be okay',
      'If you\'re having thoughts of self-harm, please reach out to a crisis service',
      'Consider speaking to a counsellor — your school or GP can arrange this',
      'You may need to involve the school/workplace formally',
      'Remember: this situation WILL change. It is not permanent.',
    ],
    matchTags: ['constant', 'regular'],
    icon: Icons.warning_amber_rounded,
    colour: Color(0xFFEF4444),
    priority: 9,
  ),

  // School specific
  _GuidanceCard(
    title: 'Your School Has a Duty',
    content:
        'Schools are legally required to have anti-bullying policies and to act on reports of bullying.',
    actionSteps: [
      'Report to your form tutor or head of year',
      'If they don\'t act, go to the head teacher',
      'Ask your parents to contact the school formally',
      'Schools must record and respond to bullying reports',
      'If the school fails to act, parents can complain to the governing body',
    ],
    matchTags: ['school'],
    icon: Icons.school_rounded,
    colour: Color(0xFF818CF8),
    priority: 6,
  ),

  // Work specific
  _GuidanceCard(
    title: 'Bullying at Work or Training',
    content:
        'Workplace bullying is taken seriously and there are formal processes to deal with it.',
    actionSteps: [
      'Report to your line manager or supervisor',
      'If your manager IS the problem, go to their manager or HR',
      'Keep a written record of incidents (dates, witnesses, what happened)',
      'In military settings, speak to your welfare officer or use the Service Complaints process',
      'You are protected by law from workplace harassment',
    ],
    matchTags: ['work'],
    icon: Icons.work_rounded,
    colour: Color(0xFF60A5FA),
    priority: 6,
  ),
];

// ================================================================
// STATIC DATA — Bystander Actions (The 5 Ds)
// ================================================================

class _BystanderAction {
  final String title;
  final String subtitle;
  final String content;
  final List<String> examples;

  const _BystanderAction({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.examples,
  });
}

const _bystanderActions = [
  _BystanderAction(
    title: 'Direct — Speak Up',
    subtitle: 'Say something in the moment',
    content:
        'If it feels safe, address the situation directly. You don\'t need to be confrontational — calm and clear is more effective.',
    examples: [
      '"That\'s not okay."',
      '"Leave them alone."',
      '"Hey, that\'s not funny."',
    ],
  ),
  _BystanderAction(
    title: 'Distract — Change the Subject',
    subtitle: 'Interrupt without confronting',
    content:
        'Create a distraction to break the dynamic. This stops the bullying without directly challenging anyone.',
    examples: [
      'Ask the bully a random question: "Hey, did you see the match last night?"',
      'Drop something or cause a commotion',
      'Ask the victim to come help you with something',
    ],
  ),
  _BystanderAction(
    title: 'Delegate — Get Help',
    subtitle: 'Tell someone who can act',
    content:
        'If you don\'t feel safe intervening directly, find someone who can — a teacher, supervisor, adult, or security.',
    examples: [
      'Tell a teacher: "Something is happening with [person] — can you check?"',
      'Alert another adult nearby',
      'Report online bullying to the platform',
    ],
  ),
  _BystanderAction(
    title: 'Document — Record Evidence',
    subtitle: 'Screenshot or note down what happened',
    content:
        'Evidence makes it harder for bullying to be dismissed. If safe to do so, document what you see.',
    examples: [
      'Screenshot messages or posts',
      'Note down what was said, when, and who was there',
      'Offer to be a witness if the victim reports it',
    ],
  ),
  _BystanderAction(
    title: 'Delay — Check In After',
    subtitle: 'Support the person afterwards',
    content:
        'Even if you can\'t act in the moment, checking in with the person afterwards is powerful. It shows them they\'re not alone.',
    examples: [
      '"Are you okay? I saw what happened."',
      '"That wasn\'t right. Do you want to talk about it?"',
      '"I\'ll go with you to report it if you want."',
    ],
  ),
];

const _bystanderDonts = [
  'Don\'t join in or laugh — even if others are. Silence is better than participation.',
  'Don\'t film it for social media — that makes you part of the problem.',
  'Don\'t tell the victim to "just ignore it" — this dismisses their experience.',
  'Don\'t put yourself in physical danger — delegate instead.',
  'Don\'t spread rumours about the situation afterwards.',
];

// ================================================================
// STATIC DATA — Coping Strategies
// ================================================================

class _CopingStrategy {
  final String title;
  final String subtitle;
  final String emoji;
  final Color colour;
  final String content;

  const _CopingStrategy({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colour,
    required this.content,
  });
}

const _copingStrategies = [
  _CopingStrategy(
    title: 'The Grey Rock Technique',
    subtitle: 'Become uninteresting to the bully',
    emoji: '🪨',
    colour: Color(0xFF94A3B8),
    content:
        'Bullies want a reaction. The grey rock technique is about being as boring and unreactive as possible.\n\n'
        '• Give short, dull responses: "okay", "sure", "cool"\n'
        '• Don\'t show anger, sadness, or frustration\n'
        '• Keep your face neutral\n'
        '• Don\'t engage in arguments\n'
        '• Walk away calmly\n\n'
        'This doesn\'t mean what they\'re doing is okay — it\'s a strategy to make them lose interest while you get proper help.',
  ),
  _CopingStrategy(
    title: 'Breathing to Stay Calm',
    subtitle: 'Quick technique for the moment',
    emoji: '🌊',
    colour: Color(0xFF60A5FA),
    content:
        'When bullying triggers anxiety, panic, or anger, your body goes into fight-or-flight. Breathing brings you back to calm.\n\n'
        'Box Breathing (4-4-4-4):\n'
        '• Breathe IN for 4 seconds\n'
        '• HOLD for 4 seconds\n'
        '• Breathe OUT for 4 seconds\n'
        '• HOLD for 4 seconds\n'
        '• Repeat 4 times\n\n'
        'This works because it activates your parasympathetic nervous system — your body\'s natural calming mechanism.',
  ),
  _CopingStrategy(
    title: 'Build Your Support Team',
    subtitle: 'You don\'t have to face this alone',
    emoji: '🤝',
    colour: Color(0xFF34D399),
    content:
        'Having people in your corner makes a massive difference.\n\n'
        '• Identify 2–3 people you trust (parent, friend, teacher, counsellor)\n'
        '• Let them know what\'s happening\n'
        '• Having a buddy at school/work helps — someone who has your back\n'
        '• Online communities of people who understand can also help\n'
        '• A counsellor or therapist can give you professional coping tools\n\n'
        'You are not a burden for asking for help. People want to help — let them.',
  ),
  _CopingStrategy(
    title: 'Protect Your Self-Worth',
    subtitle: 'What they say is NOT who you are',
    emoji: '💎',
    colour: Color(0xFFA78BFA),
    content:
        'Bullying tries to redefine who you are. Don\'t let it.\n\n'
        '• The things bullies say are projections of their own insecurities\n'
        '• Make a mental list of things you like about yourself\n'
        '• Spend time with people who genuinely appreciate you\n'
        '• Do things you\'re good at — hobbies, sports, creativity\n'
        '• Limit social media if it\'s contributing to negative feelings\n'
        '• Talk to yourself like you\'d talk to your best friend — with kindness',
  ),
  _CopingStrategy(
    title: 'When It Feels Too Much',
    subtitle: 'What to do if you\'re really struggling',
    emoji: '🆘',
    colour: Color(0xFFEF4444),
    content:
        'If bullying is making you feel hopeless, worthless, or like you want to hurt yourself — that is a sign you need support now.\n\n'
        '• You are not weak for struggling — this is a normal response to an abnormal situation\n'
        '• Tell someone immediately — a parent, teacher, GP, or helpline\n'
        '• Crisis support is available 24/7 through helplines and text services\n'
        '• This feeling is temporary — even though it doesn\'t feel like it right now\n'
        '• Professional help works — counselling and therapy make a real difference\n\n'
        'Your life matters. You matter. Please reach out.',
  ),
];

const _affirmations = [
  'I deserve to be treated with respect.',
  'What they say does not define me.',
  'Asking for help is brave.',
  'This will not last forever.',
  'I am more than this situation.',
];

// ================================================================
// STATIC DATA — Help Tab
// ================================================================

class _PersonToTell {
  final String emoji;
  final String who;
  final String how;

  const _PersonToTell(this.emoji, this.who, this.how);
}

const _peopleTotell = [
  _PersonToTell('👨‍👩‍👧', 'Parent or Guardian',
      'They can contact your school/workplace and support you'),
  _PersonToTell('👩‍🏫', 'Teacher or Tutor',
      'They have a duty to help and can escalate within school'),
  _PersonToTell('🧑‍💼', 'School Counsellor',
      'Trained to help with exactly this — confidential support'),
  _PersonToTell('👮', 'Police',
      'For physical assault, threats, or persistent harassment'),
  _PersonToTell('📞', 'Helpline',
      'Anonymous, confidential, available 24/7 — see below'),
  _PersonToTell('🤝', 'A Trusted Friend',
      'Having someone who knows can make you feel less alone'),
  _PersonToTell('👨‍⚕️', 'Your GP / Doctor',
      'If bullying is affecting your mental or physical health'),
];

class _SupportOrg {
  final String name;
  final String description;
  final String access;

  const _SupportOrg(this.name, this.description, this.access);
}

const _supportOrgs = [
  _SupportOrg(
    'Childline',
    'Free, confidential support for under-19s. Trained counsellors available.',
    'Online chat available at childline.org.uk',
  ),
  _SupportOrg(
    'The Mix',
    'Support for under-25s on any issue including bullying.',
    'Online at themix.org.uk — chat, forums, and resources',
  ),
  _SupportOrg(
    'Anti-Bullying Alliance',
    'Information, advice, and resources for young people and parents.',
    'anti-bullyingalliance.org.uk',
  ),
  _SupportOrg(
    'Ditch the Label',
    'One of the largest anti-bullying charities. Community support and advice.',
    'ditchthelabel.org — online community and resources',
  ),
  _SupportOrg(
    'Papyrus (HOPELINEUK)',
    'For young people under 35 experiencing thoughts of suicide.',
    'papyrus-uk.org — call, text, or email',
  ),
  _SupportOrg(
    'Young Minds',
    'Mental health support for young people and parents.',
    'youngminds.org.uk — text YM to 85258 for crisis support',
  ),
];
