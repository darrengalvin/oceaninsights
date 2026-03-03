import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

class LgbtqSupportScreen extends StatefulWidget {
  const LgbtqSupportScreen({super.key});

  @override
  State<LgbtqSupportScreen> createState() => _LgbtqSupportScreenState();
}

class _LgbtqSupportScreenState extends State<LgbtqSupportScreen>
    with TickerProviderStateMixin, TeaseMixin {
  int _currentTab = 0;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('LGBTQ+ Support');

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
                  _UnderstandTab(onInteract: () {
                    recordTeaseAction();
                    return checkTeaseAndContinue();
                  }),
                  _AllyTab(onAnswer: () {
                    recordTeaseAction();
                    return checkTeaseAndContinue();
                  }),
                  const _DeploymentSafetyTab(),
                  const _SupportTab(),
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
          child: Icon(Icons.arrow_back_rounded, color: colours.textBright),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LGBTQ+ Support',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text('For everyone — members and allies',
                  style: TextStyle(color: colours.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colours = context.colours;
    final tabs = ['Understand', 'Be an Ally', 'Stay Safe', 'Support'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                margin: EdgeInsets.symmetric(horizontal: 2),
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
                        fontSize: 11)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 1 — Understand (History Timeline + Myth Buster)
// ═══════════════════════════════════════════════════════════════════

class _UnderstandTab extends StatefulWidget {
  final bool Function() onInteract;
  const _UnderstandTab({required this.onInteract});

  @override
  State<_UnderstandTab> createState() => _UnderstandTabState();
}

class _UnderstandTabState extends State<_UnderstandTab> {
  int _section = 0; // 0=timeline, 1=myths, 2=terminology

  static const List<Map<String, String>> _timeline = [
    {'year': '1967', 'event': 'Homosexuality partially decriminalised in England & Wales', 'detail': 'The Sexual Offences Act decriminalised private homosexual acts between men over 21, but the military remained exempt.'},
    {'year': '1994', 'event': 'Age of consent lowered to 18 for gay men', 'detail': 'Still not equal — the heterosexual age of consent was 16. The military continued to discharge LGBTQ+ personnel.'},
    {'year': '2000', 'event': 'UK Armed Forces ban on LGBTQ+ service lifted', 'detail': 'Following the European Court of Human Rights ruling in Smith and Grady v UK, the blanket ban was lifted on 12 January 2000. Thousands had already been dismissed.'},
    {'year': '2004', 'event': 'Civil Partnership Act passed', 'detail': 'Same-sex couples gained legal recognition. Military families began to access some partner benefits for the first time.'},
    {'year': '2010', 'event': 'Equality Act becomes law', 'detail': 'Comprehensive protection against discrimination based on sexual orientation and gender reassignment in all areas, including the military.'},
    {'year': '2014', 'event': 'Same-sex marriage legalised in England & Wales', 'detail': 'Full marriage equality. Military chaplains were not compelled to perform ceremonies but same-sex married couples received equal benefits.'},
    {'year': '2017', 'event': 'UK Government apologises for historical treatment', 'detail': 'A formal apology was issued, acknowledging the suffering caused by the ban. Many veterans were still waiting for pardons and recognition.'},
    {'year': '2023', 'event': 'LGBT Veterans Independent Review (Etherton Review)', 'detail': 'Lord Etherton\'s independent review examined the impact of the ban. The government accepted all recommendations and committed to restorative measures.'},
    {'year': '2025', 'event': 'US reinstates transgender military ban', 'detail': 'Executive order bars transgender people from enlisting and serving openly. The Supreme Court allows it to take effect. This does not affect UK forces, but affects allied operations.'},
  ];

  static const List<Map<String, dynamic>> _myths = [
    {'myth': 'LGBTQ+ people can\'t handle the pressure of military life.', 'truth': false, 'explanation': 'LGBTQ+ people have served with distinction throughout history — often while hiding their identity, which required extraordinary resilience on top of their duties.'},
    {'myth': 'The UK lifted its ban on LGBTQ+ military service in 2000.', 'truth': true, 'explanation': 'The ban was lifted on 12 January 2000 after the European Court of Human Rights ruled it a violation of human rights. Before this, an estimated 5,000+ people were dismissed.'},
    {'myth': 'Being LGBTQ+ is accepted worldwide.', 'truth': false, 'explanation': 'As of 2025, 65 countries still criminalise same-sex activity. In some, the penalty is death. Service members deployed to these regions face real danger if their identity is discovered.'},
    {'myth': 'LGBTQ+ veterans have the same mental health outcomes as other veterans.', 'truth': false, 'explanation': 'Research shows LGBTQ+ veterans face significantly higher rates of depression, anxiety, and suicidal ideation — not because of their identity, but because of stigma, discrimination, and isolation.'},
    {'myth': 'If someone hasn\'t "come out" they\'re probably not LGBTQ+.', 'truth': false, 'explanation': 'Many people don\'t feel safe to come out, especially in military environments. Someone\'s silence about their identity doesn\'t mean it doesn\'t exist — it often means they don\'t feel safe.'},
    {'myth': 'Allies aren\'t important — it\'s up to LGBTQ+ people to support themselves.', 'truth': false, 'explanation': 'Allies are vital. Research shows that even one supportive person can dramatically reduce the risk of depression and suicide in LGBTQ+ individuals. Your support literally saves lives.'},
    {'myth': 'The UK military is now fully inclusive — the work is done.', 'truth': false, 'explanation': 'While huge progress has been made, many LGBTQ+ veterans who were dismissed before 2000 are still waiting for full recognition and support. And serving members can still face day-to-day prejudice.'},
    {'myth': 'Gender identity and sexual orientation are the same thing.', 'truth': false, 'explanation': 'Sexual orientation is about who you\'re attracted to. Gender identity is about who you are. A transgender person can be straight, gay, bisexual, or any other orientation.'},
  ];

  static const List<Map<String, String>> _terms = [
    {'term': 'LGBTQ+', 'meaning': 'Lesbian, Gay, Bisexual, Transgender, Queer/Questioning, and more. The "+" recognises the spectrum of identities beyond these.'},
    {'term': 'Transgender', 'meaning': 'A person whose gender identity differs from the sex they were assigned at birth. This is about identity, not sexual orientation.'},
    {'term': 'Non-binary', 'meaning': 'A person who doesn\'t identify exclusively as male or female. Some use they/them pronouns but not all.'},
    {'term': 'Cisgender', 'meaning': 'A person whose gender identity matches the sex they were assigned at birth. Most people are cisgender.'},
    {'term': 'Coming Out', 'meaning': 'The process of sharing one\'s sexual orientation or gender identity with others. It\'s deeply personal and should never be forced or done on someone else\'s behalf.'},
    {'term': 'Ally', 'meaning': 'Someone who supports LGBTQ+ people. You don\'t have to be LGBTQ+ to stand up for equality and inclusion.'},
    {'term': 'Deadnaming', 'meaning': 'Using a transgender person\'s birth name after they\'ve changed it. This can be deeply hurtful, even if unintentional.'},
    {'term': 'Intersex', 'meaning': 'A person born with physical sex characteristics that don\'t fit typical definitions of male or female. More common than many realise — about 1.7% of people.'},
  ];

  int _mythIndex = 0;
  bool? _mythAnswer;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _sectionChip(context, 'Timeline', 0),
              const SizedBox(width: 8),
              _sectionChip(context, 'Myth Buster', 1),
              const SizedBox(width: 8),
              _sectionChip(context, 'Terminology', 2),
            ],
          ),
        ),
        Expanded(
          child: _section == 0
              ? _buildTimeline(context)
              : _section == 1
                  ? _buildMyths(context)
                  : _buildTerminology(context),
        ),
      ],
    );
  }

  Widget _sectionChip(BuildContext context, String label, int index) {
    final colours = context.colours;
    final sel = _section == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _section = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF6C5CE7).withOpacity(0.15) : colours.cardLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel ? const Color(0xFF6C5CE7).withOpacity(0.4) : colours.border.withOpacity(0.2)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? const Color(0xFF6C5CE7) : colours.textMuted)),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final colours = context.colours;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _timeline.length,
      itemBuilder: (context, i) {
        final item = _timeline[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                child: Text(item['year']!,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6C5CE7),
                        fontSize: 14)),
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      border: Border.all(color: const Color(0xFF6C5CE7), width: 2),
                    ),
                  ),
                  if (i < _timeline.length - 1)
                    Container(width: 2, height: 80, color: const Color(0xFF6C5CE7).withOpacity(0.15)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colours.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colours.border.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['event']!,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colours.textBright,
                              fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(item['detail']!,
                          style: TextStyle(
                              color: colours.textLight,
                              height: 1.4,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyths(BuildContext context) {
    final colours = context.colours;
    final myth = _myths[_mythIndex];
    final correctAnswer = myth['truth'] as bool;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        const SizedBox(height: 8),
        Text('${_mythIndex + 1} of ${_myths.length}',
            style: TextStyle(color: colours.textMuted.withOpacity(0.6), fontSize: 12)),
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
            const Icon(Icons.help_outline_rounded, size: 32, color: Color(0xFF6C5CE7)),
            const SizedBox(height: 12),
            Text('"${myth['myth']}"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colours.textBright,
                    fontStyle: FontStyle.italic,
                    height: 1.4)),
          ]),
        ),
        const SizedBox(height: 16),
        if (_mythAnswer == null)
          Row(children: [
            Expanded(
              child: _TapButton(
                  label: 'TRUE', color: const Color(0xFF00B894),
                  onTap: () { if (!widget.onInteract()) return; HapticFeedback.mediumImpact(); setState(() => _mythAnswer = true); }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TapButton(
                  label: 'FALSE', color: Colors.red.shade400,
                  onTap: () { if (!widget.onInteract()) return; HapticFeedback.mediumImpact(); setState(() => _mythAnswer = false); }),
            ),
          ])
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_mythAnswer == correctAnswer)
                  ? const Color(0xFF00B894).withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: (_mythAnswer == correctAnswer)
                      ? const Color(0xFF00B894).withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3)),
            ),
            child: Column(children: [
              Text(
                  _mythAnswer == correctAnswer ? 'Correct' : 'The answer is ${correctAnswer ? "TRUE" : "FALSE"}',
                  style: TextStyle(
                      color: _mythAnswer == correctAnswer ? const Color(0xFF00B894) : Colors.orange,
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              Text(myth['explanation'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colours.textBright, height: 1.4, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 12),
          if (_mythIndex < _myths.length - 1)
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); setState(() { _mythIndex++; _mythAnswer = null; }); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: colours.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('Next', style: TextStyle(color: colours.accent, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildTerminology(BuildContext context) {
    final colours = context.colours;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _terms.length,
      itemBuilder: (context, i) {
        final t = _terms[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colours.border.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t['term']!,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6C5CE7),
                      fontSize: 15)),
              const SizedBox(height: 6),
              Text(t['meaning']!,
                  style: TextStyle(color: colours.textLight, height: 1.4, fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 2 — Be an Ally (Scenarios)
// ═══════════════════════════════════════════════════════════════════

class _AllyTab extends StatefulWidget {
  final bool Function() onAnswer;
  const _AllyTab({required this.onAnswer});

  @override
  State<_AllyTab> createState() => _AllyTabState();
}

class _AllyTabState extends State<_AllyTab> {
  int _current = 0;
  int? _selected;
  bool _revealed = false;

  static const List<Map<String, dynamic>> _scenarios = [
    {
      'scenario': 'In the mess, someone makes a homophobic joke. Everyone laughs. A colleague you suspect is gay goes quiet.',
      'options': ['Laugh along — it\'s just banter', 'Say nothing but check on them later', 'Call it out calmly — "That\'s not on"'],
      'best': 2,
      'explanation': 'Calling it out in the moment — even briefly — sends a powerful signal. "That\'s not on" is enough. Silence is interpreted as agreement. Checking privately is good too, but it doesn\'t change the culture.',
    },
    {
      'scenario': 'A colleague comes out to you privately. You\'re the first person they\'ve told in the military.',
      'options': ['Tell them it doesn\'t change anything between you', 'Ask lots of questions about their personal life', 'Suggest they tell the chain of command'],
      'best': 0,
      'explanation': 'The most powerful thing you can say is that it doesn\'t change your respect for them. Don\'t probe for details — let them share what they want, when they want. Coming out is their choice, not yours to manage.',
    },
    {
      'scenario': 'You hear someone referring to a transgender colleague by their old name (deadnaming) behind their back.',
      'options': ['It\'s not your business', 'Correct them gently — "They go by [correct name] now"', 'Report it to the chain of command immediately'],
      'best': 1,
      'explanation': 'A gentle correction normalises using the right name. It doesn\'t need to be a big deal — that\'s what makes it effective. If it becomes a pattern of harassment, then escalation is appropriate.',
    },
    {
      'scenario': 'Your unit is deploying to a country where being LGBTQ+ is illegal. You know a colleague is gay.',
      'options': ['Warn them publicly so everyone is careful', 'Have a quiet word — ask if they\'re aware and if they need support', 'It\'s their problem to manage'],
      'best': 1,
      'explanation': 'A quiet, private conversation shows you care without outing them. They likely already know, but knowing someone has their back is incredibly reassuring. Never out someone publicly, even with good intentions.',
    },
    {
      'scenario': 'During Pride Month, rainbow lanyards appear on base. A colleague scoffs and says "Why do they need special treatment?"',
      'options': ['Agree — it does seem like special treatment', 'Explain that visibility isn\'t special treatment, it\'s about safety and belonging', 'Change the subject'],
      'best': 1,
      'explanation': 'Visibility matters. For decades, LGBTQ+ service members served in silence and fear. Visible support signals that they belong. It\'s not special treatment — it\'s catching up on years of exclusion.',
    },
    {
      'scenario': 'You\'re filling out a form that asks for "next of kin." A colleague asks if they can put their same-sex partner.',
      'options': ['Say "I don\'t know, check with admin"', 'Confirm yes — same-sex partners are legally recognised for all purposes', 'Suggest they put a family member instead to avoid complications'],
      'best': 1,
      'explanation': 'Under UK law, same-sex partners (married or civil partners) have identical legal standing. There should be zero hesitation. The confidence of your "yes" matters — it tells them they\'re fully equal.',
    },
  ];

  void _select(int i) {
    if (_revealed) return;
    if (!widget.onAnswer()) return;
    HapticFeedback.mediumImpact();
    setState(() { _selected = i; _revealed = true; });
  }

  void _next() {
    if (_current < _scenarios.length - 1) {
      HapticFeedback.lightImpact();
      setState(() { _current++; _selected = null; _revealed = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final s = _scenarios[_current];
    final best = s['best'] as int;
    final options = s['options'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        const SizedBox(height: 8),
        Text('What would you do?',
            style: TextStyle(color: colours.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        Text('${_current + 1} of ${_scenarios.length}',
            style: TextStyle(color: colours.textMuted.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colours.border.withOpacity(0.3)),
          ),
          child: Text(s['scenario'] as String,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500, color: colours.textBright, height: 1.4)),
        ),
        const SizedBox(height: 16),
        ...List.generate(options.length, (i) {
          final isSel = _selected == i;
          final isBest = i == best;
          Color bg, border;
          if (!_revealed) {
            bg = colours.cardLight; border = colours.border.withOpacity(0.3);
          } else if (isSel && isBest) {
            bg = const Color(0xFF00B894).withOpacity(0.15); border = const Color(0xFF00B894).withOpacity(0.5);
          } else if (isSel) {
            bg = Colors.orange.withOpacity(0.1); border = Colors.orange.withOpacity(0.4);
          } else if (isBest) {
            bg = const Color(0xFF00B894).withOpacity(0.08); border = const Color(0xFF00B894).withOpacity(0.3);
          } else {
            bg = colours.cardLight.withOpacity(0.5); border = colours.border.withOpacity(0.15);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _select(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                child: Row(children: [
                  Expanded(child: Text(options[i],
                      style: TextStyle(color: colours.textBright, fontWeight: isSel ? FontWeight.w600 : FontWeight.w400, fontSize: 14))),
                  if (_revealed && isBest) const Icon(Icons.check_circle_rounded, color: Color(0xFF00B894), size: 20),
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
              border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
            ),
            child: Text(s['explanation'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(color: colours.textBright, fontWeight: FontWeight.w500, height: 1.4, fontSize: 14)),
          ),
          const SizedBox(height: 12),
          if (_current < _scenarios.length - 1)
            GestureDetector(
              onTap: _next,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: colours.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('Next Scenario', style: TextStyle(color: colours.accent, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 3 — Deployment Safety
// ═══════════════════════════════════════════════════════════════════

class _DeploymentSafetyTab extends StatelessWidget {
  const _DeploymentSafetyTab();

  static const List<Map<String, dynamic>> _regions = [
    {
      'region': 'Severe Risk — Death Penalty',
      'color': Color(0xFFE74C3C),
      'icon': Icons.dangerous_rounded,
      'countries': 'Afghanistan, Brunei, Iran, Mauritania, Nigeria (north), Pakistan, Qatar, Saudi Arabia, Somalia, UAE, Yemen',
      'advice': 'Same-sex activity can carry the death penalty. Absolute discretion is essential. No digital evidence, no disclosure to locals, no LGBTQ+ apps on personal devices.',
    },
    {
      'region': 'High Risk — Imprisonment',
      'color': Color(0xFFE67E22),
      'icon': Icons.warning_rounded,
      'countries': 'Egypt, Kenya, Malaysia, Myanmar, Oman, Singapore, Sri Lanka, Tanzania, Uganda, and 20+ others',
      'advice': 'Imprisonment of 10+ years for same-sex activity. Exercise extreme caution. Avoid any public display of affection or disclosure. Be aware of local informant culture.',
    },
    {
      'region': 'Elevated Risk — Criminalised',
      'color': Color(0xFFF39C12),
      'icon': Icons.shield_rounded,
      'countries': 'Jamaica, Trinidad & Tobago, Ghana, Cameroon, Morocco, Tunisia, and others',
      'advice': 'Same-sex activity is illegal with varying enforcement. Stay vigilant. Laws may be selectively enforced against foreigners.',
    },
    {
      'region': 'Caution — Social Hostility',
      'color': Color(0xFF3498DB),
      'icon': Icons.info_rounded,
      'countries': 'Russia, Hungary, Poland (some regions), Turkey, Indonesia',
      'advice': 'Not criminalised but significant social hostility exists. Pride events banned in some areas. Avoid public displays of affection and be aware of surveillance.',
    },
    {
      'region': 'Generally Safe — Legal Protections',
      'color': Color(0xFF00B894),
      'icon': Icons.check_circle_rounded,
      'countries': 'UK, most EU nations, Canada, Australia, New Zealand, and others',
      'advice': 'Legal protections in place. Same-sex marriage recognised. Still exercise normal personal security awareness.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(children: [
            const Icon(Icons.security_rounded, color: Colors.red, size: 28),
            const SizedBox(height: 8),
            Text('65 countries still criminalise LGBTQ+ activity.\n11 carry the death penalty.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colours.textBright, fontWeight: FontWeight.w600, height: 1.4)),
            const SizedBox(height: 8),
            Text('If you\'re deploying, know your destination.',
                style: TextStyle(color: colours.textMuted, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 16),
        ..._regions.map((r) => _RegionCard(region: r)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colours.border.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('General Safety Tips',
                  style: TextStyle(fontWeight: FontWeight.w700, color: colours.textBright, fontSize: 15)),
              const SizedBox(height: 10),
              _safeTip(colours, 'Remove LGBTQ+ dating apps before deployment'),
              _safeTip(colours, 'Be cautious with social media — it can be monitored'),
              _safeTip(colours, 'Know your unit\'s welfare contacts before you go'),
              _safeTip(colours, 'If you feel unsafe, your welfare officer is there for you'),
              _safeTip(colours, 'You have the right to confidential support at all times'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _safeTip(AppColours colours, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, color: const Color(0xFF00B894), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: colours.textLight, height: 1.4, fontSize: 13))),
        ],
      ),
    );
  }
}

class _RegionCard extends StatefulWidget {
  final Map<String, dynamic> region;
  const _RegionCard({required this.region});

  @override
  State<_RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<_RegionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final r = widget.region;
    final color = r['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _expanded = !_expanded);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(r['icon'] as IconData, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(r['region'] as String,
                      style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more_rounded, color: colours.textMuted, size: 22),
                ),
              ]),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Text('Includes: ${r['countries']}',
                    style: TextStyle(color: colours.textMuted, fontSize: 12, height: 1.4)),
                const SizedBox(height: 10),
                Text(r['advice'] as String,
                    style: TextStyle(color: colours.textBright, fontSize: 13, height: 1.4)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 4 — Get Support
// ═══════════════════════════════════════════════════════════════════

class _SupportTab extends StatelessWidget {
  const _SupportTab();

  static const List<Map<String, String>> _resources = [
    {
      'name': 'Fighting With Pride',
      'description': 'The UK Armed Forces LGBTQ+ charity. Support for serving personnel, veterans, and families. Founded by those who experienced the ban.',
      'contact': '020 3981 3810',
      'website': 'fightingwithpride.org.uk',
      'emoji': '🏳️‍🌈',
    },
    {
      'name': 'Op COURAGE',
      'description': 'NHS veteran mental health and wellbeing service. Confidential, free, and designed for veterans. Available across England.',
      'contact': 'Via GP or self-referral',
      'website': 'nhs.uk/opcourage',
      'emoji': '💚',
    },
    {
      'name': 'Samaritans',
      'description': 'Available 24/7 for anyone struggling. You don\'t have to be suicidal to call. They listen without judgement.',
      'contact': '116 123 (free, 24/7)',
      'website': 'samaritans.org',
      'emoji': '📞',
    },
    {
      'name': 'Switchboard LGBT+ Helpline',
      'description': 'A safe space for anyone to discuss anything, including sexuality, gender identity, and emotional wellbeing.',
      'contact': '0800 0119 100',
      'website': 'switchboard.lgbt',
      'emoji': '💜',
    },
    {
      'name': 'Mermaids',
      'description': 'Support for transgender, non-binary, and gender-diverse young people and their families.',
      'contact': '0808 801 0400',
      'website': 'mermaidsuk.org.uk',
      'emoji': '🧜',
    },
    {
      'name': 'Modern Military Association (US/International)',
      'description': 'The largest US advocacy group for LGBTQ+ military and veterans. Resources, legal support, and community.',
      'contact': 'Via website',
      'website': 'modernmilitary.org',
      'emoji': '🇺🇸',
    },
  ];

  static const List<String> _affirmations = [
    'Your identity is not a weakness — it\'s part of your strength.',
    'You deserve to serve as your full self.',
    'You are not alone. There are people who understand and care.',
    'Your courage to be yourself in a uniform is extraordinary.',
    'Being different in a world that demands conformity is bravery.',
    'You matter. Your wellbeing matters. Reach out if you need to.',
    'The people who came before you fought so you could be here.',
    'It gets better. And you deserve to be here when it does.',
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Affirmation card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6C5CE7).withOpacity(0.12),
                colours.card,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
          ),
          child: Column(children: [
            const Text('💛', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              _affirmations[DateTime.now().day % _affirmations.length],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colours.textBright,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.4),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        Text('SUPPORT ORGANISATIONS',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2, color: colours.accent)),
        const SizedBox(height: 12),

        ..._resources.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colours.border.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(r['emoji']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(r['name']!,
                          style: TextStyle(fontWeight: FontWeight.w700, color: colours.textBright, fontSize: 15)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(r['description']!,
                      style: TextStyle(color: colours.textLight, height: 1.4, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.phone_rounded, size: 14, color: const Color(0xFF00B894)),
                    const SizedBox(width: 6),
                    Text(r['contact']!,
                        style: const TextStyle(color: Color(0xFF00B894), fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.language_rounded, size: 14, color: colours.accent),
                    const SizedBox(width: 6),
                    Text(r['website']!,
                        style: TextStyle(color: colours.accent, fontSize: 13)),
                  ]),
                ],
              ),
            )),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colours.border.withOpacity(0.2)),
          ),
          child: Text(
            'All support is confidential. You don\'t have to go through this alone. Whether you\'re LGBTQ+ yourself or supporting someone who is — reaching out is a sign of strength, not weakness.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colours.textLight, height: 1.5, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════════

class _TapButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TapButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 17)),
      ),
    );
  }
}
