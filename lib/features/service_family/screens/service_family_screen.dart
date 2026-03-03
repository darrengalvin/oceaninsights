import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Service Family — support for partners, spouses & families of serving personnel
///
/// ZERO free-text input. All tap-based. Nothing stored or transmitted.
/// Covers deployment phases, coping strategies, children's support,
/// understanding military life, and getting help.
class ServiceFamilyScreen extends StatefulWidget {
  const ServiceFamilyScreen({super.key});

  @override
  State<ServiceFamilyScreen> createState() => _ServiceFamilyScreenState();
}

class _ServiceFamilyScreenState extends State<ServiceFamilyScreen>
    with TickerProviderStateMixin, TeaseMixin {
  late TabController _tabController;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Service Family');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  bool _gateExpand() {
    recordTeaseAction();
    return checkTeaseAndContinue();
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
          'Service Family',
          style: TextStyle(
            color: colours.textBright,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF60A5FA),
          labelColor: colours.textBright,
          unselectedLabelColor: colours.textMuted,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Deployment'),
            Tab(text: 'Understand'),
            Tab(text: 'Self-Care'),
            Tab(text: 'Children'),
            Tab(text: 'Get Help'),
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
                Icon(Icons.family_restroom_rounded, color: colours.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Supporting the families who support those who serve.',
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
                _buildDeploymentTab(colours),
                _buildUnderstandTab(colours),
                _buildSelfCareTab(colours),
                _buildChildrenTab(colours),
                _buildHelpTab(colours),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: DEPLOYMENT SUPPORT
  // ============================================================

  Widget _buildDeploymentTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(
            colours,
            'The Deployment Cycle',
            'Deployment affects the whole family. Understanding the emotional phases helps you prepare, cope, and recover together.',
            const Color(0xFF60A5FA),
            Icons.timeline_rounded,
          ),
          const SizedBox(height: 16),

          // Deployment phases timeline
          ..._deploymentPhases.asMap().entries.map((entry) {
            final i = entry.key;
            final phase = entry.value;
            return _PhaseCard(
              colours: colours,
              phase: phase,
              index: i,
              isLast: i == _deploymentPhases.length - 1,
              onExpandCheck: _gateExpand,
            );
          }),
          const SizedBox(height: 20),

          // Practical tips
          _ExpandableTile(
            colours: colours,
            onExpandCheck: _gateExpand,
            title: 'Before They Go',
            subtitle: 'Practical preparation checklist',
            emoji: '📋',
            colour: const Color(0xFF60A5FA),
            content:
                'Preparing practically can reduce anxiety:\n\n'
                '• Discuss finances — set up joint access, know where important documents are\n'
                '• Agree on communication expectations — how often, what platforms\n'
                '• Create a family calendar with key dates\n'
                '• Set up a support network — friends, family, other service families\n'
                '• Make a list of emergency contacts (both military and civilian)\n'
                '• Ensure car, house, and appliance maintenance is sorted\n'
                '• Take photos together and write letters/cards to open during deployment\n'
                '• Discuss plans for children\'s routines and activities\n\n'
                'Having a plan reduces the "what ifs" and gives you both confidence.',
          ),
          const SizedBox(height: 10),
          _ExpandableTile(
            colours: colours,
            onExpandCheck: _gateExpand,
            title: 'Communication During Deployment',
            subtitle: 'Making the most of limited contact',
            emoji: '📞',
            colour: const Color(0xFF34D399),
            content:
                'Communication may be limited depending on where they are deployed:\n\n'
                '• Agree in advance on realistic expectations — they may not be able to call when planned\n'
                '• Don\'t assume the worst if you don\'t hear from them\n'
                '• Keep conversations positive when possible — they worry about you too\n'
                '• It\'s okay to share difficult news, but choose the right moment\n'
                '• Send emails, photos, and care packages — these mean everything\n'
                '• If children are involved, help them write letters or draw pictures\n'
                '• Some deployments have "communication blackouts" — this is normal\n\n'
                'Quality matters more than quantity. One good call can sustain you for weeks.',
          ),
          const SizedBox(height: 10),
          _ExpandableTile(
            colours: colours,
            onExpandCheck: _gateExpand,
            title: 'Homecoming & Readjustment',
            subtitle: 'When they come back — what to expect',
            emoji: '🏠',
            colour: const Color(0xFFA78BFA),
            content:
                'Homecoming is exciting but can also be challenging:\n\n'
                '• Don\'t expect everything to go back to "normal" immediately\n'
                '• They may need space and quiet — they\'ve been in a very different environment\n'
                '• You\'ve both grown and changed — that\'s okay\n'
                '• Routines may need renegotiating — you\'ve been running things your way\n'
                '• Intimacy may feel different at first — be patient with each other\n'
                '• Children may react unexpectedly — some may be clingy, others distant\n'
                '• Watch for signs of PTSD or mental health struggles (irritability, nightmares, withdrawal)\n'
                '• Give it time. Most families find a new rhythm within a few weeks\n\n'
                'If readjustment is taking longer than expected, support is available — don\'t wait to ask.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: UNDERSTANDING MILITARY LIFE
  // ============================================================

  Widget _buildUnderstandTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(
            colours,
            'Understanding Their World',
            'Military life is unique. Understanding what your partner or family member experiences helps build empathy and connection.',
            const Color(0xFFFBBF24),
            Icons.psychology_rounded,
          ),
          const SizedBox(height: 16),

          ..._militaryLifeTopics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExpandableTile(
                  colours: colours,
                  onExpandCheck: _gateExpand,
                  title: t.title,
                  subtitle: t.subtitle,
                  emoji: t.emoji,
                  colour: t.colour,
                  content: t.content,
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 3: SELF-CARE
  // ============================================================

  Widget _buildSelfCareTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(
            colours,
            'Looking After Yourself',
            'You can\'t pour from an empty cup. Your wellbeing matters — not just for you, but for your whole family.',
            const Color(0xFFE879A0),
            Icons.favorite_rounded,
          ),
          const SizedBox(height: 16),

          ..._selfCareStrategies.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExpandableTile(
                  colours: colours,
                  onExpandCheck: _gateExpand,
                  title: s.title,
                  subtitle: s.subtitle,
                  emoji: s.emoji,
                  colour: s.colour,
                  content: s.content,
                ),
              )),
          const SizedBox(height: 16),

          // Affirmation card for families
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE879A0).withValues(alpha: 0.15),
                  const Color(0xFFA78BFA).withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE879A0).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Text('💪', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text(
                  'Remember',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ..._familyAffirmations.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '"$a"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colours.textLight,
                          fontSize: 13,
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
  // TAB 4: CHILDREN
  // ============================================================

  Widget _buildChildrenTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(
            colours,
            'Supporting Your Children',
            'Children experience deployment differently depending on their age. Understanding their perspective helps you support them through it.',
            const Color(0xFF34D399),
            Icons.child_care_rounded,
          ),
          const SizedBox(height: 16),

          // Age-specific guidance
          ..._childrenAgeGroups.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExpandableTile(
                  colours: colours,
                  onExpandCheck: _gateExpand,
                  title: g.title,
                  subtitle: g.subtitle,
                  emoji: g.emoji,
                  colour: g.colour,
                  content: g.content,
                ),
              )),
          const SizedBox(height: 16),

          // General tips
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
                    const Icon(Icons.tips_and_updates_rounded,
                        color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'General Tips for All Ages',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._generalChildTips.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('→ ', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 13)),
                          Expanded(
                            child: Text(t,
                                style: TextStyle(
                                    color: colours.textLight,
                                    fontSize: 13,
                                    height: 1.4)),
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
  // TAB 5: GET HELP
  // ============================================================

  Widget _buildHelpTab(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Crisis card
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
                  'In Crisis?',
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'If you or someone in your family is in immediate danger or having a mental health crisis, call your local emergency number now.',
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

          // When to seek help
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
                    const Icon(Icons.help_outline_rounded,
                        color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'When to Seek Help',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._whenToSeekHelp.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(t,
                                style: TextStyle(
                                    color: colours.textLight,
                                    fontSize: 13,
                                    height: 1.3)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Support organisations
          ..._familySupportOrgs.map((org) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF60A5FA).withValues(alpha: 0.2),
                    ),
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
                      const SizedBox(height: 4),
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
                        style: const TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 16),

          // Talking tips
          _ExpandableTile(
            colours: colours,
            onExpandCheck: _gateExpand,
            title: 'How to Ask for Help',
            subtitle: 'Starting the conversation',
            emoji: '💬',
            colour: const Color(0xFF818CF8),
            content:
                'Asking for help is brave, not weak. Here are ways to start:\n\n'
                '• "I\'m struggling with the deployment and could use some support"\n'
                '• "I think I need someone to talk to — can you help me find the right service?"\n'
                '• "My children are finding this hard and I need advice"\n'
                '• "I\'m not coping as well as I thought I would"\n\n'
                'You can talk to:\n'
                '• Your partner\'s unit welfare officer\n'
                '• Your GP / doctor\n'
                '• Any of the organisations listed above\n'
                '• A trusted friend or family member\n\n'
                'You don\'t have to have all the answers. Just reaching out is the first step.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────

  Widget _buildHeaderCard(
    AppColours colours, String title, String body, Color accent, IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.12), accent.withValues(alpha: 0.04)],
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
                child: Text(title,
                    style: TextStyle(
                        color: colours.textBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(body,
              style: TextStyle(
                  color: colours.textLight, fontSize: 13, height: 1.5)),
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
    required this.colours, required this.title, required this.subtitle,
    required this.emoji, required this.colour, required this.content,
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
          color: _expanded ? widget.colour.withValues(alpha: 0.08) : widget.colours.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded ? widget.colour.withValues(alpha: 0.3) : widget.colours.border,
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
                      Text(widget.title, style: TextStyle(color: widget.colours.textBright, fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(widget.subtitle, style: TextStyle(color: widget.colours.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more_rounded, color: widget.colours.textMuted),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 14),
              Container(width: double.infinity, height: 1, color: widget.colours.border),
              const SizedBox(height: 14),
              Text(widget.content, style: TextStyle(color: widget.colours.textLight, fontSize: 13, height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================
// DEPLOYMENT PHASE CARD (timeline)
// ================================================================

class _PhaseCard extends StatefulWidget {
  final AppColours colours;
  final _DeploymentPhase phase;
  final int index;
  final bool isLast;
  final bool Function()? onExpandCheck;

  const _PhaseCard({
    required this.colours, required this.phase, required this.index, required this.isLast,
    this.onExpandCheck,
  });

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.colours;
    final p = widget.phase;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: p.colour.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('${widget.index + 1}',
                      style: TextStyle(color: p.colour, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              if (!widget.isLast)
                Container(width: 2, height: _expanded ? 200 : 60, color: c.border),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _expanded ? p.colour.withValues(alpha: 0.08) : c.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _expanded ? p.colour.withValues(alpha: 0.3) : c.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: TextStyle(color: c.textBright, fontSize: 14, fontWeight: FontWeight.w600)),
                              Text(p.timing, style: TextStyle(color: p.colour, fontSize: 11, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.expand_more_rounded, color: c.textMuted, size: 20),
                        ),
                      ],
                    ),
                    if (_expanded) ...[
                      const SizedBox(height: 10),
                      Text(p.youMayFeel, style: TextStyle(color: c.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(p.feelings, style: TextStyle(color: c.textLight, fontSize: 12, height: 1.5)),
                      const SizedBox(height: 8),
                      Text(p.whatHelps, style: TextStyle(color: c.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(p.tips, style: TextStyle(color: c.textLight, fontSize: 12, height: 1.5)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// STATIC DATA
// ================================================================

class _DeploymentPhase {
  final String name;
  final String timing;
  final String youMayFeel;
  final String feelings;
  final String whatHelps;
  final String tips;
  final Color colour;

  const _DeploymentPhase({
    required this.name, required this.timing, required this.youMayFeel,
    required this.feelings, required this.whatHelps, required this.tips,
    required this.colour,
  });
}

const _deploymentPhases = [
  _DeploymentPhase(
    name: 'Pre-Deployment',
    timing: '4–6 weeks before departure',
    colour: Color(0xFF60A5FA),
    youMayFeel: 'Common feelings:',
    feelings: 'Anxiety, denial, tension, arguments, emotional distance. It\'s common to pick fights or withdraw as a way of "preparing" for separation. This is normal.',
    whatHelps: 'What helps:',
    tips: 'Talk openly about fears. Make practical plans together. Spend quality time without pressure. Accept that mixed emotions are normal.',
  ),
  _DeploymentPhase(
    name: 'Departure',
    timing: 'The day they leave',
    colour: Color(0xFFE879A0),
    youMayFeel: 'Common feelings:',
    feelings: 'Grief, numbness, relief (that the waiting is over), guilt for feeling relieved. The first 24–48 hours are often the hardest.',
    whatHelps: 'What helps:',
    tips: 'Let yourself feel whatever you feel. Have a plan for the first day — be with someone you trust. Don\'t make big decisions in the first week.',
  ),
  _DeploymentPhase(
    name: 'Settling In',
    timing: '1–4 weeks after departure',
    colour: Color(0xFFFBBF24),
    youMayFeel: 'Common feelings:',
    feelings: 'Overwhelm (handling everything alone), loneliness, disorientation, moments of empowerment. You\'re finding your rhythm.',
    whatHelps: 'What helps:',
    tips: 'Establish new routines. Accept help when offered. Connect with other service families. Celebrate small wins — you\'re doing this.',
  ),
  _DeploymentPhase(
    name: 'Stabilisation',
    timing: 'Mid-deployment',
    colour: Color(0xFF34D399),
    youMayFeel: 'Common feelings:',
    feelings: 'Growing confidence, independence, pride. But also potential loneliness, frustration with communication difficulties, and "deployment fatigue."',
    whatHelps: 'What helps:',
    tips: 'Maintain your own social life and interests. Keep counting down if it helps — or don\'t if it makes it harder. Stay connected but don\'t live for calls.',
  ),
  _DeploymentPhase(
    name: 'Pre-Homecoming',
    timing: '2–4 weeks before return',
    colour: Color(0xFFA78BFA),
    youMayFeel: 'Common feelings:',
    feelings: 'Excitement, nervousness, pressure to be perfect, anxiety about readjusting. You may worry: "Will we still be the same?"',
    whatHelps: 'What helps:',
    tips: 'Lower expectations. They\'ve changed and so have you — that\'s okay. Prepare children but keep it calm. Plan the first day but leave space for rest.',
  ),
  _DeploymentPhase(
    name: 'Post-Deployment',
    timing: 'First 3–6 months after return',
    colour: Color(0xFFE879A0),
    youMayFeel: 'Common feelings:',
    feelings: 'Joy, tension, frustration, jealousy (of their experiences or yours), difficulty sharing control of household again. This phase often has the most friction.',
    whatHelps: 'What helps:',
    tips: 'Be patient. Renegotiate roles gradually. Don\'t rush "back to normal." Seek support early if readjustment is difficult. Remember: you\'re on the same team.',
  ),
];

class _Topic {
  final String title;
  final String subtitle;
  final String emoji;
  final Color colour;
  final String content;
  const _Topic({required this.title, required this.subtitle, required this.emoji, required this.colour, required this.content});
}

const _militaryLifeTopics = [
  _Topic(title: 'Why They Can\'t Always Talk About It', subtitle: 'Operational security explained', emoji: '🤐', colour: Color(0xFF60A5FA),
    content: 'Your partner may not be able to share details about their work. This isn\'t about trust — it\'s about security.\n\n• Operational security (OPSEC) means some information must stay classified\n• They may not be able to tell you where they\'re going or what they\'re doing\n• This can feel like being shut out — but it\'s designed to protect everyone\n• Focus on how they\'re feeling rather than what they\'re doing\n• If they seem stressed but can\'t explain why, just being present helps\n\nYou don\'t need to know the details to be supportive. Sometimes "I\'m here for you" is enough.'),
  _Topic(title: 'The Culture of Service', subtitle: 'Why they seem different at home', emoji: '🎖️', colour: Color(0xFFFBBF24),
    content: 'Military culture shapes how people think and behave:\n\n• They\'re trained to suppress emotions and "crack on" — this doesn\'t mean they don\'t feel\n• They may struggle to switch off from "work mode" at home\n• Dark humour is a coping mechanism — it doesn\'t mean they don\'t take things seriously\n• They may seem more rigid or controlling — structure is comforting after chaotic environments\n• Loyalty to their unit is deep — it\'s not a replacement for loyalty to family\n\nUnderstanding the culture helps you not take things personally. It also helps them feel understood.'),
  _Topic(title: 'Frequent Moves & Postings', subtitle: 'Adapting to constant change', emoji: '🏠', colour: Color(0xFF34D399),
    content: 'Military families often relocate every 2–3 years:\n\n• It\'s okay to grieve the life you\'re leaving behind each time\n• Building a support network quickly is essential — other service families understand\n• Children may struggle with changing schools — acknowledge their feelings\n• It gets easier to settle in with practice, but it\'s always a challenge\n• Try to find one constant — a hobby, routine, or tradition that travels with you\n• Some families choose to stay in one place while the serving member commutes — this is valid too\n\nYou are not "just following them around." You are making sacrifices too, and that matters.'),
  _Topic(title: 'Mental Health in the Military', subtitle: 'Understanding what they face', emoji: '🧠', colour: Color(0xFFA78BFA),
    content: 'Mental health challenges are common in service personnel:\n\n• PTSD, anxiety, depression, and adjustment disorders are all more prevalent\n• Many serving members won\'t seek help due to stigma or fear of career impact\n• Signs to watch for: irritability, nightmares, withdrawal, alcohol increase, emotional numbness\n• You cannot fix them — but you can encourage them to seek professional help\n• Don\'t take their struggles personally — it\'s not about you\n• Your own mental health is affected by theirs — you need support too\n\nIf you\'re concerned, speak to their welfare officer or one of the support organisations in the "Get Help" tab.'),
  _Topic(title: 'Social Events & Military Etiquette', subtitle: 'Navigating the social side', emoji: '🎪', colour: Color(0xFFE879A0),
    content: 'Military social events can feel unfamiliar:\n\n• Mess dinners, families days, and social functions are part of military life\n• There may be rank-related social protocols — ask your partner to brief you\n• You don\'t have to attend everything — but showing up sometimes matters to them\n• Other military spouses/partners are often the best resource for what to expect\n• You are not defined by your partner\'s rank — you are your own person\n\nDon\'t worry about getting everything right. Most people are welcoming and understanding.'),
];

const _selfCareStrategies = [
  _Topic(title: 'Managing Loneliness', subtitle: 'When the house feels too quiet', emoji: '🌙', colour: Color(0xFF818CF8),
    content: 'Loneliness during deployment is one of the biggest challenges:\n\n• Keep a routine — structure fills the gaps\n• Stay connected with friends and family, not just the military community\n• Join a class, group, or activity — something that\'s just for you\n• Have a "bad day plan" — a list of things that comfort you (film, walk, call a friend)\n• Don\'t feel guilty for enjoying yourself — life doesn\'t stop during deployment\n• Write a journal or send letters — even if you don\'t post them\n\nLoneliness is not weakness. It\'s the natural response to missing someone you love.'),
  _Topic(title: 'Your Identity Beyond "Military Spouse"', subtitle: 'You are more than their partner', emoji: '✨', colour: Color(0xFFE879A0),
    content: 'It\'s easy to lose yourself in the military lifestyle:\n\n• Pursue your own career, education, or hobbies\n• Set goals that are about YOUR life, not just theirs\n• Build friendships outside the military bubble\n• It\'s okay to say "this is hard" — you don\'t have to be endlessly supportive\n• Your sacrifices are real and valid — acknowledge them\n• Find community with other spouses/partners who understand\n\nA strong relationship needs two whole people — not one person living entirely in the other\'s world.'),
  _Topic(title: 'Dealing with Anger & Resentment', subtitle: 'The feelings nobody talks about', emoji: '😤', colour: Color(0xFFEF4444),
    content: 'It\'s completely normal to sometimes feel:\n\n• Angry that they "chose" this over being at home\n• Resentful about managing everything alone\n• Jealous of families who are together\n• Frustrated by cancelled leave or extended deployments\n• Guilty for feeling any of these things\n\nThese are VALID feelings. Having them doesn\'t make you a bad partner or unsupportive.\n\nWhat helps:\n• Acknowledge the feelings without judgment\n• Talk to someone who understands (other military families)\n• Don\'t bottle it up until it explodes\n• Remember: you can love someone and still be angry about the situation'),
  _Topic(title: 'Physical Wellbeing', subtitle: 'Don\'t forget your body', emoji: '🏃', colour: Color(0xFF34D399),
    content: 'Stress and loneliness can affect your physical health:\n\n• Keep moving — even a 20-minute walk makes a difference\n• Eat properly — it\'s tempting to skip meals or comfort eat\n• Sleep matters — establish a bedtime routine\n• Limit alcohol — it\'s easy to use it as a coping mechanism\n• Don\'t ignore health appointments — GP, dentist, check-ups\n• Base gyms are often available to families — use them if you can\n\nLooking after your body helps your mind cope better too.'),
];

const _familyAffirmations = [
  'I am allowed to find this hard.',
  'My feelings are valid.',
  'I am holding this family together and that takes strength.',
  'Asking for help is brave, not weak.',
  'I matter in this equation too.',
  'This is temporary — we will get through it.',
];

const _childrenAgeGroups = [
  _Topic(title: 'Babies & Toddlers (0–3)', subtitle: 'Too young to understand, but still affected', emoji: '👶', colour: Color(0xFFF472B6),
    content: 'Very young children can\'t understand deployment but they sense changes:\n\n• They may become clingy, fussy, or have sleep disruptions\n• Keep routines as consistent as possible\n• Use photos and videos to maintain familiarity with the deployed parent\n• Play recordings of their voice at bedtime\n• Don\'t force them to interact via video call if they\'re not interested — they\'re too young to understand\n• Your calm energy helps them feel safe\n\nThey won\'t remember the deployment, but the stability you provide now builds their security foundation.'),
  _Topic(title: 'Young Children (4–7)', subtitle: 'They understand something is happening', emoji: '🧒', colour: Color(0xFF60A5FA),
    content: 'Children this age know someone is missing but may not understand why:\n\n• Explain simply: "Daddy/Mummy has to go away for work to help keep people safe"\n• Use a calendar or countdown chain they can physically interact with\n• Let them help pack a care package\n• Expect some regression (bedwetting, tantrums, clinginess)\n• Don\'t promise exact return dates — say "when their job is finished"\n• Read books about deployment — several are written for this age group\n• Reassure frequently: "They love you, they\'ll come back"\n\nConsistency and reassurance are everything at this age.'),
  _Topic(title: 'Older Children (8–12)', subtitle: 'They understand more and worry more', emoji: '📚', colour: Color(0xFFFBBF24),
    content: 'This age group understands deployment is potentially dangerous:\n\n• Be honest but age-appropriate — don\'t lie but don\'t overload with detail\n• Let them express feelings without judgment\n• They may act out at school or with friends — this is their way of processing\n• Give them a job: "You\'re in charge of sending photos to Dad/Mum every week"\n• Maintain their activities and friendships — stability helps\n• Watch for anxiety, sleep changes, or grades dropping\n• News and social media can be scary — monitor and discuss what they see\n\nThey need to feel involved and valued, not just "managed."'),
  _Topic(title: 'Teenagers (13–18)', subtitle: 'They have their own complex feelings', emoji: '🎓', colour: Color(0xFFA78BFA),
    content: 'Teenagers experience deployment through an adult lens:\n\n• They may feel angry, embarrassed, or resentful\n• They may take on a "parent" role to help — watch for them overloading\n• Give them space but stay available\n• Don\'t expect them to be "the man/woman of the house" — they\'re still children\n• They may worry about the same things you do — danger, infidelity, change\n• Social media makes deployment harder — they see other families together\n• Let them communicate with the deployed parent independently too\n\nTeenagers need to know they can be honest about how they feel without being told to "be strong."'),
];

const _generalChildTips = [
  'Maintain routines as much as possible — routine equals safety',
  'Don\'t hide your emotions entirely — children learn it\'s okay to feel from watching you',
  'But don\'t lean on them for emotional support — that\'s an adult\'s job',
  'Let them connect with other military children who understand',
  'Mark milestones together — halfway point, one month to go',
  'Create a "deployment box" with letters, photos, and small gifts from the deployed parent',
  'If behaviour changes significantly, speak to their school and your GP',
  'Remind them regularly: they are loved, they are safe, and this is temporary',
];

const _whenToSeekHelp = [
  'You\'re feeling overwhelmed most days',
  'You\'re not sleeping, eating, or functioning normally',
  'You\'re using alcohol or other substances to cope',
  'Your children\'s behaviour has changed significantly',
  'You feel isolated and have nobody to talk to',
  'You\'re having thoughts of self-harm',
  'Your partner has returned but something feels very wrong',
  'You\'re in a relationship that feels controlling or unsafe',
];

class _SupportOrg {
  final String name;
  final String description;
  final String access;
  const _SupportOrg(this.name, this.description, this.access);
}

const _familySupportOrgs = [
  _SupportOrg('SSAFA', 'The Armed Forces charity providing support to serving families, including emotional, practical, and financial help.', 'ssafa.org.uk — online and local support'),
  _SupportOrg('Army Families Federation (AFF)', 'Independent voice for Army families. Advice on housing, education, health, and deployment.', 'aff.org.uk'),
  _SupportOrg('Naval Families Federation (NFF)', 'Support and advocacy for Royal Navy and Royal Marines families.', 'nff.org.uk'),
  _SupportOrg('RAF Families Federation', 'Independent support for RAF families on all aspects of service life.', 'raf-ff.org.uk'),
  _SupportOrg('Combat Stress', 'Mental health charity for veterans and serving personnel. Also supports families.', 'combatstress.org.uk'),
  _SupportOrg('HIVE Information Service', 'Free, confidential information for service families. Available on most bases.', 'Ask your unit welfare office for local HIVE details'),
  _SupportOrg('Relate', 'Relationship counselling for couples and families. Military-specific services available.', 'relate.org.uk — online and in-person'),
  _SupportOrg('Winston\'s Wish', 'Support for children experiencing grief or bereavement, including military families.', 'winstonswish.org'),
];
