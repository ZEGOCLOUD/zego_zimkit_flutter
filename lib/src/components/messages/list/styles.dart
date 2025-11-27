import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';

/// Style/UI builders class for ZIMKitMessageListView
class ZIMKitMessageListStyles {
  const ZIMKitMessageListStyles({
    this.theme,
    this.itemBuilder,
    this.messageContentBuilder,
    this.avatarBuilder,
    this.statusBuilder,
    this.backgroundBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  /// Theme data
  final ThemeData? theme;

  /// Item builder
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? itemBuilder;

  /// Message content builder
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? messageContentBuilder;

  /// Avatar builder
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? avatarBuilder;

  /// Status builder
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? statusBuilder;

  /// Background builder
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? backgroundBuilder;

  /// Loading state builder
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? loadingBuilder;

  /// Error state builder
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? errorBuilder;

  /// Create a copy of this style object with some fields replaced
  ZIMKitMessageListStyles copyWith({
    ThemeData? theme,
    InputDecoration? inputDecoration,
    BoxDecoration? inputBackgroundDecoration,
    EdgeInsetsGeometry? containerPadding,
    Decoration? containerDecoration,
    Widget? sendButtonWidget,
    Widget? pickMediaButtonWidget,
    Widget? pickFileButtonWidget,
  }) {
    return ZIMKitMessageListStyles(
      theme: theme ?? this.theme,
      itemBuilder: itemBuilder ?? this.itemBuilder,
      messageContentBuilder:
          messageContentBuilder ?? this.messageContentBuilder,
      avatarBuilder: avatarBuilder ?? this.avatarBuilder,
      statusBuilder: statusBuilder ?? this.statusBuilder,
      backgroundBuilder: backgroundBuilder ?? this.backgroundBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
    );
  }
}
