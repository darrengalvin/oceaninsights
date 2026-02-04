import 'package:flutter/material.dart';
import '../models/game_particle.dart';

class ParticlePainter extends CustomPainter {
  final List<GameParticle> particles;
  
  ParticlePainter({required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Ensure opacity is valid (0.0 to 1.0)
      final opacity = particle.life.clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      // Draw based on type
      switch (particle.type) {
        case ParticleType.confetti:
          // Draw small rectangles that rotate
          canvas.save();
          canvas.translate(particle.position.dx, particle.position.dy);
          canvas.rotate(particle.velocity.dx * 0.1);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6,
            ),
            paint,
          );
          canvas.restore();
          break;
          
        case ParticleType.spark:
          // Draw small circles
          canvas.drawCircle(particle.position, particle.size, paint);
          break;
          
        case ParticleType.dust:
          // Draw soft circles with blur
          canvas.drawCircle(
            particle.position,
            particle.size,
            paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          );
          break;
      }
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

