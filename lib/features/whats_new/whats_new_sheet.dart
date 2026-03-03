import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme_options.dart';
import 'whats_new_service.dart';

/// Shows a "What's New" bottom sheet for unseen releases.
///
/// Call [showWhatsNewIfNeeded] from the home screen's initState.
/// It checks the service, and if there are unseen releases, shows the sheet.
Future<void> showWhatsNewIfNeeded(BuildContext context) async {
  final service = WhatsNewService();
  final unseen = await service.getUnseenReleases();

  if (unseen.isEmpty) return;
  if (!context.mounted) return;

  // Show the most recent unseen release
  final release = unseen.first;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WhatsNewSheet(release: release),
  );

  // Mark as seen after dismissing
  await service.markAsSeen();
}

class _WhatsNewSheet extends StatelessWidget {
  final WhatsNewRelease release;

  const _WhatsNewSheet({required this.release});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colours.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                // Version badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colours.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'v${release.version}',
                    style: TextStyle(
                      color: colours.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  release.title,
                  style: TextStyle(
                    color: colours.textBright,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (release.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    release.subtitle!,
                    style: TextStyle(
                      color: colours.textMuted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Items list
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: release.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colours.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  color: colours.textBright,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: TextStyle(
                                  color: colours.textMuted,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // CTA button
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomPadding),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Let\'s Go',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
