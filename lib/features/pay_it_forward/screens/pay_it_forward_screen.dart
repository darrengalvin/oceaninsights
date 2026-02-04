import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../services/iap_service.dart';

class PayItForwardScreen extends StatefulWidget {
  const PayItForwardScreen({super.key});

  @override
  State<PayItForwardScreen> createState() => _PayItForwardScreenState();
}

class _PayItForwardScreenState extends State<PayItForwardScreen> {
  final IAPService _iapService = IAPService();
  bool _isLoading = true;
  List<PurchaseOption> _subscriptionOptions = [];
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final options = await _iapService.loadProducts();
    setState(() {
      _subscriptionOptions = options.where((o) => o.isSubscription).toList();
      _isLoading = false;
    });
  }

  Future<void> _handlePurchase(PurchaseOption option) async {
    HapticFeedback.mediumImpact();
    UISoundService().playClick();
    
    setState(() => _selectedProductId = option.productId);
    
    await Future.delayed(const Duration(milliseconds: 150));
    
    final success = await _iapService.purchase(
      option.productId,
      isSubscription: option.isSubscription,
    );
    
    if (mounted) {
      setState(() => _selectedProductId = null);
      
      if (success) {
        UISoundService().playPerfect();
        _showThankYouDialog();
      }
    }
  }

  void _showThankYouDialog() {
    final colours = context.colours;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: colours.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chain link icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.link_rounded,
                  color: colours.accent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'The Chain Continues',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colours.textBright,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                'Because of you, someone who needs this will get it. A teenager on a tight budget. A veteran rebuilding. A family member in need.',
                style: TextStyle(
                  fontSize: 15,
                  color: colours.textLight,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colours.accent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      color: colours.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No one gets left behind.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colours.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colours.accent.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colours.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          icon: Icon(Icons.close, color: colours.textBright),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colours.accent),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildHeroSection(colours),
                    const SizedBox(height: 32),
                    _buildSubscriptionOptions(colours),
                    const SizedBox(height: 24),
                    _buildCantPaySection(colours),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroSection(AppColours colours) {
    return Column(
      children: [
        // Chain icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colours.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.link_rounded,
            size: 48,
            color: colours.accent,
          ),
        ),
        const SizedBox(height: 24),
        
        // Title - The key message
        Text(
          'Someone Covered You',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colours.textBright,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        
        Text(
          'Your access was paid forward by someone before you. Now the question is simple:',
          style: TextStyle(
            fontSize: 16,
            color: colours.textLight,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // The Question
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: colours.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colours.accent.withOpacity(0.3),
            ),
          ),
          child: Text(
            'Will you keep the chain going?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colours.accent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        
        // The Why
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
                Icons.info_outline_rounded,
                color: colours.textMuted,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                'This isn\'t a free app with optional donations.\n\n'
                'It\'s an honesty system. Some people genuinely can\'t pay - '
                'teenagers, those between jobs, families stretched thin. '
                'They still deserve support.\n\n'
                'Your contribution covers them.',
                style: TextStyle(
                  fontSize: 14,
                  color: colours.textLight,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Visual Chain
        _buildChainVisualization(colours),
      ],
    );
  }

  Widget _buildChainVisualization(AppColours colours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChainPerson(
          colours, 
          'Someone', 
          Icons.person_rounded, 
          colours.accent,
          'paid for you',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: colours.textMuted,
            size: 20,
          ),
        ),
        _buildChainPerson(
          colours, 
          'You', 
          Icons.person_rounded, 
          Colors.amber,
          'pay for next',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: colours.textMuted,
            size: 20,
          ),
        ),
        _buildChainPerson(
          colours, 
          'Next', 
          Icons.person_outline_rounded, 
          colours.textMuted,
          'pays for...',
        ),
      ],
    );
  }

  Widget _buildChainPerson(AppColours colours, String label, IconData icon, Color color, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: colours.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOptions(AppColours colours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Someone',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colours.textBright,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monthly support covers someone new every month.',
          style: TextStyle(
            fontSize: 14,
            color: colours.textMuted,
          ),
        ),
        const SizedBox(height: 20),
        ..._subscriptionOptions.map((option) => _buildPurchaseCard(option, colours)),
      ],
    );
  }

  Widget _buildPurchaseCard(PurchaseOption option, AppColours colours) {
    final bool isSelected = _selectedProductId == option.productId;
    
    return GestureDetector(
      onTap: () => _handlePurchase(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? colours.accent.withOpacity(0.1)
              : colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colours.accent
                : option.isRecommended
                    ? colours.accent.withOpacity(0.5)
                    : colours.border,
            width: isSelected || option.isRecommended ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (option.isRecommended)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colours.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MOST CHOSEN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colours.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    option.price,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colours.textBright,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colours.accent
                    : colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: isSelected ? colours.background : colours.accent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCantPaySection(AppColours colours) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(
                Icons.volunteer_activism_rounded,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Can\'t Contribute Right Now?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'That\'s exactly why this system exists.\n\n'
            'You\'re covered. Use the app. Get the support you need. '
            'When you\'re in a better position, come back.',
            style: TextStyle(
              fontSize: 14,
              color: colours.textLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Other ways to help the chain:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colours.accent,
                  ),
                ),
                const SizedBox(height: 10),
                _buildHelpItem(colours, 'Tell someone who can contribute'),
                _buildHelpItem(colours, 'Share with your unit or crew'),
                _buildHelpItem(colours, 'Leave a review (builds trust)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'The chain only breaks if everyone takes and nobody gives.',
            style: TextStyle(
              fontSize: 13,
              color: colours.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(AppColours colours, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, 
            color: colours.accent, 
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: colours.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
