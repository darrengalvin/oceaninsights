import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/providers/theme_provider.dart';

class ThemeChooserScreen extends StatelessWidget {
  const ThemeChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colours = context.colours;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Theme'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: ThemeOptions.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final theme = ThemeOptions.all[index];
          final isSelected = theme.id == themeProvider.currentTheme.id;
          
          return _ThemeCard(
            theme: theme,
            isSelected: isSelected,
            onTap: () => themeProvider.setTheme(theme),
          );
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeOption theme;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colours.accent : colours.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colours.accent.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview bar
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: theme.previewBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Preview cards
                  Expanded(
                    child: Row(
                      children: [
                        _PreviewCard(
                          color: theme.previewCard,
                          accent: theme.previewAccent,
                        ),
                        const SizedBox(width: 8),
                        _PreviewCard(
                          color: theme.previewCard,
                          accent: theme.previewAccent,
                        ),
                        const SizedBox(width: 8),
                        _PreviewCard(
                          color: theme.previewCard,
                          accent: theme.previewAccent,
                        ),
                      ],
                    ),
                  ),
                  // Selected indicator
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colours.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: colours.background,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          theme.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.previewAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.previewAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          theme.bestFor,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.previewAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.tagline,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    theme.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  // Colour swatches
                  Row(
                    children: [
                      _Swatch(color: theme.previewBackground, label: 'BG'),
                      const SizedBox(width: 8),
                      _Swatch(color: theme.previewCard, label: 'Card'),
                      const SizedBox(width: 8),
                      _Swatch(color: theme.previewAccent, label: 'Accent'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Color color;
  final Color accent;
  
  const _PreviewCard({
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: accent.withOpacity(0.4)),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 12,
                color: accent,
              ),
            ),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String label;
  
  const _Swatch({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: context.colours.textMuted,
          ),
        ),
      ],
    );
  }
}

