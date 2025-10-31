import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';

typedef ZIMKitMessageInputMessageSentEvent = void Function(
  ZIMKitMessage message,
);
typedef ZIMKitMessageInputPreMessageSendingEvent = FutureOr<ZIMKitMessage>
    Function(
  ZIMKitMessage message,
);
typedef ZIMKitMessageInputMediaFilesPickedEvent = void Function(
  BuildContext context,
  List<ZIMKitPlatformFile> files,
  Function defaultAction,
);

/// Events class for ZIMKitMessageInput
class ZIMKitMessageInputEvents {
  const ZIMKitMessageInputEvents({
    this.onMessageSent,
    this.preMessageSending,
    this.onMediaFilesPicked,
    this.onReplyCancelled,
    this.onTextFieldTap,
  });

  /// Called when a message is sent
  final ZIMKitMessageInputMessageSentEvent? onMessageSent;

  /// Called before a message is sent
  final ZIMKitMessageInputPreMessageSendingEvent? preMessageSending;

  /// Called when media files are picked
  final ZIMKitMessageInputMediaFilesPickedEvent? onMediaFilesPicked;

  /// Called when reply is cancelled
  final VoidCallback? onReplyCancelled;

  /// [onTextFieldTap] Callback when text field is tapped
  final VoidCallback? onTextFieldTap;

  /// Create a copy of this events object with some fields replaced
  ZIMKitMessageInputEvents copyWith({
    ZIMKitMessageInputMessageSentEvent? onMessageSent,
    ZIMKitMessageInputPreMessageSendingEvent? preMessageSending,
    ZIMKitMessageInputMediaFilesPickedEvent? onMediaFilesPicked,
    VoidCallback? onReplyCancelled,
    VoidCallback? onCallTap,
    VoidCallback? onTextFieldTap,
  }) {
    return ZIMKitMessageInputEvents(
      onMessageSent: onMessageSent ?? this.onMessageSent,
      preMessageSending: preMessageSending ?? this.preMessageSending,
      onMediaFilesPicked: onMediaFilesPicked ?? this.onMediaFilesPicked,
      onReplyCancelled: onReplyCancelled ?? this.onReplyCancelled,
      onTextFieldTap: onTextFieldTap ?? this.onTextFieldTap,
    );
  }
}
