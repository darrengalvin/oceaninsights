import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/bubble.dart';
import '../models/obstacle.dart';
import '../models/collectible.dart';

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final List<Obstacle> obstacles;
  final List<Collectible> collectibles;
  
  BubblePainter({
    required this.bubbles,
    required this.obstacles,
    required this.collectibles,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw obstacles first (back layer)
    for (final obstacle in obstacles) {
      _drawObstacle(canvas, obstacle);
    }
    
    // Draw collectibles (middle layer)
    for (final collectible in collectibles) {
      if (!collectible.isCollected) {
        _drawCollectible(canvas, collectible);
      }
    }
    
    // Draw bubbles last (front layer)
    for (final bubble in bubbles) {
      if (!bubble.isPopped) {
        _drawBubble(canvas, bubble);
      }
    }
  }
  
  void _drawBubble(Canvas canvas, Bubble bubble) {
    // Outer glow effect
    if (bubble.glowIntensity > 0.3) {
      final glowPaint = Paint()
        ..color = bubble.color.withOpacity(bubble.glowIntensity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(
        bubble.position,
        bubble.radius * 1.3,
        glowPaint,
      );
    }
    
    // Main bubble
    final bubblePaint = Paint()
      ..color = bubble.color.withOpacity(bubble.opacity * 0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(bubble.position, bubble.radius, bubblePaint);
    
    // Bubble outline
    final outlinePaint = Paint()
      ..color = bubble.color.withOpacity(bubble.opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(bubble.position, bubble.radius, outlinePaint);
    
    // Highlight (makes it look shiny)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(bubble.opacity * 0.6)
      ..style = PaintingStyle.fill;
    
    final highlightOffset = Offset(
      bubble.position.dx - bubble.radius * 0.3,
      bubble.position.dy - bubble.radius * 0.3,
    );
    
    canvas.drawCircle(highlightOffset, bubble.radius * 0.3, highlightPaint);
  }
  
  void _drawObstacle(Canvas canvas, Obstacle obstacle) {
    final paint = Paint()
      ..color = obstacle.color
      ..style = PaintingStyle.fill;
    
    switch (obstacle.type) {
      case ObstacleType.kelp:
        _drawKelp(canvas, obstacle, paint);
        break;
      case ObstacleType.rock:
        _drawRock(canvas, obstacle, paint);
        break;
      case ObstacleType.submarine:
        _drawSubmarine(canvas, obstacle, paint);
        break;
      case ObstacleType.coral:
        _drawCoral(canvas, obstacle, paint);
        break;
    }
  }
  
  void _drawKelp(Canvas canvas, Obstacle obstacle, Paint paint) {
    // Swaying kelp - draw as wavy line
    final path = Path();
    final sway = math.sin(obstacle.swayOffset) * 10;
    
    path.moveTo(
      obstacle.position.dx + sway,
      obstacle.position.dy + obstacle.height / 2,
    );
    
    for (int i = 0; i <= 10; i++) {
      final t = i / 10;
      final y = obstacle.position.dy + (obstacle.height / 2) - (t * obstacle.height);
      final x = obstacle.position.dx + sway * (1 - t) * math.sin(t * math.pi * 2);
      path.lineTo(x, y);
    }
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = obstacle.width;
    paint.strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }
  
  void _drawRock(Canvas canvas, Obstacle obstacle, Paint paint) {
    // Simple oval rock
    final rect = Rect.fromCenter(
      center: obstacle.position,
      width: obstacle.width,
      height: obstacle.height,
    );
    
    canvas.drawOval(rect, paint);
    
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawOval(rect, shadowPaint);
  }
  
  void _drawSubmarine(Canvas canvas, Obstacle obstacle, Paint paint) {
    // Simplified submarine shape
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: obstacle.position,
        width: obstacle.width,
        height: obstacle.height,
      ),
      const Radius.circular(20),
    );
    
    canvas.drawRRect(rect, paint);
    
    // Periscope
    final periscopePaint = Paint()
      ..color = obstacle.color.withOpacity(0.8)
      ..strokeWidth = 4;
    
    canvas.drawLine(
      Offset(obstacle.position.dx, obstacle.position.dy - obstacle.height / 2),
      Offset(obstacle.position.dx, obstacle.position.dy - obstacle.height),
      periscopePaint,
    );
  }
  
  void _drawCoral(Canvas canvas, Obstacle obstacle, Paint paint) {
    // Coral branches
    final random = math.Random(obstacle.id.hashCode);
    
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2;
      final length = obstacle.width / 2 + random.nextDouble() * 10;
      final end = Offset(
        obstacle.position.dx + math.cos(angle) * length,
        obstacle.position.dy + math.sin(angle) * length,
      );
      
      paint.strokeWidth = 6;
      paint.style = PaintingStyle.stroke;
      paint.strokeCap = StrokeCap.round;
      canvas.drawLine(obstacle.position, end, paint);
    }
  }
  
  void _drawCollectible(Canvas canvas, Collectible collectible) {
    final pulseFactor = 1.0 + (math.sin(collectible.pulseAnimation * math.pi * 2) * 0.15);
    final size = collectible.size * pulseFactor;
    
    final paint = Paint()
      ..color = collectible.color
      ..style = PaintingStyle.fill;
    
    // Glow effect
    final glowPaint = Paint()
      ..color = collectible.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(collectible.position, size * 1.5, glowPaint);
    
    switch (collectible.type) {
      case CollectibleType.starfish:
        _drawStar(canvas, collectible.position, size, paint);
        break;
      case CollectibleType.pearl:
        canvas.drawCircle(collectible.position, size, paint);
        // Pearl shine
        final shinePaint = Paint()
          ..color = Colors.white.withOpacity(0.8);
        canvas.drawCircle(
          Offset(collectible.position.dx - size * 0.3, collectible.position.dy - size * 0.3),
          size * 0.3,
          shinePaint,
        );
        break;
      case CollectibleType.shell:
        _drawShell(canvas, collectible.position, size, paint);
        break;
      case CollectibleType.treasure:
        _drawTreasure(canvas, collectible.position, size, paint);
        break;
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i / 10) * math.pi * 2 - math.pi / 2;
      final radius = i.isEven ? size : size * 0.5;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawShell(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(
      center.dx + size, center.dy,
      center.dx, center.dy + size,
    );
    path.quadraticBezierTo(
      center.dx - size, center.dy,
      center.dx, center.dy - size,
    );
    canvas.drawPath(path, paint);
  }
  
  void _drawTreasure(Canvas canvas, Offset center, double size, Paint paint) {
    // Simple treasure chest
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size * 1.5, height: size),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);
    
    // Shine
    final shinePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx - size * 0.5, center.dy),
      Offset(center.dx + size * 0.5, center.dy),
      shinePaint,
    );
  }
  
  @override
  bool shouldRepaint(BubblePainter oldDelegate) => true;
}



