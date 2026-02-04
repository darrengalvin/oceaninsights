import 'dart:ui';

enum CollectibleType {
  starfish,
  pearl,
  shell,
  treasure,
}

/// Collectible items that give affirmations and points
class Collectible {
  final String id;
  Offset position;
  final CollectibleType type;
  final Color color;
  final double size;
  final String affirmation;
  bool isCollected;
  double pulseAnimation; // 0.0 to 1.0
  
  Collectible({
    required this.id,
    required this.position,
    required this.type,
    required this.color,
    required this.size,
    required this.affirmation,
    this.isCollected = false,
    this.pulseAnimation = 0,
  });
  
  /// Update animation and position
  void update() {
    if (!isCollected) {
      // Move down (simulating bubble rising up through environment)
      position = Offset(position.dx, position.dy - 0.5);
      
      // Pulse animation
      pulseAnimation += 0.05;
      if (pulseAnimation > 1.0) pulseAnimation = 0;
    }
  }
  
  /// Check if bubble collects this item
  bool collectedBy(Offset bubblePosition, double bubbleRadius) {
    if (isCollected) return false;
    
    final distance = (position - bubblePosition).distance;
    return distance < (size + bubbleRadius);
  }
  
  /// Collect the item
  void collect() {
    isCollected = true;
  }
  
  /// Get points value based on type
  int get points {
    switch (type) {
      case CollectibleType.starfish:
        return 10;
      case CollectibleType.pearl:
        return 25;
      case CollectibleType.shell:
        return 15;
      case CollectibleType.treasure:
        return 50;
    }
  }
}

