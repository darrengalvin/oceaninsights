import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../models/ritual_topic_models.dart';
import '../services/ritual_topics_service.dart';

/// Screen showing topic details, rituals, and subscribe option
class TopicDetailScreen extends StatefulWidget {
  final RitualTopic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen>
    with SingleTickerProviderStateMixin {
  final _service = RitualTopicsService();
  late TabController _tabController;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isSubscribed = _service.isSubscribedToTopic(widget.topic.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleSubscription() async {
    HapticFeedback.mediumImpact();
    
    if (_isSubscribed) {
      await _service.unsubscribeFromTopic(widget.topic.id);
      UISoundService().playClick();
    } else {
      await _service.subscribeToTopic(widget.topic.id);
      UISoundService().playPerfect();
    }
    
    setState(() {
      _isSubscribed = !_isSubscribed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final topic = widget.topic;
    final categoryColor = topic.category != null
        ? _parseColor(topic.category!.color)
        : colours.accent;

    return Scaffold(
      backgroundColor: colours.background,
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: colours.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colours.background.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      categoryColor.withOpacity(0.3),
                      colours.background,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (topic.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              topic.category!.name,
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          topic.name,
                          style: TextStyle(
                            color: colours.textBright,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (topic.tagline != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            topic.tagline!,
                            style: TextStyle(
                              color: colours.textMuted,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip(
                    icon: Icons.access_time,
                    label: '${topic.estimatedDays} days',
                    colours: colours,
                  ),
                  _StatChip(
                    icon: Icons.checklist_rounded,
                    label: '${topic.items.length} tasks',
                    colours: colours,
                  ),
                  _DifficultyChip(difficulty: topic.difficulty, colours: colours),
                  if (topic.isSubmarineCompatible)
                    _SubmarineChip(colours: colours),
                ],
              ),
            ),
          ),

          // Description
          if (topic.description != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  topic.description!,
                  style: TextStyle(
                    color: colours.textMuted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ),

          // Subscribe button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _toggleSubscription,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _isSubscribed
                        ? colours.accent.withOpacity(0.15)
                        : colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colours.accent.withOpacity(_isSubscribed ? 0.4 : 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSubscribed
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        color: colours.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSubscribed ? 'Subscribed' : 'Start This Journey',
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
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                tabs: [
                  Tab(text: 'Tasks (${topic.items.length})'),
                  Tab(text: 'Affirmations (${topic.affirmations.length})'),
                  Tab(text: 'Milestones (${topic.milestones.length})'),
                ],
              ),
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Rituals tab
                _RitualsTab(topic: topic, colours: colours),
                // Affirmations tab
                _AffirmationsTab(topic: topic, colours: colours),
                // Milestones tab
                _MilestonesTab(topic: topic, colours: colours),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF00D9C4);
    }
  }
}

/// Stat chip widget
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColours colours;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.colours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colours.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colours.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Difficulty chip
class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  final AppColours colours;

  const _DifficultyChip({
    required this.difficulty,
    required this.colours,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (difficulty) {
      case 'beginner':
        badgeColor = Colors.green;
        break;
      case 'intermediate':
        badgeColor = Colors.orange;
        break;
      case 'advanced':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = colours.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Submarine compatible chip
class _SubmarineChip extends StatelessWidget {
  final AppColours colours;

  const _SubmarineChip({required this.colours});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Suitable during submarine deployment',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0891B2).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF0891B2).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_boat_rounded,
              size: 14,
              color: Color(0xFF0891B2),
            ),
            SizedBox(width: 4),
            Text(
              'Deployment Friendly',
              style: TextStyle(
                color: Color(0xFF0891B2),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rituals tab
class _RitualsTab extends StatelessWidget {
  final RitualTopic topic;
  final AppColours colours;

  const _RitualsTab({required this.topic, required this.colours});

  @override
  Widget build(BuildContext context) {
    if (topic.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pending_actions,
                size: 48,
                color: colours.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Tasks coming soon',
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topic.items.length,
      itemBuilder: (context, index) {
        final item = topic.items[index];
        return _RitualItemCard(item: item, colours: colours);
      },
    );
  }
}

/// Ritual item card
class _RitualItemCard extends StatefulWidget {
  final RitualTopicItem item;
  final AppColours colours;

  const _RitualItemCard({required this.item, required this.colours});

  @override
  State<_RitualItemCard> createState() => _RitualItemCardState();
}

class _RitualItemCardState extends State<_RitualItemCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _expanded = !_expanded);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.item.isCore
                ? widget.colours.accent.withOpacity(0.3)
                : widget.colours.border.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.item.isCore)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.colours.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Core',
                                style: TextStyle(
                                  color: widget.colours.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              widget.item.title,
                              style: TextStyle(
                                color: widget.colours.textBright,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            widget.item.timeOfDayDisplay,
                            style: TextStyle(
                              color: widget.colours.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.item.durationMinutes} min',
                            style: TextStyle(
                              color: widget.colours.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.item.frequencyDisplay,
                            style: TextStyle(
                              color: widget.colours.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: widget.colours.textMuted,
                ),
              ],
            ),
            if (_expanded) ...[
              if (widget.item.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.item.description!,
                  style: TextStyle(
                    color: widget.colours.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
              if (widget.item.whyItHelps != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.colours.cardLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why it helps:',
                        style: TextStyle(
                          color: widget.colours.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.whyItHelps!,
                        style: TextStyle(
                          color: widget.colours.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (widget.item.howTo != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to:',
                        style: TextStyle(
                          color: widget.colours.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.howTo!,
                        style: TextStyle(
                          color: widget.colours.textBright,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Affirmations tab
class _AffirmationsTab extends StatelessWidget {
  final RitualTopic topic;
  final AppColours colours;

  const _AffirmationsTab({required this.topic, required this.colours});

  @override
  Widget build(BuildContext context) {
    if (topic.affirmations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.format_quote,
                size: 48,
                color: colours.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Affirmations coming soon',
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topic.affirmations.length,
      itemBuilder: (context, index) {
        final affirmation = topic.affirmations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colours.accent.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.format_quote,
                color: colours.accent.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  affirmation.text,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Milestones tab
class _MilestonesTab extends StatelessWidget {
  final RitualTopic topic;
  final AppColours colours;

  const _MilestonesTab({required this.topic, required this.colours});

  @override
  Widget build(BuildContext context) {
    if (topic.milestones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 48,
                color: colours.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Milestones coming soon',
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topic.milestones.length,
      itemBuilder: (context, index) {
        final milestone = topic.milestones[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    Text(
                      'Day ${milestone.dayThreshold}',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (milestone.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        milestone.description!,
                        style: TextStyle(
                          color: colours.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
