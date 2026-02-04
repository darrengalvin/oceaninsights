import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';

/// Interest Explorer - mini challenges to discover interests (no typing)
class InterestExplorerScreen extends StatefulWidget {
  const InterestExplorerScreen({super.key});

  @override
  State<InterestExplorerScreen> createState() => _InterestExplorerScreenState();
}

class _InterestExplorerScreenState extends State<InterestExplorerScreen> {
  int _selectedCategoryIndex = 0;
  final Set<String> _triedChallenges = {};
  final Set<String> _likedChallenges = {};
  
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'creative',
      'title': 'Creative',
      'icon': Icons.palette_outlined,
      'color': Colors.orange,
      'challenges': [
        {'id': 'draw', 'title': 'Sketch something', 'description': 'Draw anything - no skill required'},
        {'id': 'music', 'title': 'Make a beat', 'description': 'Tap out a rhythm on your desk'},
        {'id': 'story', 'title': 'Start a story', 'description': 'Write 3 sentences about anything'},
        {'id': 'photo', 'title': 'Photo challenge', 'description': 'Take 5 photos of interesting textures'},
      ],
    },
    {
      'id': 'tech',
      'title': 'Tech',
      'icon': Icons.computer_outlined,
      'color': Colors.blue,
      'challenges': [
        {'id': 'build', 'title': 'Build something', 'description': 'Make a simple webpage or app screen'},
        {'id': 'fix', 'title': 'Fix a problem', 'description': 'Troubleshoot a device or app issue'},
        {'id': 'learn_code', 'title': 'Learn 3 commands', 'description': 'Try basic programming concepts'},
        {'id': 'design', 'title': 'Design an app', 'description': 'Sketch an app idea on paper'},
      ],
    },
    {
      'id': 'active',
      'title': 'Active',
      'icon': Icons.directions_run_outlined,
      'color': Colors.green,
      'challenges': [
        {'id': 'move', 'title': '10-min movement', 'description': 'Walk, stretch, or dance'},
        {'id': 'sport', 'title': 'Try a sport', 'description': 'Shoot hoops, kick a ball, anything'},
        {'id': 'nature', 'title': 'Outdoor explore', 'description': 'Walk somewhere new near you'},
        {'id': 'challenge', 'title': 'Physical challenge', 'description': 'How many push-ups can you do?'},
      ],
    },
    {
      'id': 'social',
      'title': 'Social',
      'icon': Icons.people_outline,
      'color': Colors.purple,
      'challenges': [
        {'id': 'connect', 'title': 'Reach out', 'description': 'Message someone you haven\'t talked to'},
        {'id': 'help', 'title': 'Help someone', 'description': 'Do one kind thing for another person'},
        {'id': 'listen', 'title': 'Really listen', 'description': 'Have a conversation and just listen'},
        {'id': 'group', 'title': 'Join something', 'description': 'Find a club, group, or activity'},
      ],
    },
    {
      'id': 'mind',
      'title': 'Mind',
      'icon': Icons.psychology_outlined,
      'color': Colors.teal,
      'challenges': [
        {'id': 'puzzle', 'title': 'Solve a puzzle', 'description': 'Try a riddle, sudoku, or brain teaser'},
        {'id': 'learn', 'title': 'Learn a fact', 'description': 'Research something you\'re curious about'},
        {'id': 'debate', 'title': 'Argue both sides', 'description': 'Pick a topic and debate yourself'},
        {'id': 'plan', 'title': 'Plan something', 'description': 'Map out a project or goal'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final currentCategory = _categories[_selectedCategoryIndex];
    final categoryColor = currentCategory['color'] as Color;
    
    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Explore Interests',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_likedChallenges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_likedChallenges.length}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = index == _selectedCategoryIndex;
                final color = category['color'] as Color;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedCategoryIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? color : colours.cardLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? color : colours.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : colours.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category['title'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : colours.textBright,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    currentCategory['icon'] as IconData,
                    color: categoryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentCategory['title'] as String,
                          style: TextStyle(
                            color: colours.textBright,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Try mini challenges to see if you enjoy it',
                          style: TextStyle(
                            color: colours.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Challenges
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: (currentCategory['challenges'] as List).length,
              itemBuilder: (context, index) {
                final challenge = (currentCategory['challenges'] as List)[index];
                final challengeId = challenge['id'] as String;
                final hasTried = _triedChallenges.contains(challengeId);
                final hasLiked = _likedChallenges.contains(challengeId);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colours.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasLiked ? Colors.green : colours.border,
                      width: hasLiked ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: hasTried
                                    ? (hasLiked ? Colors.green : categoryColor).withOpacity(0.1)
                                    : colours.cardLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                hasTried
                                    ? (hasLiked ? Icons.favorite : Icons.check)
                                    : Icons.play_arrow_rounded,
                                color: hasTried
                                    ? (hasLiked ? Colors.green : categoryColor)
                                    : colours.textMuted,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    challenge['title'] as String,
                                    style: TextStyle(
                                      color: colours.textBright,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    challenge['description'] as String,
                                    style: TextStyle(
                                      color: colours.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(height: 1, color: colours.border),
                      
                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  UISoundService().playClick();
                                  setState(() {
                                    _triedChallenges.add(challengeId);
                                  });
                                  _showTrySheet(challenge, categoryColor);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: hasTried
                                        ? categoryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        hasTried ? Icons.replay : Icons.play_arrow,
                                        color: hasTried ? categoryColor : colours.textMuted,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        hasTried ? 'Try Again' : 'Try It',
                                        style: TextStyle(
                                          color: hasTried ? categoryColor : colours.textMuted,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: colours.border,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  UISoundService().playClick();
                                  setState(() {
                                    if (hasLiked) {
                                      _likedChallenges.remove(challengeId);
                                    } else {
                                      _likedChallenges.add(challengeId);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: hasLiked
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        hasLiked ? Icons.favorite : Icons.favorite_outline,
                                        color: hasLiked ? Colors.green : colours.textMuted,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        hasLiked ? 'Liked!' : 'I Like This',
                                        style: TextStyle(
                                          color: hasLiked ? Colors.green : colours.textMuted,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showTrySheet(Map<String, dynamic> challenge, Color color) {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colours.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: color,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              challenge['title'] as String,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              challenge['description'] as String,
              style: TextStyle(color: colours.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.timer_outlined, color: colours.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'Take 5-10 minutes to try this challenge',
                    style: TextStyle(
                      color: colours.textBright,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got It!',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
