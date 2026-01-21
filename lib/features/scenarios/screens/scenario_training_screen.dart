import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../models/scenario.dart';
import '../services/scenario_service.dart';

/// Screen for interactive scenario training
/// Users read situations and choose responses
class ScenarioTrainingScreen extends StatefulWidget {
  final Scenario scenario;

  const ScenarioTrainingScreen({
    super.key,
    required this.scenario,
  });

  @override
  State<ScenarioTrainingScreen> createState() => _ScenarioTrainingScreenState();
}

class _ScenarioTrainingScreenState extends State<ScenarioTrainingScreen> {
  ScenarioOption? _selectedOption;
  bool _showingOutcome = false;
  bool _showingPerspectives = false;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final scenarioService = context.read<ScenarioService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision Training'),
        actions: [
          // Difficulty indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColour(widget.scenario.difficulty, colours),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.scenario.difficultyDisplay,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _showingOutcome
          ? _buildOutcomeView(colours, scenarioService)
          : _buildScenarioView(colours),
    );
  }

  Widget _buildScenarioView(AppColours colours) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colours.accent.withOpacity(0.3)),
            ),
            child: Text(
              widget.scenario.context.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colours.accent,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.scenario.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Situation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colours.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colours.border),
            ),
            child: Text(
              widget.scenario.situation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Options header
          Text(
            'How do you respond?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Options
          ...widget.scenario.sortedOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionCard(
                option: option,
                index: index,
                isSelected: _selectedOption?.id == option.id,
                onTap: () => _selectOption(option),
                colours: colours,
              ),
            );
          }),

          if (_selectedOption != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showOutcome(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'See Outcome',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutcomeView(AppColours colours, ScenarioService scenarioService) {
    final option = _selectedOption!;
    final outcome = option.outcome;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected response
          Text(
            'You chose:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colours.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colours.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colours.accent.withOpacity(0.3)),
            ),
            child: Text(
              option.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Immediate outcome
          _buildOutcomeSection(
            'Immediate Impact',
            outcome.immediate,
            Icons.bolt_rounded,
            colours,
          ),
          const SizedBox(height: 24),

          // Long-term outcome
          _buildOutcomeSection(
            'Long-Term Consideration',
            outcome.longTerm,
            Icons.trending_up_rounded,
            colours,
          ),
          const SizedBox(height: 24),

          // Risk level
          Row(
            children: [
              Icon(
                _getRiskIcon(outcome.riskLevel),
                size: 20,
                color: _getRiskColour(outcome.riskLevel, colours),
              ),
              const SizedBox(width: 8),
              Text(
                '${outcome.riskLevel.displayName} Response',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getRiskColour(outcome.riskLevel, colours),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Perspective shifts
          if (option.perspectiveShifts.isNotEmpty && !_showingPerspectives) ...[
            OutlinedButton.icon(
              onPressed: () => setState(() => _showingPerspectives = true),
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('See How This Lands With Others'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_showingPerspectives && option.perspectiveShifts.isNotEmpty) ...[
            Text(
              'Different Perspectives',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'How your choice might be interpreted by different people:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            ...option.perspectiveShifts.map((shift) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPerspectiveShift(shift, colours),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _tryAgain,
                  child: const Text('Try Another Response'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _complete(scenarioService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colours.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeSection(
    String title,
    String content,
    IconData icon,
    AppColours colours,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colours.accent),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colours.textBright,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPerspectiveShift(PerspectiveShift shift, AppColours colours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shift.viewpoint.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colours.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            shift.interpretation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _selectOption(ScenarioOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _showOutcome() {
    setState(() {
      _showingOutcome = true;
    });
  }

  void _tryAgain() {
    setState(() {
      _selectedOption = null;
      _showingOutcome = false;
      _showingPerspectives = false;
    });
  }

  void _complete(ScenarioService scenarioService) {
    // Record the choice
    scenarioService.recordChoice(
      scenarioId: widget.scenario.id,
      optionId: _selectedOption!.id,
      context: widget.scenario.context.name,
      tags: _selectedOption!.tags,
      riskLevel: _selectedOption!.riskLevel.name,
    );

    Navigator.pop(context, true); // Return true to indicate completion
  }

  Color _getDifficultyColour(int difficulty, AppColours colours) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return colours.accent;
    }
  }

  Color _getRiskColour(RiskLevel risk, AppColours colours) {
    switch (risk) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  IconData _getRiskIcon(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return Icons.check_circle_outline_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.error_outline_rounded;
    }
  }
}

class _OptionCard extends StatelessWidget {
  final ScenarioOption option;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColours colours;

  const _OptionCard({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.colours,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? colours.accent.withOpacity(0.1)
              : colours.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colours.accent
                : colours.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? colours.accent
                    : colours.cardLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : colours.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Option text
            Expanded(
              child: Text(
                option.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  height: 1.5,
                ),
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colours.accent,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

