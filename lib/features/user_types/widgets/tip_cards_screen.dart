import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/services/ui_sound_service.dart';

/// Reusable swipeable tip cards screen (no typing)
class TipCardsScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;
  final List<TipCard> tips;
  
  const TipCardsScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tips,
    this.accentColor,
  });

  @override
  State<TipCardsScreen> createState() => _TipCardsScreenState();
}

class _TipCardsScreenState extends State<TipCardsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final Set<int> _savedTips = {};
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
          icon: Icon(Icons.close_rounded, color: colours.textBright),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${widget.tips.length}',
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
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / widget.tips.length,
                backgroundColor: colours.border,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.subtitle,
                style: TextStyle(
                  color: colours.textMuted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Tip cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.tips.length,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final tip = widget.tips[index];
                  final isSaved = _savedTips.contains(index);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colours.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colours.border),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      tip.icon ?? widget.icon,
                                      color: accent,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Title
                                  Text(
                                    tip.title,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Content
                                  Text(
                                    tip.content,
                                    style: TextStyle(
                                      color: colours.textMuted,
                                      fontSize: 15,
                                      height: 1.6,
                                    ),
                                  ),
                                  
                                  // Key points
                                  if (tip.keyPoints != null && tip.keyPoints!.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    ...tip.keyPoints!.map((point) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 6),
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: accent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              point,
                                              style: TextStyle(
                                                color: colours.textBright,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Save button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            UISoundService().playClick();
                            setState(() {
                              if (isSaved) {
                                _savedTips.remove(index);
                              } else {
                                _savedTips.add(index);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSaved ? accent.withOpacity(0.15) : colours.cardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSaved ? accent : colours.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                  color: isSaved ? accent : colours.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isSaved ? 'Saved' : 'Save this tip',
                                  style: TextStyle(
                                    color: isSaved ? accent : colours.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Previous
                  if (_currentIndex > 0)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colours.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colours.border),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: colours.textMuted,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 52),
                  
                  const Spacer(),
                  
                  // Dots indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.tips.length, (index) {
                      final isActive = index == _currentIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? accent : colours.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  const Spacer(),
                  
                  // Next / Done
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (_currentIndex < widget.tips.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: _currentIndex == widget.tips.length - 1
                            ? accent
                            : colours.cardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentIndex == widget.tips.length - 1
                              ? accent
                              : colours.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentIndex == widget.tips.length - 1 ? 'Done' : 'Next',
                            style: TextStyle(
                              color: _currentIndex == widget.tips.length - 1
                                  ? Colors.white
                                  : colours.textBright,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentIndex == widget.tips.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: _currentIndex == widget.tips.length - 1
                                ? Colors.white
                                : colours.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
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
}

class TipCard {
  final String title;
  final String content;
  final IconData? icon;
  final List<String>? keyPoints;
  
  const TipCard({
    required this.title,
    required this.content,
    this.icon,
    this.keyPoints,
  });
}
