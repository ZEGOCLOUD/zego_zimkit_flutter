import 'package:flutter/material.dart';

/// ZIMKit Style Configuration
///
/// Used to customize the visual style of ZIMKit, including colors, fonts, spacing, etc.
///
/// Example:
/// ```dart
/// ZIMKitStyle(
///   primaryColor: Colors.blue,
///   backgroundColor: Colors.white,
/// )
/// ```
class ZIMKitStyle {
  ZIMKitStyle({
    this.primaryColor,
    this.backgroundColor,
    this.textColor,
    this.secondaryTextColor,
    this.dividerColor,
    this.messageBubbleColor,
    this.receivedMessageBubbleColor,
    this.sentMessageBubbleColor,
  });

  /// Primary color
  final Color? primaryColor;

  /// Background color
  final Color? backgroundColor;

  /// Main text color
  final Color? textColor;

  /// Secondary text color
  final Color? secondaryTextColor;

  /// Divider color
  final Color? dividerColor;

  /// Message bubble color (general)
  final Color? messageBubbleColor;

  /// Received message bubble color
  final Color? receivedMessageBubbleColor;

  /// Sent message bubble color
  final Color? sentMessageBubbleColor;

  @override
  String toString() {
    return 'ZIMKitStyle{'
        'primaryColor:$primaryColor, '
        'backgroundColor:$backgroundColor, '
        'textColor:$textColor, '
        'secondaryTextColor:$secondaryTextColor, '
        'dividerColor:$dividerColor, '
        'messageBubbleColor:$messageBubbleColor, '
        'receivedMessageBubbleColor:$receivedMessageBubbleColor, '
        'sentMessageBubbleColor:$sentMessageBubbleColor, '
        '}';
  }
}
