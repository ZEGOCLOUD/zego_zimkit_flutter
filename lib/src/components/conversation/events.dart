import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/defines.dart';

/// Events class for ZIMKitConversationListView
class ZIMKitConversationListEvents {
  const ZIMKitConversationListEvents({
    this.onPressed,
    this.onLongPress,
  });

  /// Called when conversation item is pressed
  final void Function(
    BuildContext context,
    ZIMKitConversation conversation,
    Function defaultAction,
  )? onPressed;

  /// Called when conversation item is long pressed
  final void Function(
    BuildContext context,
    ZIMKitConversation conversation,
    LongPressStartDetails longPressDetails,
    Function defaultAction,
  )? onLongPress;
}
