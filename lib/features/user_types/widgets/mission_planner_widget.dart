import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/content_sync_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Interactive Mission Planner - Plan Primary/Secondary/Contingency tasks (tap-only)
/// Uses synced content from admin panel - works offline with cached data
class MissionPlannerScreen extends StatefulWidget {
  const MissionPlannerScreen({super.key});

  @override
  State<MissionPlannerScreen> createState() => _MissionPlannerScreenState();
}

class _MissionPlannerScreenState extends State<MissionPlannerScreen> {
  String? _selectedPrimary;
  String? _selectedSecondary;
  String? _selectedContingency;
  
  bool _primaryComplete = false;
  bool _secondaryComplete = false;
  bool _contingencyComplete = false;
  
  // Get options from synced content (falls back to defaults if no cache)
  List<MissionObjective> get _primaryOptions => 
      ContentSyncService().getMissionObjectives(type: 'primary');
  
  List<MissionObjective> get _secondaryOptions => 
      ContentSyncService().getMissionObjectives(type: 'secondary');
  
  List<MissionObjective> get _contingencyOptions => 
      ContentSyncService().getMissionObjectives(type: 'contingency');

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
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
          'Mission Planner',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedPrimary != null)
            TextButton(
              onPressed: _saveMission,
              child: Text(
                'Save',
                style: TextStyle(
                  color: colours.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Plan your mission",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Primary is your main objective. Secondary and Contingency are backups if things change.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            
            // Primary Task
            _MissionSection(
              label: 'PRIMARY',
              subtitle: 'Your main objective - this is the mission',
              color: Colors.green,
              icon: Icons.looks_one_rounded,
              options: _primaryOptions,
              selectedOption: _selectedPrimary,
              isComplete: _primaryComplete,
              onSelect: (option) {
                HapticFeedback.lightImpact();
                UISoundService().playClick();
                setState(() => _selectedPrimary = option);
              },
              onToggleComplete: () {
                if (_selectedPrimary != null) {
                  HapticFeedback.mediumImpact();
                  setState(() => _primaryComplete = !_primaryComplete);
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Secondary Task
            _MissionSection(
              label: 'SECONDARY',
              subtitle: 'If primary is blocked, pivot to this',
              color: Colors.orange,
              icon: Icons.looks_two_rounded,
              options: _secondaryOptions,
              selectedOption: _selectedSecondary,
              isComplete: _secondaryComplete,
              onSelect: (option) {
                // Secondary requires premium
                if (!SubscriptionService().isPremium) {
                  checkPremiumAccess(context, featureName: 'Mission Planner');
                  return;
                }
                HapticFeedback.lightImpact();
                UISoundService().playClick();
                setState(() => _selectedSecondary = option);
              },
              onToggleComplete: () {
                if (_selectedSecondary != null) {
                  HapticFeedback.mediumImpact();
                  setState(() => _secondaryComplete = !_secondaryComplete);
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Contingency Task
            _MissionSection(
              label: 'CONTINGENCY',
              subtitle: 'Last resort - better than no progress',
              color: Colors.blue,
              icon: Icons.looks_3_rounded,
              options: _contingencyOptions,
              selectedOption: _selectedContingency,
              isComplete: _contingencyComplete,
              onSelect: (option) {
                // Contingency requires premium
                if (!SubscriptionService().isPremium) {
                  checkPremiumAccess(context, featureName: 'Mission Planner');
                  return;
                }
                HapticFeedback.lightImpact();
                UISoundService().playClick();
                setState(() => _selectedContingency = option);
              },
              onToggleComplete: () {
                if (_selectedContingency != null) {
                  HapticFeedback.mediumImpact();
                  setState(() => _contingencyComplete = !_contingencyComplete);
                }
              },
            ),
            
            const SizedBox(height: 32),
            
            // Quick tips
            Container(
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
                      Icon(Icons.lightbulb_outline, color: colours.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Planning Tips',
                        style: TextStyle(
                          color: colours.textBright,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip(colours, 'Primary should be specific and achievable today'),
                  _buildTip(colours, 'Secondary is for when circumstances change'),
                  _buildTip(colours, "Contingency keeps you moving even on tough days"),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTip(AppColours colours, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: colours.textMuted)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colours.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveMission() {
    final colours = context.colours;
    
    HapticFeedback.mediumImpact();
    
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
              'Mission Planned',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You have a clear path. Execute with focus.",
              style: TextStyle(color: colours.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Summary
            if (_selectedPrimary != null)
              _buildSummaryItem(colours, 'Primary', _selectedPrimary!, Colors.green),
            if (_selectedSecondary != null)
              _buildSummaryItem(colours, 'Secondary', _selectedSecondary!, Colors.orange),
            if (_selectedContingency != null)
              _buildSummaryItem(colours, 'Contingency', _selectedContingency!, Colors.blue),
            
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
                  'Start Mission',
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
  
  Widget _buildSummaryItem(AppColours colours, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colours.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: colours.textBright,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MissionObjective is imported from ContentSyncService

class _MissionSection extends StatefulWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final List<MissionObjective> options;
  final String? selectedOption;
  final bool isComplete;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleComplete;
  
  const _MissionSection({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.options,
    required this.selectedOption,
    required this.isComplete,
    required this.onSelect,
    required this.onToggleComplete,
  });

  @override
  State<_MissionSection> createState() => _MissionSectionState();
}

class _MissionSectionState extends State<_MissionSection> {
  bool _expanded = false;
  static const int _initialDisplayCount = 4;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isComplete ? Colors.green : widget.color.withOpacity(0.3),
          width: widget.isComplete ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _expanded = !_expanded);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: widget.color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (widget.selectedOption != null)
                    GestureDetector(
                      onTap: widget.onToggleComplete,
                      child: Icon(
                        widget.isComplete ? Icons.check_circle : Icons.circle_outlined,
                        color: widget.isComplete ? Colors.green : colours.textMuted,
                        size: 24,
                      ),
                    )
                  else
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: colours.textMuted,
                    ),
                ],
              ),
            ),
          ),
          
          // Selected option display
          if (widget.selectedOption != null && !_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _expanded = true);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.selectedOption!,
                          style: TextStyle(
                            color: widget.isComplete 
                                ? colours.textMuted 
                                : colours.textBright,
                            fontWeight: FontWeight.w500,
                            decoration: widget.isComplete 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: colours.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Subtitle when no selection
          if (widget.selectedOption == null && !_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.subtitle,
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          
          // Expanded options
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Select your ${widget.label.toLowerCase()} objective:',
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            // Show first few options
            ...widget.options.take(_initialDisplayCount).map((option) => 
              _buildOptionTile(context, option, colours)
            ),
            
            // Show more button
            if (widget.options.length > _initialDisplayCount)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () => _showAllOptions(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.color.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: widget.color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.options.length - _initialDisplayCount} more options',
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
  
  Widget _buildOptionTile(BuildContext context, MissionObjective option, AppColours colours) {
    final isSelected = widget.selectedOption == option.text;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () {
          widget.onSelect(option.text);
          setState(() => _expanded = false);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected 
                ? widget.color.withOpacity(0.15)
                : colours.cardLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? widget.color : colours.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: isSelected ? widget.color : colours.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(
                    color: isSelected ? widget.color : colours.textBright,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAllOptions(BuildContext context) {
    final colours = context.colours;
    
    // Group options by category
    final Map<String, List<MissionObjective>> grouped = {};
    for (final option in widget.options) {
      grouped.putIfAbsent(option.category, () => []).add(option);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colours.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colours.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: widget.color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.options.length} objectives',
                    style: TextStyle(
                      color: colours.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: colours.textMuted),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: colours.border),
            
            // Options list grouped by category
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  for (final category in grouped.keys) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: colours.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    ...grouped[category]!.map((option) {
                      final isSelected = widget.selectedOption == option.text;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            UISoundService().playClick();
                            widget.onSelect(option.text);
                            Navigator.pop(context);
                            setState(() => _expanded = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? widget.color.withOpacity(0.15)
                                  : colours.cardLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? widget.color : colours.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  size: 20,
                                  color: isSelected ? widget.color : colours.textMuted,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: TextStyle(
                                      color: isSelected ? widget.color : colours.textBright,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
