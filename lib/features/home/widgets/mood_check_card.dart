import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/mood_provider.dart';
import 'mood_response_dialog.dart';

class MoodCheckCard extends StatelessWidget {
  const MoodCheckCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, _) {
        final todaysMood = moodProvider.getTodaysMood();
        final streak = moodProvider.getCurrentStreak();
        
        if (todaysMood != null) {
          return _buildMoodLogged(context, todaysMood, streak);
        }
        
        return _buildMoodSelector(context, moodProvider);
      },
    );
  }
  
  Widget _buildMoodLogged(BuildContext context, MoodEntry entry, int streak) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getMoodIcon(entry.mood),
              color: colours.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feeling ${entry.mood.label.toLowerCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  streak > 1 
                      ? '$streak day streak' 
                      : 'Checked in today',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colours.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: colours.success,
            size: 22,
          ),
        ],
      ),
    );
  }
  
  IconData _getMoodIcon(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return Icons.sentiment_very_satisfied_rounded;
      case MoodLevel.good:
        return Icons.sentiment_satisfied_rounded;
      case MoodLevel.okay:
        return Icons.sentiment_neutral_rounded;
      case MoodLevel.low:
        return Icons.sentiment_dissatisfied_rounded;
      case MoodLevel.struggling:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }
  
  Widget _buildMoodSelector(BuildContext context, MoodProvider moodProvider) {
    final colours = context.colours;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: MoodLevel.values.map((mood) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: mood != MoodLevel.struggling ? 8 : 0,
                ),
                child: _MoodButton(
                  mood: mood,
                  onTap: () {
                    // Show response dialog, then add mood entry
                    MoodResponseDialog.show(
                      context: context,
                      mood: mood,
                      onComplete: () => moodProvider.addMoodEntry(mood),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MoodButton extends StatelessWidget {
  final MoodLevel mood;
  final VoidCallback onTap;
  
  const _MoodButton({
    required this.mood,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              _getIcon(),
              color: colours.accent,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colours.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIcon() {
    switch (mood) {
      case MoodLevel.excellent:
        return Icons.sentiment_very_satisfied_rounded;
      case MoodLevel.good:
        return Icons.sentiment_satisfied_rounded;
      case MoodLevel.okay:
        return Icons.sentiment_neutral_rounded;
      case MoodLevel.low:
        return Icons.sentiment_dissatisfied_rounded;
      case MoodLevel.struggling:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }
}
