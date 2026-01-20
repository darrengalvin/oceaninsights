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
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage 
                            ? colours.accent 
                            : colours.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colours.card,
                border: Border(
                  top: BorderSide(color: colours.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _canProceed() ? _nextPage : null,
                      child: const Text('Continue'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Get Started'),
                    ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ocean wave logo
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colours.border, width: 2),
            ),
            child: CustomPaint(
              painter: WaveLogoPainter(colour: colours.accent),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'OCEAN INSIGHT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Welcome to',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colours.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'OCEAN INSIGHT',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 6,
              color: colours.textBright,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Life requires constant navigation.\nSet your course and adjust when needed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserTypePage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'Please select for statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colours.textBright,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // First row: Serving, Veteran
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectionButton('Serving', _selectedUserType == 'Serving', () {
                setState(() => _selectedUserType = 'Serving');
              }),
              const SizedBox(width: 16),
              _buildSelectionButton('Veteran', _selectedUserType == 'Veteran', () {
                setState(() => _selectedUserType = 'Veteran');
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Second row: Deployed, Alongside
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectionButton('Deployed', _selectedUserType == 'Deployed', () {
                setState(() => _selectedUserType = 'Deployed');
              }),
              const SizedBox(width: 16),
              _buildSelectionButton('Alongside', _selectedUserType == 'Alongside', () {
                setState(() => _selectedUserType = 'Alongside');
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Third row: Young Person (centered)
          _buildSelectionButton('Young Person', _selectedUserType == 'Young Person', () {
            setState(() => _selectedUserType = 'Young Person');
          }),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildAgePage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'Please select for statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colours.textBright,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // First row: Teen, 18-24
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectionButton('TEEN', _selectedAgeBracket == 'Teen', () {
                setState(() => _selectedAgeBracket = 'Teen');
              }),
              const SizedBox(width: 16),
              _buildSelectionButton('18-24', _selectedAgeBracket == '18-24', () {
                setState(() => _selectedAgeBracket = '18-24');
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Second row: 25-30, 31-40
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectionButton('25-30', _selectedAgeBracket == '25-30', () {
                setState(() => _selectedAgeBracket = '25-30');
              }),
              const SizedBox(width: 16),
              _buildSelectionButton('31-40', _selectedAgeBracket == '31-40', () {
                setState(() => _selectedAgeBracket = '31-40');
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Third row: 40+ (centered)
          _buildSelectionButton('40+', _selectedAgeBracket == '40+', () {
            setState(() => _selectedAgeBracket = '40+');
          }),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildSelectionButton(String label, bool isSelected, VoidCallback onTap) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colours.accent : colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? colours.background : colours.textBright,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildDisclaimerPage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colours.border, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'OCEAN INSIGHT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: colours.textBright,
                  ),
                ),
                const SizedBox(height: 24),
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
        ],
      ),
    );
  }
  
  Widget _buildDisclaimerItem(String text) {
    final colours = context.colours;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '–',
          style: TextStyle(
            fontSize: 16,
            color: colours.textLight,
          ),
        ),
        const SizedBox(width: 12),
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

/// Custom painter for the wave logo
class WaveLogoPainter extends CustomPainter {
  final Color colour;
  
  WaveLogoPainter({required this.colour});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final centerY = size.height / 2;
    final amplitude = size.height * 0.15;
    
    // Draw multiple wave lines
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final yOffset = centerY + (i - 1) * amplitude * 1.5;
      
      path.moveTo(size.width * 0.15, yOffset);
      
      // Create wave pattern
      for (double x = 0; x <= 1; x += 0.01) {
        final xPos = size.width * 0.15 + (size.width * 0.7 * x);
        final yPos = yOffset + amplitude * 0.8 * 
            (0.5 * _sin(x * 4 * 3.14159 + i * 0.5) + 
             0.3 * _sin(x * 6 * 3.14159 + i * 0.3));
        
        if (x == 0) {
          path.moveTo(xPos, yPos);
        } else {
          path.lineTo(xPos, yPos);
        }
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  double _sin(double x) => (x - x * x * x / 6 + x * x * x * x * x / 120).clamp(-1.0, 1.0);
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
