import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_options.dart';
import '../../../../core/services/ui_sound_service.dart';
import '../../../subscription/mixins/tease_mixin.dart';
import '../../../subscription/widgets/premium_gate.dart';
import '../models/game_cell.dart';
import '../widgets/game_board_painter.dart';

class ConnectFourScreen extends StatefulWidget {
  const ConnectFourScreen({super.key});

  @override
  State<ConnectFourScreen> createState() => _ConnectFourScreenState();
}

class _ConnectFourScreenState extends State<ConnectFourScreen>
    with TickerProviderStateMixin, TeaseMixin {
  
  // Tease config: Allow 2 pieces before showing paywall
  @override
  TeaseConfig get teaseConfig => TeaseConfig(
    featureName: 'Connect Four',
    maxActions: 2,
    message: 'Enjoying Connect Four? Subscribe to keep playing!',
  );
  static const int rows = 6;
  static const int columns = 7;

  late List<List<Player>> _board;
  Player _currentPlayer = Player.player1;
  WinningLine? _winningLine;
  bool _isGameOver = false;
  bool _isDraw = false;
  bool _isDropping = false;

  GameMode _gameMode = GameMode.vsPlayer;
  AppDifficulty _appDifficulty = AppDifficulty.medium;

  int _player1Wins = 0;
  int _player2Wins = 0;

  // Animation
  AnimationController? _dropController;
  int? _droppingColumn;
  int? _droppingRow;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _dropController?.dispose();
    super.dispose();
  }

  void _initializeGame() {
    // Reset tease tracker for new game
    resetTeaseTracker();
    
    _board = List.generate(
      rows,
      (row) => List.generate(columns, (col) => Player.none),
    );
    _currentPlayer = Player.player1;
    _winningLine = null;
    _isGameOver = false;
    _isDraw = false;
    _isDropping = false;
    _droppingColumn = null;
    _droppingRow = null;
    _dropController?.dispose();
    _dropController = null;
  }

  int? _getLowestEmptyRow(int column) {
    for (int row = rows - 1; row >= 0; row--) {
      if (_board[row][column] == Player.none) {
        return row;
      }
    }
    return null;
  }

  Future<void> _dropPiece(int column) async {
    if (_isDropping || _isGameOver) return;

    final targetRow = _getLowestEmptyRow(column);
    if (targetRow == null) return;

    setState(() {
      _isDropping = true;
      _droppingColumn = column;
      _droppingRow = targetRow;
    });

    UISoundService().playClick();
    HapticFeedback.lightImpact();

    // Animate the drop
    _dropController = AnimationController(
      duration: Duration(milliseconds: 150 + (targetRow * 50)),
      vsync: this,
    );

    await _dropController!.forward();

    // Place the piece
    setState(() {
      _board[targetRow][column] = _currentPlayer;
      _droppingColumn = null;
      _droppingRow = null;
      _isDropping = false;
    });

    HapticFeedback.mediumImpact();
    
    // Track tease action for player's moves only
    if (_currentPlayer == Player.player1) {
      recordTeaseAction();
      
      // Check if tease limit reached
      if (hasReachedTeaseLimit) {
        showTeasePaywall(onDismiss: () {
          setState(() => _isGameOver = true);
        });
        return;
      }
    }

    // Check for win
    final winLine = _checkWin(targetRow, column);
    if (winLine != null) {
      _handleWin(winLine);
      return;
    }

    // Check for draw
    if (_checkDraw()) {
      _handleDraw();
      return;
    }

    // Switch player
    setState(() {
      _currentPlayer =
          _currentPlayer == Player.player1 ? Player.player2 : Player.player1;
    });

    // App move if applicable
    if (_gameMode == GameMode.vsApp && _currentPlayer == Player.player2) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isGameOver) {
          _makeAppMove();
        }
      });
    }
  }

  void _makeAppMove() {
    final random = math.Random();
    int column;

    switch (_appDifficulty) {
      case AppDifficulty.easy:
        // Random valid move
        final validColumns = <int>[];
        for (int c = 0; c < columns; c++) {
          if (_getLowestEmptyRow(c) != null) {
            validColumns.add(c);
          }
        }
        column = validColumns[random.nextInt(validColumns.length)];
        break;

      case AppDifficulty.medium:
        // Check for winning move or block opponent
        column = _findBestMove() ?? _findRandomValidColumn(random);
        break;

      case AppDifficulty.hard:
        // Smarter strategy - check for winning move, block, or center preference
        column = _findBestMove() ?? _findStrategicMove(random);
        break;
    }

    _dropPiece(column);
  }

  int? _findBestMove() {
    // Check if AI can win
    for (int c = 0; c < columns; c++) {
      final row = _getLowestEmptyRow(c);
      if (row != null) {
        _board[row][c] = Player.player2;
        if (_checkWin(row, c) != null) {
          _board[row][c] = Player.none;
          return c;
        }
        _board[row][c] = Player.none;
      }
    }

    // Check if opponent can win and block
    for (int c = 0; c < columns; c++) {
      final row = _getLowestEmptyRow(c);
      if (row != null) {
        _board[row][c] = Player.player1;
        if (_checkWin(row, c) != null) {
          _board[row][c] = Player.none;
          return c;
        }
        _board[row][c] = Player.none;
      }
    }

    return null;
  }

  int _findStrategicMove(math.Random random) {
    // Prefer center column
    if (_getLowestEmptyRow(3) != null && random.nextBool()) {
      return 3;
    }

    // Then adjacent to center
    final preferredCols = [2, 4, 1, 5, 0, 6];
    for (final c in preferredCols) {
      if (_getLowestEmptyRow(c) != null) {
        return c;
      }
    }

    return _findRandomValidColumn(random);
  }

  int _findRandomValidColumn(math.Random random) {
    final validColumns = <int>[];
    for (int c = 0; c < columns; c++) {
      if (_getLowestEmptyRow(c) != null) {
        validColumns.add(c);
      }
    }
    return validColumns[random.nextInt(validColumns.length)];
  }

  WinningLine? _checkWin(int row, int col) {
    final player = _board[row][col];
    if (player == Player.none) return null;

    // Directions: horizontal, vertical, diagonal-right, diagonal-left
    final directions = [
      [(0, 1), (0, -1)], // Horizontal
      [(1, 0), (-1, 0)], // Vertical
      [(1, 1), (-1, -1)], // Diagonal \
      [(1, -1), (-1, 1)], // Diagonal /
    ];

    for (final dir in directions) {
      final cells = <(int, int)>[(row, col)];

      for (final (dr, dc) in dir) {
        int r = row + dr;
        int c = col + dc;
        while (r >= 0 && r < rows && c >= 0 && c < columns) {
          if (_board[r][c] == player) {
            cells.add((r, c));
            r += dr;
            c += dc;
          } else {
            break;
          }
        }
      }

      if (cells.length >= 4) {
        return WinningLine(cells: cells, winner: player);
      }
    }

    return null;
  }

  bool _checkDraw() {
    for (int c = 0; c < columns; c++) {
      if (_board[0][c] == Player.none) {
        return false;
      }
    }
    return true;
  }

  // Track if result overlay is showing
  bool _showResultOverlay = false;

  void _handleWin(WinningLine winLine) {
    setState(() {
      _winningLine = winLine;
      _isGameOver = true;
      _showResultOverlay = true;
      if (winLine.winner == Player.player1) {
        _player1Wins++;
      } else {
        _player2Wins++;
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
    });

    HapticFeedback.mediumImpact();
  }

  Widget _buildResultOverlay(AppColours colours) {
    String title;
    String subtitle;

    if (_isDraw) {
      title = "It's a Draw!";
      subtitle = 'Neither player connected four';
    } else {
      final winner = _winningLine!.winner;
      if (_gameMode == GameMode.vsApp) {
        if (winner == Player.player1) {
          title = '🎉 You Win!';
          subtitle = 'You connected four!';
        } else {
          title = '📱 App Wins';
          subtitle = 'The app connected four';
        }
      } else {
        title = '${winner.emoji} ${winner.label} Wins!';
        subtitle = 'Connected four in a row!';
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
                  _scoreCard('🔴 Port', _player1Wins, colours),
                  _scoreCard(
                    _gameMode == GameMode.vsApp ? '📱 App' : '🟢 Starboard',
                    _player2Wins,
                    colours,
                  ),
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

  Widget _scoreCard(String label, int score, AppColours colours) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: colours.textMuted,
            fontSize: 12,
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
                      'Connect Four',
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
                children: GameMode.values.map((mode) {
                  final isSelected = mode == _gameMode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          UISoundService().playClick();
                          setState(() {
                            _gameMode = mode;
                            _player1Wins = 0;
                            _player2Wins = 0;
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

            // App Difficulty (only show when playing vs App)
            if (_gameMode == GameMode.vsApp) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: AppDifficulty.values.map((diff) {
                    final isSelected = diff == _appDifficulty;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            UISoundService().playClick();
                            setState(() {
                              _appDifficulty = diff;
                              _player1Wins = 0;
                              _player2Wins = 0;
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

            const SizedBox(height: 16),

            // Current player indicator - Port (Red) / Starboard (Green)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: colours.cardLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _currentPlayer == Player.player1
                          ? Colors.red
                          : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isGameOver
                        ? 'Game Over'
                        : (_gameMode == GameMode.vsApp &&
                                _currentPlayer == Player.player2)
                            ? "App's Turn..."
                            : "${_currentPlayer == Player.player1 ? 'Port' : 'Starboard'}'s Turn",
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

            // Score display - Port (Red) / Starboard (Green)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreChip('🔴 Port', _player1Wins, colours),
                  _buildScoreChip(
                    _gameMode == GameMode.vsApp ? '📱 App' : '🟢 Stbd',
                    _player2Wins,
                    colours,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Game board
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: columns / rows,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cellSize = constraints.maxWidth / columns;
                        return GestureDetector(
                          onTapUp: (details) {
                            if (_isGameOver || _isDropping) return;
                            if (_gameMode == GameMode.vsApp &&
                                _currentPlayer == Player.player2) return;

                            final column =
                                (details.localPosition.dx / cellSize).floor();
                            if (column >= 0 && column < columns) {
                              _dropPiece(column);
                            }
                          },
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: GameBoardPainter(
                              board: _board,
                              rows: rows,
                              columns: columns,
                              player1Color: Colors.red,        // Port (red)
                              player2Color: Colors.green,      // Starboard (green)
                              boardColor: colours.accent,
                              cellBackgroundColor: colours.background,
                              winningLine: _winningLine,
                              droppingColumn: _droppingColumn,
                              droppingRow: _droppingRow,
                              dropProgress: _dropController?.value ?? 0,
                              currentPlayer: _currentPlayer,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

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

  Widget _buildScoreChip(String label, int score, AppColours colours) {
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
              color: colours.textMuted,
              fontSize: 13,
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
