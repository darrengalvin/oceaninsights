import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/ui_preferences_service.dart';
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
import '../../navigate/screens/navigate_screen.dart';
import '../widgets/mood_check_card.dart';
import '../../scenarios/screens/scenario_library_screen.dart';
import '../../scenarios/screens/protocol_library_screen.dart';
import '../../pay_it_forward/screens/pay_it_forward_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              const SizedBox(height: 32),
              const MoodCheckCard(),
              const SizedBox(height: 32),
              _buildQuickActions(context),
              const SizedBox(height: 8),
              // Divider
              Divider(color: colours.border.withOpacity(0.5), height: 48),
              _buildExploreSection(context),
              const SizedBox(height: 8),
              Divider(color: colours.border.withOpacity(0.5), height: 48),
              _buildMoreSection(context),
              const SizedBox(height: 32),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProvider.getGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'How are you feeling today?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Settings button - minimal
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                UISoundService().playClick();
                _showSettingsSheet(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.settings_outlined,
                  color: colours.textMuted,
                  size: 22,
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
    
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.air_rounded,
            label: 'Breathe',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BreathingScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.auto_awesome_rounded,
            label: 'Inspire',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuotesScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.waves_rounded,
            label: 'Sounds',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MusicScreen()),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildExploreSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FeatureRow(
          icon: Icons.psychology_outlined,
          title: 'Decision Training',
          subtitle: 'Practice workplace scenarios',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScenarioLibraryScreen()),
          ),
        ),
        _FeatureRow(
          icon: Icons.assignment_outlined,
          title: 'Communication Protocols',
          subtitle: 'Step-by-step guides',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProtocolLibraryScreen()),
          ),
        ),
        _FeatureRow(
          icon: Icons.explore_outlined,
          title: 'Navigate',
          subtitle: 'Explore life areas and guidance',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NavigateScreen()),
          ),
        ),
        _FeatureRow(
          icon: Icons.person_outline_rounded,
          title: 'Tell Me About You',
          subtitle: 'Personalise your experience',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TellMeAboutYouScreen()),
          ),
        ),
        _FeatureRow(
          icon: Icons.flag_outlined,
          title: 'Set Goals',
          subtitle: 'Track your progress',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoalsScreen()),
          ),
        ),
        _FeatureRow(
          icon: Icons.insights_rounded,
          title: 'Mood Insights',
          subtitle: 'Track patterns over time',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssessmentScreen()),
          ),
        ),
        _FeatureRow(
          icon: Icons.favorite_outline_rounded,
          title: 'Affirmations',
          subtitle: 'Daily encouragement',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AffirmationsScreen()),
          ),
        ),
        _FeatureRow(
          icon: Icons.school_outlined,
          title: 'Learn',
          subtitle: 'Psychology and life skills',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LearnScreen()),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMoreSection(BuildContext context) {
    final colours = context.colours;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pay It Forward card
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            UISoundService().playClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PayItForwardScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9B8E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4A9B8E).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.volunteer_activism_rounded,
                  color: const Color(0xFF4A9B8E),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cover someone else\'s access',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A9B8E),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFF4A9B8E),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Prominent help card
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            UISoundService().playClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: colours.accent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Need support? Contact for help',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colours.accent,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colours.accent,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // About and Privacy links
        Row(
          children: [
            _TextLink(
              label: 'About',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
            const SizedBox(width: 24),
            _TextLink(
              label: 'Privacy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showSettingsSheet(BuildContext context) {
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
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'User Profile',
              subtitle: 'Change your type & age',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<UIPreferencesService>(
              builder: (context, prefs, _) => _SettingsSwitchTile(
                icon: Icons.volume_up_rounded,
                title: 'Navigation Sounds',
                subtitle: prefs.soundsEnabled ? 'Click sounds enabled' : 'Click sounds disabled',
                value: prefs.soundsEnabled,
                onChanged: (value) async {
                  await prefs.setSoundsEnabled(value);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      splashColor: colours.accent.withOpacity(0.2),
      highlightColor: colours.accent.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colours.accent,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colours.textBright,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        onTap();
      },
      splashColor: colours.accent.withOpacity(0.2),
      highlightColor: colours.accent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: colours.accent,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
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
              Icons.chevron_right_rounded,
              color: colours.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _TextLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        onTap();
      },
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colours.textMuted,
          decoration: TextDecoration.underline,
          decorationColor: colours.textMuted.withOpacity(0.5),
        ),
      ),
    );
  }
}


class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: colours.accent, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colours.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colours.accent, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colours.accent,
          ),
        ],
      ),
    );
  }
}

/// Full logo with waves icon + readable text below (for headers/branding)
class _OceanInsightFullLogo extends StatelessWidget {
  final double size;
  
  const _OceanInsightFullLogo({
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wave icon in bordered box
        _OceanInsightIcon(size: size),
        const SizedBox(height: 12),
        // Text below - clear and readable
        Text(
          'OCEAN INSIGHT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: colours.textBright,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

/// Minimal wave icon in bordered box (for app icon / small uses)
class _OceanInsightIcon extends StatelessWidget {
  final double size;
  
  const _OceanInsightIcon({
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(
          color: colours.accent.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18 - 1),
        child: CustomPaint(
          painter: _WaveLogoPainter(
            waveColour: colours.accent,
          ),
          size: Size(size, size),
        ),
      ),
    );
  }
}

/// Custom painter for overlapping wave lines like the reference
class _WaveLogoPainter extends CustomPainter {
  final Color waveColour;
  
  _WaveLogoPainter({required this.waveColour});
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.5; // Centre of the box
    
    // Multiple overlapping waves - clean and visible
    final waveConfigs = [
      // Top wave - gentle curve
      _LogoWaveConfig(
        yOffset: -size.height * 0.18,
        amplitude: size.height * 0.1,
        frequency: 0.8,
        phaseOffset: 0.3,
        strokeWidth: 1.2,
        opacity: 0.6,
      ),
      // Upper mid wave
      _LogoWaveConfig(
        yOffset: -size.height * 0.05,
        amplitude: size.height * 0.16,
        frequency: 1.1,
        phaseOffset: 0.0,
        strokeWidth: 1.4,
        opacity: 0.8,
      ),
      // Centre wave - main wave (boldest)
      _LogoWaveConfig(
        yOffset: size.height * 0.05,
        amplitude: size.height * 0.14,
        frequency: 1.0,
        phaseOffset: 0.5,
        strokeWidth: 1.6,
        opacity: 1.0,
      ),
      // Lower wave
      _LogoWaveConfig(
        yOffset: size.height * 0.18,
        amplitude: size.height * 0.1,
        frequency: 1.3,
        phaseOffset: 0.7,
        strokeWidth: 1.2,
        opacity: 0.6,
      ),
    ];
    
    for (final config in waveConfigs) {
      _drawWave(canvas, size, centerY, config);
    }
  }
  
  void _drawWave(
    Canvas canvas, 
    Size size, 
    double centerY, 
    _LogoWaveConfig config,
  ) {
    final paint = Paint()
      ..color = waveColour.withOpacity(config.opacity)
      ..strokeWidth = config.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final phase = config.phaseOffset * 2 * math.pi;
    
    path.moveTo(
      0,
      centerY + config.yOffset + config.amplitude * math.sin(phase),
    );
    
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final y = centerY + 
          config.yOffset + 
          config.amplitude * math.sin(normalizedX * config.frequency * 2 * math.pi + phase);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveLogoPainter oldDelegate) => 
      oldDelegate.waveColour != waveColour;
}

/// Configuration for wave in logo
class _LogoWaveConfig {
  final double yOffset;
  final double amplitude;
  final double frequency;
  final double phaseOffset;
  final double strokeWidth;
  final double opacity;
  
  const _LogoWaveConfig({
    required this.yOffset,
    required this.amplitude,
    required this.frequency,
    this.phaseOffset = 0.0,
    required this.strokeWidth,
    required this.opacity,
  });
}
