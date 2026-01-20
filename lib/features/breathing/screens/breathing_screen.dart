import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';

/// Breathing exercise types
enum BreathingExercise {
  boxBreathing,
  relaxingBreath,
  energising,
  calming478,
}

extension BreathingExerciseExtension on BreathingExercise {
  String get name {
    switch (this) {
      case BreathingExercise.boxBreathing:
        return 'Box Breathing';
      case BreathingExercise.relaxingBreath:
        return 'Relaxing Breath';
      case BreathingExercise.energising:
        return 'Energising';
      case BreathingExercise.calming478:
        return '4-7-8 Calming';
    }
  }
  
  String get description {
    switch (this) {
      case BreathingExercise.boxBreathing:
        return 'Used by Navy SEALs to stay calm under pressure. Equal inhale, hold, exhale, hold.';
      case BreathingExercise.relaxingBreath:
        return 'A simple technique to slow your heart rate and reduce stress.';
      case BreathingExercise.energising:
        return 'Quick breaths to increase alertness and energy levels.';
      case BreathingExercise.calming478:
        return 'The 4-7-8 technique helps reduce anxiety and promote sleep.';
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
      case BreathingExercise.energising:
        return [
          BreathingPhase('Breathe In', 2),
          BreathingPhase('Breathe Out', 2),
        ];
      case BreathingExercise.calming478:
        return [
          BreathingPhase('Breathe In', 4),
          BreathingPhase('Hold', 7),
          BreathingPhase('Breathe Out', 8),
        ];
    }
  }
  
  int get recommendedCycles => 4;
}

class BreathingPhase {
  final String instruction;
  final int seconds;
  
  BreathingPhase(this.instruction, this.seconds);
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }
  
  void _startExercise(BreathingExercise exercise) {
    setState(() {
      _selectedExercise = exercise;
      _isActive = true;
      _currentPhaseIndex = 0;
      _currentSecond = exercise.phases[0].seconds;
      _currentCycle = 1;
    });
    _updateAnimation();
    _startTimer();
  }
  
  void _stopExercise() {
    _timer?.cancel();
    _breathController.stop();
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
}

class _ExerciseCard extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onTap;
  
  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
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
