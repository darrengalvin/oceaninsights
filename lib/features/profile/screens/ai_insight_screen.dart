import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/theme/theme_options.dart';

/// Screen that displays the AI-generated personalised insight
/// after the user completes their profile chips
class AIInsightScreen extends StatelessWidget {
  final PersonalisedInsight insight;
  
  const AIInsightScreen({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Text(
                'What I\'m Hearing',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Based on what you\'ve shared',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colours.textLight,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              
              const SizedBox(height: 32),
              
              // Summary Card
              _InsightCard(
                child: Text(
                  insight.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: colours.textBright,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 24),
              
              // "This might be part of it" section
              Text(
                'This might be part of it',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              
              const SizedBox(height: 12),
              
              ...insight.mightBePartOfIt.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BulletPoint(text: point),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 500 + (index * 100)),
                  duration: 400.ms,
                ).slideX(begin: -0.1, end: 0);
              }),
              
              const SizedBox(height: 24),
              
              // Quick Question
              _InsightCard(
                accentBorder: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: colours.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick question',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colours.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      insight.quickQuestion,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: colours.textBright,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
              
              const SizedBox(height: 32),
              
              // Next Steps
              Text(
                'Small next steps',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colours.textBright,
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
              
              const SizedBox(height: 12),
              
              ...insight.nextSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NextStepCard(
                    number: index + 1,
                    text: step,
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 1100 + (index * 100)),
                  duration: 400.ms,
                ).slideY(begin: 0.1, end: 0);
              }),
              
              const SizedBox(height: 40),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ).animate().fadeIn(delay: 1400.ms, duration: 400.ms),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Widget child;
  final bool accentBorder;
  
  const _InsightCard({
    required this.child,
    this.accentBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentBorder ? colours.accent.withOpacity(0.4) : colours.border,
          width: accentBorder ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colours.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: colours.textLight,
            ),
          ),
        ),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final int number;
  final String text;
  
  const _NextStepCard({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colours.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: colours.textBright,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

