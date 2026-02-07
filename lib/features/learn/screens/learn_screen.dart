import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/user_provider.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../../../core/services/subscription_service.dart';
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
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colours.accent,
          unselectedLabelColor: colours.textMuted,
          indicatorColor: colours.accent,
          dividerColor: colours.border,
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
    final colours = context.colours;
    
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: colours.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colours.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final article = articles[index];
        return _ArticleCard(
          article: article,
          showAgeTag: showAgeTag,
          onTap: () async {
            final subscriptionService = SubscriptionService();
            
            // Allow first article for free (tease)
            if (!subscriptionService.isPremium && index > 0) {
              final unlocked = await checkPremiumAccess(context, featureName: 'Learn');
              if (!unlocked) return;
            }
            
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
    final colours = context.colours;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(article.category),
                color: colours.accent,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colours.textMuted,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${article.readTimeMinutes} min read',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colours.textMuted,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colours.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.brainScience:
        return Icons.psychology_outlined;
      case ArticleCategory.psychology:
        return Icons.favorite_outline_rounded;
      case ArticleCategory.lifeSituation:
        return Icons.groups_outlined;
    }
  }
}
