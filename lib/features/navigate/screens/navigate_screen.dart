import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/content_service.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../data/navigate_content.dart';
import 'topic_list_screen.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  bool _syncing = false;
  
  Future<void> _syncContent() async {
    setState(() => _syncing = true);
    await ContentService.instance.syncContent();
    setState(() => _syncing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final contentService = ContentService.instance;
    final lastSync = contentService.getLastSyncTime();
    final hasContent = contentService.hasContent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigate'),
        actions: [
          IconButton(
            onPressed: _syncing ? null : _syncContent,
            icon: _syncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colours.textMuted,
                    ),
                  )
                : Icon(Icons.refresh_rounded, color: colours.textMuted),
            tooltip: 'Sync content',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Text(
              'Explore areas of your life',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an area to understand better, reflect on, and grow in. Take your time - there\'s no pressure here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colours.textMuted,
                    height: 1.5,
                  ),
            ),
            
            // Sync status
            if (hasContent && lastSync != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: colours.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Last updated: ${_formatSyncTime(lastSync)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ] else if (!hasContent) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 14,
                    color: colours.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Using offline content',
                    style: TextStyle(
                      fontSize: 12,
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Life Areas Grid
            ...contentService.getDomains().asMap().entries.map((entry) {
              final index = entry.key;
              final domain = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DomainCard(domain: domain, isFirst: index == 0),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  String _formatSyncTime(DateTime syncTime) {
    final now = DateTime.now();
    final difference = now.difference(syncTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _DomainCard extends StatelessWidget {
  final ContentDomain domain;
  final bool isFirst;

  const _DomainCard({required this.domain, this.isFirst = false});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'favorite_outline':
        return Icons.favorite_outline_rounded;
      case 'psychology_outlined':
        return Icons.psychology_outlined;
      case 'spa_outlined':
        return Icons.spa_outlined;
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      case 'work_outline':
        return Icons.work_outline_rounded;
      case 'account_balance_outlined':
        return Icons.account_balance_outlined;
      case 'explore_outlined':
        return Icons.explore_outlined;
      case 'shield_outlined':
        return Icons.shield_outlined;
      case 'home_outlined':
        return Icons.home_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final contentService = ContentService.instance;
    final topics = contentService.getContentForDomain(domain.slug);
    final hasContent = topics.isNotEmpty;

    return Opacity(
      opacity: hasContent ? 1.0 : 0.5,
      child: Material(
        color: colours.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: hasContent
              ? () async {
                  HapticFeedback.lightImpact();
                  UISoundService().playClick();
                  
                  // First domain is free, others require subscription
                  final subscriptionService = SubscriptionService();
                  if (!isFirst && !subscriptionService.isPremium) {
                    final unlocked = await checkPremiumAccess(context, featureName: 'Navigate');
                    if (!unlocked) return;
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicListScreen(
                        domainSlug: domain.slug,
                        title: domain.name,
                      ),
                    ),
                  );
                }
              : null,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIcon(domain.icon),
                    color: colours.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        domain.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colours.textBright,
                        ),
                      ),
                      if (domain.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          domain.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colours.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasContent)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colours.textMuted,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colours.cardLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 10,
                        color: colours.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

