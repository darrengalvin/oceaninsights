import 'dart:ui';

/// A bubble that rises through the ocean
class Bubble {
  Offset position;
  double radius;
  Color color;
  double opacity;
  double glowIntensity; // 0.0 to 1.0, increases with breathing in
  bool isPopped;
  
  Bubble({
    required this.position,
    required this.radius,
    required this.color,
    this.opacity = 0.8,
    this.glowIntensity = 0.3,
    this.isPopped = false,
  });
  
  /// Update bubble position and properties based on breathing state
  void update(bool isBreathingIn, double breathIntensity) {
    if (isPopped) return;
    
    // Base rise speed
    double riseSpeed = 1.5;
    
    if (isBreathingIn) {
      // Breathing in: bubbles rise faster and glow brighter
      riseSpeed = 1.5 + (breathIntensity * 2.5); // Up to 4.0 speed
      glowIntensity = 0.3 + (breathIntensity * 0.7); // Up to 1.0 glow
      opacity = 0.8 + (breathIntensity * 0.2); // Up to 1.0 opacity
    } else {
      // Breathing out: bubbles slow down and become translucent
      riseSpeed = 1.5 - (breathIntensity * 1.0); // Down to 0.5 speed
      glowIntensity = 0.3 - (breathIntensity * 0.2); // Down to 0.1 glow
      opacity = 0.8 - (breathIntensity * 0.4); // Down to 0.4 opacity
    }
    
    // Update position
    position = Offset(position.dx, position.dy - riseSpeed);
  }
  
  /// Check if bubble collides with a circular obstacle
  bool collidesWith(Offset obstacleCenter, double obstacleRadius) {
    final distance = (position - obstacleCenter).distance;
    return distance < (radius + obstacleRadius);
  }
  
  /// Pop the bubble
  void pop() {
    isPopped = true;
  }
}



