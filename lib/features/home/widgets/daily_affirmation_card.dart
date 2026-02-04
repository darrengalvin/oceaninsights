import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/daily_affirmation_service.dart';
import '../../affirmations/data/affirmations_data.dart';

/// Daily affirmation card for home screen
class DailyAffirmationCard extends StatefulWidget {
  const DailyAffirmationCard({super.key});

  @override
  State<DailyAffirmationCard> createState() => _DailyAffirmationCardState();
}

class _DailyAffirmationCardState extends State<DailyAffirmationCard> {
  final _service = DailyAffirmationService();
  late Affirmation _affirmation;
  
  @override
  void initState() {
    super.initState();
    _affirmation = _service.getTodaysAffirmation();
  }
  
  void _showCategorySelector() {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CategorySelectorSheet(
        onCategorySelected: (category) {
          setState(() {
            _affirmation = _service.refreshAffirmation();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colours.accent.withOpacity(0.15),
            colours.accentSecondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colours.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with settings icon
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: colours.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Today\'s Affirmation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colours.textBright,
                  ),
                ),
              ),
              // Small settings button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  UISoundService().playClick();
                  _showCategorySelector();
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.tune_rounded,
                    color: colours.textMuted,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Affirmation text
          Text(
            _affirmation.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: colours.textBright,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _affirmation.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colours.accent,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category selector bottom sheet
class _CategorySelectorSheet extends StatefulWidget {
  final Function(String) onCategorySelected;
  
  const _CategorySelectorSheet({
    required this.onCategorySelected,
  });

  @override
  State<_CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<_CategorySelectorSheet> {
  final _service = DailyAffirmationService();
  late String _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _selectedCategory = _service.getSelectedCategory();
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final categories = _service.getCategories();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colours.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Affirmation Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what type of affirmations you\'d like to see',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colours.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Category options - flexible to prevent overflow
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: categories.map((category) {
                    final isSelected = category == _selectedCategory;
                    
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        UISoundService().playClick();
                        
                        setState(() {
                          _selectedCategory = category;
                        });
                        
                        await _service.setSelectedCategory(category);
                        widget.onCategorySelected(category);
                        
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? colours.accent.withOpacity(0.15)
                              : colours.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? colours.accent.withOpacity(0.5)
                                : colours.border.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                category,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                  color: isSelected 
                                      ? colours.accent 
                                      : colours.textBright,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: colours.accent,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
