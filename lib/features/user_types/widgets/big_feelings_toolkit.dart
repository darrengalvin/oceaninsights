import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../music/screens/music_screen.dart';

/// Interactive Big Feelings Toolkit - Help for tough emotions
class BigFeelingsToolkitScreen extends StatefulWidget {
  const BigFeelingsToolkitScreen({super.key});

  @override
  State<BigFeelingsToolkitScreen> createState() => _BigFeelingsToolkitScreenState();
}

class _BigFeelingsToolkitScreenState extends State<BigFeelingsToolkitScreen> {
  _Feeling? _selectedFeeling;
  
  final List<_Feeling> _feelings = [
    _Feeling(
      name: 'Anxious',
      icon: Icons.psychology_rounded,
      color: Colors.purple,
      description: 'Racing thoughts, worry, can\'t settle',
      tools: [
        _Tool('Box Breathing', 'Calm your nervous system', Icons.air_rounded, 'breathing'),
        _Tool('5-4-3-2-1 Grounding', 'Come back to the present', Icons.touch_app_rounded, 'grounding'),
        _Tool('Calm Sounds', 'Soothing background audio', Icons.volume_up_rounded, 'sounds'),
      ],
    ),
    _Feeling(
      name: 'Angry',
      icon: Icons.whatshot_rounded,
      color: Colors.red,
      description: 'Frustrated, irritated, want to explode',
      tools: [
        _Tool('Cool Down Breathing', 'Release the heat', Icons.air_rounded, 'breathing'),
        _Tool('Physical Release', 'Safe ways to let it out', Icons.fitness_center_rounded, 'physical'),
        _Tool('Perspective Check', 'Will this matter tomorrow?', Icons.visibility_rounded, 'perspective'),
      ],
    ),
    _Feeling(
      name: 'Sad',
      icon: Icons.water_drop_rounded,
      color: Colors.blue,
      description: 'Down, heavy, tearful',
      tools: [
        _Tool('Comfort Breathing', 'Gentle self-soothing', Icons.air_rounded, 'breathing'),
        _Tool('Kind Words', 'Affirmations for hard times', Icons.favorite_rounded, 'affirmations'),
        _Tool('Gentle Sounds', 'Comforting audio', Icons.volume_up_rounded, 'sounds'),
      ],
    ),
    _Feeling(
      name: 'Overwhelmed',
      icon: Icons.waves_rounded,
      color: Colors.teal,
      description: 'Too much, can\'t cope, drowning',
      tools: [
        _Tool('Pause & Breathe', 'Stop and reset', Icons.air_rounded, 'breathing'),
        _Tool('Brain Dump', 'Get thoughts out of your head', Icons.edit_note_rounded, 'journal'),
        _Tool('One Thing Focus', 'Just the next small step', Icons.looks_one_rounded, 'focus'),
      ],
    ),
    _Feeling(
      name: 'Lonely',
      icon: Icons.person_outline_rounded,
      color: Colors.indigo,
      description: 'Isolated, disconnected, alone',
      tools: [
        _Tool('Self-Compassion', 'Be your own friend', Icons.favorite_outline_rounded, 'compassion'),
        _Tool('Connection Ideas', 'Ways to reach out', Icons.people_rounded, 'connection'),
        _Tool('Cozy Sounds', 'Feel less alone', Icons.volume_up_rounded, 'sounds'),
      ],
    ),
    _Feeling(
      name: 'Scared',
      icon: Icons.shield_outlined,
      color: Colors.orange,
      description: 'Afraid, nervous, unsafe',
      tools: [
        _Tool('Safety Breathing', 'Feel grounded and safe', Icons.air_rounded, 'breathing'),
        _Tool('Reality Check', 'Separate fear from facts', Icons.fact_check_rounded, 'reality'),
        _Tool('Comfort Space', 'Create feeling of safety', Icons.home_rounded, 'comfort'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
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
          'Big Feelings Toolkit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _selectedFeeling == null
          ? _buildFeelingSelector()
          : _buildToolsForFeeling(),
    );
  }
  
  Widget _buildFeelingSelector() {
    final colours = context.colours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's the feeling?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap what you're feeling right now.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          
          // Feelings grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _feelings.length,
            itemBuilder: (context, index) {
              final feeling = _feelings[index];
              return _buildFeelingCard(feeling);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeelingCard(_Feeling feeling) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        setState(() => _selectedFeeling = feeling);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: feeling.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feeling.icon,
                color: feeling.color,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              feeling.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              feeling.description,
              style: TextStyle(
                color: colours.textMuted,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolsForFeeling() {
    final colours = context.colours;
    final feeling = _selectedFeeling!;
    
    return Column(
      children: [
        // Feeling header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: feeling.color.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feeling.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feeling.icon,
                  color: feeling.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feeling ${feeling.name}',
                      style: TextStyle(
                        color: colours.textBright,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Here's what can help right now",
                      style: TextStyle(
                        color: colours.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _selectedFeeling = null);
                },
                child: Text(
                  'Change',
                  style: TextStyle(color: feeling.color),
                ),
              ),
            ],
          ),
        ),
        
        // Tools list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feeling.tools.length,
            itemBuilder: (context, index) {
              final tool = feeling.tools[index];
              return _buildToolCard(tool, feeling.color);
            },
          ),
        ),
        
        // Quick tip
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colours.cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colours.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getQuickTipForFeeling(feeling.name),
                  style: TextStyle(
                    color: colours.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildToolCard(_Tool tool, Color accentColor) {
    final colours = context.colours;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          UISoundService().playClick();
          
          // Gate tools for premium
          if (!SubscriptionService().isPremium) {
            checkPremiumAccess(context, featureName: 'Big Feelings Toolkit');
            return;
          }
          
          _navigateToTool(tool);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tool.icon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.description,
                      style: TextStyle(
                        color: colours.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: colours.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToTool(_Tool tool) {
    Widget? screen;
    
    switch (tool.type) {
      case 'breathing':
        screen = const BreathingScreen();
        break;
      case 'sounds':
        screen = const MusicScreen();
        break;
      default:
        // Show inline exercise for other types
        _showInlineExercise(tool);
        return;
    }
    
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen!),
      );
    }
  }
  
  void _showInlineExercise(_Tool tool) {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            
            Icon(
              tool.icon,
              color: colours.accent,
              size: 48,
            ),
            const SizedBox(height: 16),
            
            Text(
              tool.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              _getExerciseInstructions(tool.type),
              style: TextStyle(
                color: colours.textBright,
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got It',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  String _getExerciseInstructions(String type) {
    switch (type) {
      case 'grounding':
        return 'Look around and find:\n\n5 things you can SEE\n4 things you can TOUCH\n3 things you can HEAR\n2 things you can SMELL\n1 thing you can TASTE\n\nTake your time with each one.';
      case 'physical':
        return 'Safe ways to release:\n\n• Squeeze a pillow tightly\n• Do jumping jacks or pushups\n• Tear up old paper\n• Scream into a pillow\n• Take a cold shower\n\nLet the energy out safely.';
      case 'perspective':
        return 'Ask yourself:\n\n• Will this matter in a week?\n• What would I tell a friend?\n• What can I actually control here?\n• Is there another way to see this?\n\nSometimes distance helps.';
      case 'affirmations':
        return 'Say to yourself:\n\n"This feeling is temporary"\n"I\'ve gotten through hard things before"\n"It\'s okay to not be okay"\n"I deserve kindness, especially from myself"';
      case 'journal':
        return 'Brain dump technique:\n\n1. Get paper and pen\n2. Set a 5-minute timer\n3. Write everything on your mind\n4. Don\'t edit, just write\n5. When done, take 3 deep breaths\n\nYour head will feel clearer.';
      case 'focus':
        return 'One thing at a time:\n\n1. Pick the smallest next step\n2. Just that - nothing else\n3. When done, pick the next small step\n4. Repeat\n\nSmall steps add up.';
      case 'compassion':
        return 'Self-compassion exercise:\n\n1. Put hand on heart\n2. Say: "This is hard right now"\n3. Say: "Everyone struggles sometimes"\n4. Say: "May I be kind to myself"\n\nTreat yourself like a friend.';
      case 'connection':
        return 'Ways to connect:\n\n• Text someone "thinking of you"\n• Call a family member\n• Go somewhere with people (cafe, park)\n• Join an online community\n• Pet an animal\n\nConnection heals.';
      case 'reality':
        return 'Reality check:\n\n1. Name the fear specifically\n2. Ask: "What evidence do I have?"\n3. Ask: "What\'s the most likely outcome?"\n4. Ask: "What can I do about this now?"\n\nFacts over fear.';
      case 'comfort':
        return 'Create safety:\n\n• Wrap yourself in a blanket\n• Hold something comforting\n• Go to your safe space\n• Put on familiar music\n• Dim the lights\n\nYou are safe right now.';
      default:
        return 'Take a moment to breathe and be present with yourself.';
    }
  }
  
  String _getQuickTipForFeeling(String feeling) {
    switch (feeling) {
      case 'Anxious':
        return 'Tip: Anxiety lives in the future. Bring yourself back to now.';
      case 'Angry':
        return 'Tip: Anger is often a cover for hurt or fear. What\'s underneath?';
      case 'Sad':
        return 'Tip: Sadness needs to move through you. Let it flow.';
      case 'Overwhelmed':
        return 'Tip: You don\'t have to solve everything right now. Just the next step.';
      case 'Lonely':
        return 'Tip: Loneliness is a signal, not a weakness. Reach out.';
      case 'Scared':
        return 'Tip: Fear is trying to protect you. Thank it, then decide what\'s true.';
      default:
        return 'Tip: All feelings pass. You\'ve gotten through before.';
    }
  }
}

class _Feeling {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<_Tool> tools;
  
  const _Feeling({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.tools,
  });
}

class _Tool {
  final String name;
  final String description;
  final IconData icon;
  final String type;
  
  const _Tool(this.name, this.description, this.icon, this.type);
}
