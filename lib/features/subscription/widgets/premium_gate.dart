import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/theme_options.dart';
import '../screens/paywall_screen.dart';

/// Configuration for how much "tease" to allow before showing paywall
class TeaseConfig {
  /// Number of actions allowed (e.g., blocks stacked, pieces dropped)
  final int? maxActions;
  
  /// Duration allowed (e.g., seconds of audio, gameplay time)
  final Duration? maxDuration;
  
  /// Custom message for the paywall
  final String? message;
  
  /// Feature name for analytics/display
  final String featureName;

  const TeaseConfig({
    this.maxActions,
    this.maxDuration,
    this.message,
    required this.featureName,
  });
  
  // Preset configurations for different features
  
  /// Games: Allow 2-3 moves/blocks
  static TeaseConfig game(String name) => TeaseConfig(
    featureName: name,
    maxActions: 3,
    message: 'Enjoying $name? Subscribe to keep playing!',
  );
  
  /// Audio: Allow 10 seconds preview
  static TeaseConfig audio(String name) => TeaseConfig(
    featureName: name,
    maxDuration: const Duration(seconds: 10),
    message: 'Like what you hear? Subscribe for full access.',
  );
  
  /// Scenarios: Allow 1 question/step
  static TeaseConfig scenario(String name) => TeaseConfig(
    featureName: name,
    maxActions: 1,
    message: 'Want to continue this journey? Subscribe to unlock.',
  );
  
  /// Breathing: Allow 1 free exercise, block others
  static TeaseConfig breathing(String name) => TeaseConfig(
    featureName: name,
    maxActions: 0, // Immediate block for non-free exercises
    message: 'Unlock all breathing exercises with a subscription.',
  );
  
  /// Content sections: Allow preview of first item
  static TeaseConfig content(String name) => TeaseConfig(
    featureName: name,
    maxActions: 1,
    message: 'Subscribe to access all $name content.',
  );
}

/// Tracks tease usage for a specific feature
class TeaseTracker {
  int _actionCount = 0;
  DateTime? _startTime;
  final TeaseConfig config;
  
  TeaseTracker(this.config);
  
  /// Record an action (block stacked, piece dropped, etc.)
  void recordAction() => _actionCount++;
  
  /// Start timing (for duration-based teases)
  void startTimer() => _startTime ??= DateTime.now();
  
  /// Check if tease limit has been reached
  bool get hasReachedLimit {
    // Check action limit
    if (config.maxActions != null && _actionCount >= config.maxActions!) {
      return true;
    }
    
    // Check duration limit
    if (config.maxDuration != null && _startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!);
      if (elapsed >= config.maxDuration!) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Get remaining actions (for display)
  int? get remainingActions {
    if (config.maxActions == null) return null;
    return (config.maxActions! - _actionCount).clamp(0, config.maxActions!);
  }
  
  /// Get remaining duration (for display)
  Duration? get remainingDuration {
    if (config.maxDuration == null || _startTime == null) return null;
    final elapsed = DateTime.now().difference(_startTime!);
    final remaining = config.maxDuration! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  /// Reset the tracker
  void reset() {
    _actionCount = 0;
    _startTime = null;
  }
}

/// Shows a soft paywall prompt when the tease limit is reached
class PremiumPrompt extends StatelessWidget {
  final TeaseConfig config;
  final VoidCallback? onDismiss;
  
  const PremiumPrompt({
    super.key,
    required this.config,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colours.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colours.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              size: 32,
              color: Color(0xFF00B894),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            "You're getting the hang of it!",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colours.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Message
          Text(
            config.message ?? 'Subscribe to unlock unlimited access to all features.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colours.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(); // Close bottom sheet
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaywallScreen(
                      featureName: config.featureName,
                      teaseMessage: config.message,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Unlock Everything',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Maybe later
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: Text(
              'Maybe Later',
              style: TextStyle(
                color: colours.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Helper function to show the premium prompt as a bottom sheet
Future<void> showPremiumPrompt(BuildContext context, TeaseConfig config, {VoidCallback? onDismiss}) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => PremiumPrompt(config: config, onDismiss: onDismiss),
  );
}

/// Check if user is premium, if not show paywall
Future<bool> checkPremiumAccess(BuildContext context, {String? featureName}) async {
  final subscriptionService = SubscriptionService();
  
  if (subscriptionService.isPremium) {
    return true;
  }
  
  // Show paywall and wait for result
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => PaywallScreen(featureName: featureName),
    ),
  );
  
  return result == true;
}

/// Widget that gates content behind premium
class PremiumGate extends StatelessWidget {
  final Widget child;
  final Widget? lockedChild;
  final String featureName;
  
  const PremiumGate({
    super.key,
    required this.child,
    this.lockedChild,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    final subscriptionService = SubscriptionService();
    
    if (subscriptionService.isPremium) {
      return child;
    }
    
    return lockedChild ?? GestureDetector(
      onTap: () => checkPremiumAccess(context, featureName: featureName),
      child: Stack(
        children: [
          // Blurred/dimmed content preview
          Opacity(
            opacity: 0.5,
            child: IgnorePointer(child: child),
          ),
          // Lock overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white54,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
