import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  
  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.border),
        ),
        child: Row(
          children: [
            // Larger, colourful emoji container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color, // SOLID colour background
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colours.accent,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: colours.accent,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
