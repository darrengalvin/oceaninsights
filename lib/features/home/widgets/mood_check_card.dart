import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/mood_provider.dart';

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
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: entry.mood.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: entry.mood.color.withOpacity(0.3)),
            ),
            child: Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feeling ${entry.mood.label.toLowerCase()}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  streak > 1 
                      ? '$streak day streak! Keep it up.' 
                      : 'Great job checking in today.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colours.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_rounded,
              color: colours.success,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodSelector(BuildContext context, MoodProvider moodProvider) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling right now?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to log your mood for today',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: MoodLevel.values.map((mood) {
              return _MoodButton(
                mood: mood,
                onTap: () => moodProvider.addMoodEntry(mood),
              );
            }).toList(),
          ),
        ],
      ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: mood.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mood.color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 6),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: mood.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
