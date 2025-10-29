import 'package:flutter/material.dart';

/// ZIMKit internal screen util configuration
/// Design size based on iOS design specs
class ZIMKitScreenUtilConfig {
  /// Design size for responsive layout
  /// Based on iOS design specs: 375 x 667 (iPhone 6/7/8 logical pixels)
  ///
  // 375 x 667 (iPhone 8 尺寸，正好是 750x1334 的一半)
  // 414 x 896 (iPhone 11 Pro Max)
  // 360 x 640 (常见 Android 尺寸)
  // 375 x 667 (iPhone 6/7/8)
  // 430 x 932 (iPhone 12 Pro Max)
  // 390 x 844 (iPhone 12 Pro)
  // 375 x 812 (iPhone 12)
  // 360 x 780 (iPhone 12 mini)
  static const Size designSize = Size(414, 896);
}
