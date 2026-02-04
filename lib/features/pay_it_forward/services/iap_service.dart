import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/services/analytics_service.dart';

class PurchaseOption {
  final String productId;
  final String price;
  final String description;
  final String duration;
  final bool isSubscription;
  final bool isRecommended;

  PurchaseOption({
    required this.productId,
    required this.price,
    required this.description,
    required this.duration,
    this.isSubscription = false,
    this.isRecommended = false,
  });
}

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs - you'll need to set these up in App Store Connect
  // One-time purchases
  static const String onetime5Id = 'com.ocean.darrengalvin.onetime.5';
  static const String onetime10Id = 'com.ocean.darrengalvin.onetime.10';
  static const String onetime25Id = 'com.ocean.darrengalvin.onetime.25';
  static const String onetime50Id = 'com.ocean.darrengalvin.onetime.50';
  static const String onetime100Id = 'com.ocean.darrengalvin.onetime.100';
  
  // Subscriptions
  static const String monthly5SubId = 'com.ocean.darrengalvin.sub.monthly5';
  static const String monthly10SubId = 'com.ocean.darrengalvin.sub.monthly10';
  
  static const Set<String> _productIds = {
    // One-time
    onetime5Id,
    onetime10Id,
    onetime25Id,
    onetime50Id,
    onetime100Id,
    // Subscriptions
    monthly5SubId,
    monthly10SubId,
  };

  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  IAPService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('⚠️ In-App Purchase not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        debugPrint('❌ Purchase stream error: $error');
      },
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
    
    if (response.error != null) {
      debugPrint('❌ Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    debugPrint('✅ Loaded ${_products.length} products');
  }

  Future<List<PurchaseOption>> loadProducts() async {
    if (!_isAvailable) {
      // Return mock data for development/testing
      return [
        // One-time purchases
        PurchaseOption(
          productId: onetime5Id,
          price: '£5',
          description: 'Cover 1 person',
          duration: 'One-time',
          isSubscription: false,
        ),
        PurchaseOption(
          productId: onetime10Id,
          price: '£10',
          description: 'Cover 2 people',
          duration: 'One-time',
          isSubscription: false,
        ),
        PurchaseOption(
          productId: onetime25Id,
          price: '£25',
          description: 'Cover 5 people',
          duration: 'One-time',
          isSubscription: false,
          isRecommended: true,
        ),
        PurchaseOption(
          productId: onetime50Id,
          price: '£50',
          description: 'Cover 10 people',
          duration: 'One-time',
          isSubscription: false,
        ),
        PurchaseOption(
          productId: onetime100Id,
          price: '£100',
          description: 'Cover 20 people',
          duration: 'One-time',
          isSubscription: false,
        ),
        // Subscriptions
        PurchaseOption(
          productId: monthly5SubId,
          price: '£5/month',
          description: 'Cover 1 person every month',
          duration: 'Monthly',
          isSubscription: true,
          isRecommended: true,
        ),
        PurchaseOption(
          productId: monthly10SubId,
          price: '£10/month',
          description: 'Cover 2 people every month',
          duration: 'Monthly',
          isSubscription: true,
        ),
      ];
    }

    await _loadProducts();

    return _products.map((product) {
      String description;
      String duration;
      bool isSubscription = false;
      bool isRecommended = false;
      
      switch (product.id) {
        // One-time
        case onetime5Id:
          description = 'Cover 1 person';
          duration = 'One-time';
          break;
        case onetime10Id:
          description = 'Cover 2 people';
          duration = 'One-time';
          break;
        case onetime25Id:
          description = 'Cover 5 people';
          duration = 'One-time';
          isRecommended = true;
          break;
        case onetime50Id:
          description = 'Cover 10 people';
          duration = 'One-time';
          break;
        case onetime100Id:
          description = 'Cover 20 people';
          duration = 'One-time';
          break;
        // Subscriptions
        case monthly5SubId:
          description = 'Cover 1 person every month';
          duration = 'Monthly';
          isSubscription = true;
          isRecommended = true;
          break;
        case monthly10SubId:
          description = 'Cover 2 people every month';
          duration = 'Monthly';
          isSubscription = true;
          break;
        default:
          description = 'Support access';
          duration = 'Unknown';
      }

      return PurchaseOption(
        productId: product.id,
        price: product.price,
        description: description,
        duration: duration,
        isSubscription: isSubscription,
        isRecommended: isRecommended,
      );
    }).toList();
  }

  Future<bool> purchase(String productId, {required bool isSubscription}) async {
    if (!_isAvailable) {
      debugPrint('⚠️ IAP not available - simulating successful purchase');
      // For development/testing, return success after a delay
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found: $productId'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      final bool success;
      
      if (isSubscription) {
        // For subscriptions, use buyNonConsumable
        success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // For one-time purchases, use buyConsumable
        success = await _iap.buyConsumable(
          purchaseParam: purchaseParam,
          autoConsume: true,
        );
      }
      
      debugPrint(success ? '✅ Purchase initiated' : '❌ Purchase failed');
      return success;
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
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
    debugPrint('✅ Purchase successful: ${purchaseDetails.productID}');
    
    // Extract amount from product ID for analytics
    double amount = 0;
    final productId = purchaseDetails.productID;
    if (productId.contains('5')) amount = 5;
    if (productId.contains('10')) amount = 10;
    if (productId.contains('25')) amount = 25;
    if (productId.contains('50')) amount = 50;
    if (productId.contains('100')) amount = 100;
    
    // Track anonymous purchase in analytics
    // This records: anonymous device_id + product + amount + timestamp
    // It does NOT record: name, email, or any identifying info
    AnalyticsService().trackPurchase(productId, amount);
    
    debugPrint('🎉 Someone just covered another person! (Anonymous)');
  }

  void dispose() {
    _subscription?.cancel();
  }
}

