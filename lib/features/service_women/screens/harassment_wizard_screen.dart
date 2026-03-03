import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../core/services/content_sync_service.dart';
import '../../subscription/mixins/tease_mixin.dart';
import '../../subscription/widgets/premium_gate.dart';

/// Harassment Support Wizard — guided tap-only assessment
/// 
/// ZERO free-text input. Every interaction is tap/select.
/// No data is stored or transmitted. Completely private.
/// All content is admin-managed via ContentSyncService.
class HarassmentWizardScreen extends StatefulWidget {
  const HarassmentWizardScreen({super.key});

  @override
  State<HarassmentWizardScreen> createState() => _HarassmentWizardScreenState();
}

class _HarassmentWizardScreenState extends State<HarassmentWizardScreen>
    with TickerProviderStateMixin, TeaseMixin {
  @override
  TeaseConfig get teaseConfig => TeaseConfig(
    featureName: 'Harassment Support',
    maxActions: 1,
    message: 'Subscribe to complete the full support assessment and receive personalised guidance.',
  );
  int _currentStep = 0;
  bool _showResults = false;
  
  // User selections — stored only in memory, never persisted
  final Map<int, List<String>> _selectedTags = {};
  final Map<int, List<String>> _selectedTexts = {};
  
  // Content from admin
  List<HarassmentWizardStep> get _steps => ContentSyncService().getHarassmentWizardSteps();
  List<HarassmentWizardOption> get _allOptions => ContentSyncService().getHarassmentWizardOptions();
  List<HarassmentGuidanceCard> get _allGuidance => ContentSyncService().getHarassmentWizardGuidance();
  List<HarassmentContact> get _allContacts => ContentSyncService().getHarassmentWizardContacts();

  int get _totalSteps => _steps.length;
  
  List<HarassmentWizardOption> _optionsForStep(String stepId) {
    return _allOptions.where((o) => o.stepId == stepId).toList();
  }
  
  /// Get all tags the user has selected across all steps
  Set<String> get _allSelectedTags {
    final tags = <String>{};
    for (final tagList in _selectedTags.values) {
      tags.addAll(tagList);
    }
    return tags;
  }
  
  /// Get filtered guidance cards based on user selections
  List<HarassmentGuidanceCard> get _matchedGuidance {
    final userTags = _allSelectedTags;
    return _allGuidance.where((card) {
      if (card.isUniversal) return true;
      // Show card if ANY of its match_tags are in user's selections
      return card.matchTags.any((tag) => userTags.contains(tag));
    }).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  bool _isMultiSelect(int stepNumber) {
    // Step 4 (impact) allows multiple selections
    return stepNumber == 4;
  }
  
  bool _canProceed() {
    final tags = _selectedTags[_currentStep];
    return tags != null && tags.isNotEmpty;
  }

  void _selectOption(int stepIndex, String tag, String text) {
    HapticFeedback.lightImpact();
    UISoundService().playClick();
    
    setState(() {
      if (_isMultiSelect(_steps[stepIndex].stepNumber)) {
        // Multi-select: toggle
        final currentTags = _selectedTags[stepIndex] ?? [];
        final currentTexts = _selectedTexts[stepIndex] ?? [];
        
        if (currentTags.contains(tag)) {
          currentTags.remove(tag);
          currentTexts.remove(text);
        } else {
          currentTags.add(tag);
          currentTexts.add(text);
        }
        _selectedTags[stepIndex] = currentTags;
        _selectedTexts[stepIndex] = currentTexts;
      } else {
        // Single select: replace
        _selectedTags[stepIndex] = [tag];
        _selectedTexts[stepIndex] = [text];
      }
    });
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (!isPremium && _currentStep >= 1) {
      recordTeaseAction();
      if (!checkTeaseAndContinue()) return;
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      setState(() => _showResults = true);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    if (_steps.isEmpty) {
      return Scaffold(
        backgroundColor: colours.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colours.textBright),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, size: 48, color: colours.textMuted),
                const SizedBox(height: 16),
                Text(
                  'Support content is loading...',
                  style: TextStyle(color: colours.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_showResults) {
      return _buildResultsScreen();
    }

    return _buildWizardScreen();
  }

  // ============================================================
  // WIZARD SCREEN
  // ============================================================

  Widget _buildWizardScreen() {
    final colours = context.colours;
    final step = _steps[_currentStep];
    final stepOptions = _optionsForStep(step.id);
    final isMulti = _isMultiSelect(step.stepNumber);

    return Scaffold(
      backgroundColor: colours.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colours.textBright),
          onPressed: () {
            // Confirm exit
            showModalBottomSheet(
              context: context,
              backgroundColor: colours.card,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: colours.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Icon(Icons.shield_rounded, size: 40, color: colours.accent),
                    const SizedBox(height: 16),
                    Text(
                      'Leave assessment?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No data has been saved. Your selections will be cleared.',
                      style: TextStyle(color: colours.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Continue'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colours.accent,
                            ),
                            child: const Text('Leave'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
        title: Text(
          'Support Assessment',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/$_totalSteps',
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
              child: Row(
                children: List.generate(_totalSteps, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? colours.accent
                            : colours.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Privacy badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: colours.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Completely private — nothing is saved',
                      style: TextStyle(
                        color: colours.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Question
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (step.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      step.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colours.textMuted,
                      ),
                    ),
                  ],
                  if (isMulti) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Select all that apply',
                      style: TextStyle(
                        color: colours.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: stepOptions.map((option) {
                    final isSelected = (_selectedTags[_currentStep] ?? []).contains(option.tag);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _selectOption(_currentStep, option.tag, option.text),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colours.accent.withOpacity(0.12)
                                : colours.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? colours.accent : colours.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Checkbox/radio indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected ? colours.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(isMulti ? 6 : 12),
                                  border: Border.all(
                                    color: isSelected ? colours.accent : colours.textMuted,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: colours.background,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              
                              // Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.text,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: colours.textBright,
                                      ),
                                    ),
                                    if (option.description != null && option.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        option.description!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colours.textMuted,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
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
            
            // Navigation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colours.card,
                border: Border(
                  top: BorderSide(color: colours.border),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _previousStep,
                    child: Text(
                      _currentStep == 0 ? 'Cancel' : 'Back',
                      style: TextStyle(color: colours.textMuted),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colours.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'See Guidance' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

  // ============================================================
  // RESULTS SCREEN
  // ============================================================

  Widget _buildResultsScreen() {
    final colours = context.colours;
    final guidanceCards = _matchedGuidance;
    final emergencyContacts = _allContacts.where((c) => c.isEmergency).toList();
    final supportContacts = _allContacts.where((c) => !c.isEmergency).toList();

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
          'Your Guidance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy reminder
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colours.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colours.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, color: colours.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This guidance is generated on your device only. Nothing has been recorded or sent anywhere.',
                        style: TextStyle(
                          color: colours.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Emergency strip (always visible if contacts exist)
              if (emergencyContacts.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB7185).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFB7185).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emergency_rounded, color: colours.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'If you are in immediate danger',
                              style: TextStyle(
                                color: colours.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...emergencyContacts.map((contact) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colours.card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colours.textBright,
                                  fontSize: 15,
                                ),
                              ),
                              if (contact.description != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  contact.description!,
                                  style: TextStyle(
                                    color: colours.textLight,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              if (contact.phone != null) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _launchPhone(contact.phone!),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: colours.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone_rounded, color: colours.error, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Call ${contact.phone!}',
                                          style: TextStyle(
                                            color: colours.error,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Guidance cards
              Text(
                'Based on your responses',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              ...guidanceCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGuidanceCard(card),
              )),
              
              const SizedBox(height: 24),
              
              // Support contacts
              Text(
                'Support available to you',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to call or visit',
                style: TextStyle(color: colours.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              
              ...supportContacts.map((contact) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildContactCard(contact),
              )),
              
              const SizedBox(height: 32),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colours.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GUIDANCE CARD WIDGET
  // ============================================================

  Widget _buildGuidanceCard(HarassmentGuidanceCard card) {
    final colours = context.colours;
    
    final typeColors = {
      'classification': colours.accent,
      'rights': const Color(0xFFA78BFA),
      'action_formal': const Color(0xFFF59E0B),
      'action_informal': const Color(0xFF34D399),
      'support': const Color(0xFF3B82F6),
      'self_care': const Color(0xFFEC4899),
      'info': colours.textMuted,
      'warning': colours.error,
    };
    
    final typeLabels = {
      'classification': 'What this means',
      'rights': 'Your rights',
      'action_formal': 'Formal process',
      'action_informal': 'Informal options',
      'support': 'Support',
      'self_care': 'Looking after you',
      'info': 'Information',
      'warning': 'Important',
    };
    
    final color = typeColors[card.guidanceType] ?? colours.accent;
    final label = typeLabels[card.guidanceType] ?? card.guidanceType;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            card.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colours.textBright,
            ),
          ),
          const SizedBox(height: 8),
          
          // Message
          Text(
            card.message,
            style: TextStyle(
              fontSize: 14,
              color: colours.textLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT CARD WIDGET
  // ============================================================

  Widget _buildContactCard(HarassmentContact contact) {
    final colours = context.colours;

    return GestureDetector(
      onTap: () {
        if (contact.phone != null) {
          _launchPhone(contact.phone!);
        } else if (contact.website != null) {
          _launchUrl(contact.website!);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colours.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colours.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                contact.phone != null ? Icons.phone_rounded : Icons.open_in_new_rounded,
                color: colours.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colours.textBright,
                      fontSize: 15,
                    ),
                  ),
                  if (contact.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.description!,
                      style: TextStyle(
                        color: colours.textMuted,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  if (contact.phone != null)
                    Text(
                      contact.phone!,
                      style: TextStyle(
                        color: colours.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  if (contact.availability != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.availability!,
                      style: TextStyle(
                        color: colours.textMuted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Tap indicator
            Icon(
              Icons.chevron_right_rounded,
              color: colours.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LAUNCHERS
  // ============================================================

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
