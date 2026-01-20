import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/user_provider.dart';
import '../data/learn_content.dart';
import 'article_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn & Understand'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.aquaGlow,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.aquaGlow,
          dividerColor: AppTheme.cardBorder,
          tabs: const [
            Tab(text: 'Brain Science'),
            Tab(text: 'Psychology'),
            Tab(text: 'Life Situations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrainScienceTab(),
          _buildPsychologyTab(),
          _buildLifeSituationsTab(),
        ],
      ),
    );
  }
  
  Widget _buildBrainScienceTab() {
    return _ArticleListView(
      articles: LearnContent.brainScienceArticles,
      emptyMessage: 'Brain science articles coming soon',
    );
  }
  
  Widget _buildPsychologyTab() {
    return _ArticleListView(
      articles: LearnContent.psychologyArticles,
      emptyMessage: 'Psychology articles coming soon',
    );
  }
  
  Widget _buildLifeSituationsTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final ageBracket = userProvider.ageBracket;
        final filteredArticles = LearnContent.lifeSituationArticles
            .where((a) => a.ageBrackets == null || 
                         a.ageBrackets!.contains(ageBracket))
            .toList();
        
        return _ArticleListView(
          articles: filteredArticles,
          emptyMessage: 'Life situation articles coming soon',
          showAgeTag: true,
        );
      },
    );
  }
}

class _ArticleListView extends StatelessWidget {
  final List<Article> articles;
  final String emptyMessage;
  final bool showAgeTag;
  
  const _ArticleListView({
    required this.articles,
    required this.emptyMessage,
    this.showAgeTag = false,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final article = articles[index];
        return _ArticleCard(
          article: article,
          showAgeTag: showAgeTag,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleScreen(article: article),
              ),
            );
          },
        );
      },
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final bool showAgeTag;
  final VoidCallback onTap;
  
  const _ArticleCard({
    required this.article,
    required this.showAgeTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.midnightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(article.category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCategoryColor(article.category).withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(article.category),
                    color: _getCategoryColor(article.category),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${article.readTimeMinutes} min read',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              article.summary,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showAgeTag && article.ageBrackets != null) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: article.ageBrackets!.map((age) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.slateDepth,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      age,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.brainScience:
        return AppTheme.aquaGlow;
      case ArticleCategory.psychology:
        return AppTheme.coralPink;
      case ArticleCategory.lifeSituation:
        return AppTheme.warmAmber;
    }
  }
  
  IconData _getCategoryIcon(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.brainScience:
        return Icons.psychology_rounded;
      case ArticleCategory.psychology:
        return Icons.favorite_rounded;
      case ArticleCategory.lifeSituation:
        return Icons.groups_rounded;
    }
  }
}
