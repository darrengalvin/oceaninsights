import 'dart:ui';

/// Particle for visual effects
class GameParticle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double life; // 0.0 to 1.0, decreases over time
  final double fadeRate;
  final ParticleType type;
  
  GameParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.life = 1.0,
    this.fadeRate = 0.02,
    this.type = ParticleType.confetti,
  });
  
  /// Update particle position and life
  void update() {
    position = Offset(
      position.dx + velocity.dx,
      position.dy + velocity.dy,
    );
    
    // Apply gravity for confetti
    if (type == ParticleType.confetti) {
      velocity = Offset(velocity.dx * 0.98, velocity.dy + 0.5);
    }
    
    life -= fadeRate;
  }
  
  bool get isDead => life <= 0;
}

enum ParticleType {
  confetti,  // Falls with gravity
  spark,     // Quick burst
  dust,      // Gentle float
}



