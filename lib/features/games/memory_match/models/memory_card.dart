import 'package:flutter/material.dart';

class MemoryCard {
  final String id;
  final IconData icon;
  final Color color;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.icon,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id,
      icon: icon,
      color: color,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

enum DifficultyLevel {
  easy(rows: 3, columns: 4, name: 'Easy'),
  medium(rows: 4, columns: 4, name: 'Medium'),
  hard(rows: 4, columns: 6, name: 'Hard');

  final int rows;
  final int columns;
  final String name;

  const DifficultyLevel({
    required this.rows,
    required this.columns,
    required this.name,
  });

  int get totalPairs => (rows * columns) ~/ 2;
}

class MemoryCardTheme {
  static final List<Map<String, dynamic>> oceanTheme = [
    {'icon': Icons.anchor, 'color': Color(0xFF4A90E2)},
    {'icon': Icons.sailing, 'color': Color(0xFF50C878)},
    {'icon': Icons.waves, 'color': Color(0xFF00BCD4)},
    {'icon': Icons.water_drop, 'color': Color(0xFF42A5F5)},
    {'icon': Icons.opacity, 'color': Color(0xFF26C6DA)},
    {'icon': Icons.bubble_chart, 'color': Color(0xFF29B6F6)},
    {'icon': Icons.water, 'color': Color(0xFF0288D1)},
    {'icon': Icons.star, 'color': Color(0xFFFFA726)},
    {'icon': Icons.circle, 'color': Color(0xFF66BB6A)},
    {'icon': Icons.favorite, 'color': Color(0xFFEF5350)},
    {'icon': Icons.flash_on, 'color': Color(0xFFFFEE58)},
    {'icon': Icons.wb_sunny, 'color': Color(0xFFFFCA28)},
  ];
}

