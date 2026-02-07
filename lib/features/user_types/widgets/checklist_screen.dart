import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Reusable interactive checklist screen (no typing)
class ChecklistScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;
  final List<ChecklistCategory> categories;
  
  const ChecklistScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.categories,
    this.accentColor,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final Map<String, bool> _checkedItems = {};
  int _checksThisSession = 0;
  static const int _freeChecks = 3;
  
  int get _totalItems => widget.categories.fold(0, (sum, cat) => sum + cat.items.length);
  int get _completedItems => _checkedItems.values.where((v) => v).length;
  double get _progress => _totalItems > 0 ? _completedItems / _totalItems : 0;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final accent = widget.accentColor ?? colours.accent;
    
    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: colours.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_completedItems of $_totalItems complete',
                              style: TextStyle(
                                color: colours.textBright,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Percentage
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: accent.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            
            // Checklist
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.categories.length,
                itemBuilder: (context, catIndex) {
                  final category = widget.categories[catIndex];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colours.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colours.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (category.color ?? accent).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color ?? accent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Divider(height: 1, color: colours.border),
                        
                        // Items
                        ...category.items.asMap().entries.map((entry) {
                          final itemIndex = entry.key;
                          final item = entry.value;
                          final itemKey = '${catIndex}_$itemIndex';
                          final isChecked = _checkedItems[itemKey] ?? false;
                          
                          return InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              UISoundService().playClick();
                              
                              // Gate after free checks (only for checking, not unchecking)
                              if (!isChecked && !SubscriptionService().isPremium) {
                                _checksThisSession++;
                                if (_checksThisSession > _freeChecks) {
                                  checkPremiumAccess(context, featureName: 'Checklists');
                                  return;
                                }
                              }
                              
                              setState(() {
                                _checkedItems[itemKey] = !isChecked;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? (category.color ?? accent)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isChecked
                                            ? (category.color ?? accent)
                                            : colours.border,
                                        width: 2,
                                      ),
                                    ),
                                    child: isChecked
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            color: isChecked
                                                ? colours.textMuted
                                                : colours.textBright,
                                            fontWeight: FontWeight.w500,
                                            decoration: isChecked
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (item.subtitle != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.subtitle!,
                                            style: TextStyle(
                                              color: colours.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Complete button
            if (_progress == 1.0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showCompletionDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.celebration_rounded),
                        SizedBox(width: 8),
                        Text(
                          'All Complete!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showCompletionDialog() {
    final colours = context.colours;
    
    showModalBottomSheet(
      context: context,
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
              'Checklist Complete!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Great job completing all items. You're making progress!",
              style: TextStyle(color: colours.textMuted),
              textAlign: TextAlign.center,
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
                  style: TextStyle(fontWeight: FontWeight.w600),
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

class ChecklistCategory {
  final String title;
  final IconData icon;
  final Color? color;
  final List<ChecklistItem> items;
  
  const ChecklistCategory({
    required this.title,
    required this.icon,
    required this.items,
    this.color,
  });
}

class ChecklistItem {
  final String title;
  final String? subtitle;
  
  const ChecklistItem({
    required this.title,
    this.subtitle,
  });
}
