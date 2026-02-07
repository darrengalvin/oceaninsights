import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Subscription status for the app
enum SubscriptionStatus {
  /// User has never subscribed
  none,
  /// User has an active subscription
  active,
  /// Subscription expired
  expired,
}

/// Manages premium subscription status with offline caching
class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs for App Store Connect
  static const String monthlySubId = 'com.belowthesurface.sub.monthly';
  static const String yearlySubId = 'com.belowthesurface.sub.yearly';
  
  static const Set<String> _productIds = {
    monthlySubId,
    yearlySubId,
  };

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  SubscriptionStatus _status = SubscriptionStatus.none;
  DateTime? _expiryDate;
  
  // Local cache keys
  static const String _boxName = 'subscription';
  static const String _keyStatus = 'status';
  static const String _keyExpiry = 'expiry';
  static const String _keyProductId = 'product_id';
  
  Box? _box;

  SubscriptionStatus get status => _status;
  bool get isPremium => _status == SubscriptionStatus.active;
  DateTime? get expiryDate => _expiryDate;
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  /// Initialize the subscription service
  Future<void> initialize() async {
    // Open local cache
    _box = await Hive.openBox(_boxName);
    
    // Load cached status first (for offline support)
    await _loadCachedStatus();
    
    // Then try to sync with App Store
    _isAvailable = await _iap.isAvailable();
    
    if (_isAvailable) {
      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) {
          debugPrint('❌ Purchase stream error: $error');
        },
      );

      await _loadProducts();
      await _restorePurchases();
    } else {
      debugPrint('⚠️ In-App Purchase not available - using cached status');
    }
    
    notifyListeners();
  }

  /// Load cached subscription status (works offline)
  Future<void> _loadCachedStatus() async {
    final statusStr = _box?.get(_keyStatus) as String?;
    final expiryStr = _box?.get(_keyExpiry) as String?;
    
    if (statusStr != null) {
      _status = SubscriptionStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => SubscriptionStatus.none,
      );
    }
    
    if (expiryStr != null) {
      _expiryDate = DateTime.tryParse(expiryStr);
      
      // Check if subscription has expired
      if (_expiryDate != null && _expiryDate!.isBefore(DateTime.now())) {
        // Give a 7-day grace period for offline users
        final graceEnd = _expiryDate!.add(const Duration(days: 7));
        if (DateTime.now().isAfter(graceEnd)) {
          _status = SubscriptionStatus.expired;
          await _saveStatus(SubscriptionStatus.expired, null);
        }
      }
    }
    
    debugPrint('📦 Loaded cached subscription: $_status (expires: $_expiryDate)');
  }

  /// Save subscription status to local cache
  Future<void> _saveStatus(SubscriptionStatus status, DateTime? expiry) async {
    _status = status;
    _expiryDate = expiry;
    
    await _box?.put(_keyStatus, status.name);
    if (expiry != null) {
      await _box?.put(_keyExpiry, expiry.toIso8601String());
    } else {
      await _box?.delete(_keyExpiry);
    }
    
    notifyListeners();
  }

  /// Load products from App Store
  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
    
    if (response.error != null) {
      debugPrint('❌ Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    debugPrint('✅ Loaded ${_products.length} subscription products');
  }

  /// Get subscription options for display
  List<SubscriptionOption> getSubscriptionOptions() {
    if (_products.isEmpty) {
      // Return default pricing for display (actual prices come from App Store)
      return [
        SubscriptionOption(
          productId: monthlySubId,
          title: 'Monthly',
          price: '£4.99',
          pricePerMonth: '£4.99/month',
          duration: 'month',
          savings: null,
        ),
        SubscriptionOption(
          productId: yearlySubId,
          title: 'Yearly',
          price: '£24.99',
          pricePerMonth: '£2.08/month',
          duration: 'year',
          savings: 'Save 58%',
          isRecommended: true,
        ),
      ];
    }

    return _products.map((product) {
      final isYearly = product.id == yearlySubId;
      return SubscriptionOption(
        productId: product.id,
        title: isYearly ? 'Yearly' : 'Monthly',
        price: product.price,
        pricePerMonth: isYearly 
            ? '${(double.tryParse(product.rawPrice.toString()) ?? 24.99) / 12}' 
            : product.price,
        duration: isYearly ? 'year' : 'month',
        savings: isYearly ? 'Save 58%' : null,
        isRecommended: isYearly,
      );
    }).toList();
  }

  /// Purchase a subscription
  Future<bool> purchase(String productId) async {
    if (!_isAvailable) {
      debugPrint('⚠️ IAP not available - simulating successful purchase for dev');
      // For development/testing
      await Future.delayed(const Duration(seconds: 1));
      await _saveStatus(
        SubscriptionStatus.active,
        DateTime.now().add(productId == yearlySubId 
            ? const Duration(days: 365) 
            : const Duration(days: 30)),
      );
      return true;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found: $productId'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      // Subscriptions are non-consumable
      final bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint(success ? '✅ Purchase initiated' : '❌ Purchase failed');
      return success;
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> _restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _iap.restorePurchases();
      debugPrint('✅ Restore purchases initiated');
    } catch (e) {
      debugPrint('❌ Restore error: $e');
    }
  }

  /// Manually trigger restore (for UI button)
  Future<bool> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('⚠️ IAP not available');
      return false;
    }
    
    try {
      await _iap.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      return false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('❌ Purchase error: ${purchaseDetails.error}');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    debugPrint('✅ Subscription activated: ${purchaseDetails.productID}');
    
    // Calculate expiry based on product
    final isYearly = purchaseDetails.productID == yearlySubId;
    final expiry = DateTime.now().add(
      isYearly ? const Duration(days: 365) : const Duration(days: 30),
    );
    
    // Save to local cache for offline access
    _saveStatus(SubscriptionStatus.active, expiry);
    _box?.put(_keyProductId, purchaseDetails.productID);
    
    debugPrint('🎉 Premium unlocked! Expires: $expiry');
  }

  void dispose() {
    _subscription?.cancel();
  }
}

/// Represents a subscription option for display
class SubscriptionOption {
  final String productId;
  final String title;
  final String price;
  final String pricePerMonth;
  final String duration;
  final String? savings;
  final bool isRecommended;

  SubscriptionOption({
    required this.productId,
    required this.title,
    required this.price,
    required this.pricePerMonth,
    required this.duration,
    this.savings,
    this.isRecommended = false,
  });
}
