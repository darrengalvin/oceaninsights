import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/theme_options.dart';

/// The main paywall screen shown when users try to access premium features
class PaywallScreen extends StatefulWidget {
  final String? featureName;
  final String? teaseMessage;
  
  const PaywallScreen({
    super.key,
    this.featureName,
    this.teaseMessage,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  String? _selectedProductId;
  bool _isLoading = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    final options = _subscriptionService.getSubscriptionOptions();
    // Default select yearly (recommended)
    _selectedProductId = options.firstWhere(
      (o) => o.isRecommended,
      orElse: () => options.first,
    ).productId;
  }

  Future<void> _purchase() async {
    if (_selectedProductId == null) return;
    
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    
    try {
      final success = await _subscriptionService.purchase(_selectedProductId!);
      if (success && mounted) {
        // Wait a moment for the purchase to process
        await Future.delayed(const Duration(milliseconds: 500));
        if (_subscriptionService.isPremium && mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _isRestoring = true);
    HapticFeedback.lightImpact();
    
    try {
      await _subscriptionService.restorePurchases();
      // Wait for restoration to process
      await Future.delayed(const Duration(seconds: 2));
      if (_subscriptionService.isPremium && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No previous subscription found'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final options = _subscriptionService.getSubscriptionOptions();
    
    return Scaffold(
      backgroundColor: const Color(0xFF8E9AAF), // Muted blue-grey from screenshot
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    const Text(
                      'Simple, Affordable Pricing',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2332),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      widget.teaseMessage ?? 
                      'Full access to all features. No hidden costs. Cancel anytime.',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF1A2332).withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Subscription options
                    Row(
                      children: options.map((option) {
                        final isSelected = _selectedProductId == option.productId;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: option == options.first ? 0 : 8,
                              right: option == options.last ? 0 : 8,
                            ),
                            child: _SubscriptionCard(
                              option: option,
                              isSelected: isSelected,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedProductId = option.productId);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // App Store note
                    Text(
                      'In-app purchase via App Store',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF1A2332).withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _purchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B894),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Subscribe Now',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Restore purchases
                    TextButton(
                      onPressed: _isRestoring ? null : _restore,
                      child: _isRestoring
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Restore Purchases',
                              style: TextStyle(
                                color: const Color(0xFF1A2332).withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Auto-renewal disclaimer (required by Apple)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. '
                'Manage subscriptions in your Apple ID settings.',
                style: TextStyle(
                  color: const Color(0xFF1A2332).withOpacity(0.5),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            
            // Terms and Privacy links
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/terms');
                    },
                    child: Text(
                      'Terms of Use',
                      style: TextStyle(
                        color: const Color(0xFF1A2332).withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: const Color(0xFF1A2332).withOpacity(0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/privacy');
                    },
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: const Color(0xFF1A2332).withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isSelected ? 1.0 : 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF00B894) 
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00B894).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Title with optional savings badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A2332),
                  ),
                ),
                if (option.savings != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      option.savings!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            
            // Price
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: option.price.replaceAll('/month', '').replaceAll('/year', ''),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2332),
                    ),
                  ),
                  TextSpan(
                    text: '/${option.duration}',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF1A2332).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
