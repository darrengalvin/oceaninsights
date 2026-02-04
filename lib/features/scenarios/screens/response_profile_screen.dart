import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../models/user_response_profile.dart';
import '../services/scenario_service.dart';

/// Screen showing user's response profile and patterns
/// Based on aggregate choice data only - privacy-safe
class ResponseProfileScreen extends StatelessWidget {
  const ResponseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final scenarioService = context.read<ScenarioService>();
    final profile = scenarioService.getUserProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Response Profile'),
        actions: [
          if (profile.totalDecisions > 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _showResetDialog(context, profile),
              tooltip: 'Reset Profile',
            ),
        ],
      ),
      body: profile.totalDecisions == 0
          ? _buildEmptyState(context, colours)
          : _buildProfileView(context, colours, profile),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppColours colours) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: colours.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Profile Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete decision training scenarios to build your response profile.\n\nYour patterns will emerge over time, helping you understand your communication tendencies.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(
    BuildContext context,
    AppColours colours,
    UserResponseProfile profile,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats
          _buildStatsCard(context, colours, profile),
          const SizedBox(height: 24),

          // Insights
          _buildInsightsSection(context, colours, profile),
          const SizedBox(height: 24),

          // Communication style
          if (profile.communicationStyle.isNotEmpty)
            _buildPatternSection(
              context,
              colours,
              'Communication Style',
              Icons.chat_bubble_outline_rounded,
              profile.communicationStyle,
            ),
          const SizedBox(height: 16),

          // Conflict approach
          if (profile.conflictApproach.isNotEmpty)
            _buildPatternSection(
              context,
              colours,
              'Conflict Approach',
              Icons.psychology_outlined,
              profile.conflictApproach,
            ),
          const SizedBox(height: 16),

          // Risk tolerance
          if (profile.riskTolerance.isNotEmpty)
            _buildPatternSection(
              context,
              colours,
              'Risk Tolerance',
              Icons.speed_rounded,
              profile.riskTolerance,
            ),
          const SizedBox(height: 32),

          // Privacy notice
          _buildPrivacyNotice(context, colours),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    AppColours colours,
    UserResponseProfile profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colours.accent.withOpacity(0.15),
            colours.accentSecondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.accent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${profile.totalDecisions}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w300,
              color: colours.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.totalDecisions == 1
                ? 'Decision Completed'
                : 'Decisions Completed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.completedScenarioIds.length} unique scenarios explored',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
    BuildContext context,
    AppColours colours,
    UserResponseProfile profile,
  ) {
    final insights = profile.insights;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, size: 20, color: colours.accent),
            const SizedBox(width: 8),
            Text(
              'Key Patterns',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colours.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPatternSection(
    BuildContext context,
    AppColours colours,
    String title,
    IconData icon,
    Map<String, int> data,
  ) {
    // Calculate percentages
    final total = data.values.fold<int>(0, (sum, count) => sum + count);
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colours.accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedEntries.map((entry) {
            final percentage = (entry.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _capitalize(entry.key),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colours.textLight,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colours.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: colours.cardLight,
                      color: colours.accent,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice(BuildContext context, AppColours colours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: colours.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your response profile is stored locally on your device only. It shows patterns in your choices, not specific decisions or personal information.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: colours.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showResetDialog(BuildContext context, UserResponseProfile profile) {
    final colours = context.colours;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile?'),
        content: const Text(
          'This will clear all your response data and patterns. You\'ll start fresh with the next scenario.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              profile.reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile reset successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}



