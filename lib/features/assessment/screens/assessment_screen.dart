import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/mood_provider.dart';
import '../../home/widgets/mood_response_dialog.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Insights'),
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodaySection(context, moodProvider),
                const SizedBox(height: 32),
                _buildStatsSection(context, moodProvider),
                const SizedBox(height: 32),
                _buildHistorySection(context, moodProvider),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTodaySection(BuildContext context, MoodProvider moodProvider) {
    final colours = context.colours;
    final todaysEntries = moodProvider.getTodaysEntries();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Log whenever you want - track your mood throughout the day',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
              ),
        ),
        const SizedBox(height: 20),
        
        // Always show mood selector
        _buildMoodSelector(context, moodProvider),
        
        // Show today's logs if any
        if (todaysEntries.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Today\'s Check-ins',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...todaysEntries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLoggedMood(context, entry),
          )),
        ],
      ],
    );
  }
  
  Widget _buildLoggedMood(BuildContext context, MoodEntry entry) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colours.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: entry.mood.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.mood.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Logged at ${_formatTime(entry.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colours.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodSelector(BuildContext context, MoodProvider moodProvider) {
    final colours = context.colours;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: MoodLevel.values.map((mood) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Show response dialog, then add mood entry
            MoodResponseDialog.show(
              context: context,
              mood: mood,
              onComplete: () => moodProvider.addMoodEntry(mood),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: colours.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colours.textBright,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildStatsSection(BuildContext context, MoodProvider moodProvider) {
    final colours = context.colours;
    final average7Days = moodProvider.getAverageMood(7);
    final totalEntries = moodProvider.entries.length;
    final todayCount = moodProvider.getTodayCount();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Insights',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Today',
                value: '$todayCount',
                suffix: todayCount == 1 ? 'check-in' : 'check-ins',
                icon: Icons.today_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: '7 Day Average',
                value: average7Days?.toStringAsFixed(1) ?? '-',
                suffix: 'of 5',
                icon: Icons.insights_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Total Check-ins',
          value: '$totalEntries',
          suffix: 'entries',
          icon: Icons.check_circle_outline,
          fullWidth: true,
        ),
      ],
    );
  }
  
  Widget _buildHistorySection(BuildContext context, MoodProvider moodProvider) {
    final colours = context.colours;
    final recentEntries = moodProvider.getRecentEntries(14);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent History',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your mood over the last two weeks',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        if (recentEntries.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colours.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 48,
                    color: colours.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No entries yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colours.textMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start tracking your mood to see patterns',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colours.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: colours.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border.withOpacity(0.3)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentEntries.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colours.border,
              ),
              itemBuilder: (context, index) {
                final entry = recentEntries[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: entry.mood.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.mood.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: Text(
                    entry.mood.label,
                    style: TextStyle(color: colours.textBright),
                  ),
                  subtitle: Text(
                    _formatDate(entry.timestamp),
                    style: TextStyle(color: colours.textMuted),
                  ),
                  trailing: Text(
                    _formatTime(entry.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colours.textMuted,
                        ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);
    
    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
  
  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final bool fullWidth;
  
  const _StatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colours.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colours.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colours.textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        suffix,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colours.textMuted,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
