import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme_options.dart';
import '../../../../core/services/ui_sound_service.dart';
import '../../../affirmations/data/affirmations_data.dart';
import '../models/bubble.dart';
import '../models/obstacle.dart';
import '../models/collectible.dart';
import '../widgets/bubble_painter.dart';

enum GameMode { zen, challenge }

class BubbleRiseScreen extends StatefulWidget {
  const BubbleRiseScreen({super.key});

  @override
  State<BubbleRiseScreen> createState() => _BubbleRiseScreenState();
}

class _BubbleRiseScreenState extends State<BubbleRiseScreen>
    with TickerProviderStateMixin {
  final List<Bubble> _bubbles = [];
  final List<Obstacle> _obstacles = [];
  final List<Collectible> _collectibles = [];
  
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _affirmationTimer;
  
  int _score = 0;
  int _highScore = 0;
  int _bubblesReached = 0;
  int _breathsCounted = 0;
  bool _isGameOver = false;
  Size? _canvasSize;
  
  // Breath control - AUTOMATIC breathing cycle
  bool _isBreathingIn = true;
  double _breathProgress = 0.0; // 0.0 to 1.0 through current phase
  Timer? _breathCycleTimer;
  static const int _breathInDuration = 4; // seconds
  static const int _breathOutDuration = 6; // seconds
  int _breathPhaseTimeRemaining = 4;
  
  // Game mode
  GameMode _gameMode = GameMode.challenge;
  
  // Affirmations
  String? _currentAffirmation;
  bool _showAffirmation = false;
  
  // Breathing circle animation
  late AnimationController _breathCircleController;
  
  // Bubble steering
  double _bubbleSteerX = 0.0; // -1.0 to 1.0
  
  @override
  void initState() {
    super.initState();
    _breathCircleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Full breath cycle
    )..repeat();
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _breathCycleTimer?.cancel();
    _affirmationTimer?.cancel();
    _breathCircleController.dispose();
    super.dispose();
  }
  
  void _startGame() {
    if (_canvasSize == null) return;
    
    setState(() {
      _bubbles.clear();
      _obstacles.clear();
      _collectibles.clear();
      _score = 0;
      _bubblesReached = 0;
      _breathsCounted = 0;
      _isGameOver = false;
      _currentAffirmation = null;
      _showAffirmation = false;
      _isBreathingIn = true;
      _breathProgress = 0.0;
      _breathPhaseTimeRemaining = _breathInDuration;
      _bubbleSteerX = 0.0;
    });
    
    // Spawn initial bubble
    _spawnBubble();
    
    // Start game loop
    _startGameLoop();
    
    // Start spawning obstacles and collectibles
    _startSpawning();
    
    // Start automatic breathing cycle
    _startBreathingCycle();
  }
  
  void _startGameLoop() {
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 FPS
      (_) => _updateGame(),
    );
  }
  
  void _startSpawning() {
    _spawnTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!_isGameOver && _canvasSize != null) {
          _spawnObstacle();
          if (math.Random().nextDouble() < 0.4) {
            _spawnCollectible();
          }
        }
      },
    );
  }
  
  void _startBreathingCycle() {
    // Update breathing cycle every 100ms
    _breathCycleTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (_isGameOver) return;
        
        setState(() {
          final currentDuration = _isBreathingIn ? _breathInDuration : _breathOutDuration;
          _breathProgress += 0.1 / currentDuration;
          
          if (_breathProgress >= 1.0) {
            // Switch phase
            _breathProgress = 0.0;
            _isBreathingIn = !_isBreathingIn;
            _breathPhaseTimeRemaining = _isBreathingIn ? _breathInDuration : _breathOutDuration;
            
            if (!_isBreathingIn) {
              // Completed a full breath cycle
              _breathsCounted++;
            }
          } else {
            // Update time remaining
            _breathPhaseTimeRemaining = ((1.0 - _breathProgress) * currentDuration).ceil();
          }
        });
      },
    );
  }
  
  void _updateGame() {
    if (_isGameOver || _canvasSize == null) return;
    
    setState(() {
      // Update all bubbles based on automatic breathing cycle
      for (final bubble in _bubbles) {
        bubble.update(_isBreathingIn, _breathProgress);
        
        // Apply steering (left/right navigation)
        if (_bubbleSteerX != 0) {
          bubble.position = Offset(
            (bubble.position.dx + _bubbleSteerX * 3).clamp(bubble.radius, _canvasSize!.width - bubble.radius),
            bubble.position.dy,
          );
        }
        
        // Check if bubble reached surface (top of screen)
        if (bubble.position.dy < -20 && !bubble.isPopped) {
          bubble.pop();
          _bubblesReached++;
          _score += 10;
          HapticFeedback.lightImpact();
          UISoundService().playPerfect();
          
          // Spawn new bubble
          _spawnBubble();
        }
        
        // Check collisions with obstacles
        for (final obstacle in _obstacles) {
          if (obstacle.contains(bubble.position, bubble.radius)) {
            if (!bubble.isPopped) {
              bubble.pop();
              if (_gameMode == GameMode.challenge) {
                _gameOver();
              } else {
                // In Zen mode, just spawn a new bubble
                _spawnBubble();
              }
              HapticFeedback.mediumImpact();
            }
          }
        }
        
        // Check collectible pickups
        for (final collectible in _collectibles) {
          if (collectible.collectedBy(bubble.position, bubble.radius)) {
            collectible.collect();
            _score += collectible.points;
            _showCollectibleAffirmation(collectible.affirmation);
            UISoundService().playClick();
            HapticFeedback.lightImpact();
          }
        }
      }
      
      // Update obstacles
      for (final obstacle in _obstacles) {
        obstacle.update();
      }
      
      // Update collectibles
      for (final collectible in _collectibles) {
        collectible.update();
      }
      
      // Remove off-screen obstacles and collectibles (they move down/up past screen)
      _obstacles.removeWhere((o) => o.position.dy < -100);
      _collectibles.removeWhere((c) => c.position.dy < -100 || c.isCollected);
    });
  }
  
  void _spawnBubble() {
    if (_canvasSize == null) return;
    
    final random = math.Random();
    final colors = [
      const Color(0xFF00D9C4),
      const Color(0xFF67E8F9),
      const Color(0xFF34D399),
    ];
    
    final bubble = Bubble(
      position: Offset(
        _canvasSize!.width / 2 + (random.nextDouble() - 0.5) * 100,
        _canvasSize!.height + 50,
      ),
      radius: 20 + random.nextDouble() * 15,
      color: colors[random.nextInt(colors.length)],
    );
    
    setState(() {
      _bubbles.add(bubble);
    });
  }
  
  void _spawnObstacle() {
    if (_canvasSize == null) return;
    
    final random = math.Random();
    final types = ObstacleType.values;
    final type = types[random.nextInt(types.length)];
    
    final colors = {
      ObstacleType.kelp: const Color(0xFF064E3B),
      ObstacleType.rock: const Color(0xFF52525B),
      ObstacleType.submarine: const Color(0xFF1E3A5F),
      ObstacleType.coral: const Color(0xFFFB7185),
    };
    
    final obstacle = Obstacle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: Offset(
        50 + random.nextDouble() * (_canvasSize!.width - 100),
        _canvasSize!.height + 50, // Spawn below screen, they'll move up
      ),
      width: 40 + random.nextDouble() * 30,
      height: 60 + random.nextDouble() * 40,
      type: type,
      color: colors[type]!,
    );
    
    setState(() {
      _obstacles.add(obstacle);
    });
  }
  
  void _spawnCollectible() {
    if (_canvasSize == null) return;
    
    final random = math.Random();
    final types = CollectibleType.values;
    final type = types[random.nextInt(types.length)];
    
    final colors = {
      CollectibleType.starfish: const Color(0xFFFBBF24),
      CollectibleType.pearl: const Color(0xFFF1F5F9),
      CollectibleType.shell: const Color(0xFFFB7185),
      CollectibleType.treasure: const Color(0xFFFFD700),
    };
    
    final affirmation = AffirmationsData.affirmations[
      random.nextInt(AffirmationsData.affirmations.length)
    ].text;
    
    final collectible = Collectible(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: Offset(
        50 + random.nextDouble() * (_canvasSize!.width - 100),
        _canvasSize!.height + 50, // Spawn below screen
      ),
      type: type,
      color: colors[type]!,
      size: 15 + random.nextDouble() * 10,
      affirmation: affirmation,
    );
    
    setState(() {
      _collectibles.add(collectible);
    });
  }
  
  void _onSteerLeft() {
    setState(() {
      _bubbleSteerX = -1.0;
    });
  }
  
  void _onSteerRight() {
    setState(() {
      _bubbleSteerX = 1.0;
    });
  }
  
  void _onSteerStop() {
    setState(() {
      _bubbleSteerX = 0.0;
    });
  }
  
  void _showCollectibleAffirmation(String affirmation) {
    if (_showAffirmation) return;
    
    setState(() {
      _currentAffirmation = affirmation;
      _showAffirmation = true;
    });
    
    _affirmationTimer?.cancel();
    _affirmationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showAffirmation = false;
        });
      }
    });
  }
  
  // Track if result overlay is showing
  bool _showResultOverlay = false;

  void _gameOver() {
    setState(() {
      _isGameOver = true;
      _showResultOverlay = true;
    });
    
    if (_score > _highScore) {
      _highScore = _score;
    }
    
    HapticFeedback.heavyImpact();
    UISoundService().playGameOver();
  }
  
  Widget _buildResultOverlay(AppColours colours) {
    final isNewRecord = _score >= _highScore && _score > 0;
    
    return Positioned(
      left: 16,
      right: 16,
      bottom: 140,
      child: AnimatedOpacity(
        opacity: _showResultOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colours.accent, width: 2),
            boxShadow: [
              BoxShadow(
                color: colours.accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNewRecord ? '🎉 New Record!' : 'Journey Complete',
                style: TextStyle(
                  color: colours.textBright,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_score',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: colours.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'points',
                    style: TextStyle(
                      color: colours.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _compactStat('Bubbles', '$_bubblesReached', colours),
                  _compactStat('Breaths', '$_breathsCounted', colours),
                  _compactStat('Best', '$_highScore', colours),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Exit', style: TextStyle(color: colours.textMuted)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showResultOverlay = false;
                        });
                        _startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colours.accent,
                        foregroundColor: colours.background,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Play Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactStat(String label, String value, AppColours colours) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colours.textBright,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colours.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
  
  Widget _statRow(String label, String value, AppColours colours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: colours.textMuted, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: colours.textBright,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A1014), // Deep ocean color
      appBar: AppBar(
        title: const Text('Bubble Rise'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            UISoundService().playClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode selector & Score
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mode buttons
                  Row(
                    children: [
                      _buildModeButton('Zen', GameMode.zen, colours),
                      const SizedBox(width: 8),
                      _buildModeButton('Challenge', GameMode.challenge, colours),
                    ],
                  ),
                  // Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score',
                        style: TextStyle(
                          color: colours.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$_score',
                        style: TextStyle(
                          color: colours.accent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Breathing Instructions & Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    _isBreathingIn 
                        ? '🫧 Breathe IN - Bubble Rises Fast!' 
                        : '💨 Breathe OUT - Bubble Slows Down',
                    style: TextStyle(
                      color: colours.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_breathPhaseTimeRemaining}s remaining',
                    style: TextStyle(
                      color: colours.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap left/right to steer',
                    style: TextStyle(
                      color: colours.textMuted.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Game Canvas with Steering
            Expanded(
              child: Stack(
                children: [
                  // Left tap area for steering
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 100,
                    child: GestureDetector(
                      onTapDown: (_) => _onSteerLeft(),
                      onTapUp: (_) => _onSteerStop(),
                      onTapCancel: () => _onSteerStop(),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Right tap area for steering
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 100,
                    child: GestureDetector(
                      onTapDown: (_) => _onSteerRight(),
                      onTapUp: (_) => _onSteerStop(),
                      onTapCancel: () => _onSteerStop(),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0EA5E9), // Light blue at surface
                          Color(0xFF0369A1), // Medium blue
                          Color(0xFF0C4A6E), // Deep blue
                          Color(0xFF0A1014), // Very deep
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (_canvasSize == null ||
                              _canvasSize!.width != constraints.maxWidth ||
                              _canvasSize!.height != constraints.maxHeight) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                                if (_bubbles.isEmpty && !_isGameOver) {
                                  _startGame();
                                }
                              });
                            });
                          }
                          
                          return CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: BubblePainter(
                              bubbles: _bubbles,
                              obstacles: _obstacles,
                              collectibles: _collectibles,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Affirmation overlay
                  if (_showAffirmation && _currentAffirmation != null)
                    Positioned(
                      top: 40,
                      left: 32,
                      right: 32,
                      child: AnimatedOpacity(
                        opacity: _showAffirmation ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colours.accent.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            _currentAffirmation!,
                            style: TextStyle(
                              color: colours.background,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  // Game Over result overlay - shows without covering the gameplay
                  if (_isGameOver && _showResultOverlay)
                    _buildResultOverlay(colours),
                ],
              ),
            ),
            
            // Breathing Circle Guide (automatic animation)
            Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _breathCircleController,
                builder: (context, child) {
                  // Scale based on breathing phase
                  final phaseValue = _isBreathingIn ? _breathProgress : (1.0 - _breathProgress);
                  final scale = 0.7 + (phaseValue * 0.5); // 0.7 to 1.2
                  
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isBreathingIn
                            ? colours.accent.withOpacity(0.3 + _breathProgress * 0.4)
                            : colours.accent.withOpacity(0.7 - _breathProgress * 0.4),
                        border: Border.all(
                          color: colours.accent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colours.accent.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isBreathingIn
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: colours.accent,
                              size: 30,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isBreathingIn ? 'IN' : 'OUT',
                              style: TextStyle(
                                color: colours.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_breathPhaseTimeRemaining}s',
                              style: TextStyle(
                                color: colours.accent,
                                fontSize: 12,
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
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeButton(String label, GameMode mode, AppColours colours) {
    final isSelected = _gameMode == mode;
    return GestureDetector(
      onTap: () {
        if (_gameMode != mode) {
          HapticFeedback.lightImpact();
          UISoundService().playClick();
          setState(() {
            _gameMode = mode;
          });
          if (_canvasSize != null) {
            _startGame();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? colours.accent.withOpacity(0.2) : colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colours.accent : colours.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

