import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_options.dart';
import '../../../../core/services/ui_sound_service.dart';
import '../../../subscription/mixins/tease_mixin.dart';
import '../../../subscription/widgets/premium_gate.dart';
import '../models/memory_card.dart';
import '../widgets/memory_card_widget.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> with TeaseMixin {
  
  // Tease config: Allow 3 card flips (1.5 turns) before showing paywall
  @override
  TeaseConfig get teaseConfig => TeaseConfig(
    featureName: 'Memory Match',
    maxActions: 3,
    message: 'Enjoying Memory Match? Subscribe to keep playing!',
  );
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  List<MemoryCard> _cards = [];
  List<MemoryCard> _flippedCards = [];
  
  int _moves = 0;
  int _matches = 0;
  int _seconds = 0;
  Timer? _gameTimer;
  bool _isGameStarted = false;
  bool _isGameComplete = false;
  bool _isProcessing = false;

  // Best scores
  Map<DifficultyLevel, int> _bestMoves = {};
  Map<DifficultyLevel, int> _bestTimes = {};

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Reset tease tracker for new game
    resetTeaseTracker();
    
    setState(() {
      _cards = _generateCards();
      _flippedCards.clear();
      _moves = 0;
      _matches = 0;
      _seconds = 0;
      _isGameStarted = false;
      _isGameComplete = false;
      _isProcessing = false;
    });
    _gameTimer?.cancel();
  }

  List<MemoryCard> _generateCards() {
    final random = math.Random();
    final totalPairs = _difficulty.totalPairs;
    final List<MemoryCard> cards = [];

    // Get random icons from theme
    final availableIcons = List.from(MemoryCardTheme.oceanTheme)..shuffle(random);
    final selectedIcons = availableIcons.take(totalPairs).toList();

    // Create pairs
    for (int i = 0; i < totalPairs; i++) {
      final iconData = selectedIcons[i];
      cards.add(MemoryCard(
        id: '${i}_a',
        icon: iconData['icon'],
        color: iconData['color'],
      ));
      cards.add(MemoryCard(
        id: '${i}_b',
        icon: iconData['icon'],
        color: iconData['color'],
      ));
    }

    // Shuffle cards
    cards.shuffle(random);
    return cards;
  }

  void _startTimer() {
    if (_isGameStarted) return;
    
    _isGameStarted = true;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGameComplete) {
        setState(() {
          _seconds++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].isFlipped || _cards[index].isMatched) {
      return;
    }

    if (!_isGameStarted) {
      _startTimer();
    }

    setState(() {
      _cards[index] = _cards[index].copyWith(isFlipped: true);
      _flippedCards.add(_cards[index]);
    });

    UISoundService().playClick();
    
    // Track tease action for each card flip
    recordTeaseAction();
    
    // Check if tease limit reached
    if (hasReachedTeaseLimit) {
      _gameTimer?.cancel();
      showTeasePaywall(onDismiss: () {
        setState(() => _isGameComplete = true);
      });
      return;
    }

    if (_flippedCards.length == 2) {
      _isProcessing = true;
      _moves++;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    final card1 = _flippedCards[0];
    final card2 = _flippedCards[1];

    if (card1.icon == card2.icon && card1.id != card2.id) {
      // Match found!
      HapticFeedback.mediumImpact();
      UISoundService().playPerfect();
      
      setState(() {
        for (int i = 0; i < _cards.length; i++) {
          if (_cards[i].id == card1.id || _cards[i].id == card2.id) {
            _cards[i] = _cards[i].copyWith(isMatched: true);
          }
        }
        _matches++;
        _flippedCards.clear();
        _isProcessing = false;
      });

      _checkGameComplete();
    } else {
      // No match - flip back after delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            for (int i = 0; i < _cards.length; i++) {
              if (_cards[i].id == card1.id || _cards[i].id == card2.id) {
                _cards[i] = _cards[i].copyWith(isFlipped: false);
              }
            }
            _flippedCards.clear();
            _isProcessing = false;
          });
        }
      });
    }
  }

  // Track if result overlay is showing
  bool _showResultOverlay = false;

  void _checkGameComplete() {
    if (_matches == _difficulty.totalPairs) {
      _isGameComplete = true;
      _showResultOverlay = true;
      _gameTimer?.cancel();
      
      // Update best scores
      final currentBestMoves = _bestMoves[_difficulty];
      final currentBestTime = _bestTimes[_difficulty];
      
      if (currentBestMoves == null || _moves < currentBestMoves) {
        _bestMoves[_difficulty] = _moves;
      }
      
      if (currentBestTime == null || _seconds < currentBestTime) {
        _bestTimes[_difficulty] = _seconds;
      }

      HapticFeedback.heavyImpact();
      UISoundService().playPerfect();
    }
  }

  Widget _buildResultOverlay(AppColours colours) {
    final isNewBest = _bestMoves[_difficulty] == _moves || _bestTimes[_difficulty] == _seconds;
    
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
                isNewBest ? '🎉 New Best!' : '🎉 Well Done!',
                style: TextStyle(
                  color: colours.textBright,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You completed the ${_difficulty.name} level',
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _scoreCard('Moves', '$_moves', colours),
                  _scoreCard('Time', _formatTime(_seconds), colours),
                ],
              ),
              if (_bestMoves[_difficulty] != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Best: ${_bestMoves[_difficulty]} moves • ${_formatTime(_bestTimes[_difficulty]!)}',
                  style: TextStyle(
                    color: colours.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                          _initializeGame();
                        });
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

  Widget _scoreCard(String label, String value, AppColours colours) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colours.textBright,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: colours.textMuted,
            fontSize: 12,
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
          style: TextStyle(
            color: colours.textMuted,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colours.textBright,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      backgroundColor: colours.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colours.textBright),
                    onPressed: () {
                      UISoundService().playClick();
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Memory Match',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            // Stats bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Moves', '$_moves', Icons.touch_app, colours),
                  _buildStat('Time', _formatTime(_seconds), Icons.timer, colours),
                  _buildStat('Matches', '$_matches/${_difficulty.totalPairs}', Icons.check_circle, colours),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Difficulty selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: DifficultyLevel.values.map((level) {
                  final isSelected = level == _difficulty;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isSelected && !_isGameStarted) {
                          UISoundService().playClick();
                          setState(() {
                            _difficulty = level;
                            _initializeGame();
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? colours.accent : colours.cardLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? colours.accent : colours.border,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          level.name,
                          style: TextStyle(
                            color: isSelected ? colours.background : colours.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Game grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _difficulty.columns,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return MemoryCardWidget(
                      card: _cards[index],
                      onTap: () => _onCardTap(index),
                      backColor: colours.card,
                    );
                  },
                ),
              ),
            ),
            
            // Reset button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    UISoundService().playClick();
                    setState(() {
                      _showResultOverlay = false;
                      _initializeGame();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colours.accent,
                    foregroundColor: colours.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Result overlay - shows at bottom without covering the board
        if (_isGameComplete && _showResultOverlay)
          _buildResultOverlay(colours),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, AppColours colours) {
    return Column(
      children: [
        Icon(icon, color: colours.accent, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colours.textBright,
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
}

