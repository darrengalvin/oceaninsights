import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/iap_service.dart';

class PayItForwardScreen extends StatefulWidget {
  const PayItForwardScreen({super.key});

  @override
  State<PayItForwardScreen> createState() => _PayItForwardScreenState();
}

class _PayItForwardScreenState extends State<PayItForwardScreen> with SingleTickerProviderStateMixin {
  final IAPService _iapService = IAPService();
  bool _isLoading = true;
  List<PurchaseOption> _oneTimeOptions = [];
  List<PurchaseOption> _subscriptionOptions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Start on Monthly Support tab
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final options = await _iapService.loadProducts();
    setState(() {
      _oneTimeOptions = options.where((o) => !o.isSubscription).toList();
      _subscriptionOptions = options.where((o) => o.isSubscription).toList();
      _isLoading = false;
    });
  }

  Future<void> _handlePurchase(PurchaseOption option) async {
    final success = await _iapService.purchase(
      option.productId,
      isSubscription: option.isSubscription,
    );
    if (success && mounted) {
      _showThankYouDialog(option.isSubscription);
    }
  }

  void _showThankYouDialog(bool isSubscription) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4A9B8E).withOpacity(0.3),
                      const Color(0xFF4A9B8E).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Color(0xFF4A9B8E),
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isSubscription ? 'You\'re Now Covering Others' : 'Mission Complete',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isSubscription
                    ? 'Every month, someone who needs this tool will get it - because of you.'
                    : 'You just gave someone access when they needed it most. That matters.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Mission Value Statement
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9B8E).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4A9B8E).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      color: Color(0xFF4A9B8E),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"No one gets left behind"',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A9B8E),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9B8E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4A9B8E),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Section
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                    
                    // Payment Options Tabs
                    _buildPaymentTabs(),
                    
                    // Tab Content
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOneTimeOptions(),
                          _buildSubscriptionOptions(),
                        ],
                      ),
                    ),
                    
                    // Can't Pay Section
                    _buildCantPaySection(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A9B8E).withOpacity(0.2),
                  const Color(0xFF4A9B8E).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 48,
              color: Color(0xFF4A9B8E),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Your Access is Free',
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            'Someone before you covered your access.\nBut we can\'t keep running without you.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white70,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Reality Check Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFC857).withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'The Reality:',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFC857),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This app costs money to run - servers, updates, content creation. If users don\'t contribute, it shuts down.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'re not asking for you. We\'re asking for them.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A9B8E),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Visual Chain Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChainLink('Them', const Color(0xFF4A9B8E)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white38, size: 20),
              const SizedBox(width: 8),
              _buildChainLink('You', const Color(0xFFFFC857)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white38, size: 20),
              const SizedBox(width: 8),
              _buildChainLink('Next', Colors.white38),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChainLink(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4A9B8E),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'One-Time'),
          Tab(text: 'Monthly Support'),
        ],
      ),
    );
  }

  Widget _buildOneTimeOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cover someone once',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A single payment. No ongoing commitment.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 20),
          ..._oneTimeOptions.map((option) => _buildPurchaseCard(option)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keep us alive',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monthly support keeps the servers running and covers others automatically.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ..._subscriptionOptions.map((option) => _buildPurchaseCard(option)),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePurchase(option),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: option.isRecommended
                    ? const Color(0xFF4A9B8E)
                    : Colors.white.withOpacity(0.1),
                width: option.isRecommended ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (option.isRecommended)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A9B8E),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                option.isSubscription ? 'MOST IMPACT' : 'RECOMMENDED',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Text(
                            option.price,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option.description,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A9B8E).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF4A9B8E),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (option.isSubscription) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A9B8E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF4A9B8E),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cancel anytime. No hidden fees.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCantPaySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2332).withOpacity(0.8),
            const Color(0xFF1A2332).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC857).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC857).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: Color(0xFFFFC857),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Can\'t Pay?',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'No guilt. No drama.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFFFFC857),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'If you\'re between postings, transitioning, or just can\'t spare it - you\'re already in. Your access stays free.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'But here\'s the truth: if enough people can\'t pay, this stops working for everyone.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9B8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What you can do instead:',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A9B8E),
                  ),
                ),
                const SizedBox(height: 12),
                _buildHelpBullet('Tell someone who can contribute'),
                _buildHelpBullet('Share it with units or crews'),
                _buildHelpBullet('Leave a review to build trust'),
                const SizedBox(height: 12),
                Text(
                  'Growth keeps this sustainable.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4A9B8E),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
