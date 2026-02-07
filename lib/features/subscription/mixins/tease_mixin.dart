import 'package:flutter/material.dart';
import '../../../core/services/subscription_service.dart';
import '../widgets/premium_gate.dart';

/// Mixin to easily add tease functionality to any StatefulWidget
/// 
/// Usage:
/// ```dart
/// class _MyGameScreenState extends State<MyGameScreen> with TeaseMixin {
///   @override
///   TeaseConfig get teaseConfig => TeaseConfig.game('Block Stacking');
///   
///   void onBlockStacked() {
///     recordTeaseAction(); // Call this when user does an action
///     if (hasReachedTeaseLimit) {
///       showTeasePaywall(); // Shows the friendly paywall
///       return;
///     }
///     // Continue with normal game logic
///   }
/// }
/// ```
mixin TeaseMixin<T extends StatefulWidget> on State<T> {
  late final TeaseTracker _teaseTracker;
  late final SubscriptionService _subscriptionService;
  
  /// Override this to provide the tease configuration
  TeaseConfig get teaseConfig;
  
  /// Whether the user has premium access
  bool get isPremium => _subscriptionService.isPremium;
  
  /// Whether the tease limit has been reached
  bool get hasReachedTeaseLimit => !isPremium && _teaseTracker.hasReachedLimit;
  
  /// Remaining actions before paywall (null if no limit)
  int? get remainingTeaseActions => isPremium ? null : _teaseTracker.remainingActions;
  
  /// Remaining duration before paywall (null if no limit)
  Duration? get remainingTeaseDuration => isPremium ? null : _teaseTracker.remainingDuration;
  
  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService();
    _teaseTracker = TeaseTracker(teaseConfig);
  }
  
  /// Call this when the user performs an action (drops a block, etc.)
  void recordTeaseAction() {
    if (isPremium) return;
    _teaseTracker.recordAction();
  }
  
  /// Call this when starting a timed feature (audio, gameplay)
  void startTeaseTimer() {
    if (isPremium) return;
    _teaseTracker.startTimer();
  }
  
  /// Reset the tease tracker (e.g., when starting a new game)
  void resetTeaseTracker() {
    _teaseTracker.reset();
  }
  
  /// Show the friendly paywall prompt
  Future<void> showTeasePaywall({VoidCallback? onDismiss}) {
    return showPremiumPrompt(context, teaseConfig, onDismiss: onDismiss);
  }
  
  /// Check if user can continue, show paywall if limit reached
  /// Returns true if user can continue, false if blocked
  bool checkTeaseAndContinue() {
    if (isPremium) return true;
    
    if (_teaseTracker.hasReachedLimit) {
      showTeasePaywall();
      return false;
    }
    
    return true;
  }
}

/// Extension to make it easy to check premium status anywhere
extension PremiumCheck on BuildContext {
  bool get isPremium => SubscriptionService().isPremium;
  
  Future<bool> requirePremium({String? featureName}) {
    return checkPremiumAccess(this, featureName: featureName);
  }
}
