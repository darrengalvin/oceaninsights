import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';
import '../models/protocol.dart';

/// Detail screen showing a communication protocol's steps
class ProtocolDetailScreen extends StatelessWidget {
  final Protocol protocol;

  const ProtocolDetailScreen({
    super.key,
    required this.protocol,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocol'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColour(protocol.category).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getCategoryColour(protocol.category).withOpacity(0.3),
                ),
              ),
              child: Text(
                protocol.category.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getCategoryColour(protocol.category),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              protocol.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            // Description
            if (protocol.description != null) ...[
              const SizedBox(height: 12),
              Text(
                protocol.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colours.textMuted,
                      height: 1.6,
                    ),
              ),
            ],
            const SizedBox(height: 32),

            // Steps
            Text(
              'Steps',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...protocol.sortedSteps.asMap().entries.map((entry) {
              final isLast = entry.key == protocol.sortedSteps.length - 1;
              final step = entry.value;
              return _buildStepItem(context, colours, step, isLast);
            }),

            // When to use
            if (protocol.whenToUse != null) ...[
              const SizedBox(height: 32),
              _buildInfoSection(
                context,
                colours,
                'When to Use',
                Icons.check_circle_outline_rounded,
                protocol.whenToUse!,
                Colors.green,
              ),
            ],

            // When NOT to use
            if (protocol.whenNotToUse != null) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                context,
                colours,
                'When NOT to Use',
                Icons.block_rounded,
                protocol.whenNotToUse!,
                Colors.red,
              ),
            ],

            // Common failures
            if (protocol.commonFailures.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCommonFailuresSection(context, colours, protocol.commonFailures),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    AppColours colours,
    ProtocolStep step,
    bool isLast,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colours.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.step}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: colours.border,
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colours.textMuted,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    AppColours colours,
    String title,
    IconData icon,
    String content,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFailuresSection(
    BuildContext context,
    AppColours colours,
    List<String> failures,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Common Failures',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...failures.map((failure) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      failure,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getCategoryColour(ProtocolCategory category) {
    switch (category) {
      case ProtocolCategory.communication:
        return Colors.blue;
      case ProtocolCategory.conflict:
        return Colors.orange;
      case ProtocolCategory.selfRegulation:
        return Colors.green;
      case ProtocolCategory.trust:
        return Colors.purple;
      case ProtocolCategory.recovery:
        return Colors.teal;
    }
  }
}



