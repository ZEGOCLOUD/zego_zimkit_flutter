import 'package:flutter/material.dart';

/// Configuration class for ZIMKitMessageListView
class ZIMKitMessageListConfigs {
  const ZIMKitMessageListConfigs({
    this.scrollController,
    this.inputFocusNode,
  });

  /// Scroll controller for message list
  final ScrollController? scrollController;

  /// Input focus node
  final FocusNode? inputFocusNode;

  ZIMKitMessageListConfigs copyWith({
    ScrollController? scrollController,
    FocusNode? inputFocusNode,
  }) {
    return ZIMKitMessageListConfigs(
      scrollController: scrollController ?? this.scrollController,
      inputFocusNode: inputFocusNode ?? this.inputFocusNode,
    );
  }
}
