import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';

/// Style/UI builders class for ZIMKitConversationListView
class ZIMKitConversationListStyles {
  const ZIMKitConversationListStyles({
    this.theme,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.lastMessageTimeBuilder,
    this.lastMessageBuilder,
    this.itemBuilder,
  });

  /// Theme data
  final ThemeData? theme;

  /// Error state builder
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? errorBuilder;

  /// Empty state builder
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? emptyBuilder;

  /// Loading state builder
  final Widget Function(
    BuildContext context,
    Widget defaultWidget,
  )? loadingBuilder;

  /// Last message time builder
  final Widget Function(
    BuildContext context,
    DateTime? messageTime,
    Widget defaultWidget,
  )? lastMessageTimeBuilder;

  /// Last message builder
  final Widget Function(
    BuildContext context,
    ZIMKitMessage? message,
    Widget defaultWidget,
  )? lastMessageBuilder;

  /// Item builder
  final Widget Function(
    BuildContext context,
    ZIMKitConversation conversation,
    Widget defaultWidget,
  )? itemBuilder;
}
