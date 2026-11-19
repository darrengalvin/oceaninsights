import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme_options.dart';
import '../services/ui_sound_service.dart';

/// Shared building blocks for information/guidance screens whose content
/// is taken from NHS or other trusted sources (for example Mind).
///
/// Every piece of content carries a [GuidanceSource] so the user can see,
/// and open, where the information came from.

/// Where a piece of content came from.
class GuidanceSource {
  final String name;
  final String url;
  const GuidanceSource(this.name, this.url);
}

/// One card of guidance: a heading, optional intro text, optional bullets.
class GuidanceSection {
  final String title;
  final IconData icon;
  final String? intro;
  final List<String> points;
  final String? footer;
  final List<GuidanceSource> sources;

  const GuidanceSection({
    required this.title,
    required this.icon,
    this.intro,
    this.points = const [],
    this.footer,
    this.sources = const [],
  });
}

enum ContactKind { phone, text, web }

/// A helpline or service the user can contact from the app.
class GuidanceContact {
  final String name;
  final String description;

  /// What is shown to the user, e.g. "116 123" or "Text SHOUT to 85258".
  final String display;

  /// Phone number / SMS number / URL used when the tile is tapped.
  final String target;

  /// Optional body for SMS contacts (e.g. "SHOUT").
  final String? smsBody;
  final String availability;
  final ContactKind kind;

  const GuidanceContact({
    required this.name,
    required this.description,
    required this.display,
    required this.target,
    required this.availability,
    this.kind = ContactKind.phone,
    this.smsBody,
  });
}

/// Opens a phone call, text message or web page. If the device can't
/// handle it, the number/link is copied to the clipboard instead.
Future<void> openGuidanceLink(
  BuildContext context, {
  required ContactKind kind,
  required String target,
  String? smsBody,
}) async {
  HapticFeedback.lightImpact();
  final Uri uri;
  switch (kind) {
    case ContactKind.phone:
      uri = Uri(scheme: 'tel', path: target.replaceAll(' ', ''));
      break;
    case ContactKind.text:
      uri = Uri(
        scheme: 'sms',
        path: target.replaceAll(' ', ''),
        queryParameters: smsBody == null ? null : {'body': smsBody},
      );
      break;
    case ContactKind.web:
      uri = Uri.parse(target);
      break;
  }

  var opened = false;
  try {
    opened = await launchUrl(
      uri,
      mode: kind == ContactKind.web
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault,
    );
  } catch (_) {
    opened = false;
  }

  if (!opened) {
    await Clipboard.setData(ClipboardData(text: target));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard: $target')),
      );
    }
  }
}

/// Back button + title + subtitle, matching other feature screens.
class GuidanceHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const GuidanceHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_rounded, color: colours.textBright),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: TextStyle(color: colours.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Horizontally scrolling pill tabs.
class GuidanceTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onSelected;
  const GuidanceTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = selected == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              UISoundService().playClick();
              onSelected(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? colours.accent.withOpacity(0.15) : colours.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel
                        ? colours.accent.withOpacity(0.4)
                        : colours.border.withOpacity(0.3)),
              ),
              child: Text(tabs[i],
                  style: TextStyle(
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      color: sel ? colours.accent : colours.textMuted,
                      fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}

/// A card showing one [GuidanceSection].
class GuidanceSectionCard extends StatelessWidget {
  final GuidanceSection section;
  final Color? tint;
  const GuidanceSectionCard({super.key, required this.section, this.tint});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final colour = tint ?? colours.accent;
    final body = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(height: 1.5, color: colours.textLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colours.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(section.icon, color: colour, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: colours.textBright)),
            ),
          ]),
          if (section.intro != null) ...[
            const SizedBox(height: 10),
            Text(section.intro!, style: body),
          ],
          if (section.points.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.points.map((p) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7, right: 10),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: colour, shape: BoxShape.circle),
                        ),
                      ),
                      Expanded(child: Text(p, style: body)),
                    ],
                  ),
                )),
          ],
          if (section.footer != null) ...[
            const SizedBox(height: 10),
            Text(section.footer!,
                style: body?.copyWith(fontStyle: FontStyle.italic)),
          ],
          if (section.sources.isNotEmpty) ...[
            const SizedBox(height: 12),
            GuidanceSourceLinks(sources: section.sources),
          ],
        ],
      ),
    );
  }
}

/// "Source: Mind, NHS" with tappable links.
class GuidanceSourceLinks extends StatelessWidget {
  final List<GuidanceSource> sources;
  const GuidanceSourceLinks({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Source:',
            style: TextStyle(fontSize: 11, color: colours.textMuted)),
        ...sources.map((s) => GestureDetector(
              onTap: () => openGuidanceLink(context,
                  kind: ContactKind.web, target: s.url),
              child: Text(s.name,
                  style: TextStyle(
                      fontSize: 11,
                      color: colours.accent,
                      decoration: TextDecoration.underline)),
            )),
      ],
    );
  }
}

/// A tappable helpline tile.
class GuidanceContactTile extends StatelessWidget {
  final GuidanceContact contact;
  const GuidanceContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final icon = switch (contact.kind) {
      ContactKind.phone => Icons.phone_rounded,
      ContactKind.text => Icons.sms_rounded,
      ContactKind.web => Icons.language_rounded,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => openGuidanceLink(context,
          kind: contact.kind, target: contact.target, smsBody: contact.smsBody),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colours.border.withOpacity(0.5)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colours.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(contact.description,
                    style: TextStyle(fontSize: 12, color: colours.textLight)),
                const SizedBox(height: 6),
                Text(contact.display,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colours.accent,
                        fontSize: 14)),
                Text(contact.availability,
                    style: TextStyle(fontSize: 11, color: colours.textMuted)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
