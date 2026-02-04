import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/memory_card.dart';

class MemoryCardWidget extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final Color backColor;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.backColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: card.isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: card.isMatched
              ? card.color.withOpacity(0.3)
              : (card.isFlipped ? card.color : backColor),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? card.color.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: card.isMatched
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final angle = animation.value * math.pi;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle);
                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          child: Center(
            key: ValueKey(card.isFlipped || card.isMatched),
            child: (card.isFlipped || card.isMatched)
                ? Icon(
                    card.icon,
                    size: 32,
                    color: card.isMatched
                        ? card.color.withOpacity(0.5)
                        : Colors.white,
                  )
                : Icon(
                    Icons.question_mark_rounded,
                    size: 32,
                    color: Colors.white.withOpacity(0.3),
                  ),
          ),
        ),
      ),
    );
  }
}



