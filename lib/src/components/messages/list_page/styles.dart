import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/input/styles.dart';
import 'package:zego_zimkit/src/components/messages/list/styles.dart';

/// Style/UI builders class for ZIMKitMessageListPage
class ZIMKitMessageListPageStyles {
  const ZIMKitMessageListPageStyles({
    this.theme,
    this.appBarBuilder,
    this.appBarActions,
    this.messageInput,
    this.messageList,
  });

  /// Theme data
  final ThemeData? theme;

  /// AppBar builder
  final AppBar? Function(BuildContext context, AppBar defaultAppBar)?
      appBarBuilder;

  /// AppBar actions
  final List<Widget>? appBarActions;

  final ZIMKitMessageInputStyles? messageInput;

  final ZIMKitMessageListStyles? messageList;
}
