import 'package:flutter/material.dart';

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
            const SizedBox(height: 24),
            
            Text(
              'Support Services',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
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
              'SSAFA',
              'Armed Forces charity',
              '0800 731 4880',
              'Mon-Fri 9am-5pm',
            ),
            
            _buildContactCard(
              context,
              'Royal Navy & Royal Marines Charity',
              'Support for serving personnel and families',
              '023 9387 1520',
              'Mon-Fri 9am-5pm',
            ),
            
            _buildContactCard(
              context,
              'Veterans Gateway',
              'First point of contact for veterans',
              '0808 802 1212',
              '24/7 support',
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
  
  Widget _buildContactCard(
    BuildContext context,
    String name,
    String description,
    String phone,
    String availability,
  ) {
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
              fontWeight: FontWeight.bold,
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
              Icon(Icons.phone, size: 18, color: colours.accent),
              const SizedBox(width: 8),
              Text(
                phone,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colours.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
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

