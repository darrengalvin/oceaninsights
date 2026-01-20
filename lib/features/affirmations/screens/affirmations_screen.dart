import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/affirmations_data.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(AffirmationsData.affirmations.length);
    _pageController = PageController(initialPage: _currentIndex);
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
    return Scaffold(
      backgroundColor: AppTheme.abyssBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Daily Affirmations'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
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
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.coralPink.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.coralPink.withOpacity(0.3)),
            ),
            child: Text(
              affirmation.category,
              style: TextStyle(
                color: AppTheme.coralPink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            affirmation.text,
            style: TextStyle(
              color: AppTheme.textBright,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (affirmation.reflection != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.midnightBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppTheme.warmAmber,
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    affirmation.reflection!,
                    style: TextStyle(
                      color: AppTheme.textLight,
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
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _previousAffirmation,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.textMuted,
            iconSize: 32,
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.midnightBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Text(
              '${_currentIndex + 1} / ${AffirmationsData.affirmations.length}',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: _nextAffirmation,
            icon: const Icon(Icons.arrow_forward_rounded),
            color: AppTheme.textMuted,
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}
