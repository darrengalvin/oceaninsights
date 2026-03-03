import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Sexual Education — age-appropriate, tap-only
///
/// Covers consent, healthy relationships, STI awareness, and key facts.
/// ZERO free-text input. All interactions are tap/select.
/// Nothing stored or transmitted.
class SexEducationScreen extends StatefulWidget {
  const SexEducationScreen({super.key});

  @override
  State<SexEducationScreen> createState() => _SexEducationScreenState();
}

class _SexEducationScreenState extends State<SexEducationScreen>
    with TickerProviderStateMixin, TeaseMixin {
  late TabController _tabController;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Sex Education');

  // Consent scenario quiz state
  int _scenarioIndex = 0;
  bool _scenarioAnswered = false;
  String? _selectedAnswer;

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
          'Relationships & Sex Ed',
          style: TextStyle(
            color: colours.textBright,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFA78BFA),
          labelColor: colours.textBright,
          unselectedLabelColor: colours.textMuted,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Consent'),
            Tab(text: 'Relationships'),
            Tab(text: 'STI Awareness'),
            Tab(text: 'Key Facts'),
          ],
        ),
      ),
      body: Column(
        children: [
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
                    'Educational content to help you make informed, safe decisions.',
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
                _buildConsentTab(colours),
                _buildRelationshipsTab(colours),
                _buildStiTab(colours),
                _buildKeyFactsTab(colours),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: CONSENT
  // ============================================================

  Widget _buildConsentTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // What is consent
          _buildHeaderCard(
            colours,
            'Understanding Consent',
            'Consent means giving permission freely, without pressure. It applies to all physical contact — not just sex.\n\n'
                'Consent is:',
            const Color(0xFFA78BFA),
            Icons.handshake_rounded,
          ),
          const SizedBox(height: 12),

          // FRIES model
          ..._consentPrinciples.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildPrincipleCard(colours, p),
              )),
          const SizedBox(height: 24),

          // Scenario heading
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz_rounded,
                        color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Scenario Check',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap the answer you think is right for each scenario.',
                  style: TextStyle(color: colours.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Scenario quiz
          if (_scenarioIndex < _consentScenarios.length)
            _buildScenarioCard(colours)
          else
            _buildScenarioComplete(colours),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(AppColours colours) {
    final scenario = _consentScenarios[_scenarioIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Text(
            'Scenario ${_scenarioIndex + 1} of ${_consentScenarios.length}',
            style: TextStyle(
              color: colours.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // Scenario text
          Text(
            scenario.scenario,
            style: TextStyle(
              color: colours.textBright,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scenario.question,
            style: TextStyle(
              color: const Color(0xFFA78BFA),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // Options
          ...scenario.options.map((option) {
            final isSelected = _selectedAnswer == option.id;
            final showResult = _scenarioAnswered;
            final isCorrect = option.id == scenario.correctId;

            Color borderColour = colours.border;
            Color bgColour = colours.cardLight;
            if (showResult && isCorrect) {
              borderColour = const Color(0xFF22C55E).withValues(alpha: 0.5);
              bgColour = const Color(0xFF22C55E).withValues(alpha: 0.1);
            } else if (showResult && isSelected && !isCorrect) {
              borderColour = const Color(0xFFEF4444).withValues(alpha: 0.5);
              bgColour = const Color(0xFFEF4444).withValues(alpha: 0.1);
            } else if (isSelected) {
              borderColour = const Color(0xFFA78BFA);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: _scenarioAnswered
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        UISoundService().playClick();
                        setState(() {
                          _selectedAnswer = option.id;
                          _scenarioAnswered = true;
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColour,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColour),
                  ),
                  child: Row(
                    children: [
                      if (showResult && isCorrect)
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF22C55E), size: 18)
                      else if (showResult && isSelected && !isCorrect)
                        const Icon(Icons.cancel_rounded,
                            color: Color(0xFFEF4444), size: 18)
                      else
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFA78BFA)
                                  : colours.textMuted,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected
                                ? const Color(0xFFA78BFA)
                                    .withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            color: colours.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Explanation after answering
          if (_scenarioAnswered) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFA78BFA).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                scenario.explanation,
                style: TextStyle(
                  color: colours.textLight,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _scenarioIndex++;
                    _scenarioAnswered = false;
                    _selectedAnswer = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA78BFA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _scenarioIndex + 1 >= _consentScenarios.length
                      ? 'Finish'
                      : 'Next Scenario',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScenarioComplete(AppColours colours) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF22C55E), size: 36),
          const SizedBox(height: 10),
          Text(
            'Well done!',
            style: TextStyle(
              color: colours.textBright,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Understanding consent is one of the most important things you\'ll ever learn. Remember: if it\'s not a clear yes, it\'s a no.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colours.textLight,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              setState(() {
                _scenarioIndex = 0;
                _scenarioAnswered = false;
                _selectedAnswer = null;
              });
            },
            child: const Text('Try Again',
                style: TextStyle(color: Color(0xFFA78BFA))),
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleCard(AppColours colours, _ConsentPrinciple p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colours.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.colour.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                p.letter,
                style: TextStyle(
                  color: p.colour,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
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
                  p.word,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  p.description,
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
    );
  }

  // ============================================================
  // TAB 2: RELATIONSHIPS
  // ============================================================

  Widget _buildRelationshipsTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(
            colours,
            'Healthy vs Unhealthy Relationships',
            'A good relationship — romantic, friendship, or family — should make you feel safe, respected, and supported. Here\'s how to tell the difference.',
            const Color(0xFFE879A0),
            Icons.favorite_border_rounded,
          ),
          const SizedBox(height: 16),

          // Healthy signs
          _buildSignsSection(
            colours,
            'Signs of a Healthy Relationship',
            Icons.check_circle_outline_rounded,
            const Color(0xFF22C55E),
            _healthySigns,
          ),
          const SizedBox(height: 14),

          // Warning signs
          _buildSignsSection(
            colours,
            'Warning Signs (Red Flags)',
            Icons.warning_amber_rounded,
            const Color(0xFFEF4444),
            _warningSigns,
          ),
          const SizedBox(height: 20),

          // Relationship rights
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFA78BFA).withValues(alpha: 0.12),
                  const Color(0xFFE879A0).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: Color(0xFFA78BFA), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Your Rights in Any Relationship',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._relationshipRights.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✓ ',
                              style: TextStyle(
                                  color: Color(0xFFA78BFA), fontSize: 14)),
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(
                                color: colours.textLight,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pressure section
          _buildExpandableTile(
            colours,
            'Dealing with Pressure',
            'What to do when someone pushes your boundaries',
            Icons.block_rounded,
            const Color(0xFFF59E0B),
            'Pressure can be subtle or obvious. Here are ways it might look:\n\n'
                '• "If you loved me, you\'d do it"\n'
                '• "Everyone else is doing it"\n'
                '• "Don\'t be boring/scared"\n'
                '• Making you feel guilty for saying no\n'
                '• Threatening to break up or tell others\n\n'
                'What you can do:\n\n'
                '• You NEVER owe anyone anything with your body\n'
                '• "No" is a complete sentence — you don\'t need a reason\n'
                '• A good partner will respect your boundaries without question\n'
                '• If someone pressures you repeatedly, that is a red flag\n'
                '• Talk to a trusted adult if you feel unsafe\n'
                '• Leave the situation if you feel uncomfortable',
          ),
          const SizedBox(height: 10),
          _buildExpandableTile(
            colours,
            'Online Relationships & Safety',
            'Staying safe with online connections',
            Icons.phone_android_rounded,
            const Color(0xFF60A5FA),
            'Online relationships are real, but they carry unique risks:\n\n'
                '• People online may not be who they say they are\n'
                '• NEVER share intimate photos — once sent, you lose control\n'
                '• Sharing intimate images of under-18s is illegal, even if you\'re the person in the image\n'
                '• If someone asks you to keep the relationship secret from adults, that\'s a red flag\n'
                '• Never meet someone in person alone who you\'ve only met online\n'
                '• If someone sends you unwanted sexual messages or images, that is not okay\n\n'
                'If anything online makes you uncomfortable, tell a trusted adult. You will not be in trouble for asking for help.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSignsSection(
    AppColours colours,
    String title,
    IconData icon,
    Color colour,
    List<String> signs,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colour.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colour, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colours.textBright,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...signs.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: colour, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
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
    );
  }

  // ============================================================
  // TAB 3: STI AWARENESS
  // ============================================================

  Widget _buildStiTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(
            colours,
            'STI Awareness',
            'Sexually transmitted infections (STIs) are infections passed from one person to another through sexual contact. Learning about them helps you protect yourself and others.',
            const Color(0xFF34D399),
            Icons.health_and_safety_rounded,
          ),
          const SizedBox(height: 16),

          // Key facts card
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
                Text(
                  'Important to Know',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ..._stiKeyFacts.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF34D399), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                color: colours.textLight,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Individual STIs
          ..._stiInfoCards.map((sti) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StiExpandableCard(colours: colours, sti: sti, onExpandCheck: _gateExpand),
              )),

          const SizedBox(height: 16),

          // Protection section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF34D399).withValues(alpha: 0.12),
                  const Color(0xFF60A5FA).withValues(alpha: 0.08),
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
                    const Icon(Icons.shield_rounded,
                        color: Color(0xFF34D399), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Protecting Yourself',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._protectionTips.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🛡️ ', style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: Text(
                              t,
                              style: TextStyle(
                                color: colours.textLight,
                                fontSize: 13,
                                height: 1.4,
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
  // TAB 4: KEY FACTS
  // ============================================================

  Widget _buildKeyFactsTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(
            colours,
            'Things You Should Know',
            'Clear, honest information — no awkwardness, no judgement.',
            const Color(0xFFFBBF24),
            Icons.lightbulb_rounded,
          ),
          const SizedBox(height: 16),

          ..._keyFactTopics.map((topic) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildExpandableTile(
                  colours,
                  topic.title,
                  topic.subtitle,
                  topic.icon,
                  topic.colour,
                  topic.content,
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────

  Widget _buildHeaderCard(
    AppColours colours,
    String title,
    String body,
    Color accent,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.12),
            accent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
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

  Widget _buildExpandableTile(
    AppColours colours,
    String title,
    String subtitle,
    IconData icon,
    Color colour,
    String content,
  ) {
    return _ExpandableTile(
      colours: colours,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColour: colour,
      content: content,
      onExpandCheck: _gateExpand,
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
  final IconData icon;
  final Color iconColour;
  final String content;
  final bool Function()? onExpandCheck;

  const _ExpandableTile({
    required this.colours,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColour,
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
              ? widget.iconColour.withValues(alpha: 0.08)
              : widget.colours.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? widget.iconColour.withValues(alpha: 0.3)
                : widget.colours.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.iconColour, size: 22),
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
// STI EXPANDABLE CARD
// ================================================================

class _StiExpandableCard extends StatefulWidget {
  final AppColours colours;
  final _StiInfo sti;
  final bool Function()? onExpandCheck;

  const _StiExpandableCard({required this.colours, required this.sti, this.onExpandCheck});

  @override
  State<_StiExpandableCard> createState() => _StiExpandableCardState();
}

class _StiExpandableCardState extends State<_StiExpandableCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.colours;
    final s = widget.sti;

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _expanded
              ? const Color(0xFF34D399).withValues(alpha: 0.06)
              : c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded
                ? const Color(0xFF34D399).withValues(alpha: 0.3)
                : c.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.name,
                    style: TextStyle(
                      color: c.textBright,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: s.treatable
                        ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s.treatable ? 'Treatable' : 'Manageable',
                    style: TextStyle(
                      color: s.treatable
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF59E0B),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: c.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              _buildStiRow(c, 'What is it', s.description),
              const SizedBox(height: 8),
              _buildStiRow(c, 'Symptoms', s.symptoms),
              const SizedBox(height: 8),
              _buildStiRow(c, 'Treatment', s.treatment),
              const SizedBox(height: 8),
              _buildStiRow(c, 'Prevention', s.prevention),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStiRow(AppColours c, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: c.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: c.textLight, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// STATIC DATA
// ================================================================

class _ConsentPrinciple {
  final String letter;
  final String word;
  final String description;
  final Color colour;

  const _ConsentPrinciple(this.letter, this.word, this.description, this.colour);
}

const _consentPrinciples = [
  _ConsentPrinciple('F', 'Freely given',
      'Not pressured, manipulated, or under the influence of alcohol/drugs.',
      Color(0xFFE879A0)),
  _ConsentPrinciple('R', 'Reversible',
      'Anyone can change their mind at any time — even after saying yes.',
      Color(0xFF60A5FA)),
  _ConsentPrinciple('I', 'Informed',
      'You can only consent if you have the full picture. No deception.',
      Color(0xFFFBBF24)),
  _ConsentPrinciple('E', 'Enthusiastic',
      'You should WANT to do it — not just go along with it.',
      Color(0xFF34D399)),
  _ConsentPrinciple('S', 'Specific',
      'Saying yes to one thing doesn\'t mean yes to everything.',
      Color(0xFFA78BFA)),
];

class _ConsentScenario {
  final String scenario;
  final String question;
  final List<_ScenarioOption> options;
  final String correctId;
  final String explanation;

  const _ConsentScenario({
    required this.scenario,
    required this.question,
    required this.options,
    required this.correctId,
    required this.explanation,
  });
}

class _ScenarioOption {
  final String id;
  final String text;

  const _ScenarioOption(this.id, this.text);
}

const _consentScenarios = [
  _ConsentScenario(
    scenario:
        'Alex and Sam are at a party. Sam has had several drinks and is stumbling. Alex asks Sam to go somewhere private.',
    question: 'Can Sam give consent?',
    options: [
      _ScenarioOption('a', 'Yes — Sam is old enough to make decisions'),
      _ScenarioOption('b', 'No — Sam is too intoxicated to give informed consent'),
      _ScenarioOption('c', 'Only if Sam says yes verbally'),
    ],
    correctId: 'b',
    explanation:
        'A person who is heavily intoxicated cannot give informed consent. It doesn\'t matter if they say "yes" — they are not in a state to make clear decisions. The right thing is to make sure they get home safely.',
  ),
  _ConsentScenario(
    scenario:
        'Jordan and Casey have been dating for 3 months. They\'ve kissed before. Jordan wants to go further, but Casey says "I\'m not ready."',
    question: 'What should Jordan do?',
    options: [
      _ScenarioOption('a', 'Keep trying — they\'ve been together a while'),
      _ScenarioOption('b', 'Respect Casey\'s answer completely and not bring it up again until Casey does'),
      _ScenarioOption('c', 'Say "okay" but act disappointed to guilt Casey'),
    ],
    correctId: 'b',
    explanation:
        'Consent means respecting the answer — fully. Being in a relationship doesn\'t mean you owe anyone anything physical. Guilt-tripping or repeatedly asking is a form of pressure, which is not consent.',
  ),
  _ConsentScenario(
    scenario:
        'Taylor sends a selfie to a friend. The friend shares it in a group chat without asking.',
    question: 'Is this okay?',
    options: [
      _ScenarioOption('a', 'Yes — it\'s just a selfie'),
      _ScenarioOption('b', 'No — sharing someone\'s photo without permission is a breach of consent'),
      _ScenarioOption('c', 'Only if it\'s a non-embarrassing photo'),
    ],
    correctId: 'b',
    explanation:
        'Consent applies to digital content too. Sharing someone\'s photos, messages, or personal information without their permission is a breach of trust and consent. Always ask before sharing.',
  ),
  _ConsentScenario(
    scenario:
        'Riley and Jamie are together. They\'ve done something physical before. Today, Riley says yes initially but then says "actually, I want to stop."',
    question: 'What happens now?',
    options: [
      _ScenarioOption('a', 'They already said yes, so they should continue'),
      _ScenarioOption('b', 'Jamie should stop immediately — consent can be withdrawn at any time'),
      _ScenarioOption('c', 'They should finish what they started'),
    ],
    correctId: 'b',
    explanation:
        'Consent is REVERSIBLE. Anyone can change their mind at any time — even mid-way through. The moment someone says stop, you stop. No exceptions, no arguments.',
  ),
  _ConsentScenario(
    scenario:
        'A 19-year-old is messaging a 14-year-old and asks them for photos.',
    question: 'Is this acceptable?',
    options: [
      _ScenarioOption('a', 'If the 14-year-old agrees, it\'s okay'),
      _ScenarioOption('b', 'No — this is inappropriate regardless of whether the younger person agrees'),
      _ScenarioOption('c', 'It depends on what kind of photos'),
    ],
    correctId: 'b',
    explanation:
        'A young person under the age of consent cannot give legal consent, and the age gap creates a power imbalance. An older person requesting photos from a minor is predatory behaviour. If this happens to you or someone you know, tell a trusted adult immediately.',
  ),
];

// ── Relationship signs ──

const _healthySigns = [
  'You feel safe and respected',
  'You can be yourself without fear',
  'They support your goals and friendships',
  'You can disagree without it becoming scary',
  'They respect your boundaries (including physical)',
  'Communication is open and honest',
  'They celebrate your successes',
  'You feel free to spend time apart',
];

const _warningSigns = [
  'They try to control who you see or talk to',
  'They check your phone without permission',
  'They make you feel guilty for saying no',
  'They use anger or silence to punish you',
  'They pressure you physically or emotionally',
  'They put you down or belittle you, even "as a joke"',
  'You feel like you\'re walking on eggshells',
  'They threaten to share private information or images',
];

const _relationshipRights = [
  'To be treated with respect',
  'To say no at any time — for any reason',
  'To have your own friends, interests, and privacy',
  'To feel safe physically and emotionally',
  'To change your mind',
  'To leave a relationship at any time',
  'To ask for help without being judged',
];

// ── STI Data ──

class _StiInfo {
  final String name;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final bool treatable;

  const _StiInfo({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    this.treatable = true,
  });
}

const _stiKeyFacts = [
  'Many STIs have NO visible symptoms — you can have one without knowing',
  'STIs are very common and nothing to be ashamed of',
  'Most STIs are easily treatable, especially when caught early',
  'Condoms are the best protection against STIs (other than abstinence)',
  'Getting tested regularly is a responsible and mature thing to do',
  'You can get tested confidentially at sexual health clinics',
];

const _stiInfoCards = [
  _StiInfo(
    name: 'Chlamydia',
    description:
        'The most common STI in young people. A bacterial infection that can affect the genitals, throat, or rectum.',
    symptoms:
        'Often no symptoms at all. May include unusual discharge, pain when urinating, or bleeding between periods.',
    treatment: 'Easily treated with a short course of antibiotics.',
    prevention: 'Condoms. Regular testing (recommended annually if sexually active).',
  ),
  _StiInfo(
    name: 'Gonorrhoea',
    description:
        'A bacterial infection similar to chlamydia. Can infect the genitals, throat, or rectum.',
    symptoms:
        'May have no symptoms. Possible green/yellow discharge, pain when urinating, or pain in lower abdomen.',
    treatment: 'Treated with antibiotics (usually an injection and tablets).',
    prevention: 'Condoms. Testing if you change partners.',
  ),
  _StiInfo(
    name: 'Genital Herpes (HSV)',
    description:
        'A viral infection causing blisters or sores around the genitals. Very common — many people carry it without knowing.',
    symptoms:
        'Tingling or itching, followed by blisters that become sores. First outbreak is usually worst. Many people have no symptoms.',
    treatment:
        'No cure, but antiviral medication manages symptoms. Outbreaks usually become less frequent over time.',
    prevention: 'Condoms reduce risk but don\'t eliminate it (skin-to-skin contact).',
    treatable: false,
  ),
  _StiInfo(
    name: 'HPV (Human Papillomavirus)',
    description:
        'The most common STI worldwide. Many strains — some cause genital warts, some can cause cancer over time.',
    symptoms:
        'Often no symptoms. Some strains cause visible warts. High-risk strains have no symptoms but can cause cell changes.',
    treatment:
        'Warts can be treated. The body often clears HPV on its own. Cervical screening detects cell changes early.',
    prevention: 'HPV vaccination (offered to all young people). Condoms reduce but don\'t eliminate risk.',
    treatable: false,
  ),
  _StiInfo(
    name: 'HIV',
    description:
        'A virus that attacks the immune system. With modern treatment, people with HIV live long and healthy lives.',
    symptoms:
        'Initial flu-like illness 2–6 weeks after infection. Then often no symptoms for years.',
    treatment:
        'No cure, but antiretroviral therapy (ART) keeps the virus undetectable and untransmittable (U=U).',
    prevention: 'Condoms. PrEP (preventative medication). Testing. Never share needles.',
    treatable: false,
  ),
  _StiInfo(
    name: 'Syphilis',
    description:
        'A bacterial infection that progresses in stages. Rates have been increasing in recent years.',
    symptoms:
        'Stage 1: painless sore. Stage 2: rash, flu-like symptoms. Can become serious if untreated.',
    treatment: 'Easily treated with antibiotics, especially in early stages.',
    prevention: 'Condoms. Regular testing.',
  ),
];

const _protectionTips = [
  'Use condoms correctly and consistently — they protect against most STIs',
  'Get the HPV vaccine if you haven\'t already',
  'Get tested regularly — many clinics offer free, confidential testing',
  'Talk to your partner about testing before becoming sexually active together',
  'Limit the number of sexual partners to reduce risk',
  'Never share needles or drug equipment',
  'If you think you\'ve been exposed, get tested — don\'t wait for symptoms',
];

// ── Key Facts ──

class _KeyFactTopic {
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;
  final Color colour;

  const _KeyFactTopic({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    required this.colour,
  });
}

const _keyFactTopics = [
  _KeyFactTopic(
    title: 'Age of Consent',
    subtitle: 'Understanding the law',
    icon: Icons.gavel_rounded,
    colour: Color(0xFF60A5FA),
    content:
        'The age of consent is the legal age at which a person can agree to sexual activity.\n\n'
        '• In the UK, the age of consent is 16\n'
        '• This is the same regardless of gender or sexual orientation\n'
        '• Sex with anyone under 16 is illegal, even if they "agree"\n'
        '• Adults in positions of trust (teachers, coaches) have a higher age of consent (18)\n'
        '• These laws exist to protect young people from exploitation\n\n'
        'The age of consent varies by country. If you travel or are posted abroad, be aware of local laws.',
  ),
  _KeyFactTopic(
    title: 'Pornography vs Reality',
    subtitle: 'Why porn is not sex education',
    icon: Icons.warning_amber_rounded,
    colour: Color(0xFFEF4444),
    content:
        'Many young people encounter pornography online, often accidentally. It\'s important to understand:\n\n'
        '• Porn is NOT real. It\'s performed, directed, and edited like a movie\n'
        '• Bodies in porn are not "normal" — they are selected and often surgically altered\n'
        '• Real intimacy involves communication, awkwardness, and respect\n'
        '• Porn often shows no consent discussion, no protection, and unrealistic expectations\n'
        '• Watching porn can create anxiety about your own body or performance\n'
        '• Many acts shown in porn are not things most people do or enjoy\n\n'
        'If you have questions about what\'s normal, talk to a trusted adult or look at reputable sex education resources — not porn.',
  ),
  _KeyFactTopic(
    title: 'It\'s Okay to Wait',
    subtitle: 'There\'s no pressure or timeline',
    icon: Icons.timer_rounded,
    colour: Color(0xFF34D399),
    content:
        'Despite what you might hear, there is no "right" time to become sexually active:\n\n'
        '• Many young people wait, and that\'s completely normal\n'
        '• Virginity is not something to "lose" — it\'s a personal choice\n'
        '• People who wait often report more positive first experiences\n'
        '• There\'s no rush. You have your whole life\n'
        '• Anyone who pressures you is NOT respecting you\n'
        '• Being curious is normal — acting on curiosity should only happen when YOU are ready\n\n'
        'The right time is when you feel safe, informed, and genuinely want to — with someone who respects you fully.',
  ),
  _KeyFactTopic(
    title: 'Sexting & Nude Images',
    subtitle: 'The law and the risks',
    icon: Icons.phone_android_rounded,
    colour: Color(0xFFF59E0B),
    content:
        'Sending or receiving sexual images is a serious matter, especially for under-18s:\n\n'
        '• Taking, sending, or possessing sexual images of under-18s is illegal — even your own images\n'
        '• Once an image is sent, you lose all control over where it goes\n'
        '• Images can be shared, screenshotted, or used for blackmail\n'
        '• "Revenge porn" (sharing intimate images without consent) is a criminal offence\n'
        '• If someone pressures you for images, that is coercion — tell a trusted adult\n'
        '• If an image of you has been shared, you can report it to police or CEOP\n\n'
        'Never send an image you wouldn\'t want your family, school, or future employer to see.',
  ),
  _KeyFactTopic(
    title: 'LGBTQ+ & Identity',
    subtitle: 'Understanding sexuality and gender',
    icon: Icons.diversity_3_rounded,
    colour: Color(0xFFA78BFA),
    content:
        'Sexuality and gender identity are natural parts of who you are:\n\n'
        '• Sexual orientation (who you\'re attracted to) exists on a spectrum\n'
        '• Common terms: straight, gay, lesbian, bisexual, asexual, pansexual — and more\n'
        '• Gender identity (how you feel inside) may or may not match the sex you were assigned at birth\n'
        '• It\'s normal to question or explore your identity — there\'s no deadline\n'
        '• You don\'t have to label yourself if you don\'t want to\n'
        '• Coming out is a personal choice — only do it when you feel safe and ready\n\n'
        'Everyone deserves to be treated with respect regardless of their identity. Discrimination and bullying based on sexuality or gender is never acceptable.',
  ),
  _KeyFactTopic(
    title: 'Where to Get Help',
    subtitle: 'Confidential support and advice',
    icon: Icons.support_agent_rounded,
    colour: Color(0xFFE879A0),
    content:
        'If you need advice, support, or are worried about anything:\n\n'
        '• Your GP / Doctor — completely confidential, even for under-16s\n'
        '• Sexual health clinics — free, confidential testing and advice\n'
        '• School nurse or counsellor\n'
        '• Childline — free, confidential support for under-19s (available online)\n'
        '• Brook — sexual health charity for young people (brook.org.uk)\n'
        '• The Mix — support for under-25s (themix.org.uk)\n\n'
        'Asking for help or information is a sign of maturity, not weakness. No question is too embarrassing.',
  ),
];
