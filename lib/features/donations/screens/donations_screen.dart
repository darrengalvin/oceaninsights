import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  int _selectedAmount = 2; // index into amounts list

  static const List<int> _amounts = [1, 5, 10, 25, 50];

  static const List<Map<String, String>> _impacts = [
    {'emoji': '💬', 'text': 'Help fund a crisis text-line shift for someone who needs to talk'},
    {'emoji': '🎒', 'text': 'Provide wellbeing resources to a young person in need'},
    {'emoji': '👨‍👩‍👧', 'text': 'Help a military family access specialist counselling'},
    {'emoji': '🏠', 'text': 'Contribute to a veteran housing support programme'},
    {'emoji': '🤝', 'text': 'Help fund a community wellbeing event for service members'},
  ];

  Future<void> _openDonateLink() async {
    final uri = Uri.parse('https://belowthesurface.co.uk/donate');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_rounded,
                        color: colours.textBright)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Support Charities',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600))),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Make a donation to support charities that help service members, veterans, and their families. Each month we partner with different organisations doing vital work.',
                      style: TextStyle(
                          color: colours.textLight,
                          height: 1.5,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 24),

                    // Amount selector
                    Text('SEE YOUR IMPACT',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: colours.accent)),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(_amounts.length, (i) {
                        final sel = _selectedAmount == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              UISoundService().playClick();
                              setState(() => _selectedAmount = i);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: EdgeInsets.only(
                                  right: i < _amounts.length - 1 ? 8 : 0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF00B894).withOpacity(0.15)
                                    : colours.cardLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: sel
                                        ? const Color(0xFF00B894)
                                            .withOpacity(0.5)
                                        : colours.border.withOpacity(0.3)),
                              ),
                              child: Text(
                                '£${_amounts[i]}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: sel
                                        ? const Color(0xFF00B894)
                                        : colours.textLight,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Impact card
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(_selectedAmount),
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF00B894).withOpacity(0.12),
                              colours.card,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  const Color(0xFF00B894).withOpacity(0.2)),
                        ),
                        child: Column(children: [
                          Text(_impacts[_selectedAmount]['emoji']!,
                              style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text(
                            '£${_amounts[_selectedAmount]} could provide:',
                            style: TextStyle(
                                color: colours.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _impacts[_selectedAmount]['text']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: colours.textBright,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                height: 1.4),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // How it works
                    Text('HOW IT WORKS',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: colours.accent)),
                    const SizedBox(height: 14),
                    _HowItWorksStep(
                      colours: colours,
                      number: '1',
                      title: 'You donate',
                      detail: 'All donations go directly to our partner charity fund — not to app development.',
                    ),
                    _HowItWorksStep(
                      colours: colours,
                      number: '2',
                      title: 'We find charities that matter',
                      detail: 'Each month we partner with organisations supporting military, veterans, and families.',
                    ),
                    _HowItWorksStep(
                      colours: colours,
                      number: '3',
                      title: 'Your money makes a difference',
                      detail: '100% of donations are distributed to that month\'s partner charities. We\'ll share updates so you can see the impact.',
                    ),
                    const SizedBox(height: 24),

                    // Donate button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _openDonateLink();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B894),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    const Color(0xFF00B894).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Donate to Charity',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You\'ll be taken to a secure external page to complete your donation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: colours.textMuted.withOpacity(0.6),
                          fontSize: 12),
                    ),
                    const SizedBox(height: 28),

                    // Thank you
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colours.card,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: colours.border.withOpacity(0.3)),
                      ),
                      child: Column(children: [
                        const Text('🙏', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 12),
                        Text(
                          'Every penny goes to charity — not to us. Below the Surface connects you with organisations making a real difference for service members, veterans, and their families.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: colours.textLight,
                              height: 1.5,
                              fontSize: 14),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 40),
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

class _HowItWorksStep extends StatelessWidget {
  final AppColours colours;
  final String number;
  final String title;
  final String detail;

  const _HowItWorksStep({
    required this.colours,
    required this.number,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Color(0xFF00B894),
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: colours.textBright,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(detail,
                    style: TextStyle(
                        color: colours.textLight,
                        height: 1.4,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
