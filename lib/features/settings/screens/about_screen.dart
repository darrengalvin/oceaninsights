import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/subscription_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _tapCount = 0;
  DateTime? _lastTap;
  
  // Secret phrase for developer access
  static const String _secretPhrase = 'deepblue';
  
  void _handleVersionTap() {
    final now = DateTime.now();
    
    // Reset if more than 2 seconds since last tap
    if (_lastTap != null && now.difference(_lastTap!).inSeconds > 2) {
      _tapCount = 0;
    }
    
    _lastTap = now;
    _tapCount++;
    
    if (_tapCount >= 10) {
      _tapCount = 0;
      _showDeveloperDialog();
    } else if (_tapCount >= 7) {
      // Give a subtle hint after 7 taps
      HapticFeedback.lightImpact();
    }
  }
  
  void _showDeveloperDialog() {
    final controller = TextEditingController();
    final subscriptionService = SubscriptionService();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subscriptionService.isPremium 
                  ? 'Premium is currently: ENABLED' 
                  : 'Premium is currently: DISABLED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: subscriptionService.isPremium ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter phrase',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _validatePhrase(value, controller),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _validatePhrase(controller.text, controller),
            child: const Text('Toggle Premium'),
          ),
        ],
      ),
    );
  }
  
  void _validatePhrase(String phrase, TextEditingController controller) {
    if (phrase.toLowerCase().trim() == _secretPhrase) {
      final subscriptionService = SubscriptionService();
      subscriptionService.toggleDeveloperOverride();
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            subscriptionService.isPremium 
                ? 'Developer mode: Premium ENABLED' 
                : 'Developer mode: Premium DISABLED',
          ),
          backgroundColor: subscriptionService.isPremium ? Colors.green : Colors.orange,
        ),
      );
      
      setState(() {}); // Refresh UI
    } else {
      controller.clear();
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phrase'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                    'BTS',
                    style: TextStyle(
                      color: colours.accent,
                      fontSize: 32,
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
            // Version number - tap 10 times for developer access
            Center(
              child: GestureDetector(
                onTap: _handleVersionTap,
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
              'Simple Pricing',
              'Below the Surface offers a free trial so you can explore the app. A small subscription unlocks all features and supports ongoing development. Mental health tools should be affordable and accessible.',
            ),
            
            _buildSection(
              context,
              'Privacy First',
              'Your data stays on your device. We don\'t collect personal information, use GPS tracking, or access your camera. No ads. Just tools to help you navigate life.',
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
