import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_options.dart';
import '../../../../core/services/ui_sound_service.dart';
import '../models/game_state.dart';
import '../widgets/game_grid_painter.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with TickerProviderStateMixin {
  late List<CellState> _board;
  CellState _currentPlayer = CellState.x;
  WinResult? _winResult;
  bool _isGameOver = false;
  bool _isDraw = false;

  TicTacToeGameMode _gameMode = TicTacToeGameMode.vsPlayer;
  TicTacToeAppDifficulty _appDifficulty = TicTacToeAppDifficulty.medium;

  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  int? _lastPlayedIndex;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _board = List.filled(9, CellState.empty);
    _currentPlayer = CellState.x;
    _winResult = null;
    _isGameOver = false;
    _isDraw = false;
    _lastPlayedIndex = null;
  }

  void _playMove(int index) {
    if (_board[index] != CellState.empty || _isGameOver) return;
    if (_gameMode == TicTacToeGameMode.vsApp && _currentPlayer == CellState.o) return;

    setState(() {
      _board[index] = _currentPlayer;
      _lastPlayedIndex = index;
    });

    _scaleController.reset();
    _scaleController.forward();

    UISoundService().playClick();
    HapticFeedback.lightImpact();

    // Check for win
    final result = _checkWin();
    if (result != null) {
      _handleWin(result);
      return;
    }

    // Check for draw
    if (_checkDraw()) {
      _handleDraw();
      return;
    }

    // Switch player
    setState(() {
      _currentPlayer = _currentPlayer == CellState.x ? CellState.o : CellState.x;
    });

    // App move if applicable
    if (_gameMode == TicTacToeGameMode.vsApp && _currentPlayer == CellState.o) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && !_isGameOver) {
          _makeAppMove();
        }
      });
    }
  }

  void _makeAppMove() {
    final random = math.Random();
    int move;

    switch (_appDifficulty) {
      case TicTacToeAppDifficulty.easy:
        move = _getRandomMove(random);
        break;

      case TicTacToeAppDifficulty.medium:
        // 50% chance of making optimal move
        if (random.nextBool()) {
          move = _getBestMove() ?? _getRandomMove(random);
        } else {
          move = _getRandomMove(random);
        }
        break;

      case TicTacToeAppDifficulty.hard:
        // Use smart strategy for challenging play
        move = _getBestMove() ?? _getRandomMove(random);
        break;
    }

    _playMoveForAI(move);
  }

  void _playMoveForAI(int index) {
    setState(() {
      _board[index] = _currentPlayer;
      _lastPlayedIndex = index;
    });

    _scaleController.reset();
    _scaleController.forward();

    UISoundService().playClick();
    HapticFeedback.lightImpact();

    // Check for win
    final result = _checkWin();
    if (result != null) {
      _handleWin(result);
      return;
    }

    // Check for draw
    if (_checkDraw()) {
      _handleDraw();
      return;
    }

    // Switch player
    setState(() {
      _currentPlayer = CellState.x;
    });
  }

  int _getRandomMove(math.Random random) {
    final emptyCells = <int>[];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == CellState.empty) {
        emptyCells.add(i);
      }
    }
    return emptyCells[random.nextInt(emptyCells.length)];
  }

  int? _getBestMove() {
    // Check for winning move
    for (int i = 0; i < 9; i++) {
      if (_board[i] == CellState.empty) {
        _board[i] = CellState.o;
        if (_checkWin() != null) {
          _board[i] = CellState.empty;
          return i;
        }
        _board[i] = CellState.empty;
      }
    }

    // Check for blocking move
    for (int i = 0; i < 9; i++) {
      if (_board[i] == CellState.empty) {
        _board[i] = CellState.x;
        if (_checkWin() != null) {
          _board[i] = CellState.empty;
          return i;
        }
        _board[i] = CellState.empty;
      }
    }

    // Take center if available
    if (_board[4] == CellState.empty) {
      return 4;
    }

    // Take corners
    final corners = [0, 2, 6, 8];
    final random = math.Random();
    corners.shuffle(random);
    for (final corner in corners) {
      if (_board[corner] == CellState.empty) {
        return corner;
      }
    }

    return null;
  }

  WinResult? _checkWin() {
    const winPatterns = [
      [0, 1, 2], // Top row
      [3, 4, 5], // Middle row
      [6, 7, 8], // Bottom row
      [0, 3, 6], // Left column
      [1, 4, 7], // Middle column
      [2, 5, 8], // Right column
      [0, 4, 8], // Diagonal
      [2, 4, 6], // Anti-diagonal
    ];

    for (final pattern in winPatterns) {
      final a = _board[pattern[0]];
      final b = _board[pattern[1]];
      final c = _board[pattern[2]];

      if (a != CellState.empty && a == b && b == c) {
        return WinResult(winner: a, winningCells: pattern);
      }
    }

    return null;
  }

  bool _checkDraw() {
    return !_board.contains(CellState.empty);
  }

  // Track if result overlay is showing
  bool _showResultOverlay = false;

  void _handleWin(WinResult result) {
    setState(() {
      _winResult = result;
      _isGameOver = true;
      _showResultOverlay = true;
      if (result.winner == CellState.x) {
        _xWins++;
      } else {
        _oWins++;
      }
    });

    HapticFeedback.heavyImpact();
    UISoundService().playPerfect();
  }

  void _handleDraw() {
    setState(() {
      _isDraw = true;
      _isGameOver = true;
      _showResultOverlay = true;
      _draws++;
    });

    HapticFeedback.mediumImpact();
  }

  Widget _buildResultOverlay(AppColours colours) {
    String title;
    String subtitle;

    if (_isDraw) {
      title = "It's a Draw!";
      subtitle = 'Neither player got three in a row';
    } else {
      final winner = _winResult!.winner;
      if (_gameMode == TicTacToeGameMode.vsApp) {
        if (winner == CellState.x) {
          title = '🎉 You Win!';
          subtitle = 'You got three in a row!';
        } else {
          title = '📱 App Wins';
          subtitle = 'The app got three in a row';
        }
      } else {
        title = '${winner.symbol} Wins!';
        subtitle = 'Three in a row!';
      }
    }

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
                title,
                style: TextStyle(
                  color: colours.textBright,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _scoreCard('X', _xWins, Colors.cyan, colours),
                  _scoreCard('Draws', _draws, colours.textMuted, colours),
                  _scoreCard('O', _oWins, Colors.pink, colours),
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

  Widget _scoreCard(String label, int score, Color color, AppColours colours) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            color: colours.textBright,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
                      'Tic Tac Toe',
                      style: TextStyle(
                        color: colours.textBright,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Mode selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: TicTacToeGameMode.values.map((mode) {
                  final isSelected = mode == _gameMode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          UISoundService().playClick();
                          setState(() {
                            _gameMode = mode;
                            _xWins = 0;
                            _oWins = 0;
                            _draws = 0;
                            _initializeGame();
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? colours.accent : colours.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? colours.accent : colours.border,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mode.icon,
                              size: 16,
                              color: isSelected
                                  ? colours.background
                                  : colours.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mode.label,
                              style: TextStyle(
                                color: isSelected
                                    ? colours.background
                                    : colours.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // App Difficulty
            if (_gameMode == TicTacToeGameMode.vsApp) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: TicTacToeAppDifficulty.values.map((diff) {
                    final isSelected = diff == _appDifficulty;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            UISoundService().playClick();
                            setState(() {
                              _appDifficulty = diff;
                              _xWins = 0;
                              _oWins = 0;
                              _draws = 0;
                              _initializeGame();
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colours.accent.withOpacity(0.3)
                                : colours.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected ? colours.accent : colours.border,
                            ),
                          ),
                          child: Text(
                            diff.label,
                            style: TextStyle(
                              color: isSelected
                                  ? colours.accent
                                  : colours.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Current player indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: colours.cardLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPlayer.symbol,
                    style: TextStyle(
                      color: _currentPlayer == CellState.x
                          ? Colors.cyan
                          : Colors.pink,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isGameOver
                        ? 'Game Over'
                        : (_gameMode == TicTacToeGameMode.vsApp &&
                                _currentPlayer == CellState.o)
                            ? "App's Turn..."
                            : "${_currentPlayer.symbol}'s Turn",
                    style: TextStyle(
                      color: colours.textBright,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Score display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreChip('X', _xWins, Colors.cyan, colours),
                  _buildScoreChip('Draws', _draws, colours.textMuted, colours),
                  _buildScoreChip(
                    _gameMode == TicTacToeGameMode.vsApp ? 'App' : 'O',
                    _oWins,
                    Colors.pink,
                    colours,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Game grid
            Padding(
              padding: const EdgeInsets.all(32),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth;
                    final cellSize = size / 3;

                    return Stack(
                      children: [
                        // Grid lines
                        CustomPaint(
                          size: Size(size, size),
                          painter: GameGridPainter(
                            lineColor: colours.border,
                            winningCells: _winResult?.winningCells,
                            winColor: colours.accent,
                          ),
                        ),
                        // Cells
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _playMove(index),
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) {
                                      final scale = _lastPlayedIndex == index
                                          ? _scaleAnimation.value
                                          : 1.0;
                                      return Transform.scale(
                                        scale: _board[index] == CellState.empty
                                            ? 1.0
                                            : scale.clamp(0.0, 1.0),
                                        child: child,
                                      );
                                    },
                                    child: _buildCell(index, cellSize, colours),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const Spacer(),

            // New Game button
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
        if (_isGameOver && _showResultOverlay)
          _buildResultOverlay(colours),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int index, double cellSize, AppColours colours) {
    final cell = _board[index];
    if (cell == CellState.empty) {
      return const SizedBox();
    }

    final isWinningCell = _winResult?.winningCells.contains(index) ?? false;
    final color = cell == CellState.x ? Colors.cyan : Colors.pink;

    return Text(
      cell.symbol,
      style: TextStyle(
        color: isWinningCell ? colours.accent : color,
        fontSize: cellSize * 0.5,
        fontWeight: FontWeight.bold,
        shadows: isWinningCell
            ? [
                Shadow(
                  color: colours.accent.withOpacity(0.5),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildScoreChip(
      String label, int score, Color color, AppColours colours) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score',
            style: TextStyle(
              color: colours.textBright,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
