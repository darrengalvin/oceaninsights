import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

class MilitaryPerksScreen extends StatefulWidget {
  const MilitaryPerksScreen({super.key});

  @override
  State<MilitaryPerksScreen> createState() => _MilitaryPerksScreenState();
}

class _MilitaryPerksScreenState extends State<MilitaryPerksScreen>
    with TickerProviderStateMixin, TeaseMixin {
  int _currentTab = 0;

  @override
  TeaseConfig get teaseConfig => TeaseConfig.content('Military Perks');

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
                  const _PerkCalculatorTab(),
                  _DidYouKnowTab(onSwipe: () {
                    recordTeaseAction();
                    return checkTeaseAndContinue();
                  }),
                  _RegretStoriesTab(onSwipe: () {
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Military Perks',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colours = context.colours;
    final tabs = ['Calculator', 'Did You Know?', 'Regret Stories'];
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
                    right: i < 2 ? 4 : 0, left: i > 0 ? 4 : 0),
                decoration: BoxDecoration(
                  color: selected
                      ? colours.accent.withOpacity(0.15)
                      : colours.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: selected
                          ? colours.accent.withOpacity(0.4)
                          : colours.border.withOpacity(0.3)),
                ),
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? colours.accent : colours.textMuted,
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
// Tab 1 — Perk Calculator
// ═══════════════════════════════════════════════════════════════════

class _PerkCalculatorTab extends StatefulWidget {
  const _PerkCalculatorTab();

  @override
  State<_PerkCalculatorTab> createState() => _PerkCalculatorTabState();
}

class _PerkCalculatorTabState extends State<_PerkCalculatorTab> {
  int _rankTier = 0; // 0=Junior, 1=Senior NCO, 2=Officer
  int _yearsServed = 0; // 0=0-4, 1=5-9, 2=10-15, 3=16-22, 4=22+
  int _familyStatus = 0; // 0=Single, 1=Married, 2=Married+Kids
  int _housing = 0; // 0=Quarters, 1=Own Home, 2=Renting

  Map<String, int> get _breakdown {
    final rankMultiplier = [1.0, 1.4, 1.8][_rankTier];
    final yearsMultiplier = [0.7, 1.0, 1.3, 1.5, 1.7][_yearsServed];

    int pension = (4500 * rankMultiplier * yearsMultiplier).round();
    int healthcare = 3200;
    int dental = 800;
    int housing = _housing == 0 ? 8400 : (_housing == 2 ? 2400 : 0);
    int fhtb = _housing == 1 ? 2500 : 0; // FHTB averages £25k over 10 years = £2,500/yr
    int gyhTravel = _housing == 1 ? 600 : 0; // GYH(T) ~25p/mile
    int education = (1200 * rankMultiplier).round();
    int gym = 480;
    int holiday = (1800 * rankMultiplier).round();
    int familyBonus = _familyStatus == 2
        ? 3200
        : (_familyStatus == 1 ? 1600 : 0);

    return {
      'Pension Contribution': pension,
      'Healthcare (NHS Priority + Military)': healthcare,
      'Dental Care': dental,
      if (housing > 0) 'Housing Subsidy': housing,
      if (fhtb > 0) 'FHTB (Interest-Free Loan Value)': fhtb,
      if (gyhTravel > 0) 'GYH(T) Travel Allowance': gyhTravel,
      'Education Allowance': education,
      'Gym & Fitness Access': gym,
      'Holiday Entitlement Value': holiday,
      if (familyBonus > 0) 'Family Allowances': familyBonus,
    };
  }

  int get _total => _breakdown.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _chipGroup(context, 'Rank Tier',
              ['Junior', 'Senior NCO', 'Officer'], _rankTier, (v) {
            setState(() => _rankTier = v);
          }),
          _chipGroup(context, 'Years Served',
              ['0–4', '5–9', '10–15', '16–22', '22+'], _yearsServed, (v) {
            setState(() => _yearsServed = v);
          }),
          _chipGroup(context, 'Family Status',
              ['Single', 'Married', 'Married + Kids'], _familyStatus, (v) {
            setState(() => _familyStatus = v);
          }),
          _chipGroup(context, 'Housing',
              ['Quarters', 'Own Home', 'Renting'], _housing, (v) {
            setState(() => _housing = v);
          }),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text('YOUR ESTIMATED BENEFITS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: colours.accent)),
                const SizedBox(height: 16),
                ..._breakdown.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(e.key,
                                style: TextStyle(
                                    color: colours.textLight, fontSize: 14)),
                          ),
                          Text('£${_formatNum(e.value)}',
                              style: TextStyle(
                                  color: colours.textBright,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Annual Value',
                        style: TextStyle(
                            color: colours.textBright,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Text('£${_formatNum(_total)}',
                        style: const TextStyle(
                            color: Color(0xFF00B894),
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
            ),
            child: Text(
              'In civilian life, this package would cost approximately £${_formatNum(_total)} per year out of your own pocket.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These are illustrative estimates, not financial advice.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.5), fontSize: 11),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _chipGroup(BuildContext context, String label, List<String> options,
      int selected, ValueChanged<int> onChanged) {
    final colours = context.colours;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List.generate(options.length, (i) {
              final sel = selected == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? colours.accent.withOpacity(0.15)
                        : colours.cardLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel
                            ? colours.accent.withOpacity(0.4)
                            : colours.border.withOpacity(0.3)),
                  ),
                  child: Text(options[i],
                      style: TextStyle(
                          color: sel ? colours.accent : colours.textLight,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k'
          .replaceAll('.0k', 'k');
    }
    return n.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 2 — Did You Know? Cards
// ═══════════════════════════════════════════════════════════════════

class _DidYouKnowTab extends StatefulWidget {
  final bool Function() onSwipe;
  const _DidYouKnowTab({required this.onSwipe});

  @override
  State<_DidYouKnowTab> createState() => _DidYouKnowTabState();
}

class _DidYouKnowTabState extends State<_DidYouKnowTab> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  int _viewedCount = 0;

  static const List<Map<String, String>> _facts = [
    {'emoji': '🏡', 'title': 'FHTB — Forces Help to Buy', 'detail': 'The military will give you up to £25,000 as an interest-free loan to help you buy a house. Interest free. No civilian employer does this. You repay it gradually from salary over 10 years.'},
    {'emoji': '🚗', 'title': 'GYH(T) — Get You Home Travel', 'detail': 'If you own a home, the military pays you 25p per mile to travel home every month. That adds up fast — someone living 200 miles from base gets around £600 a year just for going home.'},
    {'emoji': '⚓', 'title': 'GYH(S) — Get You Home Seagoers', 'detail': 'Submariners and seagoers get 10 warrants per year to travel home and see their families. The military pays for you to get home — because they know how hard time away is.'},
    {'emoji': '💰', 'title': 'Pension Value', 'detail': 'Your military pension is worth hundreds of thousands over a lifetime. Most civilian employers don\'t offer anything close to this defined-benefit scheme.'},
    {'emoji': '🏥', 'title': 'Healthcare', 'detail': 'You get priority NHS treatment, military medical facilities, and dental care — all free. A family health plan privately costs £3,000+ per year.'},
    {'emoji': '🎓', 'title': 'Education', 'detail': 'Enhanced Learning Credits give you up to £2,000 per year for qualifications. Many service members leave with degrees paid for entirely.'},
    {'emoji': '🏠', 'title': 'Subsidised Housing', 'detail': 'Service Family Accommodation is heavily subsidised. The equivalent rent in many areas would be £800–£1,200 per month. And with FHTB, getting on the property ladder is within reach.'},
    {'emoji': '💪', 'title': 'Fitness', 'detail': 'Free gym access, sports facilities, and paid time to exercise. A civilian gym membership alone costs £40–£80 per month.'},
    {'emoji': '🌴', 'title': 'Leave', 'detail': 'You get 38 days leave per year — far more than the UK average of 28 days (including bank holidays).'},
    {'emoji': '🛡️', 'title': 'Job Security', 'detail': 'In uncertain economic times, military careers offer a level of job security that most industries simply cannot match.'},
    {'emoji': '📈', 'title': 'Career Progression', 'detail': 'Clear, structured promotion pathways. You know exactly what you need to do to progress — no office politics.'},
    {'emoji': '🤝', 'title': 'Community', 'detail': 'A built-in support network wherever you go. The friendships and bonds formed in service last a lifetime.'},
    {'emoji': '🎖️', 'title': 'Transition Support', 'detail': 'The Career Transition Partnership helps you find civilian work with CV workshops, training, and job matching.'},
    {'emoji': '👨‍👩‍👧', 'title': 'Family Support', 'detail': 'HIVE information services, welfare support, childcare vouchers, and family activity centres on most bases.'},
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Column(
      children: [
        const SizedBox(height: 12),
        Text('Swipe to explore',
            style: TextStyle(color: colours.textMuted, fontSize: 13)),
        Text('${_currentPage + 1} of ${_facts.length}',
            style: TextStyle(
                color: colours.textMuted.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 12),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _facts.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _viewedCount++;
              if (_viewedCount > 2) widget.onSwipe();
            },
            itemBuilder: (context, i) {
              final fact = _facts[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: colours.card,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: colours.border.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(fact['emoji']!,
                          style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 20),
                      Text(fact['title']!,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colours.textBright)),
                      const SizedBox(height: 16),
                      Text(fact['detail']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: colours.textLight,
                              height: 1.5,
                              fontSize: 15)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                _facts.length,
                (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _currentPage ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? colours.accent
                            : colours.border.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab 3 — Regret Stories
// ═══════════════════════════════════════════════════════════════════

class _RegretStoriesTab extends StatefulWidget {
  final bool Function() onSwipe;
  const _RegretStoriesTab({required this.onSwipe});

  @override
  State<_RegretStoriesTab> createState() => _RegretStoriesTabState();
}

class _RegretStoriesTabState extends State<_RegretStoriesTab> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  int _viewedCount = 0;

  static const List<Map<String, String>> _stories = [
    {'quote': 'I left after 12 years thinking civilian life would be easier. Within 6 months I realised nobody cares about you the way the military does. No structure, no purpose, no mates around the corner.', 'branch': 'Army', 'years': '12 years'},
    {'quote': 'The pension I walked away from haunts me. I\'d have been set by 40. Instead I\'m starting again at 35 with nothing saved.', 'branch': 'Royal Navy', 'years': '8 years'},
    {'quote': 'I thought I\'d find better opportunities outside. What I found was loneliness. The camaraderie you have in service doesn\'t exist in civvy street.', 'branch': 'RAF', 'years': '10 years'},
    {'quote': 'My biggest regret is not appreciating what I had. Free gym, free healthcare, guaranteed housing. Now I\'m paying £1,500 a month rent for a flat half the size of my quarter.', 'branch': 'Royal Marines', 'years': '6 years'},
    {'quote': 'I left because I thought the grass was greener. It\'s not. It\'s just different grass, and nobody mows it for you.', 'branch': 'Army', 'years': '9 years'},
    {'quote': 'People said "you\'ll walk into a job with your military experience." That\'s not how it works. I spent 8 months unemployed and lost all my confidence.', 'branch': 'RAF', 'years': '14 years'},
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Column(
      children: [
        const SizedBox(height: 12),
        Text('Anonymous stories from those who left',
            style: TextStyle(color: colours.textMuted, fontSize: 13)),
        const SizedBox(height: 12),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _stories.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _viewedCount++;
              if (_viewedCount > 1) widget.onSwipe();
            },
            itemBuilder: (context, i) {
              final story = _stories[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: colours.card,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: colours.border.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_quote_rounded,
                          color: colours.accent.withOpacity(0.3), size: 40),
                      const SizedBox(height: 20),
                      Text('"${story['quote']!}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: colours.textBright,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              fontSize: 16)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colours.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(story['branch']!,
                                style: TextStyle(
                                    color: colours.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text('${story['years']!} served',
                              style: TextStyle(
                                  color: colours.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                _stories.length,
                (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _currentPage ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? colours.accent
                            : colours.border.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
          ),
        ),
      ],
    );
  }
}
