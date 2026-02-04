import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Represents a stackable block in the game
class GameBlock {
  final String id;
  Offset position;
  final Size size;
  final Color color;
  double rotation; // Rotation in radians
  double velocityY; // Vertical velocity for physics
  double velocityX; // Horizontal velocity
  double angularVelocity; // Rotation velocity
  bool isStatic; // If true, block won't move (ground or settled blocks)
  
  GameBlock({
    required this.id,
    required this.position,
    required this.size,
    required this.color,
    this.rotation = 0.0,
    this.velocityY = 0.0,
    this.velocityX = 0.0,
    this.angularVelocity = 0.0,
    this.isStatic = false,
  });
  
  /// Get the corners of the block for collision detection
  List<Offset> getCorners() {
    final centerX = position.dx;
    final centerY = position.dy;
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;
    
    // Corners before rotation
    final corners = [
      Offset(-halfWidth, -halfHeight),
      Offset(halfWidth, -halfHeight),
      Offset(halfWidth, halfHeight),
      Offset(-halfWidth, halfHeight),
    ];
    
    // Apply rotation
    return corners.map((corner) {
      final cosAngle = math.cos(rotation);
      final sinAngle = math.sin(rotation);
      final x = corner.dx * cosAngle - corner.dy * sinAngle;
      final y = corner.dx * sinAngle + corner.dy * cosAngle;
      return Offset(centerX + x, centerY + y);
    }).toList();
  }
  
  GameBlock copyWith({
    Offset? position,
    double? rotation,
    double? velocityY,
    double? velocityX,
    double? angularVelocity,
    bool? isStatic,
  }) {
    return GameBlock(
      id: id,
      position: position ?? this.position,
      size: size,
      color: color,
      rotation: rotation ?? this.rotation,
      velocityY: velocityY ?? this.velocityY,
      velocityX: velocityX ?? this.velocityX,
      angularVelocity: angularVelocity ?? this.angularVelocity,
      isStatic: isStatic ?? this.isStatic,
    );
  }
}

