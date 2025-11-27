import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';

/// Configuration class for ZIMKitConversationListView
class ZIMKitConversationListConfigs {
  const ZIMKitConversationListConfigs({
    this.filter,
    this.sorter,
    this.scrollController,
  });

  /// Filter function to filter conversation list
  final List<ZIMKitConversationNotifier> Function(
    BuildContext context,
    List<ZIMKitConversationNotifier>,
  )? filter;

  /// Sorter function to sort conversation list
  final List<ZIMKitConversationNotifier> Function(
    BuildContext context,
    List<ZIMKitConversationNotifier>,
  )? sorter;

  /// Custom scroll controller
  final ScrollController? scrollController;
}
