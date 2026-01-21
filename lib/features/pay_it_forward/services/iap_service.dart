import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseOption {
  final String productId;
  final String price;
  final String description;
  final String duration;

  PurchaseOption({
    required this.productId,
    required this.price,
    required this.description,
    required this.duration,
  });
}

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs - you'll need to set these up in App Store Connect
  static const String monthlyProductId = 'com.ocean.darrengalvin.monthly';
  static const String quarterlyProductId = 'com.ocean.darrengalvin.quarterly';
  static const String yearlyProductId = 'com.ocean.darrengalvin.yearly';
  
  static const Set<String> _productIds = {
    monthlyProductId,
    quarterlyProductId,
    yearlyProductId,
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
        PurchaseOption(
          productId: monthlyProductId,
          price: '£5',
          description: '1 month for someone deployed',
          duration: '1 month',
        ),
        PurchaseOption(
          productId: quarterlyProductId,
          price: '£15',
          description: '3 months for a mate who needs it',
          duration: '3 months',
        ),
        PurchaseOption(
          productId: yearlyProductId,
          price: '£50',
          description: '1 year for someone transitioning out',
          duration: '1 year',
        ),
      ];
    }

    await _loadProducts();

    return _products.map((product) {
      String description;
      String duration;
      
      switch (product.id) {
        case monthlyProductId:
          description = '1 month for someone deployed';
          duration = '1 month';
          break;
        case quarterlyProductId:
          description = '3 months for a mate who needs it';
          duration = '3 months';
          break;
        case yearlyProductId:
          description = '1 year for someone transitioning out';
          duration = '1 year';
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
      );
    }).toList();
  }

  Future<bool> purchase(String productId) async {
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
      final bool success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      
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

