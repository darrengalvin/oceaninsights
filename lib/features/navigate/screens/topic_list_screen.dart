import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/ui_sound_service.dart';
import 'guidance_screen.dart';

class TopicListScreen extends StatelessWidget {
  final String domainSlug;
  final String title;

  const TopicListScreen({
    super.key,
    required this.domainSlug,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final contentService = ContentService.instance;

    // Get all content items for this domain
    final allTopics = contentService.getContentForDomain(domainSlug);

    // Group topics by pillar
    final understandTopics =
        allTopics.where((t) => t.pillar == 'understand').toList();
    final reflectTopics =
        allTopics.where((t) => t.pillar == 'reflect').toList();
    final growTopics =
        allTopics.where((t) => t.pillar == 'grow').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Understand Section
            if (understandTopics.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Understand',
                subtitle: 'Learn how things work',
                colour: colours.accent,
              ),
              const SizedBox(height: 12),
              ...understandTopics.map((topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TopicCard(topic: topic),
                  )),
              const SizedBox(height: 24),
            ],

            // Reflect Section
            if (reflectTopics.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.psychology_outlined,
                title: 'Reflect',
                subtitle: 'Questions to consider',
                colour: Colors.purple,
              ),
              const SizedBox(height: 12),
              ...reflectTopics.map((topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TopicCard(topic: topic),
                  )),
              const SizedBox(height: 24),
            ],

            // Grow Section
            if (growTopics.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.trending_up_rounded,
                title: 'Grow',
                subtitle: 'Practical steps forward',
                colour: Colors.green,
              ),
              const SizedBox(height: 12),
              ...growTopics.map((topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TopicCard(topic: topic),
                  )),
            ],

            // Empty state
            if (allTopics.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.construction_outlined,
                      size: 48,
                      color: colours.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Content coming soon',
                      style: TextStyle(
                        fontSize: 16,
                        color: colours.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'re working on adding helpful content\nfor this area.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colours.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color colour;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colour.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: colour),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colours.textBright,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colours.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  final ContentItem topic;

  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Material(
      color: colours.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          UISoundService().playClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GuidanceScreen(contentItem: topic),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: colours.accent.withOpacity(0.2),
        highlightColor: colours.accent.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colours.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colours.textBright,
                      ),
                    ),
                    if (topic.microcopy != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        topic.microcopy!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colours.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colours.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

