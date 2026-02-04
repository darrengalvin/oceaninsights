import 'package:flutter/material.dart';

enum CellState {
  empty,
  x,
  o;

  String get symbol {
    switch (this) {
      case CellState.x:
        return 'X';
      case CellState.o:
        return 'O';
      case CellState.empty:
        return '';
    }
  }

  Color getColor(Color xColor, Color oColor) {
    switch (this) {
      case CellState.x:
        return xColor;
      case CellState.o:
        return oColor;
      case CellState.empty:
        return Colors.transparent;
    }
  }
}

enum TicTacToeGameMode {
  vsPlayer('vs Player', Icons.people),
  vsApp('vs App', Icons.phone_android);

  final String label;
  final IconData icon;

  const TicTacToeGameMode(this.label, this.icon);
}

enum TicTacToeAppDifficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  final String label;

  const TicTacToeAppDifficulty(this.label);
}

class WinResult {
  final CellState winner;
  final List<int> winningCells;

  WinResult({
    required this.winner,
    required this.winningCells,
  });
}
