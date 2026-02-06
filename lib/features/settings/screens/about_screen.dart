import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('About the App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colours.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colours.border, width: 2),
                ),
                child: Center(
                  child: Text(
                    'OI',
                    style: TextStyle(
                      color: colours.accent,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'BELOW THE SURFACE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: colours.textBright,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              context,
              'Our Mission',
              'Below the Surface is designed to support military personnel and their families with mental wellbeing tools that work completely offline. We understand that life at sea or on deployment means limited connectivity, so everything in this app works without internet access.',
            ),
            
            _buildSection(
              context,
              'What We Offer',
              '• Breathing exercises for calm and focus\n'
              '• Mood tracking to recognise patterns\n'
              '• Educational content about brain function and psychology\n'
              '• Goal setting with guided reflection\n'
              '• Inspirational quotes and affirmations\n'
              '• Calming soundscapes',
            ),
            
            _buildSection(
              context,
              'Pay It Forward',
              'Your access was covered by someone before you. When you contribute, you cover access for someone who genuinely can\'t afford it - like a teenager needing support. This keeps mental health tools available to everyone.',
            ),
            
            _buildSection(
              context,
              'Privacy First',
              'Your data stays on your device. We don\'t collect personal information, use GPS tracking, or access your camera. No ads. No subscriptions. Just tools to help you navigate life.',
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2026 Below the Surface',
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
              color: colours.accent,
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



