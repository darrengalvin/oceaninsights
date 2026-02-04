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
        return _buildMoodSelector(context, moodProvider);
      },
    );
  }
  
  Widget _buildMoodSelector(BuildContext context, MoodProvider moodProvider) {
    final colours = context.colours;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to get personalized support',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                    // Show response dialog with personalized actions
                    MoodResponseDialog.show(
                      context: context,
                      mood: mood,
                      onComplete: () {
                        // Log the mood entry for tracking purposes
                        moodProvider.addMoodEntry(mood);
                      },
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
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colours.border.withOpacity(0.3),
            width: 1,
          ),
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
