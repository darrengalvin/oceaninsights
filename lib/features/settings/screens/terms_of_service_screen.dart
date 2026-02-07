import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.gavel_rounded, color: colours.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please read these terms carefully',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colours.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By downloading, installing, or using Below the Surface ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.',
            ),
            
            _buildSection(
              context,
              '2. Important Medical Disclaimer',
              'Below the Surface is designed for general mental wellbeing support ONLY.\n\n'
              '• This App is NOT a substitute for professional medical advice, diagnosis, or treatment\n'
              '• Never disregard professional medical advice because of something you read in this App\n'
              '• If you are experiencing a mental health crisis, please contact emergency services immediately\n'
              '• The App should not be used as the sole basis for any mental health decisions\n\n'
              'By using this App, you acknowledge that you understand and accept these limitations.',
            ),
            
            _buildSection(
              context,
              '3. Free Access',
              'Below the Surface is completely free:\n\n'
              '• The App is free to download and use\n'
              '• All features are available with no locked content\n'
              '• No subscriptions or premium tiers required\n'
              '• Works completely offline for deployment environments',
            ),
            
            _buildSection(
              context,
              '4. User Content & Data',
              '• All personal data (mood logs, settings, preferences) is stored locally on your device\n'
              '• We do not collect, store, or transmit personal information to our servers\n'
              '• If you delete the App, all your data is permanently deleted\n'
              '• Anonymous usage statistics may be collected for App improvement (you can opt out)',
            ),
            
            _buildSection(
              context,
              '5. Intellectual Property',
              '• All content, features, and functionality are owned by Below the Surface\n'
              '• You may not copy, modify, distribute, or reverse engineer the App\n'
              '• The App is licensed, not sold, for personal, non-commercial use only',
            ),
            
            _buildSection(
              context,
              '6. Limitation of Liability',
              'To the maximum extent permitted by law:\n\n'
              '• Below the Surface is provided "as is" without warranties of any kind\n'
              '• We are not liable for any damages arising from your use of the App\n'
              '• We are not responsible for any decisions you make based on App content\n'
              '• Our liability is limited to the amount you have contributed, if any',
            ),
            
            _buildSection(
              context,
              '7. Changes to Terms',
              'We may update these terms from time to time. Continued use of the App after changes constitutes acceptance of the new terms.',
            ),
            
            _buildSection(
              context,
              '8. Contact Us',
              'For questions about these terms, please contact us through the App Store or Google Play Store listing, or via the Support section in the App.',
            ),
            
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Last updated: January 2026',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colours.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, String content) {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colours.textBright,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
