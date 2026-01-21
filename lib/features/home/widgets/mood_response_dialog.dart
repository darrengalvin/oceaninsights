import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/mood_provider.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../music/screens/music_screen.dart';
import '../../navigate/screens/navigate_screen.dart';
import '../../scenarios/screens/scenario_library_screen.dart';

/// Shows a contextual response after mood check-in
class MoodResponseDialog {
  static Future<void> show({
    required BuildContext context,
    required MoodLevel mood,
    required VoidCallback onComplete,
  }) async {
    final response = _getResponseForMood(mood);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MoodResponseContent(
        mood: mood,
        response: response,
        onComplete: onComplete,
      ),
    );
  }
  
  static _MoodResponse _getResponseForMood(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.struggling:
        return _MoodResponse(
          icon: Icons.favorite_rounded,
          title: 'I hear you',
          message: 'Difficult moments pass. You\'re not alone in this.',
          actions: [
            _ResponseAction(
              label: 'Breathing Exercise',
              subtitle: 'Ground yourself (2-5 mins)',
              icon: Icons.air_rounded,
              screen: const BreathingScreen(),
            ),
            _ResponseAction(
              label: 'Calm Sounds',
              subtitle: 'Soothing background audio',
              icon: Icons.volume_up_rounded,
              screen: const MusicScreen(),
            ),
          ],
        );
        
      case MoodLevel.low:
        return _MoodResponse(
          icon: Icons.self_improvement_rounded,
          title: 'Tough day',
          message: 'Small steps count. Let\'s find something that helps.',
          actions: [
            _ResponseAction(
              label: 'Breathing Exercise',
              subtitle: 'Reset in a few minutes',
              icon: Icons.air_rounded,
              screen: const BreathingScreen(),
            ),
            _ResponseAction(
              label: 'Navigate',
              subtitle: 'Practical guidance',
              icon: Icons.explore_rounded,
              screen: const NavigateScreen(),
            ),
            _ResponseAction(
              label: 'Calm Sounds',
              subtitle: 'Background relief',
              icon: Icons.volume_up_rounded,
              screen: const MusicScreen(),
            ),
          ],
        );
        
      case MoodLevel.okay:
        return _MoodResponse(
          icon: Icons.psychology_rounded,
          title: 'Just okay',
          message: 'That\'s honest. Would any of these help shift things?',
          actions: [
            _ResponseAction(
              label: 'Decision Training',
              subtitle: 'Practice scenarios',
              icon: Icons.psychology_outlined,
              screen: const ScenarioLibraryScreen(),
            ),
            _ResponseAction(
              label: 'Navigate',
              subtitle: 'Explore guidance',
              icon: Icons.explore_rounded,
              screen: const NavigateScreen(),
            ),
          ],
        );
        
      case MoodLevel.good:
        return _MoodResponse(
          icon: Icons.wb_sunny_rounded,
          title: 'Good to hear',
          message: 'Want to maintain momentum or just carry on?',
          actions: [
            _ResponseAction(
              label: 'Decision Training',
              subtitle: 'Build skills while sharp',
              icon: Icons.psychology_outlined,
              screen: const ScenarioLibraryScreen(),
            ),
          ],
        );
        
      case MoodLevel.excellent:
        return _MoodResponse(
          icon: Icons.celebration_rounded,
          title: 'That\'s brilliant',
          message: 'Momentum is valuable. Keep it or bank it for later.',
          actions: [
            _ResponseAction(
              label: 'Decision Training',
              subtitle: 'Sharpen skills while energised',
              icon: Icons.psychology_outlined,
              screen: const ScenarioLibraryScreen(),
            ),
          ],
        );
    }
  }
}

class _MoodResponse {
  final IconData icon;
  final String title;
  final String message;
  final List<_ResponseAction> actions;
  
  const _MoodResponse({
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
  });
}

class _ResponseAction {
  final String label;
  final String subtitle;
  final IconData icon;
  final Widget screen;
  
  const _ResponseAction({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.screen,
  });
}

class _MoodResponseContent extends StatelessWidget {
  final MoodLevel mood;
  final _MoodResponse response;
  final VoidCallback onComplete;
  
  const _MoodResponseContent({
    required this.mood,
    required this.response,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Dialog(
      backgroundColor: colours.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
                response.icon,
                size: 32,
                color: colours.accent,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              response.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              response.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (response.actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              
              // Suggested Actions
              Text(
                'Might help:',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colours.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              ...response.actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActionButton(
                  action: action,
                  onTap: () {
                    Navigator.pop(context);
                    onComplete();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => action.screen),
                    );
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
    );
  }
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

