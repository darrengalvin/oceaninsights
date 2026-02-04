import 'dart:ui';

enum ObstacleType {
  kelp,      // Swaying kelp
  rock,      // Static rock
  submarine, // Moving submarine
  coral,     // Coral formation
}

/// Obstacles that bubbles must avoid
class Obstacle {
  final String id;
  Offset position;
  final double width;
  final double height;
  final ObstacleType type;
  final Color color;
  double swayOffset; // For animated obstacles like kelp
  
  Obstacle({
    required this.id,
    required this.position,
    required this.width,
    required this.height,
    required this.type,
    required this.color,
    this.swayOffset = 0,
  });
  
  /// Update obstacle (for animations)
  void update() {
    // Move obstacles down (simulating bubble rising up)
    position = Offset(position.dx, position.dy - 1.0);
    
    switch (type) {
      case ObstacleType.kelp:
        // Gentle swaying motion
        swayOffset += 0.02;
        break;
      case ObstacleType.submarine:
        // Slow horizontal movement
        position = Offset(position.dx + 0.5, position.dy);
        break;
      default:
        break;
    }
  }
  
  /// Check if point is inside obstacle bounds (simplified collision)
  bool contains(Offset point, double radius) {
    // Simple rectangular collision for now
    final left = position.dx - width / 2;
    final right = position.dx + width / 2;
    final top = position.dy - height / 2;
    final bottom = position.dy + height / 2;
    
    return point.dx + radius > left &&
           point.dx - radius < right &&
           point.dy + radius > top &&
           point.dy - radius < bottom;
  }
}

