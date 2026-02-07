import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../data/quotes_data.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  int _viewedCount = 0; // Track how many they've seen
  static const int _freeLimit = 2; // Allow 2 free quotes
  
  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(QuotesData.quotes.length);
    _pageController = PageController(initialPage: _currentIndex);
    _viewedCount = 1; // They see one on load
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextQuote() {
    final nextIndex = (_currentIndex + 1) % QuotesData.quotes.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspirational Quotes'),
        actions: [
          IconButton(
            onPressed: _nextQuote,
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Random quote',
          ),
        ],
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
                      featureName: 'Quotes',
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
              itemCount: QuotesData.quotes.length,
              itemBuilder: (context, index) {
                final quote = QuotesData.quotes[index];
                return _buildQuoteCard(quote);
              },
            ),
          ),
          _buildNavigation(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildQuoteCard(Quote quote) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 48,
            color: AppTheme.warmAmber.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            quote.text,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 2,
                color: AppTheme.steelBlue,
              ),
              const SizedBox(width: 16),
              Text(
                quote.author,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.steelBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 2,
                color: AppTheme.steelBlue,
              ),
            ],
          ),
          if (quote.context != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warmAmber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warmAmber.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.warmAmber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      quote.context!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textBright,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildNavigation() {
    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              final prevIndex = (_currentIndex - 1 + QuotesData.quotes.length) 
                  % QuotesData.quotes.length;
              _pageController.animateToPage(
                prevIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.midnightBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Text(
              '${_currentIndex + 1} / ${QuotesData.quotes.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _nextQuote,
            icon: const Icon(Icons.arrow_forward_rounded),
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }
}
