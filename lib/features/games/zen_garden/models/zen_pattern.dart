import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Predefined zen patterns for guided drawing
enum ZenPattern {
  circle,
  spiral,
  mandala,
  waves,
  grid,
}

class ZenPatternHelper {
  /// Get display name for pattern
  static String getPatternName(ZenPattern pattern) {
    switch (pattern) {
      case ZenPattern.circle:
        return 'Circle';
      case ZenPattern.spiral:
        return 'Spiral';
      case ZenPattern.mandala:
        return 'Mandala';
      case ZenPattern.waves:
        return 'Waves';
      case ZenPattern.grid:
        return 'Grid';
    }
  }

  /// Get icon for pattern
  static IconData getPatternIcon(ZenPattern pattern) {
    switch (pattern) {
      case ZenPattern.circle:
        return Icons.circle_outlined;
      case ZenPattern.spiral:
        return Icons.cyclone_rounded;
      case ZenPattern.mandala:
        return Icons.filter_vintage_rounded;
      case ZenPattern.waves:
        return Icons.waves_rounded;
      case ZenPattern.grid:
        return Icons.grid_4x4_rounded;
    }
  }

  /// Generate guide points for a pattern
  static List<Offset> generatePattern(
    ZenPattern pattern,
    Size canvasSize,
  ) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = math.min(canvasSize.width, canvasSize.height) * 0.35;

    switch (pattern) {
      case ZenPattern.circle:
        return _generateCircle(center, radius);
      case ZenPattern.spiral:
        return _generateSpiral(center, radius);
      case ZenPattern.mandala:
        return _generateMandala(center, radius);
      case ZenPattern.waves:
        return _generateWaves(canvasSize);
      case ZenPattern.grid:
        return _generateGrid(canvasSize);
    }
  }

  static List<Offset> _generateCircle(Offset center, double radius) {
    final points = <Offset>[];
    const steps = 100;
    for (int i = 0; i <= steps; i++) {
      final angle = (i / steps) * 2 * math.pi;
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }
    return points;
  }

  static List<Offset> _generateSpiral(Offset center, double maxRadius) {
    final points = <Offset>[];
    const steps = 200;
    for (int i = 0; i <= steps; i++) {
      final progress = i / steps;
      final radius = maxRadius * progress;
      final angle = progress * 4 * 2 * math.pi; // 4 full rotations
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }
    return points;
  }

  static List<Offset> _generateMandala(Offset center, double radius) {
    final points = <Offset>[];
    const petals = 8;
    const steps = 50;

    // Create flower-like mandala pattern
    for (int petal = 0; petal < petals; petal++) {
      final baseAngle = (petal / petals) * 2 * math.pi;
      for (int i = 0; i <= steps; i++) {
        final progress = i / steps;
        final angle = baseAngle + (progress - 0.5) * (math.pi / petals);
        final r = radius * (0.3 + 0.7 * math.sin(progress * math.pi));
        points.add(Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ));
      }
    }

    // Add centre circle
    const innerSteps = 50;
    for (int i = 0; i <= innerSteps; i++) {
      final angle = (i / innerSteps) * 2 * math.pi;
      final r = radius * 0.2;
      points.add(Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      ));
    }

    return points;
  }

  static List<Offset> _generateWaves(Size canvasSize) {
    final points = <Offset>[];
    const waveCount = 5;
    const steps = 100;

    for (int wave = 0; wave < waveCount; wave++) {
      final y = (canvasSize.height / (waveCount + 1)) * (wave + 1);
      for (int i = 0; i <= steps; i++) {
        final x = (i / steps) * canvasSize.width;
        final offset = 30 * math.sin((i / steps) * 4 * 2 * math.pi);
        points.add(Offset(x, y + offset));
      }
    }

    return points;
  }

  static List<Offset> _generateGrid(Size canvasSize) {
    final points = <Offset>[];
    const divisions = 6;
    final spacing = canvasSize.width / divisions;

    // Vertical lines
    for (int i = 1; i < divisions; i++) {
      final x = spacing * i;
      for (double y = 0; y <= canvasSize.height; y += 5) {
        points.add(Offset(x, y));
      }
    }

    // Horizontal lines
    for (int i = 1; i < divisions; i++) {
      final y = spacing * i;
      for (double x = 0; x <= canvasSize.width; x += 5) {
        points.add(Offset(x, y));
      }
    }

    return points;
  }
}



