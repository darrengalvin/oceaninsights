import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../models/ritual_topic_models.dart';
import '../services/ritual_topics_service.dart';
import 'topic_detail_screen.dart';

/// Screen for browsing ritual topic categories and topics
class TopicBrowserScreen extends StatefulWidget {
  const TopicBrowserScreen({super.key});

  @override
  State<TopicBrowserScreen> createState() => _TopicBrowserScreenState();
}

class _TopicBrowserScreenState extends State<TopicBrowserScreen> {
  final _service = RitualTopicsService();
  bool _loading = true;
  String? _selectedCategoryId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _service.initialize();
    if (!_service.hasData()) {
      await _service.syncFromSupabase();
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _service.syncFromSupabase();
    setState(() => _loading = false);
  }

  void _navigateToTopic(RitualTopic topic) async {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    
    // First topic is free, others require subscription
    final subscriptionService = SubscriptionService();
    if (!subscriptionService.isPremium) {
      final allTopics = _service.getAllTopics();
      final isFirst = allTopics.isNotEmpty && allTopics.first.id == topic.id;
      
      if (!isFirst) {
        final unlocked = await checkPremiumAccess(context, featureName: 'Rituals');
        if (!unlocked) return;
      }
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(topic: topic),
      ),
    ).then((_) => setState(() {})); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final categories = _service.getCategories();
    final featuredTopics = _service.getFeaturedTopics();
    final subscribedTopics = _service.getSubscribedTopics();

    List<RitualTopic> displayTopics;
    if (_searchQuery.isNotEmpty) {
      displayTopics = _service.searchTopics(_searchQuery);
    } else if (_selectedCategoryId != null) {
      displayTopics = _service.getTopicsForCategory(_selectedCategoryId!);
    } else {
      displayTopics = _service.getAllTopics();
    }

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        title: const Text('Missions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: colours.accent),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              color: colours.accent,
              child: CustomScrollView(
                slivers: [
                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search topics...',
                          hintStyle: TextStyle(color: colours.textMuted),
                          prefixIcon: Icon(Icons.search, color: colours.textMuted),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: colours.textMuted),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: colours.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: colours.textBright),
                      ),
                    ),
                  ),

                  // Your subscribed topics (if any)
                  if (subscribedTopics.isNotEmpty && _searchQuery.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: colours.accent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Your Topics',
                              style: TextStyle(
                                color: colours.textBright,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: subscribedTopics.length,
                          itemBuilder: (context, index) {
                            final topic = subscribedTopics[index];
                            return _SubscribedTopicCard(
                              topic: topic,
                              colours: colours,
                              onTap: () => _navigateToTopic(topic),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],

                  // Featured topics
                  if (featuredTopics.isNotEmpty && _searchQuery.isEmpty && _selectedCategoryId == null) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Featured',
                              style: TextStyle(
                                color: colours.textBright,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: featuredTopics.length,
                          itemBuilder: (context, index) {
                            final topic = featuredTopics[index];
                            return _FeaturedTopicCard(
                              topic: topic,
                              colours: colours,
                              isSubscribed: _service.isSubscribedToTopic(topic.id),
                              onTap: () => _navigateToTopic(topic),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],

                  // Category filter chips
                  if (_searchQuery.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          'Browse by Category',
                          style: TextStyle(
                            color: colours.textBright,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_searchQuery.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _CategoryChip(
                                label: 'All',
                                isSelected: _selectedCategoryId == null,
                                colour: colours.accent,
                                onTap: () => setState(() => _selectedCategoryId = null),
                              );
                            }
                            final category = categories[index - 1];
                            return _CategoryChip(
                              label: category.name,
                              isSelected: _selectedCategoryId == category.id,
                              colour: _parseColor(category.color),
                              onTap: () => setState(() => _selectedCategoryId = category.id),
                            );
                          },
                        ),
                      ),
                    ),

                  // Topics list
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'Search Results (${displayTopics.length})'
                            : _selectedCategoryId != null
                                ? '${categories.firstWhere((c) => c.id == _selectedCategoryId).name} Topics'
                                : 'All Topics',
                        style: TextStyle(
                          color: colours.textBright,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  if (displayTopics.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No topics found',
                            style: TextStyle(color: colours.textMuted),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final topic = displayTopics[index];
                          return _TopicListTile(
                            topic: topic,
                            colours: colours,
                            isSubscribed: _service.isSubscribedToTopic(topic.id),
                            onTap: () => _navigateToTopic(topic),
                          );
                        },
                        childCount: displayTopics.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
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

/// Category filter chip
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color colour;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.colour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colour.withOpacity(0.2) : colours.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colour : colours.border.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colour : colours.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Subscribed topic horizontal card
class _SubscribedTopicCard extends StatelessWidget {
  final RitualTopic topic;
  final AppColours colours;
  final VoidCallback onTap;

  const _SubscribedTopicCard({
    required this.topic,
    required this.colours,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colours.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: colours.accent, size: 16),
                if (topic.isSubmarineCompatible) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.directions_boat_rounded, color: Color(0xFF0891B2), size: 14),
                ],
                const Spacer(),
                Text(
                  '${topic.items.length} tasks',
                  style: TextStyle(
                    color: colours.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              topic.name,
              style: TextStyle(
                color: colours.textBright,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              topic.tagline ?? '',
              style: TextStyle(
                color: colours.textMuted,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Featured topic horizontal card
class _FeaturedTopicCard extends StatelessWidget {
  final RitualTopic topic;
  final AppColours colours;
  final bool isSubscribed;
  final VoidCallback onTap;

  const _FeaturedTopicCard({
    required this.topic,
    required this.colours,
    required this.isSubscribed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = topic.category != null
        ? _parseColor(topic.category!.color)
        : colours.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                if (topic.isSubmarineCompatible) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.directions_boat_rounded, color: Color(0xFF0891B2), size: 14),
                ],
                const Spacer(),
                if (isSubscribed)
                  Icon(Icons.check_circle, color: colours.accent, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              topic.name,
              style: TextStyle(
                color: colours.textBright,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              topic.tagline ?? '',
              style: TextStyle(
                color: colours.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _DifficultyBadge(difficulty: topic.difficulty, colours: colours),
                const Spacer(),
                Text(
                  '${topic.estimatedDays} days',
                  style: TextStyle(
                    color: colours.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
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

/// Topic list tile
class _TopicListTile extends StatelessWidget {
  final RitualTopic topic;
  final AppColours colours;
  final bool isSubscribed;
  final VoidCallback onTap;

  const _TopicListTile({
    required this.topic,
    required this.colours,
    required this.isSubscribed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSubscribed 
                  ? colours.accent.withOpacity(0.5) 
                  : colours.border.withOpacity(0.3),
              width: isSubscribed ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            topic.name,
                            style: TextStyle(
                              color: colours.textBright,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSubscribed)
                          Icon(Icons.check_circle, color: colours.accent, size: 18),
                      ],
                    ),
                    if (topic.tagline != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        topic.tagline!,
                        style: TextStyle(
                          color: colours.textMuted,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _DifficultyBadge(difficulty: topic.difficulty, colours: colours),
                        const SizedBox(width: 8),
                        if (topic.isSubmarineCompatible) ...[
                          _SubmarineBadge(colours: colours),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '${topic.estimatedDays} days',
                          style: TextStyle(
                            color: colours.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${topic.items.length} tasks',
                          style: TextStyle(
                            color: colours.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colours.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Submarine compatible badge
class _SubmarineBadge extends StatelessWidget {
  final AppColours colours;

  const _SubmarineBadge({required this.colours});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Suitable during submarine deployment',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF0891B2).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF0891B2).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_boat_rounded,
              size: 12,
              color: Color(0xFF0891B2),
            ),
            const SizedBox(width: 4),
            const Text(
              'Deployment',
              style: TextStyle(
                color: Color(0xFF0891B2),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Difficulty badge
class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  final AppColours colours;

  const _DifficultyBadge({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
