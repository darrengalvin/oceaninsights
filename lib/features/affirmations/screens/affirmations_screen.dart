import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../data/affirmations_data.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  int _viewedCount = 0; // Track how many they've seen
  static const int _freeLimit = 2; // Allow 2 free affirmations
  
  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(AffirmationsData.affirmations.length);
    _pageController = PageController(initialPage: _currentIndex);
    _viewedCount = 1; // They see one on load
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextAffirmation() {
    final nextIndex = (_currentIndex + 1) % AffirmationsData.affirmations.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _previousAffirmation() {
    final prevIndex = (_currentIndex - 1 + AffirmationsData.affirmations.length) 
        % AffirmationsData.affirmations.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Affirmations'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                final subscriptionService = SubscriptionService();
                
                // Check tease limit
                if (!subscriptionService.isPremium) {
                  _viewedCount++;
                  if (_viewedCount > _freeLimit) {
                    // Revert to previous page
                    _pageController.jumpToPage(_currentIndex);
                    
                    // Show paywall
                    final unlocked = await checkPremiumAccess(
                      context, 
                      featureName: 'Affirmations',
                    );
                    if (unlocked) {
                      setState(() {});
                    }
                    return;
                  }
                }
                
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: AffirmationsData.affirmations.length,
              itemBuilder: (context, index) {
                final affirmation = AffirmationsData.affirmations[index];
                return _buildAffirmationCard(affirmation);
              },
            ),
          ),
          _buildControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildAffirmationCard(Affirmation affirmation) {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colours.border),
            ),
            child: Text(
              affirmation.category,
              style: TextStyle(
                color: colours.accent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            affirmation.text,
            style: TextStyle(
              color: colours.textBright,
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (affirmation.reflection != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colours.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: colours.accent,
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    affirmation.reflection!,
                    style: TextStyle(
                      color: colours.textLight,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildControls() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _previousAffirmation,
            icon: const Icon(Icons.arrow_back_rounded),
            color: colours.textMuted,
            iconSize: 28,
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colours.border),
            ),
            child: Text(
              '${_currentIndex + 1} / ${AffirmationsData.affirmations.length}',
              style: TextStyle(
                color: colours.textLight,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: _nextAffirmation,
            icon: const Icon(Icons.arrow_forward_rounded),
            color: colours.textMuted,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
