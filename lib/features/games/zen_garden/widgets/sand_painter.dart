import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/sand_particle.dart';

/// Custom painter that renders sand particles and wave clearing animation
class SandPainter extends CustomPainter {
  final List<SandParticle> particles;
  final double waveProgress;
  final Color particleColor;
  final List<Offset> guidePoints;

  SandPainter({
    required this.particles,
    required this.waveProgress,
    required this.particleColor,
    this.guidePoints = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw pattern guide points (visible but not overwhelming)
    if (guidePoints.isNotEmpty) {
      final guidePaint = Paint()
        ..color = particleColor.withOpacity(0.25) // More visible
        ..style = PaintingStyle.fill;

      for (final point in guidePoints) {
        canvas.drawCircle(point, 2.0, guidePaint); // Bigger dots
      }
    }

    // Draw all sand particles
    for (final particle in particles) {
      // Calculate if particle should be hidden by wave
      final shouldHide = waveProgress > 0 &&
          particle.position.dy < (size.height * waveProgress);

      if (!shouldHide) {
        final paint = Paint()
          ..color = particleColor.withOpacity(particle.opacity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          particle.position,
          particle.size,
          paint,
        );
      }
    }

    // Draw wave animation if clearing
    if (waveProgress > 0 && waveProgress < 1.0) {
      _drawWave(canvas, size, waveProgress);
    }
  }

  void _drawWave(Canvas canvas, Size size, double progress) {
    final waveY = size.height * progress;
    final amplitude = 15.0; // Wave height
    final frequency = 2.0; // Number of wave cycles

    final wavePaint = Paint()
      ..color = particleColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Start from left edge
    path.moveTo(0, waveY);

    // Draw wave curve across the screen
    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final y = waveY + 
          amplitude * math.sin(normalizedX * frequency * 2 * math.pi);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, wavePaint);

    // Draw secondary wave (slightly delayed)
    final secondWavePaint = Paint()
      ..color = particleColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final secondPath = Path();
    final secondWaveY = waveY - 10;
    
    secondPath.moveTo(0, secondWaveY);

    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final y = secondWaveY + 
          (amplitude * 0.6) * math.sin(normalizedX * frequency * 2 * math.pi + 0.5);
      secondPath.lineTo(x, y);
    }

    canvas.drawPath(secondPath, secondWavePaint);
  }

  @override
  bool shouldRepaint(SandPainter oldDelegate) {
    return oldDelegate.particles.length != particles.length ||
        oldDelegate.waveProgress != waveProgress ||
        oldDelegate.guidePoints.length != guidePoints.length;
  }
}

