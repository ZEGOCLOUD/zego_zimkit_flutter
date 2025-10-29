import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/input/configs.dart';

/// Configuration class for ZIMKitMessageListPage
class ZIMKitMessageListPageConfigs {
  const ZIMKitMessageListPageConfigs({
    this.messageInputConfigs,
    this.messageInputHeight,
    this.messageListScrollController,
    this.inputFocusNode,
  });

  final ZIMKitMessageInputConfigs? messageInputConfigs;

  /// Message input height
  final double? messageInputHeight;

  /// Message list scroll controller
  final ScrollController? messageListScrollController;

  /// Input focus node
  final FocusNode? inputFocusNode;
}
