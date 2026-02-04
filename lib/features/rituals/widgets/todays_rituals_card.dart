import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../services/ritual_topics_service.dart';
import '../screens/rituals_modal_screen.dart';
import '../screens/topic_browser_screen.dart';

/// Today's Rituals card for home screen showing progress
class TodaysRitualsCard extends StatefulWidget {
  const TodaysRitualsCard({super.key});

  @override
  State<TodaysRitualsCard> createState() => _TodaysRitualsCardState();
}

class _TodaysRitualsCardState extends State<TodaysRitualsCard> {
  final _service = RitualTopicsService();
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    _initService();
  }
  
  Future<void> _initService() async {
    await _service.initialize();
    if (mounted) {
      setState(() => _loading = false);
    }
  }
  
  String _getTimeOfDayLabel() {
    final timeOfDay = _service.getCurrentTimeOfDay();
    switch (timeOfDay) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      case 'evening':
        return 'Evening';
      default:
        return 'Daily';
    }
  }
  
  IconData _getTimeOfDayIcon() {
    final timeOfDay = _service.getCurrentTimeOfDay();
    switch (timeOfDay) {
      case 'morning':
        return Icons.wb_sunny_rounded;
      case 'afternoon':
        return Icons.wb_cloudy_rounded;
      case 'evening':
        return Icons.nightlight_round;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }
  
  void _openRitualsModal() {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RitualsModalScreen(),
    ).then((_) {
      // Refresh the card when modal closes
      if (mounted) setState(() {});
    });
  }
  
  void _openTopicBrowser() {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TopicBrowserScreen()),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colours.accent,
            ),
          ),
        ),
      );
    }
    
    final subscribedTopics = _service.getSubscribedTopics();
    final hasSubscriptions = subscribedTopics.isNotEmpty;
    
    // If no subscriptions, show prompt to browse topics
    if (!hasSubscriptions) {
      return _buildNoSubscriptionsCard(colours);
    }
    
    // Show progress from subscribed topics
    final progress = _service.getTodayProgress();
    final completed = progress['completed'] ?? 0;
    final total = progress['total'] ?? 0;
    final progressPercent = total > 0 ? completed / total : 0.0;
    final affirmation = _service.getRandomAffirmation();
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openRitualsModal,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colours.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getTimeOfDayIcon(),
                  color: colours.accentSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Today\'s Missions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colours.textBright,
                    ),
                  ),
                ),
                // Topics count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${subscribedTopics.length} topic${subscribedTopics.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: colours.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colours.textMuted,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            if (total > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: colours.cardLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressPercent >= 1.0 ? Colors.green : colours.accentSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Progress text and time of day
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (progressPercent >= 1.0)
                        const Icon(Icons.check_circle, color: Colors.green, size: 16)
                      else
                        Text(
                          '$completed of $total',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colours.textBright,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (progressPercent >= 1.0) ...[
                        const SizedBox(width: 6),
                        Text(
                          'All done!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colours.accentSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTimeOfDayLabel(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colours.accentSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'No missions scheduled right now',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colours.textMuted,
                ),
              ),
            ],
            
            // Show affirmation if available
            if (affirmation != null && total > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colours.cardLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: colours.accent.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        affirmation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colours.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoSubscriptionsCard(AppColours colours) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openTopicBrowser,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colours.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.self_improvement_rounded,
                  color: colours.accent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ready to Complete a Mission?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colours.textBright,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colours.accent,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Choose from 30+ missions like Finding Love, Better Sleep, Confidence Building, and more.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, color: colours.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Browse Missions',
                    style: TextStyle(
                      color: colours.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
