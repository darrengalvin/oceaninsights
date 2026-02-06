import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';

/// Reusable resource directory screen (no typing)
class ResourceListScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;
  final List<ResourceCategory> categories;
  
  const ResourceListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.categories,
    this.accentColor,
  });

  @override
  State<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends State<ResourceListScreen> {
  int _selectedCategoryIndex = 0;

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - descriptive, not a search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.subtitle,
              style: TextStyle(
                color: colours.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          
          // Category tabs
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final isSelected = index == _selectedCategoryIndex;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      UISoundService().playClick();
                      setState(() => _selectedCategoryIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? accent : colours.cardLight,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected ? accent : colours.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: isSelected ? Colors.white : colours.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : colours.textBright,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Resources list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.categories[_selectedCategoryIndex].resources.length,
              itemBuilder: (context, index) {
                final resource = widget.categories[_selectedCategoryIndex].resources[index];
                
                return _ResourceCard(
                  resource: resource,
                  accent: accent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatefulWidget {
  final ResourceItem resource;
  final Color accent;
  
  const _ResourceCard({
    required this.resource,
    required this.accent,
  });

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.resource.icon,
                      color: widget.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resource.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.resource.subtitle,
                          style: TextStyle(
                            color: colours.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _expanded
                ? Column(
                    children: [
                      Divider(height: 1, color: colours.border),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resource.description,
                              style: TextStyle(
                                color: colours.textMuted,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            if (widget.resource.details != null && widget.resource.details!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ...widget.resource.details!.map((detail) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: widget.accent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        detail,
                                        style: TextStyle(
                                          color: colours.textBright,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      UISoundService().playClick();
                                      // Would launch URL or show more info
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Resource saved: ${widget.resource.title}'),
                                          backgroundColor: widget.accent,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: widget.accent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bookmark_outline,
                                            color: widget.accent,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Save',
                                            style: TextStyle(
                                              color: widget.accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      UISoundService().playClick();
                                      // Would share resource
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Share feature coming soon'),
                                          backgroundColor: widget.accent,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: colours.cardLight,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: colours.border),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.share_outlined,
                                            color: colours.textMuted,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Share',
                                            style: TextStyle(
                                              color: colours.textMuted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class ResourceCategory {
  final String title;
  final IconData icon;
  final List<ResourceItem> resources;
  
  const ResourceCategory({
    required this.title,
    required this.icon,
    required this.resources,
  });
}

class ResourceItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<String>? details;
  
  const ResourceItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.details,
  });
}
