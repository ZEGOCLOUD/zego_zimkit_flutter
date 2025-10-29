import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/defines.dart';
import 'package:zego_zimkit/src/defines.dart';

typedef ZIMKitMessageListPressedEvent = void Function(
  BuildContext context,
  ZIMKitMessage message,
  Function defaultAction,
);

typedef ZIMKitMessageListLongPressedEvent = void Function(
  BuildContext context,
  LongPressStartDetails details,
  ZIMKitMessage message,
  Function defaultAction,
);
typedef ZIMKitMessageListMultiSelectChangedEvent = void Function(
  bool enabled,
  Set<ZIMKitMessage> selectedMessages,
);
typedef ZIMKitMessageListReplyMessageTapEvent = void Function(
  String repliedMessageID,
);
typedef ZIMKitMessageListReplyMessageEvent = void Function(
  ZIMKitMessage message,
);

/// Events class for ZIMKitMessageListView
class ZIMKitMessageListEvents {
  const ZIMKitMessageListEvents({
    this.onPressed,
    this.onLongPress,
    this.onMultiSelectChanged,
    this.onReplyMessageTap,
    this.onReplyMessage,
  });

  /// Called when message item is pressed
  final ZIMKitMessageListPressedEvent? onPressed;

  /// Called when message item is long pressed
  final ZIMKitMessageListLongPressedEvent? onLongPress;

  /// Called when multi-select mode changes
  final ZIMKitMessageListMultiSelectChangedEvent? onMultiSelectChanged;

  /// Called when reply message is tapped
  final ZIMKitMessageListReplyMessageTapEvent? onReplyMessageTap;

  /// Called when user wants to reply to a message
  final ZIMKitMessageListReplyMessageEvent? onReplyMessage;

  ZIMKitMessageListEvents copyWith({
    ZIMKitMessageListPressedEvent? onPressed,
    ZIMKitMessageListLongPressedEvent? onLongPress,
    ZIMKitMessageListMultiSelectChangedEvent? onMultiSelectChanged,
    ZIMKitMessageListReplyMessageTapEvent? onReplyMessageTap,
    ZIMKitMessageListReplyMessageEvent? onReplyMessage,
  }) {
    return ZIMKitMessageListEvents(
      onPressed: onPressed ?? this.onPressed,
      onLongPress: onLongPress ?? this.onLongPress,
      onMultiSelectChanged: onMultiSelectChanged ?? this.onMultiSelectChanged,
      onReplyMessageTap: onReplyMessageTap ?? this.onReplyMessageTap,
      onReplyMessage: onReplyMessage ?? this.onReplyMessage,
    );
  }
}
