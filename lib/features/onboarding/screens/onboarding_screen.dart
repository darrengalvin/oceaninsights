import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/user_provider.dart';
import '../../home/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String? _selectedUserType;
  String? _selectedAgeBracket;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  Future<void> _completeOnboarding() async {
    final userProvider = context.read<UserProvider>();
    
    if (_selectedUserType != null) {
      await userProvider.setUserType(_selectedUserType!);
    }
    
    if (_selectedAgeBracket != null) {
      await userProvider.setAgeBracket(_selectedAgeBracket!);
    }
    
    await userProvider.completeOnboarding();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      body: Stack(
        children: [
          // Subtle background wave decoration
          Positioned(
            bottom: -100,
            left: -50,
            right: -50,
            child: Opacity(
              opacity: 0.06,
              child: CustomPaint(
                size: const Size(double.infinity, 300),
                painter: _BackgroundWavePainter(colour: colours.accent),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Progress indicator - hidden on first page for cleaner intro
                AnimatedOpacity(
                  opacity: _currentPage > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Row(
                      children: List.generate(4, (index) {
                        final isActive = index <= _currentPage;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 1.5,
                            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? colours.accent.withOpacity(0.6) 
                                  : colours.border.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildWelcomePage(),
                      _buildUserTypePage(),
                      _buildAgePage(),
                      _buildDisclaimerPage(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: _currentPage == 0
                      // First page: centred, wide button
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      // Other pages: back and continue
                      : Row(
                          children: [
                            TextButton(
                              onPressed: _previousPage,
                              style: TextButton.styleFrom(
                                foregroundColor: colours.textMuted,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              child: const Text('Back'),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _currentPage < 3 
                                  ? (_canProceed() ? _nextPage : null)
                                  : _completeOnboarding,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(_currentPage < 3 ? 'Continue' : 'Finish'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _selectedUserType != null;
      case 2:
        return _selectedAgeBracket != null;
      case 3:
        return true;
      default:
        return true;
    }
  }
  
  Widget _buildWelcomePage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          // Logo - clean, no border
          _OceanInsightFullLogo(size: 100, showBorder: false),
          const SizedBox(height: 48),
          // Tagline - refined typography
          Text(
            'Life requires constant navigation.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colours.textBright,
              height: 1.4,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Set your course and adjust when needed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textMuted,
              height: 1.6,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
  
  
  Widget _buildUserTypePage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            '👤',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 24),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us provide relevant content\n(for statistics only)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: UserProvider.userTypes.map((type) {
              return _buildChip(type, _selectedUserType == type, () {
                setState(() => _selectedUserType = type);
              });
            }).toList(),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildAgePage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            '📊',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 24),
          Text(
            'What\'s your age bracket?',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us show relevant scenarios',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: UserProvider.ageBrackets.map((bracket) {
              return _buildChip(bracket, _selectedAgeBracket == bracket, () {
                setState(() => _selectedAgeBracket = bracket);
              });
            }).toList(),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colours.accent : colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colours.accent.withOpacity(0.3),
              blurRadius: 12,
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? colours.background : colours.textBright,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDisclaimerPage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colours.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('⚠️', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Important',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colours.border),
            ),
            child: Column(
              children: [
                _buildDisclaimerItem(
                  'Designed to support you in times of need. This is not a replacement for professional help.',
                ),
                const SizedBox(height: 16),
                _buildDisclaimerItem(
                  'Provides educational content and self-help tools only.',
                ),
                const SizedBox(height: 16),
                _buildDisclaimerItem(
                  'If you are in a crisis or experiencing a mental health emergency, please seek immediate professional help.',
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildDisclaimerItem(String text) {
    final colours = context.colours;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colours.accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textLight,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Full logo with waves icon + readable text below (for headers/branding)
class _OceanInsightFullLogo extends StatelessWidget {
  final double size;
  final bool showBorder;
  
  const _OceanInsightFullLogo({
    this.size = 80,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wave icon
        _OceanInsightIcon(size: size, showBorder: showBorder),
        const SizedBox(height: 14),
        // Text below - refined letter-spacing
        Text(
          'OCEAN INSIGHT',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: colours.textBright,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}

/// Minimal wave icon (for app icon / small uses)
class _OceanInsightIcon extends StatelessWidget {
  final double size;
  final bool showBorder;
  
  const _OceanInsightIcon({
    this.size = 80,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      width: size,
      height: size,
      decoration: showBorder ? BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(
          color: colours.accent.withOpacity(0.5),
          width: 1,
        ),
      ) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: CustomPaint(
          painter: _WaveLogoPainter(
            waveColour: colours.accent,
          ),
          size: Size(size, size),
        ),
      ),
    );
  }
}

/// Custom painter for overlapping wave lines
class _WaveLogoPainter extends CustomPainter {
  final Color waveColour;
  
  _WaveLogoPainter({required this.waveColour});
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.5;
    
    // Multiple overlapping waves - clean and visible
    final waveConfigs = [
      _LogoWaveConfig(
        yOffset: -size.height * 0.18,
        amplitude: size.height * 0.1,
        frequency: 0.8,
        phaseOffset: 0.3,
        strokeWidth: 1.5,
        opacity: 0.6,
      ),
      _LogoWaveConfig(
        yOffset: -size.height * 0.05,
        amplitude: size.height * 0.16,
        frequency: 1.1,
        phaseOffset: 0.0,
        strokeWidth: 1.8,
        opacity: 0.8,
      ),
      _LogoWaveConfig(
        yOffset: size.height * 0.05,
        amplitude: size.height * 0.14,
        frequency: 1.0,
        phaseOffset: 0.5,
        strokeWidth: 2.0,
        opacity: 1.0,
      ),
      _LogoWaveConfig(
        yOffset: size.height * 0.18,
        amplitude: size.height * 0.1,
        frequency: 1.3,
        phaseOffset: 0.7,
        strokeWidth: 1.5,
        opacity: 0.6,
      ),
    ];
    
    for (final config in waveConfigs) {
      _drawWave(canvas, size, centerY, config);
    }
  }
  
  void _drawWave(
    Canvas canvas, 
    Size size, 
    double centerY, 
    _LogoWaveConfig config,
  ) {
    final paint = Paint()
      ..color = waveColour.withOpacity(config.opacity)
      ..strokeWidth = config.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final phase = config.phaseOffset * 2 * math.pi;
    
    path.moveTo(
      0,
      centerY + config.yOffset + config.amplitude * math.sin(phase),
    );
    
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final y = centerY + 
          config.yOffset + 
          config.amplitude * math.sin(normalizedX * config.frequency * 2 * math.pi + phase);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveLogoPainter oldDelegate) => 
      oldDelegate.waveColour != waveColour;
}

/// Configuration for wave in logo
class _LogoWaveConfig {
  final double yOffset;
  final double amplitude;
  final double frequency;
  final double phaseOffset;
  final double strokeWidth;
  final double opacity;
  
  const _LogoWaveConfig({
    required this.yOffset,
    required this.amplitude,
    required this.frequency,
    this.phaseOffset = 0.0,
    required this.strokeWidth,
    required this.opacity,
  });
}

/// Subtle background wave decoration
class _BackgroundWavePainter extends CustomPainter {
  final Color colour;
  
  _BackgroundWavePainter({required this.colour});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Draw multiple flowing waves
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = size.height * (0.2 + i * 0.15);
      final amplitude = size.height * (0.08 + i * 0.02);
      final frequency = 0.8 + i * 0.1;
      final phase = i * 0.4;
      
      path.moveTo(0, yOffset + amplitude * math.sin(phase * math.pi));
      
      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / size.width;
        final y = yOffset + amplitude * math.sin((normalizedX * frequency + phase) * 2 * math.pi);
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, paint..color = colour.withOpacity(0.3 + i * 0.1));
    }
  }
  
  @override
  bool shouldRepaint(covariant _BackgroundWavePainter oldDelegate) => 
      oldDelegate.colour != colour;
}
