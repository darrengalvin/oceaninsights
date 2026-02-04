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
              'By downloading, installing, or using Ocean Insight ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.',
            ),
            
            _buildSection(
              context,
              '2. Important Medical Disclaimer',
              'Ocean Insight is designed for general mental wellbeing support ONLY.\n\n'
              '• This App is NOT a substitute for professional medical advice, diagnosis, or treatment\n'
              '• Never disregard professional medical advice because of something you read in this App\n'
              '• If you are experiencing a mental health crisis, please contact emergency services immediately\n'
              '• The App should not be used as the sole basis for any mental health decisions\n\n'
              'By using this App, you acknowledge that you understand and accept these limitations.',
            ),
            
            _buildSection(
              context,
              '3. The Pay It Forward Model',
              'Ocean Insight operates on a community-supported "Pay It Forward" model:\n\n'
              '• The App is free to download and use\n'
              '• Your access has been covered by someone before you in the chain\n'
              '• You are invited (but not required) to contribute to cover someone else\'s access\n'
              '• This ensures those who genuinely cannot afford to pay (teenagers, those between jobs, families in difficulty) still receive support\n\n'
              'This is an honesty-based system. The App continues to exist because enough people choose to contribute.',
            ),
            
            _buildSection(
              context,
              '4. Contributions & Payments',
              'If you choose to contribute:\n\n'
              '• Contributions are processed securely through Apple App Store or Google Play Store\n'
              '• You can choose one-time or monthly contributions\n'
              '• Monthly contributions can be cancelled at any time through your app store settings\n'
              '• Contributions cover access for others who genuinely cannot afford it (e.g., teenagers, those in financial hardship)\n'
              '• Contributions also support ongoing development, servers, and maintenance\n'
              '• Refunds are subject to the respective app store\'s refund policy',
            ),
            
            _buildSection(
              context,
              '5. No Obligation to Pay',
              'You are under no obligation to contribute:\n\n'
              '• If you cannot afford to contribute, you are still welcome to use the App\n'
              '• Your access will not be restricted based on contribution status\n'
              '• We trust users to contribute when and if they are able\n'
              '• The chain continues because of the generosity of those who can',
            ),
            
            _buildSection(
              context,
              '6. User Content & Data',
              '• All personal data (mood logs, settings, preferences) is stored locally on your device\n'
              '• We do not collect, store, or transmit personal information to our servers\n'
              '• If you delete the App, all your data is permanently deleted\n'
              '• Anonymous usage statistics may be collected for App improvement (you can opt out)',
            ),
            
            _buildSection(
              context,
              '7. Intellectual Property',
              '• All content, features, and functionality are owned by Ocean Insight\n'
              '• You may not copy, modify, distribute, or reverse engineer the App\n'
              '• The App is licensed, not sold, for personal, non-commercial use only',
            ),
            
            _buildSection(
              context,
              '8. Limitation of Liability',
              'To the maximum extent permitted by law:\n\n'
              '• Ocean Insight is provided "as is" without warranties of any kind\n'
              '• We are not liable for any damages arising from your use of the App\n'
              '• We are not responsible for any decisions you make based on App content\n'
              '• Our liability is limited to the amount you have contributed, if any',
            ),
            
            _buildSection(
              context,
              '9. Sustainability',
              'The Pay It Forward model requires community participation to remain sustainable:\n\n'
              '• If contributions decline significantly, the App may need to change its model or cease operation\n'
              '• We will provide notice of any significant changes to the model\n'
              '• Users who have contributed will be notified of any changes that affect them',
            ),
            
            _buildSection(
              context,
              '10. Changes to Terms',
              'We may update these terms from time to time. Continued use of the App after changes constitutes acceptance of the new terms.',
            ),
            
            _buildSection(
              context,
              '11. Contact Us',
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
