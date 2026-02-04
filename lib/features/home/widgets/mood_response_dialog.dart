import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/mood_provider.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../music/screens/music_screen.dart';
import '../../navigate/screens/navigate_screen.dart';
import '../../scenarios/screens/scenario_library_screen.dart';
import '../../settings/screens/contact_help_screen.dart';
import '../../rituals/screens/topic_browser_screen.dart';

/// Reasons for feeling a certain way
class MoodReason {
  final String label;
  final IconData icon;
  final bool isPositive; // Whether this is typically a positive or negative reason
  
  const MoodReason({
    required this.label,
    required this.icon,
    this.isPositive = false,
  });
}

/// All available mood reasons
class MoodReasons {
  static const List<MoodReason> negativeReasons = [
    MoodReason(label: 'Bad sleep', icon: Icons.bedtime_outlined),
    MoodReason(label: 'Overthinking', icon: Icons.psychology_outlined),
    MoodReason(label: 'Anxiety', icon: Icons.air_outlined),
    MoodReason(label: 'Feeling low', icon: Icons.mood_bad_outlined),
    MoodReason(label: 'Work stress', icon: Icons.work_outline),
    MoodReason(label: 'Long day', icon: Icons.schedule_outlined),
    MoodReason(label: 'Relationship issues', icon: Icons.people_outline),
    MoodReason(label: 'Going through a breakup', icon: Icons.heart_broken_outlined),
    MoodReason(label: 'Feeling lonely', icon: Icons.person_outline),
    MoodReason(label: 'Health concerns', icon: Icons.health_and_safety_outlined),
    MoodReason(label: 'Financial stress', icon: Icons.account_balance_outlined),
    MoodReason(label: 'Starting something new', icon: Icons.new_releases_outlined),
    MoodReason(label: 'Dark thoughts', icon: Icons.nights_stay_outlined),
    MoodReason(label: 'Just not feeling it', icon: Icons.sentiment_neutral_outlined),
  ];
  
  static const List<MoodReason> positiveReasons = [
    MoodReason(label: 'Good sleep', icon: Icons.bedtime_outlined, isPositive: true),
    MoodReason(label: 'Achieved something', icon: Icons.emoji_events_outlined, isPositive: true),
    MoodReason(label: 'Quality time with loved ones', icon: Icons.favorite_outline, isPositive: true),
    MoodReason(label: 'Good news', icon: Icons.celebration_outlined, isPositive: true),
    MoodReason(label: 'Feeling healthy', icon: Icons.fitness_center_outlined, isPositive: true),
    MoodReason(label: 'Work going well', icon: Icons.trending_up_outlined, isPositive: true),
    MoodReason(label: 'Personal growth', icon: Icons.self_improvement_outlined, isPositive: true),
    MoodReason(label: 'Nice weather', icon: Icons.wb_sunny_outlined, isPositive: true),
    MoodReason(label: 'Just feeling good', icon: Icons.sentiment_satisfied_outlined, isPositive: true),
  ];
  
  static List<MoodReason> getReasonsForMood(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
      case MoodLevel.good:
        return positiveReasons;
      case MoodLevel.okay:
        // Mix of both for "okay" mood
        return [...negativeReasons.take(6), ...positiveReasons.take(4)];
      case MoodLevel.low:
      case MoodLevel.struggling:
        return negativeReasons;
    }
  }
  
  /// Get personalized message based on mood and reason
  static String getPersonalizedMessage(MoodLevel mood, MoodReason reason) {
    // For positive moods
    if (mood == MoodLevel.excellent || mood == MoodLevel.good) {
      switch (reason.label) {
        case 'Good sleep':
          return "Rest makes such a difference! Let's make the most of this energy.";
        case 'Achieved something':
          return "That's worth celebrating! You should feel proud.";
        case 'Quality time with loved ones':
          return "Connection is so important. Those moments matter.";
        case 'Good news':
          return "How exciting! Enjoy this feeling.";
        case 'Feeling healthy':
          return "Health is wealth! Keep that momentum going.";
        case 'Work going well':
          return "Great to hear things are clicking. Keep building on it.";
        case 'Personal growth':
          return "Growth feels good! You're on the right path.";
        case 'Nice weather':
          return "Sometimes the simple things lift us most!";
        default:
          return "I'm glad you're having a good day! Let's make it even better.";
      }
    }
    
    // For neutral/okay mood
    if (mood == MoodLevel.okay) {
      if (reason.isPositive) {
        return "That's something positive to hold onto. Want to build on it?";
      }
      return "I can see why you'd be feeling that way. Take a look around for some guidance.";
    }
    
    // For negative moods
    switch (reason.label) {
      case 'Bad sleep':
        return "No wonder you're feeling this way. Sleep affects everything. Be gentle with yourself today.";
      case 'Overthinking':
        return "Your mind is working overtime. Sometimes we need to step back and reset.";
      case 'Anxiety':
        return "Anxiety is tough to carry. You're not alone in this, and there are things that can help.";
      case 'Feeling low':
        return "Low moments are part of being human. They pass, even when it doesn't feel like it.";
      case 'Work stress':
        return "Work pressure can really weigh on us. Let's find something to help you decompress.";
      case 'Long day':
        return "Long days are exhausting. You've made it this far - that counts.";
      case 'Relationship issues':
        return "Relationships take work and can hurt. Your feelings are valid.";
      case 'Going through a breakup':
        return "Breakups are genuinely painful. Be kind to yourself right now.";
      case 'Feeling lonely':
        return "Loneliness is hard. You matter, and these feelings won't last forever.";
      case 'Health concerns':
        return "Health worries can consume our thoughts. Take things one step at a time.";
      case 'Financial stress':
        return "Money stress is very real. It's okay to feel this way.";
      case 'Starting something new':
        return "New beginnings can be scary. It's normal to feel unsettled.";
      case 'Dark thoughts':
        return "I hear you. You're not alone, and reaching out is important. Please consider talking to someone.";
      default:
        return "Whatever you're going through, it's valid. Let's see what might help.";
    }
  }
}

/// Shows a contextual response after mood check-in
class MoodResponseDialog {
  static Future<void> show({
    required BuildContext context,
    required MoodLevel mood,
    required VoidCallback onComplete,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MoodReasonSelector(
        mood: mood,
        onComplete: onComplete,
      ),
    );
  }
}

/// Step 1: Select the reason for the mood
class _MoodReasonSelector extends StatelessWidget {
  final MoodLevel mood;
  final VoidCallback onComplete;
  
  const _MoodReasonSelector({
    required this.mood,
    required this.onComplete,
  });

  String _getMoodLabel() {
    switch (mood) {
      case MoodLevel.excellent:
        return "That's brilliant!";
      case MoodLevel.good:
        return "Good to hear!";
      case MoodLevel.okay:
        return "Just okay";
      case MoodLevel.low:
        return "Having a tough time";
      case MoodLevel.struggling:
        return "I hear you";
    }
  }
  
  String _getMoodQuestion() {
    switch (mood) {
      case MoodLevel.excellent:
      case MoodLevel.good:
        return "What's making today good?";
      case MoodLevel.okay:
        return "What's on your mind?";
      case MoodLevel.low:
      case MoodLevel.struggling:
        return "What's contributing to how you feel?";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final reasons = MoodReasons.getReasonsForMood(mood);
    
    return Dialog(
      backgroundColor: colours.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mood icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getMoodIcon(),
                  size: 32,
                  color: colours.accent,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                _getMoodLabel(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Question
              Text(
                _getMoodQuestion(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colours.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Reasons list (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reasons.map((reason) => _ReasonChip(
                      reason: reason,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        // Show the personalized response
                        _showPersonalizedResponse(
                          context: context,
                          mood: mood,
                          reason: reason,
                          onComplete: onComplete,
                        );
                      },
                    )).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip option
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Show default response without reason
                  _showPersonalizedResponse(
                    context: context,
                    mood: mood,
                    reason: null,
                    onComplete: onComplete,
                  );
                },
                child: Text(
                  'Skip this step',
                  style: TextStyle(
                    color: colours.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getMoodIcon() {
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
  
  static void _showPersonalizedResponse({
    required BuildContext context,
    required MoodLevel mood,
    required MoodReason? reason,
    required VoidCallback onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PersonalizedResponseDialog(
        mood: mood,
        reason: reason,
        onComplete: onComplete,
      ),
    );
  }
}

/// Chip for selecting a reason
class _ReasonChip extends StatelessWidget {
  final MoodReason reason;
  final VoidCallback onTap;
  
  const _ReasonChip({
    required this.reason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colours.border.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              reason.icon,
              size: 16,
              color: colours.accent,
            ),
            const SizedBox(width: 6),
            Text(
              reason.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 2: Personalized response based on mood + reason
class _PersonalizedResponseDialog extends StatelessWidget {
  final MoodLevel mood;
  final MoodReason? reason;
  final VoidCallback onComplete;
  
  const _PersonalizedResponseDialog({
    required this.mood,
    required this.reason,
    required this.onComplete,
  });

  String _getTitle() {
    if (reason != null) {
      // Reference the reason in the title
      if (mood == MoodLevel.excellent || mood == MoodLevel.good) {
        return "That's wonderful";
      } else if (mood == MoodLevel.okay) {
        return "I understand";
      } else {
        return "I hear you";
      }
    }
    // Default titles
    switch (mood) {
      case MoodLevel.excellent:
        return "That's brilliant";
      case MoodLevel.good:
        return "Good to hear";
      case MoodLevel.okay:
        return "I understand";
      case MoodLevel.low:
        return "Tough moment";
      case MoodLevel.struggling:
        return "I hear you";
    }
  }
  
  String _getMessage() {
    if (reason != null) {
      return MoodReasons.getPersonalizedMessage(mood, reason!);
    }
    // Default messages
    switch (mood) {
      case MoodLevel.excellent:
        return "Momentum is valuable. Keep building or just enjoy it.";
      case MoodLevel.good:
        return "I'm glad you're having a good day! Take a look around to make it even better.";
      case MoodLevel.okay:
        return "That's honest. Take a look around for some guidance.";
      case MoodLevel.low:
        return "Small steps count. Here are some things that might help.";
      case MoodLevel.struggling:
        return "Difficult moments pass. Here are some things that might help right now.";
    }
  }
  
  List<_ResponseAction> _getActions() {
    switch (mood) {
      case MoodLevel.struggling:
        return [
          _ResponseAction(
            label: 'Breathing Exercise',
            subtitle: 'Ground yourself in 2-5 minutes',
            icon: Icons.air_rounded,
            screen: const BreathingScreen(),
          ),
          _ResponseAction(
            label: 'Calm Sounds',
            subtitle: 'Soothing background audio',
            icon: Icons.volume_up_rounded,
            screen: const MusicScreen(),
          ),
          _ResponseAction(
            label: 'Stress Relief Missions',
            subtitle: 'Daily practices for tough times',
            icon: Icons.self_improvement_rounded,
            screen: const TopicBrowserScreen(),
          ),
          _ResponseAction(
            label: 'Need Support',
            subtitle: 'Contact someone for help',
            icon: Icons.support_agent_rounded,
            isSupport: true,
          ),
        ];
        
      case MoodLevel.low:
        return [
          _ResponseAction(
            label: 'Breathing Exercise',
            subtitle: 'Reset in a few minutes',
            icon: Icons.air_rounded,
            screen: const BreathingScreen(),
          ),
          _ResponseAction(
            label: 'Daily Missions',
            subtitle: 'Small habits that lift your mood',
            icon: Icons.checklist_rounded,
            screen: const TopicBrowserScreen(),
          ),
          _ResponseAction(
            label: 'Calm Sounds',
            subtitle: 'Background relief',
            icon: Icons.volume_up_rounded,
            screen: const MusicScreen(),
          ),
          _ResponseAction(
            label: 'Navigate Guidance',
            subtitle: "Practical support for what you're facing",
            icon: Icons.explore_rounded,
            screen: const NavigateScreen(),
          ),
        ];
        
      case MoodLevel.okay:
        return [
          _ResponseAction(
            label: 'Daily Missions',
            subtitle: 'Build habits that improve your day',
            icon: Icons.checklist_rounded,
            screen: const TopicBrowserScreen(),
          ),
          _ResponseAction(
            label: 'Breathing Exercise',
            subtitle: 'Quick mood lift',
            icon: Icons.air_rounded,
            screen: const BreathingScreen(),
          ),
          _ResponseAction(
            label: 'Decision Training',
            subtitle: 'Practice scenarios',
            icon: Icons.psychology_outlined,
            screen: const ScenarioLibraryScreen(),
          ),
          _ResponseAction(
            label: 'Navigate Guidance',
            subtitle: "Explore what's on your mind",
            icon: Icons.explore_rounded,
            screen: const NavigateScreen(),
          ),
        ];
        
      case MoodLevel.good:
        return [
          _ResponseAction(
            label: 'Build Daily Missions',
            subtitle: 'Keep the good momentum going',
            icon: Icons.trending_up_rounded,
            screen: const TopicBrowserScreen(),
          ),
          _ResponseAction(
            label: 'Decision Training',
            subtitle: "Build skills while you're sharp",
            icon: Icons.psychology_outlined,
            screen: const ScenarioLibraryScreen(),
          ),
          _ResponseAction(
            label: 'Navigate Guidance',
            subtitle: 'Explore areas of growth',
            icon: Icons.explore_rounded,
            screen: const NavigateScreen(),
          ),
        ];
        
      case MoodLevel.excellent:
        return [
          _ResponseAction(
            label: 'Level Up Missions',
            subtitle: 'Confidence, goals, growth',
            icon: Icons.rocket_launch_rounded,
            screen: const TopicBrowserScreen(),
          ),
          _ResponseAction(
            label: 'Decision Training',
            subtitle: 'Sharpen skills while energized',
            icon: Icons.psychology_outlined,
            screen: const ScenarioLibraryScreen(),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final actions = _getActions();
    
    return Dialog(
      backgroundColor: colours.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(),
                    size: 32,
                    color: colours.accent,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  _getTitle(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Personalized Message
                Text(
                  _getMessage(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colours.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  
                  // Suggested Actions header
                  Text(
                    'What would help right now?',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colours.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...actions.map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ActionButton(
                      action: action,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        onComplete();
                        
                        if (action.isSupport) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ContactHelpScreen()),
                          );
                        } else if (action.screen != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => action.screen!),
                          );
                        }
                      },
                    ),
                  )),
                ],
                
                const SizedBox(height: 16),
                
                // "Not now" button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onComplete();
                  },
                  child: Text(
                    'Not right now',
                    style: TextStyle(
                      color: colours.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getIcon() {
    switch (mood) {
      case MoodLevel.struggling:
        return Icons.favorite_rounded;
      case MoodLevel.low:
        return Icons.self_improvement_rounded;
      case MoodLevel.okay:
        return Icons.psychology_rounded;
      case MoodLevel.good:
        return Icons.wb_sunny_rounded;
      case MoodLevel.excellent:
        return Icons.celebration_rounded;
    }
  }
}

class _ResponseAction {
  final String label;
  final String subtitle;
  final IconData icon;
  final Widget? screen;
  final bool isSupport;
  
  const _ResponseAction({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.screen,
    this.isSupport = false,
  });
}

class _ActionButton extends StatelessWidget {
  final _ResponseAction action;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colours.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                action.icon,
                size: 20,
                color: colours.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colours.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
