import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/learn_content.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;
  
  const ArticleScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getCategoryColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getCategoryColor(),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${article.readTimeMinutes} minute read',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              article.title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            
            // Summary
            Text(
              article.summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            
            // Divider
            Container(
              height: 1,
              color: AppTheme.cardBorder,
            ),
            const SizedBox(height: 24),
            
            // Content sections
            ...article.sections.map((section) => _buildSection(context, section)),
            
            // Key takeaways
            if (article.keyTakeaways.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.aquaGlow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.aquaGlow.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: AppTheme.aquaGlow,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Key Takeaways',
                          style: TextStyle(
                            color: AppTheme.aquaGlow,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...article.keyTakeaways.map((takeaway) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.aquaGlow,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                takeaway,
                                style: TextStyle(
                                  color: AppTheme.textBright,
                                  fontSize: 14,
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
              ),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, ArticleSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.heading != null) ...[
            Text(
              section.heading!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            section.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.7,
            ),
          ),
          if (section.tip != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warmAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warmAmber.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    color: AppTheme.warmAmber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.tip!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textBright,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getCategoryColor() {
    switch (article.category) {
      case ArticleCategory.brainScience:
        return AppTheme.aquaGlow;
      case ArticleCategory.psychology:
        return AppTheme.coralPink;
      case ArticleCategory.lifeSituation:
        return AppTheme.warmAmber;
    }
  }
  
  IconData _getCategoryIcon() {
    switch (article.category) {
      case ArticleCategory.brainScience:
        return Icons.psychology_rounded;
      case ArticleCategory.psychology:
        return Icons.favorite_rounded;
      case ArticleCategory.lifeSituation:
        return Icons.groups_rounded;
    }
  }
  
  String _getCategoryLabel() {
    switch (article.category) {
      case ArticleCategory.brainScience:
        return 'BRAIN SCIENCE';
      case ArticleCategory.psychology:
        return 'PSYCHOLOGY';
      case ArticleCategory.lifeSituation:
        return 'LIFE SITUATION';
    }
  }
}
