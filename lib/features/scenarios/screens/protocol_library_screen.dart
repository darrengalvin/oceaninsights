import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';
import '../models/protocol.dart';
import '../services/scenario_service.dart';
import 'protocol_detail_screen.dart';

/// Library screen for browsing communication protocols
class ProtocolLibraryScreen extends StatefulWidget {
  const ProtocolLibraryScreen({super.key});

  @override
  State<ProtocolLibraryScreen> createState() => _ProtocolLibraryScreenState();
}

class _ProtocolLibraryScreenState extends State<ProtocolLibraryScreen> {
  ProtocolCategory? _selectedCategory;
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
    final protocols = scenarioService.getAllProtocols();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication Protocols'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => _showSyncOptions(context, scenarioService),
            tooltip: 'Sync',
          ),
        ],
      ),
      body: protocols.isEmpty
          ? _buildEmptyState(context, colours, scenarioService)
          : _buildLibraryView(context, colours, scenarioService, protocols),
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
              'No Protocols Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Connect to the internet to download communication protocols.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colours.textMuted,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _syncProtocols(scenarioService, force: true),
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Download Protocols'),
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
    List<Protocol> protocols,
  ) {
    // Filter protocols
    var filteredProtocols = protocols;
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredProtocols = filteredProtocols.where((p) {
        return p.title.toLowerCase().contains(query) ||
               (p.description?.toLowerCase().contains(query) ?? false) ||
               p.steps.any((step) => step.title.toLowerCase().contains(query));
      }).toList();
    }
    
    // Category filter
    if (_selectedCategory != null) {
      filteredProtocols = filteredProtocols
          .where((p) => p.category == _selectedCategory)
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
              hintText: 'Search protocols...',
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
        
        // Category filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildCategoryChip(context, colours, 'All', null),
              const SizedBox(width: 8),
              ...ProtocolCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(
                    context,
                    colours,
                    category.displayName,
                    category,
                  ),
                );
              }),
            ],
          ),
        ),

        // Protocols list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filteredProtocols.length,
            itemBuilder: (context, index) {
              final protocol = filteredProtocols[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProtocolCard(
                  protocol: protocol,
                  onTap: () => _openProtocol(context, protocol),
                  colours: colours,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    AppColours colours,
    String label,
    ProtocolCategory? category,
  ) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colours.accent : colours.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colours.textLight,
          ),
        ),
      ),
    );
  }

  void _openProtocol(BuildContext context, Protocol protocol) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProtocolDetailScreen(protocol: protocol),
      ),
    );
  }

  void _showSyncOptions(BuildContext context, ScenarioService scenarioService) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Protocols',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Download the latest protocols from the server.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colours.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _syncProtocols(scenarioService, force: false);
                },
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Smart Sync (Check Version)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colours.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _syncProtocols(scenarioService, force: true);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Force Sync (Re-download All)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colours.accent,
                  side: BorderSide(color: colours.accent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncProtocols(ScenarioService scenarioService, {bool force = false}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await scenarioService.syncScenarios(force: force);

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
          SnackBar(
            content: Text(force ? 'Re-downloaded all protocols' : 'Synced successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _ProtocolCard extends StatelessWidget {
  final Protocol protocol;
  final VoidCallback onTap;
  final AppColours colours;

  const _ProtocolCard({
    required this.protocol,
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
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getCategoryColour(protocol.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  protocol.category.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColour(protocol.category),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                protocol.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              // Description
              if (protocol.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  protocol.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colours.textMuted,
                        height: 1.4,
                      ),
                ),
              ],
              const SizedBox(height: 12),

              // Step count
              Row(
                children: [
                  Icon(
                    Icons.list_rounded,
                    size: 16,
                    color: colours.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${protocol.stepCount} steps',
                    style: TextStyle(
                      fontSize: 13,
                      color: colours.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: colours.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColour(ProtocolCategory category) {
    switch (category) {
      case ProtocolCategory.communication:
        return Colors.blue;
      case ProtocolCategory.conflict:
        return Colors.orange;
      case ProtocolCategory.selfRegulation:
        return Colors.green;
      case ProtocolCategory.trust:
        return Colors.purple;
      case ProtocolCategory.recovery:
        return Colors.teal;
    }
  }
}

