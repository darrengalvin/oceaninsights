import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_options.dart';

class BreathingLoaderScreen extends StatefulWidget {
  final Widget nextScreen;
  
  const BreathingLoaderScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<BreathingLoaderScreen> createState() => _BreathingLoaderScreenState();
}

class _BreathingLoaderScreenState extends State<BreathingLoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isBreathingIn = true;
  int _breathCycles = 0;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation - in and out cycle
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 4000), // 4 seconds per cycle
      vsync: this,
    );
    
    // Smooth breathing curve
    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Circle scale animation
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Pulsing opacity
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
    
    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isBreathingIn = false;
          _breathCycles++;
        });
        _breathController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (_breathCycles >= 1) {
          // After 1 complete cycle (breathe in + out once), navigate
          _navigateToNext();
        } else {
          setState(() {
            _isBreathingIn = true;
          });
          _breathController.forward();
        }
      }
    });
    
    _breathController.forward();
  }
  
  void _skip() {
    _breathController.stop();
    _navigateToNext();
  }
  
  void _navigateToNext() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              widget.nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      backgroundColor: colours.background,
      body: AnimatedBuilder(
        animation: _breathController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background gradient circles
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colours.accent.withOpacity(_opacityAnimation.value * 0.3),
                          colours.accent.withOpacity(0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value * 0.8,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colours.accentSecondary.withOpacity(_opacityAnimation.value * 0.4),
                          colours.accentSecondary.withOpacity(0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Animated breathing circles
              Center(
                child: CustomPaint(
                  painter: BreathingCirclesPainter(
                    progress: _breathAnimation.value,
                    color: colours.accent,
                  ),
                  size: const Size(300, 300),
                ),
              ),
              
              // Center text
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      Icons.air_rounded,
                      size: 48,
                      color: colours.accent.withOpacity(0.8),
                    ),
                    const SizedBox(height: 40),
                    
                    // Breathing text with fade transition
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _isBreathingIn ? 'Breathe In' : 'Breathe Out',
                        key: ValueKey<bool>(_isBreathingIn),
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: colours.textBright,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Subtitle
                    Text(
                      'Preparing your mindful space...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: colours.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Skip button at bottom
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: colours.card.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: colours.border.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          color: colours.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Custom painter for animated breathing circles
class BreathingCirclesPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  BreathingCirclesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    // Draw multiple expanding/contracting circles
    for (int i = 0; i < 4; i++) {
      final circleProgress = (progress + (i * 0.15)) % 1.0;
      final radius = maxRadius * 0.3 + (maxRadius * 0.4 * circleProgress);
      final opacity = (1.0 - circleProgress) * 0.4;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(center, radius, paint);
    }
    
    // Draw center pulsing circle
    final centerRadius = 30 + (20 * math.sin(progress * math.pi));
    final centerPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, centerRadius, centerPaint);
    
    // Center border
    final centerBorderPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, centerRadius, centerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant BreathingCirclesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
