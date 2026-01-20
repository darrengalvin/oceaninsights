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
import '../../profile/screens/user_settings_screen.dart';
import '../../profile/screens/tell_me_about_you_screen.dart';
import '../../settings/screens/about_screen.dart';
import '../../settings/screens/privacy_policy_screen.dart';
import '../../settings/screens/contact_help_screen.dart';
import '../../settings/screens/theme_chooser_screen.dart';
import '../widgets/mood_check_card.dart';

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
              _buildMainMenu(context),
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
            // Home icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colours.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colours.border),
              ),
              child: Icon(
                Icons.home_rounded,
                color: colours.textBright,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProvider.getGreeting(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ocean Insight',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                      letterSpacing: 1,
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
  
  Widget _buildMainMenu(BuildContext context) {
    final colours = context.colours;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main menu items (matching client slides structure)
        _buildMenuButton(
          context,
          'USER',
          'Change your profile settings',
          Icons.person_outline_rounded,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
          ),
        ),
        
        _buildMenuButton(
          context,
          'LOG MY MOOD',
          'Mood tracker and mood reason',
          Icons.mood_rounded,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssessmentScreen()),
          ),
        ),
        
        _buildMenuButton(
          context,
          'QUICK ACTIONS',
          'Breathing, Music, Quotes, Affirmations',
          Icons.flash_on_rounded,
          () => _showQuickActionsSheet(context),
        ),
        
        _buildMenuButton(
          context,
          'TELL ME ABOUT YOU',
          'Personalise your experience',
          Icons.psychology_outlined,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TellMeAboutYouScreen()),
          ),
        ),
        
        _buildMenuButton(
          context,
          'SET GOALS',
          'Set and track your personal goals',
          Icons.flag_outlined,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoalsScreen()),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Content categories grid
        Text(
          'Explore Topics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colours.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildCategoryGrid(context),
        
        const SizedBox(height: 16),
        
        // Footer menu items
        _buildMenuButton(
          context,
          'ABOUT THE APP',
          'Learn more about Ocean Insight',
          Icons.info_outline_rounded,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
        
        _buildMenuButton(
          context,
          'PRIVACY POLICY',
          'How we protect your data',
          Icons.privacy_tip_outlined,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
        
        _buildMenuButton(
          context,
          'CONTACT FOR HELP',
          'Professional support numbers',
          Icons.support_agent_rounded,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
          ),
          isHighlighted: true,
        ),
      ],
    );
  }
  
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isHighlighted = false,
  }) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isHighlighted ? colours.accent.withOpacity(0.1) : colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? colours.accent : colours.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlighted ? colours.accent : colours.textLight,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isHighlighted ? colours.accent : colours.textBright,
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colours.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      ('RELATIONSHIPS', Icons.favorite_outline_rounded),
      ('PURPOSE', Icons.explore_outlined),
      ('PHYSICAL HEALTH', Icons.fitness_center_rounded),
      ('EMOTIONAL HEALTH', Icons.self_improvement_rounded),
      ('FINANCE', Icons.account_balance_wallet_outlined),
      ('EDUCATION', Icons.school_outlined),
      ('PSYCHOLOGY', Icons.psychology_outlined),
      ('BRAIN FUNCTIONS', Icons.memory_rounded),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final (title, icon) = categories[index];
        return _buildCategoryButton(context, title, icon);
      },
    );
  }
  
  Widget _buildCategoryButton(BuildContext context, String title, IconData icon) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LearnScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colours.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colours.textLight),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showQuickActionsSheet(BuildContext context) {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colours.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionTile(
                    context,
                    '🧘',
                    'Breathe',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BreathingScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionTile(
                    context,
                    '🎵',
                    'Music',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MusicScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionTile(
                    context,
                    '💬',
                    'Quotes',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuotesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionTile(
                    context,
                    '💝',
                    'Affirmations',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AffirmationsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionTile(
    BuildContext context,
    String emoji,
    String label,
    VoidCallback onTap,
  ) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colours.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colours.background,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
