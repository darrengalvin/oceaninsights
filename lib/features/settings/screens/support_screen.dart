import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_options.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  
  // TODO: Update these with your actual URLs
  static const String supportEmail = 'support@belowthesurface.app';
  static const String websiteUrl = 'https://belowthesurface.app';
  static const String privacyPolicyUrl = 'https://belowthesurface.app/privacy';
  static const String termsUrl = 'https://belowthesurface.app/terms';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  Future<void> _sendEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Below the Surface Support Request',
        'body': 'App Version: 1.0.0\n\nPlease describe your issue:\n\n',
      },
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Copy email to clipboard if mail app not available
      await Clipboard.setData(const ClipboardData(text: supportEmail));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email copied to clipboard')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help Header
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
                    Icons.support_agent_rounded,
                    size: 48,
                    color: colours.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'How can we help?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colours.textBright,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'re here to support you on your wellbeing journey',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colours.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact Options
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colours.textBright,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildOptionTile(
              context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: supportEmail,
              onTap: () => _sendEmail(context),
            ),
            
            const SizedBox(height: 24),
            
            // Crisis Resources
            Text(
              'Crisis Resources',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colours.textBright,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency_rounded, color: Colors.red[400], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'If you\'re in crisis',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If you or someone you know is in immediate danger, please contact emergency services:\n\n'
                    '• UK: 999 or Samaritans 116 123\n'
                    '• US: 911 or 988 Suicide & Crisis Lifeline\n'
                    '• Veterans Crisis Line: 1-800-273-8255 (Press 1)\n\n'
                    'This app is not a substitute for professional help.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: colours.textLight,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colours.textBright,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildFaqItem(
              context,
              'Does this app work offline?',
              'Yes! All core features work completely offline. Content syncs automatically when you have an internet connection.',
            ),
            _buildFaqItem(
              context,
              'Is my data private?',
              'Your data stays on your device. We don\'t collect personal information, and everything is deleted if you remove the app.',
            ),
            _buildFaqItem(
              context,
              'Can I get a refund?',
              'Refunds are handled through Apple App Store or Google Play Store according to their respective policies.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colours.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colours.accent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colours.textBright,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colours.textMuted),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final colours = context.colours;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colours.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colours.textBright,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: colours.accent,
        collapsedIconColor: colours.textMuted,
        children: [
          Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
