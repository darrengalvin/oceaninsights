import 'package:flutter/material.dart';

/// Consistent spacing values throughout the app
class AppSpacing {
  AppSpacing._();
  
  // Base spacing unit
  static const double unit = 4.0;
  
  // Named spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(20.0);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(vertical: 20.0);
  
  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(24.0);
  
  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  
  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
}

/// Extension for easy SizedBox creation
extension SpacingExtension on num {
  SizedBox get vSpace => SizedBox(height: toDouble());
  SizedBox get hSpace => SizedBox(width: toDouble());
}



