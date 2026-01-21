import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  static const String oneTimeSmallId = 'com.ocean.darrengalvin.onetime.small';
  static const String oneTimeMediumId = 'com.ocean.darrengalvin.onetime.medium';
  static const String oneTimeLargeId = 'com.ocean.darrengalvin.onetime.large';
  
  // Subscriptions
  static const String monthlySubId = 'com.ocean.darrengalvin.sub.monthly';
  static const String yearlySubId = 'com.ocean.darrengalvin.sub.yearly';
  
  static const Set<String> _productIds = {
    // One-time
    oneTimeSmallId,
    oneTimeMediumId,
    oneTimeLargeId,
    // Subscriptions
    monthlySubId,
    yearlySubId,
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
          productId: oneTimeSmallId,
          price: '£5',
          description: 'Cover 1 person',
          duration: 'One-time',
          isSubscription: false,
        ),
        PurchaseOption(
          productId: oneTimeMediumId,
          price: '£15',
          description: 'Cover 3 people',
          duration: 'One-time',
          isSubscription: false,
        ),
        PurchaseOption(
          productId: oneTimeLargeId,
          price: '£50',
          description: 'Cover 10 people',
          duration: 'One-time',
          isSubscription: false,
        ),
        // Subscriptions
        PurchaseOption(
          productId: monthlySubId,
          price: '£5/month',
          description: 'Cover 1 person every month',
          duration: 'Monthly',
          isSubscription: true,
          isRecommended: true,
        ),
        PurchaseOption(
          productId: yearlySubId,
          price: '£50/year',
          description: 'Cover 10 people per year',
          duration: 'Yearly',
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
        case oneTimeSmallId:
          description = 'Cover 1 person';
          duration = 'One-time';
          break;
        case oneTimeMediumId:
          description = 'Cover 3 people';
          duration = 'One-time';
          break;
        case oneTimeLargeId:
          description = 'Cover 10 people';
          duration = 'One-time';
          break;
        // Subscriptions
        case monthlySubId:
          description = 'Cover 1 person every month';
          duration = 'Monthly';
          isSubscription = true;
          isRecommended = true;
          break;
        case yearlySubId:
          description = 'Cover 10 people per year';
          duration = 'Yearly';
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
    
    // Here you would typically:
    // 1. Verify the purchase with your backend
    // 2. Grant access to another user
    // 3. Log the transaction
    
    // For now, we just log it
    debugPrint('🎉 Someone just covered another person!');
  }

  void dispose() {
    _subscription?.cancel();
  }
}

