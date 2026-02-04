import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_block.dart';

/// Custom painter that renders all blocks with physics
class BlockPainter extends CustomPainter {
  final List<GameBlock> blocks;
  final GameBlock? currentBlock;
  final Color borderColor;
  final bool showLandingGuide;

  BlockPainter({
    required this.blocks,
    this.currentBlock,
    required this.borderColor,
    this.showLandingGuide = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all placed blocks
    for (final block in blocks) {
      _drawBlock(canvas, block);
    }
    
    // Draw landing guide (ghost showing where block will land)
    if (showLandingGuide && currentBlock != null && blocks.isNotEmpty) {
      _drawLandingGuide(canvas, currentBlock!, blocks.last);
    }
    
    // Draw current block being placed (if any)
    if (currentBlock != null) {
      _drawBlock(canvas, currentBlock!, isPreview: true);
    }
  }
  
  void _drawLandingGuide(Canvas canvas, GameBlock movingBlock, GameBlock lastBlock) {
    // Calculate where the block would land
    final targetY = lastBlock.position.dy - lastBlock.size.height;
    
    // Calculate the overlap to show how much will be trimmed
    final movingLeft = movingBlock.position.dx - movingBlock.size.width / 2;
    final movingRight = movingBlock.position.dx + movingBlock.size.width / 2;
    final lastLeft = lastBlock.position.dx - lastBlock.size.width / 2;
    final lastRight = lastBlock.position.dx + lastBlock.size.width / 2;
    
    final overlapLeft = math.max(movingLeft, lastLeft);
    final overlapRight = math.min(movingRight, lastRight);
    final overlap = overlapRight - overlapLeft;
    
    if (overlap <= 0) {
      // Complete miss - draw a warning X
      final warnPaint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      final centerX = movingBlock.position.dx;
      canvas.drawLine(
        Offset(centerX - 15, targetY - 15),
        Offset(centerX + 15, targetY + 15),
        warnPaint,
      );
      canvas.drawLine(
        Offset(centerX + 15, targetY - 15),
        Offset(centerX - 15, targetY + 15),
        warnPaint,
      );
      return;
    }
    
    // Draw ghost of where the trimmed block will be
    final ghostCenterX = (overlapLeft + overlapRight) / 2;
    
    canvas.save();
    canvas.translate(ghostCenterX, targetY);
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: overlap,
      height: movingBlock.size.height,
    );
    
    // Ghost fill
    final ghostPaint = Paint()
      ..color = movingBlock.color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    // Ghost border (dashed effect via dotted line)
    final ghostBorderPaint = Paint()
      ..color = movingBlock.color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      ghostPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      ghostBorderPaint,
    );
    
    canvas.restore();
    
    // Draw a vertical guide line from current block to landing position
    final guidePaint = Paint()
      ..color = movingBlock.color.withOpacity(0.2)
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset(movingBlock.position.dx, movingBlock.position.dy + movingBlock.size.height / 2),
      Offset(movingBlock.position.dx, targetY),
      guidePaint,
    );
  }
  
  void _drawBlock(Canvas canvas, GameBlock block, {bool isPreview = false}) {
    canvas.save();
    
    // Move to block position and rotate
    canvas.translate(block.position.dx, block.position.dy);
    canvas.rotate(block.rotation);
    
    // Draw block
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: block.size.width,
      height: block.size.height,
    );
    
    final paint = Paint()
      ..color = isPreview ? block.color.withOpacity(0.7) : block.color
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw filled block
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );
    
    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      borderPaint,
    );
    
    // Draw subtle texture lines for depth
    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset(-block.size.width / 2 + 8, -block.size.height / 2 + 4),
      Offset(block.size.width / 2 - 8, -block.size.height / 2 + 4),
      texturePaint,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(BlockPainter oldDelegate) {
    return oldDelegate.blocks.length != blocks.length ||
        oldDelegate.currentBlock != currentBlock ||
        oldDelegate.showLandingGuide != showLandingGuide;
  }
}



