import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../services/ritual_service.dart';
import '../services/ritual_topics_service.dart';
import '../models/ritual_item.dart';
import '../models/ritual_topic_models.dart';
import 'topic_browser_screen.dart';

// Track ritual checks for tease gating
int _ritualChecksThisSession = 0;
const int _freeRitualChecks = 2;

/// Full-screen modal for managing daily rituals
class RitualsModalScreen extends StatefulWidget {
  const RitualsModalScreen({super.key});

  @override
  State<RitualsModalScreen> createState() => _RitualsModalScreenState();
}

class _RitualsModalScreenState extends State<RitualsModalScreen>
    with SingleTickerProviderStateMixin {
  final _topicsService = RitualTopicsService();
  final _legacyService = RitualService();
  late TabController _tabController;
  bool _loading = true;
  String _selectedTimeOfDay = 'all';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
    
    // Start on appropriate tab based on time of day
    final timeOfDay = _topicsService.getCurrentTimeOfDay();
    switch (timeOfDay) {
      case 'morning':
        _tabController.index = 0;
        _selectedTimeOfDay = 'morning';
        break;
      case 'evening':
        _tabController.index = 1;
        _selectedTimeOfDay = 'evening';
        break;
      default:
        _tabController.index = 0;
        _selectedTimeOfDay = 'all';
    }
  }
  
  Future<void> _initializeService() async {
    await _topicsService.initialize();
    if (mounted) {
      setState(() => _loading = false);
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _navigateToTopicBrowser() {
    HapticFeedback.lightImpact();
    Navigator.pop(context); // Close modal
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopicBrowserScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final subscribedTopics = _topicsService.getSubscribedTopics();
    final hasSubscriptions = subscribedTopics.isNotEmpty;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colours.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colours.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Rituals',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasSubscriptions 
                            ? '${subscribedTopics.length} topic${subscribedTopics.length > 1 ? 's' : ''} active'
                            : 'Choose your focus areas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colours.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Browse topics button
                GestureDetector(
                  onTap: _navigateToTopicBrowser,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colours.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_outlined, color: colours.accent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Browse',
                          style: TextStyle(
                            color: colours.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Close button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      color: colours.textMuted,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_loading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: colours.accent),
              ),
            )
          else if (!hasSubscriptions)
            // No subscriptions - show onboarding
            Expanded(
              child: _NoSubscriptionsView(
                colours: colours,
                onBrowse: _navigateToTopicBrowser,
              ),
            )
          else ...[
            // Tab bar for time of day filter
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: colours.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: colours.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: colours.background,
                unselectedLabelColor: colours.textMuted,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                onTap: (index) {
                  setState(() {
                    _selectedTimeOfDay = ['morning', 'evening', 'anytime'][index];
                  });
                },
                tabs: const [
                  Tab(text: '🌅 Morning'),
                  Tab(text: '🌙 Evening'),
                  Tab(text: '⏰ Anytime'),
                ],
              ),
            ),
            
            // Rituals list from subscribed topics
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TopicRitualsList(
                    timeOfDay: 'morning',
                    service: _topicsService,
                    colours: colours,
                    onChanged: () => setState(() {}),
                  ),
                  _TopicRitualsList(
                    timeOfDay: 'evening',
                    service: _topicsService,
                    colours: colours,
                    onChanged: () => setState(() {}),
                  ),
                  _TopicRitualsList(
                    timeOfDay: 'anytime',
                    service: _topicsService,
                    colours: colours,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// View shown when user has no subscribed topics
class _NoSubscriptionsView extends StatelessWidget {
  final AppColours colours;
  final VoidCallback onBrowse;

  const _NoSubscriptionsView({
    required this.colours,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.self_improvement_rounded,
            size: 80,
            color: colours.accent.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose Your Journey',
            style: TextStyle(
              color: colours.textBright,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select topics that match your goals and we\'ll create a personalized daily ritual checklist for you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colours.textMuted,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onBrowse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colours.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, color: colours.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Browse Topics',
                    style: TextStyle(
                      color: colours.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '30+ topics available',
            style: TextStyle(
              color: colours.textMuted.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rituals list for subscribed topics filtered by time of day
class _TopicRitualsList extends StatelessWidget {
  final String timeOfDay;
  final RitualTopicsService service;
  final AppColours colours;
  final VoidCallback onChanged;

  const _TopicRitualsList({
    required this.timeOfDay,
    required this.service,
    required this.colours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final rituals = service.getDailyRituals(timeOfDay: timeOfDay);
    final completed = rituals.where((r) => r.isCompletedToday).length;
    
    return Column(
      children: [
        // Progress summary
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completed of ${rituals.length} completed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (rituals.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: rituals.isEmpty ? 0 : completed / rituals.length,
                          backgroundColor: colours.border.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation(colours.accent),
                          minHeight: 6,
                        ),
                      ),
                  ],
                ),
              ),
              if (completed == rituals.length && rituals.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
        
        // Rituals list
        Expanded(
          child: rituals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 48,
                        color: colours.textMuted.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${timeOfDay == 'anytime' ? 'flexible' : timeOfDay} rituals',
                        style: TextStyle(
                          color: colours.textMuted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your subscribed topics have rituals\nscheduled at different times.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colours.textMuted.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: rituals.length,
                  itemBuilder: (context, index) {
                    final ritual = rituals[index];
                    return _TopicRitualTile(
                      ritual: ritual,
                      service: service,
                      colours: colours,
                      onChanged: onChanged,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Ritual tile for topic-based rituals
class _TopicRitualTile extends StatelessWidget {
  final RitualTopicItem ritual;
  final RitualTopicsService service;
  final AppColours colours;
  final VoidCallback onChanged;

  const _TopicRitualTile({
    required this.ritual,
    required this.service,
    required this.colours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = ritual.isCompletedToday;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        HapticFeedback.lightImpact();
        
        // Premium check - only for completing items, not unchecking
        if (!isCompleted && !SubscriptionService().isPremium) {
          _ritualChecksThisSession++;
          if (_ritualChecksThisSession > _freeRitualChecks) {
            checkPremiumAccess(context, featureName: 'Daily Rituals');
            return;
          }
        }
        
        if (isCompleted) {
          UISoundService().playClick();
        } else {
          UISoundService().playPerfect();
        }
        await service.toggleRitualItem(ritual.id);
        onChanged();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted 
              ? colours.accent.withOpacity(0.1)
              : colours.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? colours.accent.withOpacity(0.3)
                : colours.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? colours.accent 
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted 
                      ? colours.accent 
                      : colours.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      color: colours.background,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            
            // Title and meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ritual.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isCompleted 
                          ? colours.textMuted 
                          : colours.textBright,
                      decoration: isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${ritual.durationMinutes} min',
                        style: TextStyle(
                          color: colours.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (ritual.isCore) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colours.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Core',
                            style: TextStyle(
                              color: colours.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
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

/// List of rituals for a specific type
class _RitualsList extends StatelessWidget {
  final RitualType type;
  final RitualService service;
  final VoidCallback onAdd;
  final VoidCallback onChanged;
  
  const _RitualsList({
    required this.type,
    required this.service,
    required this.onAdd,
    required this.onChanged,
  });
  
  String _getEmptyMessage() {
    switch (type) {
      case RitualType.morning:
        return 'Start your day with intention';
      case RitualType.evening:
        return 'Wind down mindfully';
      case RitualType.productivity:
        return 'Remember: progress, not perfection';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final rituals = service.getRitualsByType(type);
    final progress = service.getProgress(type);
    
    return Column(
      children: [
        // Progress summary
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${progress['completed']} of ${progress['total']} completed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getEmptyMessage(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colours.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Add button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  UISoundService().playClick();
                  onAdd();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: colours.accent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Rituals list
        Expanded(
          child: rituals.isEmpty
              ? Center(
                  child: Text(
                    'No rituals yet. Tap + to add one.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: rituals.length,
                  itemBuilder: (context, index) {
                    final ritual = rituals[index];
                    return _RitualTile(
                      ritual: ritual,
                      service: service,
                      onChanged: onChanged,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Individual ritual tile with checkbox
class _RitualTile extends StatelessWidget {
  final RitualItem ritual;
  final RitualService service;
  final VoidCallback onChanged;
  
  const _RitualTile({
    required this.ritual,
    required this.service,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Dismissible(
      key: Key(ritual.id),
      direction: ritual.isDefault ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) async {
        await service.deleteRitual(ritual.id);
        onChanged();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          HapticFeedback.lightImpact();
          
          // Premium check - only for completing items, not unchecking
          if (!ritual.isCompleted && !SubscriptionService().isPremium) {
            _ritualChecksThisSession++;
            if (_ritualChecksThisSession > _freeRitualChecks) {
              checkPremiumAccess(context, featureName: 'Daily Rituals');
              return;
            }
          }
          
          UISoundService().playClick();
          await service.toggleRitual(ritual.id);
          onChanged();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ritual.isCompleted 
                ? colours.accent.withOpacity(0.1)
                : colours.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ritual.isCompleted
                  ? colours.accent.withOpacity(0.3)
                  : colours.border.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: ritual.isCompleted 
                      ? colours.accent 
                      : Colors.transparent,
                  border: Border.all(
                    color: ritual.isCompleted 
                        ? colours.accent 
                        : colours.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ritual.isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        color: colours.background,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              
              // Title
              Expanded(
                child: Text(
                  ritual.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ritual.isCompleted 
                        ? colours.textMuted 
                        : colours.textBright,
                    decoration: ritual.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                  ),
                ),
              ),
              
              // Delete hint for custom items
              if (!ritual.isDefault)
                Icon(
                  Icons.drag_indicator_rounded,
                  color: colours.textMuted.withOpacity(0.5),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
