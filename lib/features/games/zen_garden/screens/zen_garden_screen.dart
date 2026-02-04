import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme_options.dart';
import '../../../../core/services/ui_sound_service.dart';
import '../widgets/sand_painter.dart';
import '../models/sand_particle.dart';
import '../models/zen_pattern.dart';

class ZenGardenScreen extends StatefulWidget {
  const ZenGardenScreen({super.key});

  @override
  State<ZenGardenScreen> createState() => _ZenGardenScreenState();
}

class _ZenGardenScreenState extends State<ZenGardenScreen>
    with TickerProviderStateMixin {
  final List<SandParticle> _particles = [];
  double _brushSize = 20.0;
  bool _isClearing = false;
  ZenPattern? _selectedPattern;
  List<Offset> _patternGuidePoints = [];
  Color? _selectedColor; // Will use theme accent by default
  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveAnimation = CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    super.dispose();
  }

  Offset? _lastPosition;

  void _addParticle(Offset position) {
    if (_isClearing) return;

    setState(() {
      // Add multiple particles around the touch point for fuller effect
      final random = math.Random();
      
      // Interpolate between last position and current for smooth lines
      if (_lastPosition != null) {
        final distance = (position - _lastPosition!).distance;
        final steps = (distance / 3).ceil().clamp(1, 10); // More steps for smoother lines
        
        for (int step = 0; step < steps; step++) {
          final t = step / steps;
          final interpolated = Offset.lerp(_lastPosition!, position, t)!;
          _addParticlesAt(interpolated, random);
        }
      }
      
      _addParticlesAt(position, random);
      _lastPosition = position;
    });
  }

  void _addParticlesAt(Offset position, math.Random random) {
    // Increased particle count for denser drawing
    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = random.nextDouble() * _brushSize * 0.4; // Tighter clustering
      final offset = Offset(
        position.dx + math.cos(angle) * distance,
        position.dy + math.sin(angle) * distance,
      );
      _particles.add(SandParticle(
        position: offset,
        size: 2.5 + random.nextDouble() * 2.5, // Slightly larger
        opacity: 0.7 + random.nextDouble() * 0.3, // More opaque
      ));
    }
  }

  void _resetLastPosition() {
    _lastPosition = null;
  }

  void _clearWithWaveAnimation() async {
    if (_isClearing) return;

    HapticFeedback.mediumImpact();
    UISoundService().playClick();

    setState(() {
      _isClearing = true;
      _lastPosition = null; // Reset last position
    });

    await _waveAnimationController.forward(from: 0.0);

    setState(() {
      _particles.clear();
      _isClearing = false;
    });

    _waveAnimationController.reset();
  }

  void _showSettingsSheet() {
    final colours = context.colours;

    showModalBottomSheet(
      context: context,
      backgroundColor: colours.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colours.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Pattern Selection
            Text(
              'Pattern Guides',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PatternChip(
                  pattern: null,
                  label: 'None',
                  icon: Icons.close_rounded,
                  isSelected: _selectedPattern == null,
                  onTap: () {
                    setState(() {
                      _selectedPattern = null;
                      _patternGuidePoints = [];
                    });
                    setModalState(() {}); // Update modal UI
                  },
                ),
                ...ZenPattern.values.map((pattern) => _PatternChip(
                      pattern: pattern,
                      label: ZenPatternHelper.getPatternName(pattern),
                      icon: ZenPatternHelper.getPatternIcon(pattern),
                      isSelected: _selectedPattern == pattern,
                      onTap: () {
                        setState(() {
                          _selectedPattern = pattern;
                          _patternGuidePoints = [];
                        });
                        setModalState(() {}); // Update modal UI
                      },
                    )),
              ],
            ),
            
            const SizedBox(height: 24),
            Divider(color: colours.border),
            const SizedBox(height: 24),
            
            // Brush Size
            Text(
              'Brush Size',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Slider(
              value: _brushSize,
              min: 10.0,
              max: 50.0,
              divisions: 8,
              activeColor: colours.accent,
              inactiveColor: colours.border,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() {
                  _brushSize = value;
                });
                setModalState(() {}); // Update modal UI
              },
            ),
            Center(
              child: Text(
                '${_brushSize.round()}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colours.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            
            const SizedBox(height: 24),
            Divider(color: colours.border),
            const SizedBox(height: 24),
            
            // Colour Palette
            Text(
              'Draw Colour',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ColorOption(
                  color: colours.accent,
                  label: 'Theme',
                  isSelected: _selectedColor == null || _selectedColor == colours.accent,
                  onTap: () {
                    setState(() => _selectedColor = null); // Use theme accent
                    setModalState(() {}); // Update modal UI
                  },
                ),
                _ColorOption(
                  color: colours.textBright,
                  label: 'Light',
                  isSelected: _selectedColor == colours.textBright,
                  onTap: () {
                    setState(() => _selectedColor = colours.textBright);
                    setModalState(() {}); // Update modal UI
                  },
                ),
                _ColorOption(
                  color: const Color(0xFFFBBF24),
                  label: 'Gold',
                  isSelected: _selectedColor == const Color(0xFFFBBF24),
                  onTap: () {
                    setState(() => _selectedColor = const Color(0xFFFBBF24));
                    setModalState(() {}); // Update modal UI
                  },
                ),
                _ColorOption(
                  color: const Color(0xFF34D399),
                  label: 'Green',
                  isSelected: _selectedColor == const Color(0xFF34D399),
                  onTap: () {
                    setState(() => _selectedColor = const Color(0xFF34D399));
                    setModalState(() {}); // Update modal UI
                  },
                ),
                _ColorOption(
                  color: const Color(0xFFFB7185),
                  label: 'Coral',
                  isSelected: _selectedColor == const Color(0xFFFB7185),
                  onTap: () {
                    setState(() => _selectedColor = const Color(0xFFFB7185));
                    setModalState(() {}); // Update modal UI
                  },
                ),
                _ColorOption(
                  color: const Color(0xFF94A3B8),
                  label: 'Silver',
                  isSelected: _selectedColor == const Color(0xFF94A3B8),
                  onTap: () {
                    setState(() => _selectedColor = const Color(0xFF94A3B8));
                    setModalState(() {}); // Update modal UI
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    // Use theme accent as default color if not set
    final drawColor = _selectedColor ?? colours.accent;

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        title: Text(
          'Zen Garden',
          style: TextStyle(color: colours.textBright),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colours.textBright,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () {
            HapticFeedback.lightImpact();
            UISoundService().playClick();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: colours.textBright),
            onPressed: () {
              HapticFeedback.lightImpact();
              UISoundService().playClick();
              _showSettingsSheet();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Draw patterns in the sand with your finger',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colours.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Drawing Canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colours.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colours.border.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Generate pattern points when canvas size is known AND pattern changes
                      if (_selectedPattern != null && _patternGuidePoints.isEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _patternGuidePoints = ZenPatternHelper.generatePattern(
                                _selectedPattern!,
                                Size(constraints.maxWidth, constraints.maxHeight),
                              );
                            });
                          }
                        });
                      }

                      return GestureDetector(
                        onPanUpdate: (details) {
                          _addParticle(details.localPosition);
                        },
                        onPanStart: (details) {
                          _resetLastPosition();
                          _addParticle(details.localPosition);
                        },
                        onPanEnd: (details) {
                          _resetLastPosition();
                        },
                        child: AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) => CustomPaint(
                            painter: SandPainter(
                              particles: _particles,
                              waveProgress: _waveAnimation.value,
                              particleColor: drawColor,
                              guidePoints: _patternGuidePoints,
                            ),
                            child: Container(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.waves_rounded,
                      label: 'Clear',
                      onTap: _clearWithWaveAnimation,
                      color: colours.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _ControlButton(
                      icon: Icons.tune_rounded,
                      label: 'Settings',
                      onTap: _showSettingsSheet,
                      color: colours.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colours.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternChip extends StatelessWidget {
  final ZenPattern? pattern;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatternChip({
    required this.pattern,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colours.accent.withOpacity(0.15)
              : colours.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? colours.accent : colours.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? colours.accent : colours.textLight,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        UISoundService().playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : colours.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : colours.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colours.border,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? color : colours.textLight,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

