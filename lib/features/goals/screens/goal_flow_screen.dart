import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/theme_options.dart';
import '../data/goals_data.dart';

class GoalFlowScreen extends StatefulWidget {
  final GoalCategory category;
  final Function(SavedGoal) onComplete;
  
  const GoalFlowScreen({
    super.key,
    required this.category,
    required this.onComplete,
  });

  @override
  State<GoalFlowScreen> createState() => _GoalFlowScreenState();
}

class _GoalFlowScreenState extends State<GoalFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Selections
  String? _selectedGoalType;
  String? _selectedTimeframe;
  List<String> _selectedChallenges = [];
  List<String> _selectedValues = [];
  
  int get _totalPages => 4; // Goal type, Timeframe, Challenges, Values
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeGoal();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }
  
  void _completeGoal() {
    final goal = SavedGoal(
      id: const Uuid().v4(),
      categoryId: widget.category.id,
      goalType: _selectedGoalType!,
      timeframe: _selectedTimeframe!,
      challenges: _selectedChallenges,
      values: _selectedValues,
      createdAt: DateTime.now(),
    );
    
    widget.onComplete(goal);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Goal saved successfully!'),
        backgroundColor: context.colours.success,
      ),
    );
  }
  
  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGoalType != null;
      case 1:
        return _selectedTimeframe != null;
      case 2:
        return _selectedChallenges.isNotEmpty;
      case 3:
        return _selectedValues.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.category.name),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(_totalPages, (index) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: index < _totalPages - 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentPage 
                          ? widget.category.color 
                          : colours.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildGoalTypePage(),
                _buildTimeframePage(),
                _buildChallengesPage(),
                _buildValuesPage(),
              ],
            ),
          ),
          
          // Navigation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colours.card,
              border: Border(
                top: BorderSide(color: colours.border),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: _previousPage,
                  child: Text(_currentPage == 0 ? 'Cancel' : 'Back'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _canProceed() ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.category.color,
                  ),
                  child: Text(
                    _currentPage == _totalPages - 1 ? 'Save Goal' : 'Continue',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalTypePage() {
    final colours = context.colours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to achieve?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the goal that best describes what you want.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 24),
          ...widget.category.goalTypes.map((goalType) {
            final isSelected = _selectedGoalType == goalType;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectionTile(
                text: goalType,
                isSelected: isSelected,
                color: widget.category.color,
                onTap: () {
                  setState(() {
                    _selectedGoalType = goalType;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildTimeframePage() {
    final colours = context.colours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When do you want to achieve this?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a realistic timeframe for your goal.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 24),
          ...GoalsData.timeframes.map((timeframe) {
            final isSelected = _selectedTimeframe == timeframe;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectionTile(
                text: timeframe,
                isSelected: isSelected,
                color: widget.category.color,
                onTap: () {
                  setState(() {
                    _selectedTimeframe = timeframe;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildChallengesPage() {
    final colours = context.colours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What might get in your way?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply. Being aware of obstacles helps you overcome them.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.category.challenges.map((challenge) {
              final isSelected = _selectedChallenges.contains(challenge);
              return _MultiSelectChip(
                text: challenge,
                isSelected: isSelected,
                color: widget.category.color,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedChallenges.remove(challenge);
                    } else {
                      _selectedChallenges.add(challenge);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildValuesPage() {
    final colours = context.colours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What matters most to you?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select your top priorities. This helps focus your journey.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.category.values.map((value) {
              final isSelected = _selectedValues.contains(value);
              return _MultiSelectChip(
                text: value,
                isSelected: isSelected,
                color: widget.category.color,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedValues.remove(value);
                    } else if (_selectedValues.length < 5) {
                      _selectedValues.add(value);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '${_selectedValues.length}/5 selected',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  
  const _SelectionTile({
    required this.text,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? color : colours.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : colours.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? colours.background : colours.textBright,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colours.background,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _MultiSelectChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  
  const _MultiSelectChip({
    required this.text,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : colours.cardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : colours.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_rounded,
                size: 18,
                color: colours.background,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colours.background : colours.textBright,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
