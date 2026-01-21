import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/content_service.dart';

class GuidanceScreen extends StatelessWidget {
  final ContentItem contentItem;

  const GuidanceScreen({super.key, required this.contentItem});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Scaffold(
      appBar: AppBar(
        title: Text(contentItem.label),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Microcopy
            if (contentItem.microcopy != null) ...[
              Text(
                contentItem.microcopy!,
                style: TextStyle(
                  fontSize: 16,
                  color: colours.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Understand Section
            if (contentItem.understandBody != null) ...[
              _SectionHeader(
                icon: Icons.lightbulb_outline_rounded,
                title: contentItem.understandTitle ?? 'Understand',
                colour: colours.accent,
              ),
              const SizedBox(height: 12),
              Text(
                contentItem.understandBody!,
                style: TextStyle(
                  fontSize: 15,
                  color: colours.textBright,
                  height: 1.6,
                ),
              ),
              if (contentItem.understandInsights.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...contentItem.understandInsights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colours.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              insight,
                              style: TextStyle(
                                fontSize: 14,
                                color: colours.textLight,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 32),
            ],

            // Reflect Section
            if (contentItem.reflectPrompts.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.psychology_outlined,
                title: 'Reflect',
                colour: Colors.purple,
              ),
              const SizedBox(height: 12),
              ...contentItem.reflectPrompts.map((prompt) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 14,
                          color: colours.textBright,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 32),
            ],

            // Grow Section
            if (contentItem.growSteps.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.trending_up_rounded,
                title: contentItem.growTitle ?? 'Grow',
                colour: Colors.green,
              ),
              const SizedBox(height: 12),
              ...contentItem.growSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['action'] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colours.textBright,
                                ),
                              ),
                              if (step['detail'] != null &&
                                  step['detail'].toString().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  step['detail'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colours.textLight,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
            ],

            // Affirmation
            if (contentItem.affirmation != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colours.accent.withOpacity(0.1),
                      colours.accent.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colours.accent.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: colours.accent,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      contentItem.affirmation!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colours.textBright,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color colour;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colour.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colour,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colour,
            ),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
