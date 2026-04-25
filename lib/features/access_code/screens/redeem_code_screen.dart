import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/access_code_service.dart';
import '../../../core/services/subscription_service.dart';

/// Lets a user redeem a sponsor-issued access code to unlock premium.
/// Designed to be optional and unobtrusive: surfaced from the paywall and
/// from settings as "I have an access code".
class RedeemCodeScreen extends StatefulWidget {
  const RedeemCodeScreen({super.key});

  @override
  State<RedeemCodeScreen> createState() => _RedeemCodeScreenState();
}

class _RedeemCodeScreenState extends State<RedeemCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final AccessCodeService _service = AccessCodeService();
  final SubscriptionService _subscription = SubscriptionService();

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onChange);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await _service.redeem(raw);

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = result.success ? null : result.message;
    });

    if (result.success) {
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.organizationName != null
                  ? 'Access unlocked - sponsored by ${result.organizationName}'
                  : 'Access unlocked',
            ),
            backgroundColor: const Color(0xFF0891B2),
          ),
        );
      }
    }
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove access code?'),
        content: const Text(
          'Premium will return to whatever your subscription status is. '
          'You can redeem the code again later if it is still valid.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clear();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCode = _service.hasActiveCode;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1520),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Access Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _Header(hasCode: hasCode),
              const SizedBox(height: 32),
              if (hasCode) _activeCard() else _redeemCard(),
              const SizedBox(height: 24),
              _explainerCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _redeemCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131D2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243447)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Courier',
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: 'BTS-XXXX-XXXX',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontFamily: 'Courier',
                letterSpacing: 2,
              ),
              filled: true,
              fillColor: const Color(0xFF0D1520),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF243447)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00D9C4), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF243447)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9C4),
                foregroundColor: const Color(0xFF0D1520),
                disabledBackgroundColor: const Color(0xFF00D9C4).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Redeem Code',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeCard() {
    final expiry = _service.expiresAt;
    final orgName = _service.organizationName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0891B2), Color(0xFF00D9C4)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Premium Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (orgName != null && orgName.isNotEmpty) ...[
            const Text(
              'Sponsored by',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              orgName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (expiry != null) ...[
            const Text(
              'Active until',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(expiry),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _remove,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Remove access code',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _explainerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'About access codes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Access codes are issued by sponsoring organisations - military '
            'units, schools, charities - to give their members free premium '
            'access to Below the Surface.\n\n'
            'If you have not been given a code, you can subscribe instead and '
            'still get full access.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _Header extends StatelessWidget {
  final bool hasCode;
  const _Header({required this.hasCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF00D9C4).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.confirmation_number_outlined,
            color: Color(0xFF00D9C4),
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          hasCode ? 'You have premium access' : 'Got an access code?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasCode
              ? 'Your sponsor is covering the cost of premium for you.'
              : 'If your unit, school, or charity has given you a code, '
                  'enter it here to unlock premium for free.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
