import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../models/scenario.dart';
import '../models/user_response_profile.dart';
import '../services/scenario_service.dart';
import 'scenario_training_screen.dart';

/// Library screen for browsing and selecting scenarios
class ScenarioLibraryScreen extends StatefulWidget {
  const ScenarioLibraryScreen({super.key});

  @override
  State<ScenarioLibraryScreen> createState() => _ScenarioLibraryScreenState();
}

class _ScenarioLibraryScreenState extends State<ScenarioLibraryScreen> {
  String? _selectedPackId;
  ScenarioContext? _filterContext;
  int? _filterDifficulty;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    final scenarioService = context.read<ScenarioService>();
    final contentPacks = scenarioService.getContentPacks();
    final profile = scenarioService.getUserProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenario Training'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context, colours),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: contentPacks.isEmpty
          ? _buildEmptyState(context, colours, scenarioService)
          : _buildLibraryView(context, colours, scenarioService, contentPacks, profile),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppColours colours,
    ScenarioService scenarioService,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_download_rounded,
              size: 80,
              color: colours.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Scenarios Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Connect to the internet to download decision training scenarios.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colours.textMuted,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _syncScenarios(scenarioService),
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Download Scenarios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colours.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryView(
    BuildContext context,
    AppColours colours,
    ScenarioService scenarioService,
    List<ContentPack> contentPacks,
    UserResponseProfile profile,
  ) {
    // Get scenarios
    final scenarios = _selectedPackId != null
        ? scenarioService.getScenariosByPack(_selectedPackId!)
        : scenarioService.getAllScenarios();

    // Apply filters
    var filteredScenarios = scenarios;
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredScenarios = filteredScenarios.where((s) {
        return s.title.toLowerCase().contains(query) ||
               s.situation.toLowerCase().contains(query) ||
               s.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }
    
    // Context filter
    if (_filterContext != null) {
      filteredScenarios = filteredScenarios
          .where((s) => s.context == _filterContext)
          .toList();
    }
    
    // Difficulty filter
    if (_filterDifficulty != null) {
      filteredScenarios = filteredScenarios
          .where((s) => s.difficulty == _filterDifficulty)
          .toList();
    }

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          color: colours.background,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search scenarios...',
              prefixIcon: Icon(Icons.search_rounded, color: colours.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: colours.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: colours.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        
        // Content pack tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildPackChip(
                context,
                colours,
                'All Scenarios',
                null,
                null,
                profile,
              ),
              const SizedBox(width: 8),
              ...contentPacks.map((pack) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildPackChip(
                    context,
                    colours,
                    pack.name,
                    pack.id,
                    pack.icon,
                    profile,
                  ),
                );
              }),
            ],
          ),
        ),

        // Active filters
        if (_filterContext != null || _filterDifficulty != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: colours.cardLight,
            child: Row(
              children: [
                Text(
                  'Filters: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: colours.textMuted,
                  ),
                ),
                if (_filterContext != null) ...[
                  Chip(
                    label: Text(_filterContext!.displayName),
                    onDeleted: () => setState(() => _filterContext = null),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                ],
                if (_filterDifficulty != null) ...[
                  Chip(
                    label: Text(_getDifficultyName(_filterDifficulty!)),
                    onDeleted: () => setState(() => _filterDifficulty = null),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton(
                  onPressed: () => setState(() {
                    _filterContext = null;
                    _filterDifficulty = null;
                  }),
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

        // Scenarios list
        Expanded(
          child: filteredScenarios.isEmpty
              ? _buildNoResults(context, colours)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredScenarios.length,
                  itemBuilder: (context, index) {
                    final scenario = filteredScenarios[index];
                    final isCompleted =
                        profile.completedScenarioIds.contains(scenario.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ScenarioCard(
                        scenario: scenario,
                        isCompleted: isCompleted,
                        onTap: () => _openScenario(context, scenario),
                        colours: colours,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPackChip(
    BuildContext context,
    AppColours colours,
    String label,
    String? packId,
    String? icon,
    UserResponseProfile profile,
  ) {
    final isSelected = _selectedPackId == packId;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedPackId = packId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colours.accent : colours.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                _getIconData(icon),
                size: 16,
                color: isSelected ? Colors.white : colours.textLight,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : colours.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, AppColours colours) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colours.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No scenarios match your filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colours.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, AppColours colours) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Scenarios',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),

                // Context filter
                Text(
                  'Context',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ScenarioContext.values.map((context) {
                    final isSelected = _filterContext == context;
                    return FilterChip(
                      label: Text(context.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          setState(() {
                            _filterContext = selected ? context : null;
                          });
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Difficulty filter
                Text(
                  'Difficulty',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 3].map((difficulty) {
                    final isSelected = _filterDifficulty == difficulty;
                    return FilterChip(
                      label: Text(_getDifficultyName(difficulty)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          setState(() {
                            _filterDifficulty = selected ? difficulty : null;
                          });
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openScenario(BuildContext context, Scenario scenario) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScenarioTrainingScreen(scenario: scenario),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh to show completed state
    }
  }

  Future<void> _syncScenarios(ScenarioService scenarioService) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await scenarioService.syncScenarios();
    
    if (mounted) {
      Navigator.pop(context);
      setState(() {});
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sync. Check your connection.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloaded latest scenarios'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'MessageSquare':
        return Icons.chat_bubble_outline_rounded;
      case 'Shield':
        return Icons.shield_outlined;
      case 'Users':
        return Icons.people_outline_rounded;
      case 'Zap':
        return Icons.bolt_rounded;
      case 'Award':
        return Icons.emoji_events_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  String _getDifficultyName(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Foundational';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }
}

class _ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final bool isCompleted;
  final VoidCallback onTap;
  final AppColours colours;

  const _ScenarioCard({
    required this.scenario,
    required this.isCompleted,
    required this.onTap,
    required this.colours,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colours.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          UISoundService().playClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colours.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Context tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colours.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      scenario.context.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colours.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Difficulty indicator
                  ...List.generate(3, (index) {
                    return Icon(
                      index < scenario.difficulty
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: 8,
                      color: _getDifficultyColour(scenario.difficulty),
                    );
                  }),

                  const Spacer(),

                  // Completed indicator
                  if (isCompleted)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                scenario.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),

              // Situation preview
              Text(
                scenario.situation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colours.textMuted,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 12),

              // Options count
              Row(
                children: [
                  Icon(
                    Icons.list_alt_rounded,
                    size: 16,
                    color: colours.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${scenario.options.length} response options',
                    style: TextStyle(
                      fontSize: 13,
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColour(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

