import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                  Icon(Icons.shield_outlined, color: colours.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy is our priority',
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
              'Important Disclaimer',
              'Ocean Insight is designed for general mental wellbeing support only. '
              'This app is NOT a replacement for professional medical advice, diagnosis, or treatment.\n\n'
              'If you are experiencing a mental health crisis or emergency, please seek immediate professional help.',
            ),
            
            _buildSection(
              context,
              'Data Collection',
              'We collect minimal information:\n\n'
              '• Your selected user type (for anonymous statistics only)\n'
              '• Your age bracket (for anonymous statistics only)\n\n'
              'This information never leaves your device and cannot be used to identify you.',
            ),
            
            _buildSection(
              context,
              'What We Don\'t Do',
              '• No personal data collection (name, email, phone)\n'
              '• No GPS or location tracking\n'
              '• No camera or microphone access\n'
              '• No advertisements\n'
              '• No data sharing with third parties\n'
              '• Optional Pay It Forward contributions (processed by Apple/Google)\n'
              '• Internet used only for content sync (no personal data sent)',
            ),
            
            _buildSection(
              context,
              'Your Data',
              'All app data (mood logs, settings, preferences) is stored locally on your device only. '
              'If you delete the app, all data is permanently removed.',
            ),
            
            _buildSection(
              context,
              'Pay It Forward Model',
              'Ocean Insight uses a community "Pay It Forward" model. '
              'Your access was covered by someone before you. Contributions help cover access for others who cannot afford it, '
              'such as teenagers or those facing financial hardship.',
            ),
            
            _buildSection(
              context,
              'Contact',
              'For questions about this privacy policy or the app, please contact us through the App Store.',
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



