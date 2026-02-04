import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A decorative wavy divider that replaces straight lines
class WavyDivider extends StatelessWidget {
  final Color? color;
  final double height;
  final double opacity;
  
  const WavyDivider({
    super.key,
    this.color,
    this.height = 48,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).dividerColor;
    
    return SizedBox(
      height: height,
      child: Center(
        child: CustomPaint(
          painter: WavyDividerPainter(
            color: dividerColor.withOpacity(opacity),
          ),
          size: Size(MediaQuery.of(context).size.width, 2),
        ),
      ),
    );
  }
}

/// Custom painter for wavy divider line
class WavyDividerPainter extends CustomPainter {
  final Color color;
  
  WavyDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final amplitude = 3.0; // Height of the waves
    final frequency = 1.5; // Number of waves across the width
    final centerY = size.height / 2;
    
    // Start from left edge
    path.moveTo(0, centerY);
    
    // Draw wavy line across
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final y = centerY + amplitude * math.sin(normalizedX * frequency * 2 * math.pi);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavyDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
