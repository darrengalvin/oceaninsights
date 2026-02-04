import 'package:flutter/material.dart';
import '../models/game_cell.dart';

class GameBoardPainter extends CustomPainter {
  final List<List<Player>> board;
  final int rows;
  final int columns;
  final Color player1Color;
  final Color player2Color;
  final Color boardColor;
  final Color cellBackgroundColor;
  final WinningLine? winningLine;
  final int? droppingColumn;
  final int? droppingRow;
  final double dropProgress;
  final Player currentPlayer;

  GameBoardPainter({
    required this.board,
    required this.rows,
    required this.columns,
    required this.player1Color,
    required this.player2Color,
    required this.boardColor,
    required this.cellBackgroundColor,
    this.winningLine,
    this.droppingColumn,
    this.droppingRow,
    this.dropProgress = 0,
    required this.currentPlayer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    final pieceRadius = (cellWidth < cellHeight ? cellWidth : cellHeight) * 0.38;

    // Draw board background
    final boardPaint = Paint()
      ..color = boardColor
      ..style = PaintingStyle.fill;

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(boardRect, boardPaint);

    // Draw cells (holes in the board)
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final centerX = col * cellWidth + cellWidth / 2;
        final centerY = row * cellHeight + cellHeight / 2;

        // Draw hole background
        final holePaint = Paint()
          ..color = cellBackgroundColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(centerX, centerY),
          pieceRadius + 2,
          holePaint,
        );

        // Draw piece if present
        final player = board[row][col];
        if (player != Player.none) {
          final isWinningCell = winningLine?.cells.contains((row, col)) ?? false;
          
          final piecePaint = Paint()
            ..color = player == Player.player1 ? player1Color : player2Color
            ..style = PaintingStyle.fill;

          canvas.drawCircle(
            Offset(centerX, centerY),
            pieceRadius,
            piecePaint,
          );

          // Add gradient/3D effect
          final gradient = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 1.0,
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.transparent,
            ],
          );

          final gradientPaint = Paint()
            ..shader = gradient.createShader(
              Rect.fromCircle(center: Offset(centerX, centerY), radius: pieceRadius),
            );

          canvas.drawCircle(
            Offset(centerX, centerY),
            pieceRadius,
            gradientPaint,
          );

          // Highlight winning pieces
          if (isWinningCell) {
            final highlightPaint = Paint()
              ..color = Colors.white.withOpacity(0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4;

            canvas.drawCircle(
              Offset(centerX, centerY),
              pieceRadius - 2,
              highlightPaint,
            );
          }
        }
      }
    }

    // Draw dropping piece animation
    if (droppingColumn != null && droppingRow != null) {
      final centerX = droppingColumn! * cellWidth + cellWidth / 2;
      final startY = -pieceRadius;
      final endY = droppingRow! * cellHeight + cellHeight / 2;
      final currentY = startY + (endY - startY) * dropProgress;

      final droppingPaint = Paint()
        ..color = currentPlayer == Player.player1 ? player1Color : player2Color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(centerX, currentY),
        pieceRadius,
        droppingPaint,
      );

      // Add gradient effect to dropping piece
      final gradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.transparent,
        ],
      );

      final gradientPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(centerX, currentY), radius: pieceRadius),
        );

      canvas.drawCircle(
        Offset(centerX, currentY),
        pieceRadius,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GameBoardPainter oldDelegate) {
    return oldDelegate.board != board ||
        oldDelegate.winningLine != winningLine ||
        oldDelegate.droppingColumn != droppingColumn ||
        oldDelegate.droppingRow != droppingRow ||
        oldDelegate.dropProgress != dropProgress;
  }
}
