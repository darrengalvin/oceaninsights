import 'package:flutter/material.dart';

enum Player {
  none,
  player1,
  player2;

  Color getColor(Color player1Color, Color player2Color) {
    switch (this) {
      case Player.player1:
        return player1Color;
      case Player.player2:
        return player2Color;
      case Player.none:
        return Colors.transparent;
    }
  }

  // Nautical theme: Port (left/red) and Starboard (right/green)
  String get label {
    switch (this) {
      case Player.player1:
        return 'Port';
      case Player.player2:
        return 'Starboard';
      case Player.none:
        return '';
    }
  }

  String get emoji {
    switch (this) {
      case Player.player1:
        return '🔴';
      case Player.player2:
        return '🟢';
      case Player.none:
        return '';
    }
  }
}

class GameCell {
  final int row;
  final int column;
  Player player;

  GameCell({
    required this.row,
    required this.column,
    this.player = Player.none,
  });

  bool get isEmpty => player == Player.none;

  GameCell copyWith({Player? player}) {
    return GameCell(
      row: row,
      column: column,
      player: player ?? this.player,
    );
  }
}

class WinningLine {
  final List<(int, int)> cells;
  final Player winner;

  WinningLine({
    required this.cells,
    required this.winner,
  });
}

enum GameMode {
  vsPlayer('vs Player', Icons.people),
  vsApp('vs App', Icons.phone_android);

  final String label;
  final IconData icon;

  const GameMode(this.label, this.icon);
}

enum AppDifficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  final String label;

  const AppDifficulty(this.label);
}
