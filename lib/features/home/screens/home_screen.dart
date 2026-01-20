import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../affirmations/screens/affirmations_screen.dart';
import '../../assessment/screens/assessment_screen.dart';
import '../../music/screens/music_screen.dart';
import '../../learn/screens/learn_screen.dart';
import '../../quotes/screens/quotes_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../settings/screens/theme_chooser_screen.dart';
import '../widgets/mood_check_card.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(context),
              const SizedBox(height: 28),
              const MoodCheckCard(),
              const SizedBox(height: 28),
              _buildQuickActions(context),
              const SizedBox(height: 28),
              _buildExploreSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    final colours = context.colours;
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProvider.getGreeting(),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How are you feeling today?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colours.textLight,
                    ),
                  ),
                ],
              ),
            ),
            // Theme chooser button
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeChooserScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colours.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colours.border),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: colours.accent,
                  size: 24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    final colours = context.colours;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                emoji: '🧘',
                label: 'Breathe',
                subtitle: '2 min calm',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BreathingScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                emoji: '✨',
                label: 'Inspire',
                subtitle: 'Daily quote',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuotesScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                emoji: '🎵',
                label: 'Relax',
                subtitle: 'Soundscape',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MusicScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildExploreSection(BuildContext context) {
    final colours = context.colours;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        FeatureCard(
          title: 'My Goals',
          description: 'Set and track your personal goals',
          emoji: '🎯',
          color: const Color(0xFFE57373), // Coral/salmon
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoalsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        FeatureCard(
          title: 'Breathing Exercises',
          description: 'Calm your mind with guided techniques',
          emoji: '🧘',
          color: const Color(0xFFFFB74D), // Warm amber
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BreathingScreen()),
          ),
        ),
        const SizedBox(height: 12),
        FeatureCard(
          title: 'Daily Affirmations',
          description: 'Start your day with positive thoughts',
          emoji: '💝',
          color: const Color(0xFFF48FB1), // Soft pink
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AffirmationsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        FeatureCard(
          title: 'Self Assessment',
          description: 'Track your mood and recognise patterns',
          emoji: '📊',
          color: const Color(0xFF4FC3F7), // Light blue
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssessmentScreen()),
          ),
        ),
        const SizedBox(height: 12),
        FeatureCard(
          title: 'Calm Music',
          description: 'Relaxing sounds to help you unwind',
          emoji: '🎵',
          color: const Color(0xFF81C784), // Soft green
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MusicScreen()),
          ),
        ),
        const SizedBox(height: 12),
        FeatureCard(
          title: 'Learn & Understand',
          description: 'Brain science, psychology, and life situations',
          emoji: '🧠',
          color: const Color(0xFFBA68C8), // Soft purple
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LearnScreen()),
          ),
        ),
        const SizedBox(height: 12),
        FeatureCard(
          title: 'Inspirational Quotes',
          description: 'Words of wisdom and motivation',
          emoji: '💬',
          color: colours.accent, // Aqua
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuotesScreen()),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.border),
        ),
        child: Column(
          children: [
            // Bright solid aqua container for the emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colours.accent, // SOLID bright aqua
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colours.textBright,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colours.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
