import 'package:flutter/material.dart';

/// Represents a single sand particle in the zen garden
class SandParticle {
  final Offset position;
  final double size;
  final double opacity;
  
  const SandParticle({
    required this.position,
    required this.size,
    required this.opacity,
  });
  
  SandParticle copyWith({
    Offset? position,
    double? size,
    double? opacity,
  }) {
    return SandParticle(
      position: position ?? this.position,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
    );
  }
}



