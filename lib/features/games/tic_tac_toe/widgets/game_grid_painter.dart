import 'package:flutter/material.dart';

class GameGridPainter extends CustomPainter {
  final Color lineColor;
  final List<int>? winningCells;
  final Color winColor;

  GameGridPainter({
    required this.lineColor,
    this.winningCells,
    required this.winColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cellSize = size.width / 3;

    // Draw vertical lines
    canvas.drawLine(
      Offset(cellSize, 20),
      Offset(cellSize, size.height - 20),
      paint,
    );
    canvas.drawLine(
      Offset(cellSize * 2, 20),
      Offset(cellSize * 2, size.height - 20),
      paint,
    );

    // Draw horizontal lines
    canvas.drawLine(
      Offset(20, cellSize),
      Offset(size.width - 20, cellSize),
      paint,
    );
    canvas.drawLine(
      Offset(20, cellSize * 2),
      Offset(size.width - 20, cellSize * 2),
      paint,
    );

    // Draw winning line
    if (winningCells != null && winningCells!.length == 3) {
      final winPaint = Paint()
        ..color = winColor
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      final startCell = winningCells![0];
      final endCell = winningCells![2];

      final startX = (startCell % 3) * cellSize + cellSize / 2;
      final startY = (startCell ~/ 3) * cellSize + cellSize / 2;
      final endX = (endCell % 3) * cellSize + cellSize / 2;
      final endY = (endCell ~/ 3) * cellSize + cellSize / 2;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        winPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GameGridPainter oldDelegate) {
    return oldDelegate.winningCells != winningCells ||
        oldDelegate.lineColor != lineColor;
  }
}
