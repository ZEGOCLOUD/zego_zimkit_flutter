import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/input/configs.dart';

/// Configuration class for ZIMKitMessageListPage
class ZIMKitMessageListPageConfigs {
  const ZIMKitMessageListPageConfigs({
    this.messageInput,
    this.messageListScrollController,
    this.inputFocusNode,
  });

  /// message input configs
  final ZIMKitMessageInputConfigs? messageInput;

  /// Message list scroll controller
  final ScrollController? messageListScrollController;

  /// Input focus node
  final FocusNode? inputFocusNode;
}
