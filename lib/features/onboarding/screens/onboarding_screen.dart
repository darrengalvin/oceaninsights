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
  
  String? _selectedName;
  String? _selectedAgeBracket;
  
  // Pre-set name options (no typing required - OPSEC safe)
  // Generic, welcoming names - not role-specific to avoid identity issues
  static const List<String> nameOptions = [
    'Friend',
    'Traveller',
    'Explorer',
    'Companion',
    'Guest',
    'Mate',
  ];
  
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
    
    if (_selectedName != null) {
      await userProvider.setFirstName(_selectedName!);
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
                  _buildNamePage(),
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
        return _selectedName != null;
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
          // Logo with glow effect
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colours.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: colours.accent.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: colours.accent.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'DD',
                style: TextStyle(
                  color: colours.accent,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Welcome to Deep Dive',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal mental health companion,\ndesigned to support you when you need it most.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildFeatureRow(Icons.wifi_off_rounded, 'Works completely offline'),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.shield_outlined, 'Your privacy protected'),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.favorite_outline_rounded, 'Supporting mental health charities'),
        ],
      ),
    );
  }
  
  Widget _buildFeatureRow(IconData icon, String text) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colours.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colours.accent),
          const SizedBox(width: 16),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNamePage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'What should we call you?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a name for your journey. This keeps things personal while protecting your privacy.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: nameOptions.map((name) {
              final isSelected = _selectedName == name;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedName = name;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colours.accent : colours.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colours.accent : colours.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: colours.accent.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ] : null,
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colours.background : colours.textBright,
                    ),
                  ),
                ),
              );
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'What\'s your age bracket?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us show you relevant content and relatable scenarios.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 32),
          ...UserProvider.ageBrackets.map((bracket) {
            final isSelected = _selectedAgeBracket == bracket;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAgeBracket = bracket;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colours.accent : colours.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colours.accent : colours.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: colours.accent.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ] : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        bracket,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colours.background : colours.textBright,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: colours.background,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildDisclaimerPage() {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colours.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colours.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Important Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colours.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Before you begin',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Deep Dive is designed to support your mental wellbeing, but it is not a replacement for professional help.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colours.textLight,
            ),
          ),
          const SizedBox(height: 24),
          _buildDisclaimerItem(
            'This app provides educational content and self-help tools only.',
          ),
          _buildDisclaimerItem(
            'It is not a substitute for professional medical advice, diagnosis, or treatment.',
          ),
          _buildDisclaimerItem(
            'If you are in crisis or experiencing a mental health emergency, please seek immediate professional help.',
          ),
          _buildDisclaimerItem(
            'Always consult a qualified healthcare provider with any questions about your mental health.',
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildDisclaimerItem(String text) {
    final colours = context.colours;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colours.accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
