import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/theme/theme_options.dart';
import '../../subscription/widgets/premium_gate.dart';
import '../../../core/services/subscription_service.dart';

/// Breathing exercise types
enum BreathingExercise {
  nhsCalming,
  boxBreathing,
  relaxingBreath,
  calming478,
}

extension BreathingExerciseExtension on BreathingExercise {
  String get name {
    switch (this) {
      case BreathingExercise.boxBreathing:
        return 'Box Breathing';
      case BreathingExercise.relaxingBreath:
        return 'Relaxing Breath';
      case BreathingExercise.nhsCalming:
        return 'NHS Calming Breath';
      case BreathingExercise.calming478:
        return '4-7-8 Calming';
    }
  }
  
  String get description {
    switch (this) {
      case BreathingExercise.boxBreathing:
        return 'Equal counts: breathe in, hold, breathe out, hold.';
      case BreathingExercise.relaxingBreath:
        return 'A simple technique to slow your heart rate and reduce stress.';
      case BreathingExercise.nhsCalming:
        return 'The NHS breathing exercise for stress, anxiety and panic.';
      case BreathingExercise.calming478:
        return 'The 4-7-8 technique helps reduce anxiety and promote sleep.';
    }
  }
  
  /// Detailed information about the exercise
  ExerciseInfo get info {
    switch (this) {
      case BreathingExercise.boxBreathing:
        return ExerciseInfo(
          whatIsIt: 'Box breathing, also known as square breathing or 4-4-4-4 breathing. The name comes from its four equal phases that form a "box" pattern when visualised.',
          whyItHelps: 'Slow, steady breathing can help you feel calmer. Counting gives your mind something simple to focus on. If holding your breath feels uncomfortable, use the NHS Calming Breath instead, which has no holds.',
          benefits: [
            'A simple pattern to focus on',
            'Can help you feel calmer',
            'Can be done anywhere',
          ],
          howToUse: 'Find a comfortable position, sitting or lying down. Breathe through your nose if possible. Follow the visual guide: breathe in for 4 seconds, hold for 4 seconds, breathe out for 4 seconds, hold for 4 seconds. Repeat for 4 cycles.',
          frequency: 'Practice 2-3 times daily, or whenever you feel stressed. It\'s particularly effective before important meetings, during moments of anxiety, or as part of your morning/evening routine.',
        );
      case BreathingExercise.relaxingBreath:
        return ExerciseInfo(
          whatIsIt: 'A gentle breathing pattern with a longer exhale than inhale. This simple ratio shift tells your body it\'s safe to relax.',
          whyItHelps: 'Breathing out slowly and gently can help you relax. Many people find it a simple way to unwind.',
          benefits: [
            'Can ease tension',
            'Useful before sleep',
            'Simple and easy to remember',
          ],
          howToUse: 'Breathe in slowly for 4 seconds, then breathe out even more slowly for 6 seconds. Focus on making your exhale smooth and controlled.',
          frequency: 'Use anytime you need to quickly calm down. Ideal before sleep or during stressful moments. Can be practised anywhere, anytime.',
        );
      case BreathingExercise.nhsCalming:
        return ExerciseInfo(
          whatIsIt: 'The calming breathing technique recommended by the NHS for stress, anxiety and panic. It takes just a few minutes and can be done anywhere.',
          whyItHelps: 'The NHS says this exercise can help with stress, anxiety and panic. It uses gentle, regular breaths with no holding, so it is comfortable for most people. Source: NHS, breathing exercises for stress.',
          benefits: [
            'Recommended by the NHS',
            'No breath holding',
            'Can be done standing, sitting or lying down',
          ],
          howToUse: 'Let your breath flow as deep into your belly as is comfortable, without forcing it. Breathe in through your nose and out through your mouth. Breathe in gently, counting from 1 to 5. Then let it flow out gently, counting from 1 to 5. You may not reach 5 at first, and that is fine.',
          frequency: 'Keep going for at least 5 minutes. You will get the most benefit if you do it regularly, as part of your daily routine.',
        );
      case BreathingExercise.calming478:
        return ExerciseInfo(
          whatIsIt: 'The 4-7-8 technique is a popular relaxation exercise based on yogic breathing. It is not an NHS technique.',
          whyItHelps: 'Some people find the slow count and long out-breath relaxing, especially at bedtime. If holding your breath feels uncomfortable, use the NHS Calming Breath instead.',
          benefits: [
            'A slow, steady rhythm',
            'Some people find it helps them wind down',
            'Can be used at bedtime',
          ],
          howToUse: 'Inhale quietly through your nose for 4 seconds. Hold your breath for 7 seconds. Exhale completely through your mouth for 8 seconds. The exhale should make a gentle "whoosh" sound.',
          frequency: 'Try it when you want to wind down, for example at bedtime. Stop if you feel light-headed.',
        );
    }
  }
  
  List<BreathingPhase> get phases {
    switch (this) {
      case BreathingExercise.boxBreathing:
        return [
          BreathingPhase('Breathe In', 4),
          BreathingPhase('Hold', 4),
          BreathingPhase('Breathe Out', 4),
          BreathingPhase('Hold', 4),
        ];
      case BreathingExercise.relaxingBreath:
        return [
          BreathingPhase('Breathe In', 4),
          BreathingPhase('Breathe Out', 6),
        ];
      case BreathingExercise.nhsCalming:
        return [
          BreathingPhase('Breathe In', 5),
          BreathingPhase('Breathe Out', 5),
        ];
      case BreathingExercise.calming478:
        return [
          BreathingPhase('Breathe In', 4),
          BreathingPhase('Hold', 7),
          BreathingPhase('Breathe Out', 8),
        ];
    }
  }
  
  // The NHS exercise runs for at least 5 minutes (30 breaths of 10 seconds).
  int get recommendedCycles => this == BreathingExercise.nhsCalming ? 30 : 4;
}

class BreathingPhase {
  final String instruction;
  final int seconds;
  
  BreathingPhase(this.instruction, this.seconds);
}

/// Detailed information about a breathing exercise
class ExerciseInfo {
  final String whatIsIt;
  final String whyItHelps;
  final List<String> benefits;
  final String howToUse;
  final String frequency;
  
  const ExerciseInfo({
    required this.whatIsIt,
    required this.whyItHelps,
    required this.benefits,
    required this.howToUse,
    required this.frequency,
  });
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  BreathingExercise? _selectedExercise;
  bool _isActive = false;
  int _currentPhaseIndex = 0;
  int _currentSecond = 0;
  int _currentCycle = 0;
  Timer? _timer;
  
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  
  // Phase-specific audio for breathing exercises
  final AudioPlayer _breathInPlayer = AudioPlayer();
  final AudioPlayer _breathOutPlayer = AudioPlayer();
  final AudioPlayer _heartbeatPlayer = AudioPlayer();
  
  // Combined breath audio for Energising (fast-paced)
  final AudioPlayer _energisingPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _initAudio();
  }
  
  Future<void> _initAudio() async {
    // Audio will be loaded just-in-time when playing for better reliability in Release builds
    debugPrint('🎵 Audio players initialized - will load on demand');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    _breathInPlayer.dispose();
    _breathOutPlayer.dispose();
    _heartbeatPlayer.dispose();
    _energisingPlayer.dispose();
    super.dispose();
  }
  
  void _startExercise(BreathingExercise exercise) async {
    // The NHS exercise and Box Breathing are free, others require subscription
    if (exercise != BreathingExercise.boxBreathing &&
        exercise != BreathingExercise.nhsCalming) {
      final subscriptionService = SubscriptionService();
      if (!subscriptionService.isPremium) {
        final unlocked = await checkPremiumAccess(context, featureName: exercise.name);
        if (!unlocked) return;
      }
    }
    
    setState(() {
      _selectedExercise = exercise;
      _isActive = true;
      _currentPhaseIndex = 0;
      _currentSecond = exercise.phases[0].seconds;
      _currentCycle = 1;
    });
    _updateAnimation();
    _startTimer();
    
    // Start appropriate audio for the exercise
    _startExerciseAudio(exercise);
  }
  
  Future<void> _startExerciseAudio(BreathingExercise exercise) async {
    switch (exercise) {
      case BreathingExercise.nhsCalming:
      case BreathingExercise.boxBreathing:
      case BreathingExercise.relaxingBreath:
      case BreathingExercise.calming478:
        // All exercises use phase-specific audio
        _playPhaseAudio(exercise.phases[0].instruction);
        break;
    }
  }
  
  Future<void> _stopAllPhaseAudio() async {
    try {
      await _breathInPlayer.stop();
      await _breathOutPlayer.stop();
      await _heartbeatPlayer.stop();
      await _energisingPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping phase audio: $e');
    }
  }
  
  Future<void> _playPhaseAudio(String instruction) async {
    debugPrint('🎵 Playing phase audio for: $instruction');
    try {
      if (instruction.contains('In')) {
        // Stop only the other players, not the one we're about to use
        await _breathOutPlayer.stop();
        await _heartbeatPlayer.stop();
        await _energisingPlayer.stop();
        
        debugPrint('🎵 Loading and playing breath IN audio');
        await _breathInPlayer.setAsset('assets/audio/breath-in-242641.mp3');
        await _breathInPlayer.setVolume(0.6);
        await _breathInPlayer.play();
        debugPrint('✅ Breath IN audio playing');
      } else if (instruction.contains('Out')) {
        // Stop only the other players
        await _breathInPlayer.stop();
        await _heartbeatPlayer.stop();
        await _energisingPlayer.stop();
        
        debugPrint('🎵 Loading and playing breath OUT audio');
        await _breathOutPlayer.setAsset('assets/audio/breath-out-242642.mp3');
        await _breathOutPlayer.setVolume(0.6);
        await _breathOutPlayer.play();
        debugPrint('✅ Breath OUT audio playing');
      } else if (instruction.contains('Hold')) {
        // Stop only the other players
        await _breathInPlayer.stop();
        await _breathOutPlayer.stop();
        await _energisingPlayer.stop();
        
        debugPrint('🎵 Loading and playing HEARTBEAT audio');
        await _heartbeatPlayer.setAsset('assets/audio/heart-beat-137135.mp3');
        await _heartbeatPlayer.setVolume(0.5);
        await _heartbeatPlayer.play();
        debugPrint('✅ Heartbeat audio playing');
      }
    } catch (e) {
      debugPrint('❌ Error playing phase audio: $e');
    }
  }
  
  void _stopExercise() {
    _timer?.cancel();
    _breathController.stop();
    _stopAllPhaseAudio();
    setState(() {
      _isActive = false;
      _selectedExercise = null;
    });
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSecond > 1) {
        setState(() {
          _currentSecond--;
        });
      } else {
        _nextPhase();
      }
    });
  }
  
  void _nextPhase() {
    final exercise = _selectedExercise!;
    final nextIndex = (_currentPhaseIndex + 1) % exercise.phases.length;
    
    if (nextIndex == 0) {
      if (_currentCycle >= exercise.recommendedCycles) {
        _completeExercise();
        return;
      }
      setState(() {
        _currentCycle++;
      });
    }
    
    setState(() {
      _currentPhaseIndex = nextIndex;
      _currentSecond = exercise.phases[nextIndex].seconds;
    });
    _updateAnimation();
    
    // Play phase audio for exercises that use phase-specific sounds
    _playPhaseAudio(exercise.phases[nextIndex].instruction);
  }
  
  void _updateAnimation() {
    final phase = _selectedExercise!.phases[_currentPhaseIndex];
    _breathController.duration = Duration(seconds: phase.seconds);
    
    if (phase.instruction.contains('In')) {
      _breathController.forward(from: 0);
    } else if (phase.instruction.contains('Out')) {
      _breathController.reverse(from: 1);
    }
  }
  
  void _completeExercise() {
    _timer?.cancel();
    _breathController.stop();
    _stopAllPhaseAudio();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Well done!'),
        content: const Text(
          'You\'ve completed the breathing exercise. Take a moment to notice how you feel.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isActive = false;
                _selectedExercise = null;
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercises'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isActive) {
              _stopExercise();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: _isActive ? _buildActiveExercise() : _buildExerciseList(),
    );
  }
  
  Widget _buildExerciseList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose an exercise',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Each exercise is designed to help you in different situations.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ...BreathingExercise.values.map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseCard(
                exercise: exercise,
                onTap: () => _startExercise(exercise),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildActiveExercise() {
    final colours = context.colours;
    final exercise = _selectedExercise!;
    final phase = exercise.phases[_currentPhaseIndex];
    
    // Calculate progress for box animation
    final phaseProgress = 1.0 - (_currentSecond / phase.seconds);
    
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cycle $_currentCycle of ${exercise.recommendedCycles}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 48),
                // Use box animation for Box Breathing, circle for others
                if (exercise == BreathingExercise.boxBreathing)
                  _buildBoxBreathingVisual(colours, phaseProgress)
                else
                  AnimatedBuilder(
                    animation: _breathAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 220 * _breathAnimation.value,
                        height: 220 * _breathAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colours.accent.withOpacity(0.1),
                          border: Border.all(
                            color: colours.accent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colours.accent.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$_currentSecond',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: colours.accent,
                              fontSize: 64,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 48),
                Text(
                  phase.instruction,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _stopExercise,
              child: const Text('Stop Exercise'),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildBoxBreathingVisual(AppColours colours, double phaseProgress) {
    const boxSize = 220.0;
    
    // Calculate overall progress (0-4 representing all 4 sides)
    final overallProgress = _currentPhaseIndex + phaseProgress;
    
    return SizedBox(
      width: boxSize + 60,
      height: boxSize + 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle outer glow
          Container(
            width: boxSize + 30,
            height: boxSize + 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colours.accent.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // The animated box
          CustomPaint(
            size: const Size(boxSize, boxSize),
            painter: _BoxBreathingPainter(
              currentPhase: _currentPhaseIndex,
              phaseProgress: phaseProgress,
              accentColor: colours.accent,
              backgroundColor: colours.card,
            ),
          ),
          // Centre content with countdown
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Phase icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _getPhaseIcon(_currentPhaseIndex),
                  key: ValueKey(_currentPhaseIndex),
                  size: 28,
                  color: colours.accent,
                ),
              ),
              const SizedBox(height: 8),
              // Countdown number
              Text(
                '$_currentSecond',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w200,
                  color: colours.accent,
                ),
              ),
              const SizedBox(height: 4),
              // Progress indicator text
              Text(
                '${(overallProgress / 4 * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colours.textMuted,
                ),
              ),
            ],
          ),
          // Corner labels - simple text
          Positioned(
            left: 8,
            bottom: 8,
            child: _buildCornerLabel('IN', 0, colours),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: _buildCornerLabel('HOLD', 1, colours),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: _buildCornerLabel('OUT', 2, colours),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: _buildCornerLabel('HOLD', 3, colours),
          ),
        ],
      ),
    );
  }
  
  IconData _getPhaseIcon(int phase) {
    switch (phase) {
      case 0: return Icons.arrow_upward_rounded;
      case 1: return Icons.pause_rounded;
      case 2: return Icons.arrow_downward_rounded;
      case 3: return Icons.pause_rounded;
      default: return Icons.circle;
    }
  }
  
  Widget _buildCornerLabel(String label, int phaseIndex, AppColours colours) {
    final isActive = _currentPhaseIndex == phaseIndex;
    final isCompleted = _currentPhaseIndex > phaseIndex;
    
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        color: isActive 
            ? colours.accent 
            : isCompleted 
                ? colours.accent.withOpacity(0.7)
                : colours.textMuted.withOpacity(0.5),
        letterSpacing: 1,
      ),
      child: Text(label),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final BreathingExercise exercise;
  final VoidCallback onTap;
  
  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final exercise = widget.exercise;
    final info = exercise.info;
    
    return Container(
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main card content - tappable to start
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colours.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colours.accent.withOpacity(0.3)),
                        ),
                        child: Icon(
                          Icons.air_rounded,
                          color: colours.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colours.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: colours.accent,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildPhaseChip(context, exercise.phases),
                      const SizedBox(width: 12),
                      Text(
                        '${exercise.recommendedCycles} cycles',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Learn More button
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colours.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: colours.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isExpanded ? 'Show Less' : 'Learn More',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colours.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable info section
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildInfoSection(context, info, colours),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(BuildContext context, ExerciseInfo info, AppColours colours) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBlock(
            context,
            colours,
            icon: Icons.help_outline_rounded,
            title: 'What is it?',
            content: info.whatIsIt,
          ),
          const SizedBox(height: 16),
          _buildInfoBlock(
            context,
            colours,
            icon: Icons.psychology_outlined,
            title: 'Why does it help?',
            content: info.whyItHelps,
          ),
          const SizedBox(height: 16),
          _buildInfoBlock(
            context,
            colours,
            icon: Icons.check_circle_outline_rounded,
            title: 'Benefits',
            content: null,
            bulletPoints: info.benefits,
          ),
          const SizedBox(height: 16),
          _buildInfoBlock(
            context,
            colours,
            icon: Icons.lightbulb_outline_rounded,
            title: 'How to use',
            content: info.howToUse,
          ),
          const SizedBox(height: 16),
          _buildInfoBlock(
            context,
            colours,
            icon: Icons.schedule_rounded,
            title: 'How often?',
            content: info.frequency,
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoBlock(
    BuildContext context,
    AppColours colours, {
    required IconData icon,
    required String title,
    String? content,
    List<String>? bulletPoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colours.accent),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colours.textBright,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (content != null)
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: colours.textLight,
              ),
            ),
          ),
        if (bulletPoints != null)
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colours.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: colours.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPhaseChip(BuildContext context, List<BreathingPhase> phases) {
    final colours = context.colours;
    final pattern = phases.map((p) => '${p.seconds}s').join('-');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        pattern,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colours.textLight,
        ),
      ),
    );
  }
}

/// Custom painter for the box breathing animation
/// Draws a box with progress indicator using shades of the accent colour
class _BoxBreathingPainter extends CustomPainter {
  final int currentPhase;
  final double phaseProgress;
  final Color accentColor;
  final Color backgroundColor;
  
  _BoxBreathingPainter({
    required this.currentPhase,
    required this.phaseProgress,
    required this.accentColor,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const radius = Radius.circular(20);
    const margin = 12.0;
    
    // Draw the background box
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), bgPaint);
    
    // Draw the inactive border (full box outline - dimmed)
    final inactivePaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    
    final borderRect = Rect.fromLTWH(margin, margin, size.width - 2 * margin, size.height - 2 * margin);
    canvas.drawRRect(RRect.fromRectAndRadius(borderRect, const Radius.circular(12)), inactivePaint);
    
    // Draw completed sides (full opacity)
    final completedPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < currentPhase; i++) {
      _drawSide(canvas, size, i, 1.0, completedPaint, margin);
    }
    
    // Draw the current phase with progress
    _drawSide(canvas, size, currentPhase, phaseProgress, completedPaint, margin);
    
    // Draw the progress dot
    final dotPosition = _getPositionOnBox(size, currentPhase, phaseProgress, margin);
    
    // Outer glow
    final outerGlowPaint = Paint()
      ..color = accentColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotPosition, 18, outerGlowPaint);
    
    // Middle glow
    final middleGlowPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotPosition, 12, middleGlowPaint);
    
    // Inner dot
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotPosition, 8, dotPaint);
    
    // White centre highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotPosition + const Offset(-2, -2), 3, highlightPaint);
  }
  
  void _drawSide(Canvas canvas, Size size, int side, double progress, Paint paint, double margin) {
    if (progress <= 0) return;
    
    final path = Path();
    final innerWidth = size.width - 2 * margin;
    final innerHeight = size.height - 2 * margin;
    
    switch (side) {
      case 0: // Left side - bottom to top (Breathe In)
        path.moveTo(margin, size.height - margin);
        path.lineTo(margin, size.height - margin - (innerHeight * progress));
        break;
      case 1: // Top side - left to right (Hold)
        path.moveTo(margin, margin);
        path.lineTo(margin + (innerWidth * progress), margin);
        break;
      case 2: // Right side - top to bottom (Breathe Out)
        path.moveTo(size.width - margin, margin);
        path.lineTo(size.width - margin, margin + (innerHeight * progress));
        break;
      case 3: // Bottom side - right to left (Hold)
        path.moveTo(size.width - margin, size.height - margin);
        path.lineTo(size.width - margin - (innerWidth * progress), size.height - margin);
        break;
    }
    
    canvas.drawPath(path, paint);
  }
  
  Offset _getPositionOnBox(Size size, int side, double progress, double margin) {
    final innerWidth = size.width - 2 * margin;
    final innerHeight = size.height - 2 * margin;
    
    switch (side) {
      case 0: // Left side - bottom to top
        return Offset(margin, size.height - margin - (innerHeight * progress));
      case 1: // Top side - left to right
        return Offset(margin + (innerWidth * progress), margin);
      case 2: // Right side - top to bottom
        return Offset(size.width - margin, margin + (innerHeight * progress));
      case 3: // Bottom side - right to left
        return Offset(size.width - margin - (innerWidth * progress), size.height - margin);
      default:
        return Offset.zero;
    }
  }
  
  @override
  bool shouldRepaint(covariant _BoxBreathingPainter oldDelegate) {
    return currentPhase != oldDelegate.currentPhase ||
           phaseProgress != oldDelegate.phaseProgress;
  }
}
