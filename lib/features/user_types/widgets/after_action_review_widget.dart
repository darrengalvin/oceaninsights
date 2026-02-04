import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/content_sync_service.dart';

/// Interactive After Action Review - Reflect on your day (tap-only, no typing)
/// Uses synced content from admin panel - works offline with cached data
class AfterActionReviewScreen extends StatefulWidget {
  const AfterActionReviewScreen({super.key});

  @override
  State<AfterActionReviewScreen> createState() => _AfterActionReviewScreenState();
}

class _AfterActionReviewScreenState extends State<AfterActionReviewScreen> {
  int _currentStep = 0;
  int _overallRating = 0;
  final List<String> _selectedWentWell = [];
  final List<String> _selectedImprove = [];
  String? _selectedTakeaway;
  
  // Options from admin (with fallbacks)
  List<String> get _wentWellOptions => ContentSyncService().getAarWentWellOptions();
  List<String> get _improveOptions => ContentSyncService().getAarImproveOptions();
  List<String> get _takeawayOptions => ContentSyncService().getAarTakeawayOptions();

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'After Action Review',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/4',
                style: TextStyle(
                  color: colours.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: colours.border,
                valueColor: AlwaysStoppedAnimation<Color>(colours.accent),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildRatingStep();
      case 1:
        return _buildWentWellStep();
      case 2:
        return _buildImproveStep();
      case 3:
        return _buildTakeawayStep();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildRatingStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('rating'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "How did today go overall?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Quick gut check - don't overthink it.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 48),
          
          // Rating buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = _overallRating >= rating;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  UISoundService().playClick();
                  setState(() => _overallRating = rating);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colours.accent.withOpacity(0.2)
                          : colours.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colours.accent : colours.border,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? colours.accent : colours.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rough',
                style: TextStyle(color: colours.textMuted, fontSize: 12),
              ),
              Text(
                'Excellent',
                style: TextStyle(color: colours.textMuted, fontSize: 12),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _overallRating > 0
                  ? () {
                      HapticFeedback.mediumImpact();
                      setState(() => _currentStep = 1);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colours.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWentWellStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('went_well'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "What went well?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Even on hard days, something worked. Select all that apply.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _wentWellOptions.map((option) {
                  final isSelected = _selectedWentWell.contains(option);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() {
                        if (isSelected) {
                          _selectedWentWell.remove(option);
                        } else {
                          _selectedWentWell.add(option);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.green.withOpacity(0.15)
                            : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.green : colours.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.add_circle_outline,
                            color: isSelected ? Colors.green : colours.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option,
                            style: TextStyle(
                              color: isSelected ? Colors.green : colours.textBright,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildNavButtons(0, 2),
        ],
      ),
    );
  }
  
  Widget _buildImproveStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('improve'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "What could be better?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No judgment. Just honest assessment. Select all that apply.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _improveOptions.map((option) {
                  final isSelected = _selectedImprove.contains(option);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() {
                        if (isSelected) {
                          _selectedImprove.remove(option);
                        } else {
                          _selectedImprove.add(option);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.orange.withOpacity(0.15)
                            : colours.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.orange : colours.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.add_circle_outline,
                            color: isSelected ? Colors.orange : colours.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option,
                            style: TextStyle(
                              color: isSelected ? Colors.orange : colours.textBright,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildNavButtons(1, 3),
        ],
      ),
    );
  }
  
  Widget _buildTakeawayStep() {
    final colours = context.colours;
    
    return Padding(
      key: const ValueKey('takeaway'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "What's one takeaway?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "One thing to remember or do differently tomorrow.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _takeawayOptions.map((option) {
                  final isSelected = _selectedTakeaway == option;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        UISoundService().playClick();
                        setState(() => _selectedTakeaway = option);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? colours.accent.withOpacity(0.15)
                              : colours.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? colours.accent : colours.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? colours.accent : colours.textMuted,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected ? colours.accent : colours.textBright,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: Text(
                  'Back',
                  style: TextStyle(color: colours.textMuted),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedTakeaway != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        _showCompletion();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Review',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavButtons(int prevStep, int nextStep) {
    final colours = context.colours;
    
    return Row(
      children: [
        TextButton(
          onPressed: () => setState(() => _currentStep = prevStep),
          child: Text(
            'Back',
            style: TextStyle(color: colours.textMuted),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            setState(() => _currentStep = nextStep);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colours.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
  
  void _showCompletion() {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colours.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Checkmark
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Review Complete',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Reflection builds growth. Well done.",
              style: TextStyle(color: colours.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colours.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Day Rating: ',
                        style: TextStyle(color: colours.textMuted),
                      ),
                      ...List.generate(5, (i) => Icon(
                        i < _overallRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: i < _overallRating ? Colors.amber : colours.textMuted,
                        size: 20,
                      )),
                    ],
                  ),
                  if (_selectedTakeaway != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Takeaway:',
                      style: TextStyle(
                        color: colours.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedTakeaway!,
                      style: TextStyle(
                        color: colours.textBright,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
