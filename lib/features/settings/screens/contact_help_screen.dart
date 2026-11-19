import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_options.dart';

class ContactHelpScreen extends StatelessWidget {
  const ContactHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact for Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colours.error),
                      const SizedBox(width: 12),
                      Text(
                        'In an emergency',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colours.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you are in immediate danger or experiencing a mental health crisis, please contact emergency services (999) or go to your nearest A&E.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Togetherall - Featured
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colours.accent.withOpacity(0.15),
                    colours.accent.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colours.accent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: colours.accent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Togetherall',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colours.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Anonymous, round-the-clock online support',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Trained counsellors available 24/7\n'
                    '• Supportive community forums\n'
                    '• Free resources for mental health\n'
                    '• Available to all armed forces personnel, reservists, veterans and families',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: colours.textLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _launchURL('https://togetherall.com'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colours.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Visit Togetherall'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Support Services',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildContactCard(
              context,
              'NHS 111, option 2',
              'Urgent mental health crisis support. A trained mental health professional will listen and help you get the right support, for yourself or someone else',
              'Call 111, select option 2',
              'Free, 24/7',
            ),
            
            _buildContactCard(
              context,
              'Samaritans',
              '24/7 support for anyone struggling',
              '116 123',
              'Free, confidential',
            ),
            
            _buildContactCard(
              context,
              'Combat Stress',
              'Veterans\' mental health charity',
              '0800 138 1619',
              'Free helpline 24/7',
            ),
            
            _buildContactCard(
              context,
              'SSAFA Forcesline',
              'Free, confidential helpline for serving personnel, veterans and their families. Independent of the chain of command',
              '0800 260 6767',
              'Mon-Thu 9am-5pm, Fri 9am-4pm',
            ),
            
            _buildContactCard(
              context,
              'Help for Heroes',
              'Physical and mental health support for veterans, reservists and their families',
              '0300 303 9888',
              'Mon-Fri 9am-5pm',
            ),
            
            _buildContactCard(
              context,
              'Royal British Legion',
              'Financial, social and emotional support for serving and ex-serving personnel and their families',
              '0808 802 8080\nOverseas: +44 20 3376 8080',
              '8am-8pm, 7 days',
            ),
            
            _buildContactCard(
              context,
              'Support for veterans (GOV.UK)',
              'Official directory of UK veterans\' services: health, housing, money, employment and welfare',
              'www.gov.uk/support-for-veterans',
              'Online, any time',
            ),
            
            _buildContactCard(
              context,
              'Mind',
              'Mental health charity',
              '0300 123 3393',
              'Mon-Fri 9am-6pm',
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When Deployed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colours.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If you are currently deployed and need support:\n\n'
                    '• Speak to your Divisional Officer or Line Manager\n'
                    '• Contact the ship\'s Medical Officer\n'
                    '• Request to speak with a Chaplain\n'
                    '• Use the confidential welfare services available\n\n'
                    'Remember: Seeking help is a sign of strength, not weakness.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  Widget _buildContactCard(
    BuildContext context,
    String name,
    String description,
    String contact,
    String availability, {
    bool isUrl = false,
  }) {
    final colours = context.colours;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isUrl ? Icons.language_rounded : Icons.phone,
                size: 18,
                color: colours.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contact,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colours.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                availability,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colours.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
