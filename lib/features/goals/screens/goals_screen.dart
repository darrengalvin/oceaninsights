import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/theme/theme_options.dart';
import '../data/goals_data.dart';
import 'goal_flow_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final Box _userBox = Hive.box('user_data');
  List<SavedGoal> _savedGoals = [];
  
  @override
  void initState() {
    super.initState();
    _loadSavedGoals();
  }
  
  void _loadSavedGoals() {
    final goalsData = _userBox.get('saved_goals', defaultValue: <dynamic>[]);
    setState(() {
      _savedGoals = (goalsData as List)
          .map((e) => SavedGoal.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }
  
  Future<void> _saveGoal(SavedGoal goal) async {
    _savedGoals.add(goal);
    await _userBox.put(
      'saved_goals',
      _savedGoals.map((g) => g.toMap()).toList(),
    );
    setState(() {});
  }
  
  Future<void> _deleteGoal(String id) async {
    _savedGoals.removeWhere((g) => g.id == id);
    await _userBox.put(
      'saved_goals',
      _savedGoals.map((g) => g.toMap()).toList(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
      ),
      body: _savedGoals.isEmpty 
          ? _buildEmptyState() 
          : _buildGoalsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalCategories(context),
        backgroundColor: colours.accent,
        foregroundColor: colours.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal'),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final colours = context.colours;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colours.accent.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.flag_rounded,
                size: 56,
                color: colours.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No goals yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Set your first goal to start your journey.\nAll selections are tap-only - no typing needed.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colours.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showGoalCategories(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Your First Goal'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _savedGoals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final goal = _savedGoals[index];
        final category = GoalsData.categories.firstWhere(
          (c) => c.id == goal.categoryId,
          orElse: () => GoalsData.categories.first,
        );
        
        return _GoalCard(
          goal: goal,
          category: category,
          onDelete: () => _deleteGoal(goal.id),
        );
      },
    );
  }
  
  void _showGoalCategories(BuildContext context) {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colours.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'What area of life?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: GoalsData.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = GoalsData.categories[index];
                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GoalFlowScreen(
                              category: category,
                              onComplete: _saveGoal,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final GoalCategory category;
  final VoidCallback onTap;
  
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: category.color.withOpacity(0.3)),
              ),
              child: Text(
                category.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colours.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavedGoal goal;
  final GoalCategory category;
  final VoidCallback onDelete;
  
  const _GoalCard({
    required this.goal,
    required this.category,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.goalType,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: colours.textMuted),
                onPressed: () => _showDeleteConfirmation(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colours.cardLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: colours.accent),
                const SizedBox(width: 8),
                Text(
                  goal.timeframe,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colours.accent,
                  ),
                ),
              ],
            ),
          ),
          if (goal.challenges.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Challenges:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colours.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: goal.challenges.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colours.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colours.warning.withOpacity(0.3)),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 12,
                    color: colours.warning,
                  ),
                ),
              )).toList(),
            ),
          ],
          if (goal.values.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'What matters:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colours.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: goal.values.map((v) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colours.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colours.success.withOpacity(0.3)),
                ),
                child: Text(
                  v,
                  style: TextStyle(
                    fontSize: 12,
                    color: colours.success,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    final colours = context.colours;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('Are you sure you want to remove this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: colours.error),
            ),
          ),
        ],
      ),
    );
  }
}
