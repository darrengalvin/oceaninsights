import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/theme_options.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  
  const SplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  
  // Audio player for ocean waves
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // Start ocean waves audio
    _initAudio();
    
    // Wave animation - continuous flowing
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    // Fade in/out animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _fadeController.forward();
    
    // Navigate after splash duration
    Future.delayed(const Duration(milliseconds: 3500), () {
      _fadeOutAudio();
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
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }
  
  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/ocean-waves-crashing-the-shoreline-423649.mp3');
      await _audioPlayer.setVolume(0.4); // Gentle volume
      await _audioPlayer.play();
    } catch (e) {
      // Audio failed to load - continue silently (offline/missing file)
      debugPrint('Splash audio failed: $e');
    }
  }
  
  Future<void> _fadeOutAudio() async {
    // Gracefully fade out the audio
    try {
      for (double vol = 0.4; vol >= 0; vol -= 0.05) {
        await _audioPlayer.setVolume(vol);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      await _audioPlayer.stop();
    } catch (_) {
      // Ignore errors during fade out
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    
    // Wave colours adapt to theme
    final waveColour = isLightTheme 
        ? colours.accent 
        : colours.accent;
    final waveColourSecondary = isLightTheme 
        ? colours.accentSecondary 
        : colours.accentSecondary;
    
    return Scaffold(
      backgroundColor: colours.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_waveController, _fadeController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated wave background
              Opacity(
                opacity: _fadeAnimation.value,
                child: CustomPaint(
                  painter: OceanWavesPainter(
                    animationValue: _waveController.value,
                    waveColour: waveColour,
                    waveColourSecondary: waveColourSecondary,
                  ),
                  size: Size.infinite,
                ),
              ),
              
              // Centered text
              Center(
                child: Transform.translate(
                  offset: Offset(0, _textSlideAnimation.value),
                  child: Opacity(
                    opacity: _textFadeAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Wave icon
                        Icon(
                          Icons.waves,
                          size: 48,
                          color: colours.accent.withOpacity(0.8),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          'OCEAN INSIGHT',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: colours.textBright,
                            letterSpacing: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          'Dive Deep Within',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: colours.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
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

/// Custom painter that draws multiple flowing sine waves
class OceanWavesPainter extends CustomPainter {
  final double animationValue;
  final Color waveColour;
  final Color waveColourSecondary;
  
  OceanWavesPainter({
    required this.animationValue,
    required this.waveColour,
    required this.waveColourSecondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.5;
    
    // Wave configurations with theme-aware colours
    final waveConfigs = [
      WaveConfig(
        amplitude: 60,
        frequency: 1.5,
        phaseOffset: 0,
        color: waveColour.withOpacity(0.25),
        strokeWidth: 2.0,
        verticalOffset: -40,
      ),
      WaveConfig(
        amplitude: 80,
        frequency: 1.2,
        phaseOffset: 0.5,
        color: waveColourSecondary.withOpacity(0.3),
        strokeWidth: 1.5,
        verticalOffset: 0,
      ),
      WaveConfig(
        amplitude: 50,
        frequency: 2.0,
        phaseOffset: 1.0,
        color: waveColour.withOpacity(0.2),
        strokeWidth: 2.5,
        verticalOffset: 20,
      ),
      WaveConfig(
        amplitude: 70,
        frequency: 1.0,
        phaseOffset: 1.5,
        color: waveColourSecondary.withOpacity(0.15),
        strokeWidth: 1.0,
        verticalOffset: -20,
      ),
      WaveConfig(
        amplitude: 45,
        frequency: 1.8,
        phaseOffset: 2.0,
        color: waveColour.withOpacity(0.25),
        strokeWidth: 2.0,
        verticalOffset: 40,
      ),
      WaveConfig(
        amplitude: 90,
        frequency: 0.8,
        phaseOffset: 2.5,
        color: waveColourSecondary.withOpacity(0.12),
        strokeWidth: 1.5,
        verticalOffset: -60,
      ),
    ];
    
    for (final config in waveConfigs) {
      _drawWave(canvas, size, centerY, config);
    }
  }
  
  void _drawWave(Canvas canvas, Size size, double centerY, WaveConfig config) {
    final paint = Paint()
      ..color = config.color
      ..strokeWidth = config.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final phase = animationValue * 2 * math.pi + config.phaseOffset;
    
    // Start from left edge
    path.moveTo(
      -50,
      centerY + config.verticalOffset + 
          config.amplitude * math.sin(phase),
    );
    
    // Draw wave across the screen
    for (double x = -50; x <= size.width + 50; x += 2) {
      final normalizedX = x / size.width;
      final y = centerY + 
          config.verticalOffset + 
          config.amplitude * math.sin(
            normalizedX * config.frequency * 2 * math.pi + phase
          );
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant OceanWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.waveColour != waveColour ||
           oldDelegate.waveColourSecondary != waveColourSecondary;
  }
}

/// Configuration for a single wave
class WaveConfig {
  final double amplitude;
  final double frequency;
  final double phaseOffset;
  final Color color;
  final double strokeWidth;
  final double verticalOffset;
  
  const WaveConfig({
    required this.amplitude,
    required this.frequency,
    required this.phaseOffset,
    required this.color,
    required this.strokeWidth,
    required this.verticalOffset,
  });
}
