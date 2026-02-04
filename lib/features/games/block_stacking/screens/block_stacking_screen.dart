import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme_options.dart';
import '../../../../core/services/ui_sound_service.dart';
import '../../../affirmations/data/affirmations_data.dart';
import '../models/game_block.dart';
import '../models/game_particle.dart';
import '../widgets/block_painter.dart';
import '../widgets/particle_painter.dart';

class BlockStackingScreen extends StatefulWidget {
  const BlockStackingScreen({super.key});

  @override
  State<BlockStackingScreen> createState() => _BlockStackingScreenState();
}

enum GameMode { normal, zen }

class _BlockStackingScreenState extends State<BlockStackingScreen>
    with TickerProviderStateMixin {
  final List<GameBlock> _stackedBlocks = [];
  final List<GameParticle> _particles = [];
  GameBlock? _movingBlock;
  Timer? _gameTimer;
  int _score = 0;
  int _highScore = 0;
  bool _gameOver = false;
  double _cameraOffset = 0.0; // Y offset to follow the stack
  Size? _canvasSize;
  
  // Game mode
  GameMode _gameMode = GameMode.normal;
  
  // Affirmation display
  String? _currentAffirmation;
  bool _showAffirmation = false;
  Timer? _affirmationTimer;
  
  // Perfect placement & combo tracking
  int _perfectCount = 0;
  int _comboCount = 0;
  int _maxCombo = 0;
  static const double _perfectThreshold = 5.0; // pixels
  
  // Game constants
  static const double _blockHeight = 40.0;
  static const double _initialBlockWidth = 100.0;
  static const double _baseSpeed = 120.0; // Base pixels per second
  static const double _zenSpeed = 80.0; // Slower for zen mode
  
  double _blockDirection = 1.0; // 1 = right, -1 = left
  
  double get _groundY => (_canvasSize?.height ?? 600) - 50;
  
  // Current speed increases slowly with score (not in zen mode)
  double get _currentSpeed {
    if (_gameMode == GameMode.zen) return _zenSpeed;
    return _baseSpeed + (_score * 5.0).clamp(0, 100);
  }
  
  @override
  void initState() {
    super.initState();
    // Game will start once canvas size is known (see LayoutBuilder)
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _affirmationTimer?.cancel();
    super.dispose();
  }
  
  void _startGame() {
    if (_canvasSize == null) return;
    
    // Start with a base block at the bottom center
    _stackedBlocks.clear();
    _stackedBlocks.add(GameBlock(
      id: 'base',
      position: Offset(_canvasSize!.width / 2, _groundY - _blockHeight / 2),
      size: Size(_initialBlockWidth, _blockHeight),
      color: const Color(0xFF1A2634),
      isStatic: true,
    ));
    
    _spawnMovingBlock();
    _startGameLoop();
  }
  
  void _startGameLoop() {
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 FPS
      (_) => _updateGame(),
    );
  }
  
  void _updateGame() {
    if (_gameOver || _movingBlock == null || _canvasSize == null) return;
    
    setState(() {
      // Move the current block left/right with current speed
      final movement = _currentSpeed * 0.016 * _blockDirection;
      _movingBlock!.position = Offset(
        _movingBlock!.position.dx + movement,
        _movingBlock!.position.dy,
      );
      
      // Reverse direction at screen edges
      final leftEdge = _movingBlock!.size.width / 2;
      final rightEdge = _canvasSize!.width - _movingBlock!.size.width / 2;
      
      if (_movingBlock!.position.dx <= leftEdge) {
        _movingBlock!.position = Offset(leftEdge, _movingBlock!.position.dy);
        _blockDirection = 1.0;
      } else if (_movingBlock!.position.dx >= rightEdge) {
        _movingBlock!.position = Offset(rightEdge, _movingBlock!.position.dy);
        _blockDirection = -1.0;
      }
      
      // Update particles
      _particles.removeWhere((p) => p.isDead);
      for (final particle in _particles) {
        particle.update();
      }
    });
  }
  
  void _spawnMovingBlock() {
    if (_gameOver || _canvasSize == null) return;
    
    final random = math.Random();
    final colors = [
      const Color(0xFF00D9C4),
      const Color(0xFF34D399),
      const Color(0xFFFBBF24),
      const Color(0xFFFB7185),
      const Color(0xFF67E8F9),
    ];
    
    // Get the last placed block's width
    final lastBlock = _stackedBlocks.last;
    final newWidth = lastBlock.size.width;
    
    // Spawn block above the last block at a consistent visible height
    final newY = lastBlock.position.dy - _blockHeight - 120;
    
    setState(() {
      _movingBlock = GameBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        position: Offset(_canvasSize!.width / 2, newY),
        size: Size(newWidth, _blockHeight),
        color: colors[random.nextInt(colors.length)],
      );
      _blockDirection = 1.0;
    });
  }
  
  void _dropBlock() {
    if (_movingBlock == null || _gameOver) return;
    
    final lastBlock = _stackedBlocks.last;
    final movingBlockLeft = _movingBlock!.position.dx - _movingBlock!.size.width / 2;
    final movingBlockRight = _movingBlock!.position.dx + _movingBlock!.size.width / 2;
    final lastBlockLeft = lastBlock.position.dx - lastBlock.size.width / 2;
    final lastBlockRight = lastBlock.position.dx + lastBlock.size.width / 2;
    
    // Calculate overlap
    final overlapLeft = math.max(movingBlockLeft, lastBlockLeft);
    final overlapRight = math.min(movingBlockRight, lastBlockRight);
    final overlap = overlapRight - overlapLeft;
    
    if (overlap <= 0) {
      // Complete miss
      _comboCount = 0;
      
      if (_gameMode == GameMode.zen) {
        // In zen mode, complete miss = block falls off but game continues
        // Give a "free retry" - just spawn a new block at same width
        HapticFeedback.heavyImpact();
        UISoundService().playGameOver(); // Feedback for miss
        
        // Spawn falling dust effect to show the miss
        _spawnDust(_movingBlock!.position, 3);
        
        setState(() {
          _movingBlock = null;
          // Don't increment score - this was a miss
          _spawnMovingBlock();
        });
        return;
      } else {
        // Normal mode - game over!
        setState(() {
          _gameOver = true;
        });
        HapticFeedback.heavyImpact();
        UISoundService().playGameOver();
        _showGameOverDialog();
        return;
      }
    }
    
    // Calculate the new block position and width based on overlap
    // In zen mode, blocks still trim but with more forgiveness
    final newWidth = overlap;
    final newCenterX = (overlapLeft + overlapRight) / 2;
    
    // Zen mode forgiveness: if block would get too small, give partial recovery
    final double finalWidth;
    if (_gameMode == GameMode.zen && newWidth < 50) {
      // Zen mode: recover some width (but not all) when getting too thin
      finalWidth = math.min(newWidth + 20, _movingBlock!.size.width * 0.7);
    } else {
      finalWidth = newWidth;
    }
    
    // Position directly on top of the last block
    final newY = lastBlock.position.dy - _blockHeight;
    
    // Check if it's a perfect placement (use original overlap for accuracy check)
    final centerDiff = (newCenterX - lastBlock.position.dx).abs();
    final isPerfect = centerDiff < _perfectThreshold;
    
    setState(() {
      // Create the trimmed block
      final placedBlock = GameBlock(
        id: _movingBlock!.id,
        position: Offset(newCenterX, newY),
        size: Size(finalWidth, _blockHeight),
        color: _movingBlock!.color,
        isStatic: true,
      );
      
      _stackedBlocks.add(placedBlock);
      _score++;
      
      if (_score > _highScore) {
        _highScore = _score;
      }
      
      // Handle perfect placement
      if (isPerfect) {
        _perfectCount++;
        _comboCount++;
        if (_comboCount > _maxCombo) {
          _maxCombo = _comboCount;
        }
        
        // Spawn confetti particles
        _spawnConfetti(placedBlock.position, placedBlock.color);
        HapticFeedback.mediumImpact();
        
        // Play appropriate sound
        if (_comboCount >= 3) {
          UISoundService().playCombo(_comboCount);
        } else {
          UISoundService().playPerfect();
        }
      } else {
        // Spawn dust particles for trim
        _spawnDust(placedBlock.position, _comboCount);
        _comboCount = 0;
        HapticFeedback.lightImpact();
        UISoundService().playClick();
      }
      
      // Show affirmation every 3 blocks or on perfect placement
      if (_score % 3 == 0 || isPerfect) {
        _showRandomAffirmation();
      }
      
      // Update camera / dissolve bottom blocks
      _updateCamera(placedBlock);
      
      // Check if block is too small to continue (not in zen mode)
      if (_gameMode == GameMode.normal && finalWidth < 30) {
        _gameOver = true;
        _comboCount = 0;
        UISoundService().playGameOver();
        _showGameOverDialog();
      } else {
        _movingBlock = null;
        _spawnMovingBlock();
      }
    });
  }
  
  void _resetGame() {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    
    // Cancel any existing timer
    _gameTimer?.cancel();
    
    setState(() {
      _score = 0;
      _gameOver = false;
      _cameraOffset = 0.0;
      _movingBlock = null;
      _blockDirection = 1.0; // Reset direction
      _stackedBlocks.clear();
      _particles.clear();
      _currentAffirmation = null;
      _showAffirmation = false;
      _affirmationTimer?.cancel();
      _perfectCount = 0;
      _comboCount = 0;
      _maxCombo = 0;
      _startGame();
    });
  }
  
  void _updateCamera(GameBlock placedBlock) {
    if (_canvasSize == null) return;
    
    final topBlockY = placedBlock.position.dy;
    final screenHeight = _canvasSize!.height;
    
    // Start dissolving earlier and more aggressively
    // Goal: Keep the action in the middle/lower portion of the screen
    
    if (_stackedBlocks.length > 6) {
      // If top block is in the top 40% of screen, start dissolving
      if (topBlockY < screenHeight * 0.4) {
        // Calculate how many blocks to remove based on how high we are
        int blocksToRemove = 1;
        
        if (topBlockY < screenHeight * 0.25) {
          blocksToRemove = 3; // Very high - remove more
        } else if (topBlockY < screenHeight * 0.35) {
          blocksToRemove = 2; // Getting high
        }
        
        _removeBottomBlocks(blocksToRemove);
      }
    }
  }
  
  void _removeBottomBlocks(int count) {
    if (_stackedBlocks.length <= 2) return; // Always keep base block
    
    final blocksToRemove = math.min(count, _stackedBlocks.length - 2);
    
    // Spawn particles for removed blocks
    for (int i = 1; i <= blocksToRemove; i++) {
      if (i < _stackedBlocks.length) {
        final block = _stackedBlocks[i];
        _spawnDust(block.position, 0); // Dust effect
      }
    }
    
    // Remove blocks from bottom (but keep the base block at index 0)
    _stackedBlocks.removeRange(1, 1 + blocksToRemove);
    
    // Shift all remaining blocks down
    final dropDistance = _blockHeight * blocksToRemove;
    for (int i = 1; i < _stackedBlocks.length; i++) {
      _stackedBlocks[i].position = Offset(
        _stackedBlocks[i].position.dx,
        _stackedBlocks[i].position.dy + dropDistance,
      );
    }
    
    // No camera offset needed anymore
    _cameraOffset = 0;
  }
  
  void _showRandomAffirmation() {
    // Don't show new affirmation if one is already visible
    if (_showAffirmation) return;
    
    final random = math.Random();
    final affirmation = AffirmationsData.affirmations[
      random.nextInt(AffirmationsData.affirmations.length)
    ];
    
    setState(() {
      _currentAffirmation = affirmation.text;
      _showAffirmation = true;
    });
    
    // Cancel existing timer
    _affirmationTimer?.cancel();
    
    // Hide after 4 seconds (longer to read)
    _affirmationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showAffirmation = false;
        });
      }
    });
  }
  
  void _spawnConfetti(Offset position, Color blockColor) {
    final random = math.Random();
    final colors = [
      const Color(0xFFFBBF24),
      const Color(0xFFFB7185),
      const Color(0xFF67E8F9),
      const Color(0xFF34D399),
      blockColor,
    ];
    
    // More particles for higher combos
    final particleCount = 10 + (_comboCount * 3).clamp(0, 20);
    
    for (int i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 2.0 + random.nextDouble() * 4.0;
      
      _particles.add(GameParticle(
        position: position,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed - 3, // Upward burst
        ),
        size: 4 + random.nextDouble() * 4,
        color: colors[random.nextInt(colors.length)],
        fadeRate: 0.015,
        type: ParticleType.confetti,
      ));
    }
  }
  
  void _spawnDust(Offset position, int lostCombo) {
    final random = math.Random();
    
    // More dust if combo was broken
    final particleCount = 5 + (lostCombo * 2);
    
    for (int i = 0; i < particleCount; i++) {
      _particles.add(GameParticle(
        position: position + Offset(
          random.nextDouble() * 20 - 10,
          random.nextDouble() * 10 - 5,
        ),
        velocity: Offset(
          random.nextDouble() * 2 - 1,
          -random.nextDouble() * 2,
        ),
        size: 3 + random.nextDouble() * 3,
        color: Colors.grey.withOpacity(0.6),
        fadeRate: 0.02,
        type: ParticleType.dust,
      ));
    }
  }
  
  // Track if result overlay is showing
  bool _showResultOverlay = false;

  void _showGameOverDialog() {
    setState(() {
      _showResultOverlay = true;
    });
  }

  Widget _buildResultOverlay(AppColours colours) {
    final accuracy = _score > 0 ? (_perfectCount / _score * 100).toStringAsFixed(1) : '0.0';
    final isNewRecord = _score >= _highScore && _score > 0;
    
    return Positioned(
      left: 16,
      right: 16,
      bottom: 100,
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
                isNewRecord ? '🎉 New Record!' : 'Game Over',
                style: TextStyle(
                  color: colours.textBright,
                  fontSize: 24,
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
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: colours.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'blocks',
                    style: TextStyle(
                      color: colours.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _compactStat('Perfect', '$_perfectCount', colours),
                  _compactStat('Combo', '${_maxCombo}x', colours),
                  _compactStat('Accuracy', '$accuracy%', colours),
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
                        _resetGame();
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
  
  Widget _buildModeButton(String label, GameMode mode, AppColours colours) {
    final isSelected = _gameMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_gameMode != mode) {
            HapticFeedback.lightImpact();
            UISoundService().playClick();
            setState(() {
              _gameMode = mode;
            });
            _resetGame();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? colours.accent.withOpacity(0.2) : colours.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colours.accent : colours.border.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mode == GameMode.zen ? Icons.spa_rounded : Icons.sports_esports_rounded,
                size: 16,
                color: isSelected ? colours.accent : colours.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? colours.accent : colours.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        title: const Text('Block Stacking'),
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
            // Mode Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton('Normal', GameMode.normal, colours),
                  const SizedBox(width: 8),
                  _buildModeButton('Zen', GameMode.zen, colours),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Score Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colours.textMuted,
                            ),
                      ),
                      Text(
                        '$_score',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: colours.accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Best',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colours.textMuted,
                            ),
                      ),
                      Text(
                        '$_highScore',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: colours.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Instruction & Combo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Tap to drop! Align perfectly to keep blocks wide',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colours.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (_score > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Speed: ${(_currentSpeed / _baseSpeed * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colours.accent.withOpacity(0.7),
                                ),
                          ),
                          if (_comboCount >= 2) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colours.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colours.accent.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.whatshot_rounded,
                                    size: 14,
                                    color: colours.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_comboCount}x COMBO',
                                    style: TextStyle(
                                      color: colours.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Game Canvas
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colours.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colours.border.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Update canvas size when layout is ready
                      if (_canvasSize == null || 
                          _canvasSize!.width != constraints.maxWidth ||
                          _canvasSize!.height != constraints.maxHeight) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                            if (_stackedBlocks.isEmpty) {
                              _startGame();
                            }
                          });
                        });
                      }
                      
                      return GestureDetector(
                        onTap: _dropBlock,
                        child: ClipRect(
                          child: Transform.translate(
                            offset: Offset(0, _cameraOffset),
                            child: Stack(
                              children: [
                                // Blocks layer
                                CustomPaint(
                                  size: Size(constraints.maxWidth, constraints.maxHeight + _cameraOffset),
                                  painter: BlockPainter(
                                    blocks: _stackedBlocks,
                                    currentBlock: _movingBlock,
                                    borderColor: colours.border,
                                  ),
                                ),
                                // Particles layer
                                CustomPaint(
                                  size: Size(constraints.maxWidth, constraints.maxHeight + _cameraOffset),
                                  painter: ParticlePainter(particles: _particles),
                                ),
                              ],
                            ),
                          ),
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
                  // Game Over result overlay - shows at bottom without covering the tower
                  if (_gameOver && _showResultOverlay)
                    _buildResultOverlay(colours),
                ],
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colours.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Clear & Restart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colours.background,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

