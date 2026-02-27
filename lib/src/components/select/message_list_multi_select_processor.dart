import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:zego_zimkit/src/components/messages/defines.dart';
import 'package:zego_zimkit/src/defines.dart';

/// Processor for handling multi-select mode in message list
///
/// Manages the state of selected messages and provides methods for
/// entering/exiting multi-select mode and selecting/deselecting messages.
class ZIMKitMessageListMultiSelectProcessor {
  /// Multi-select mode notifier for external control
  ValueNotifier<ZIMKitMessageListMultiModeData> modeNotifier =
      ValueNotifier<ZIMKitMessageListMultiModeData>(
          ZIMKitMessageListMultiModeData(
    isMultiMode: false,
  ));

  /// selected message notifier
  final ValueNotifier<Set<ZIMKitMessage>> selectedMessagesNotifier =
      ValueNotifier<Set<ZIMKitMessage>>({});

  Set<ZIMKitMessage> get selectedMessages => selectedMessagesNotifier.value;

  void appleMultiSelect(ZIMKitMessage initialMessage) {
    modeNotifier.value = ZIMKitMessageListMultiModeData(
      isMultiMode: true,
      initialMessage: initialMessage,
    );
  }

  void cancelMultiSelect() {
    modeNotifier.value = ZIMKitMessageListMultiModeData(
      isMultiMode: false,
    );
  }

  void clearSelectedMessage() {
    selectedMessagesNotifier.value = {};
  }

  void removeSelectedMessage(ZIMKitMessage message) {
    selectedMessagesNotifier.value = Set.from(selectedMessagesNotifier.value)
      ..remove(message);
  }

  void addSelectedMessage(ZIMKitMessage message) {
    selectedMessagesNotifier.value = {
      ...selectedMessagesNotifier.value,
      message,
    };
  }

  void _onMultiSelectModeChanged() {
    if (modeNotifier.value.isMultiMode) {
      clearSelectedMessage();

      if (modeNotifier.value.initialMessage != null) {
        addSelectedMessage(
          modeNotifier.value.initialMessage!,
        );
      }
    } else {
      clearSelectedMessage();
    }
  }

  factory ZIMKitMessageListMultiSelectProcessor() => instance;
  static final ZIMKitMessageListMultiSelectProcessor instance =
      ZIMKitMessageListMultiSelectProcessor._internal();
  ZIMKitMessageListMultiSelectProcessor._internal() {
    modeNotifier.addListener(_onMultiSelectModeChanged);
  }
}
