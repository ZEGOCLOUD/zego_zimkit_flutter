import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/audio/style.dart';
import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util_config.dart';
import 'package:zego_zimkit/src/services/services.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// if your text flows is right to left:
///
/// ``` dart
/// Directionality(
///   textDirection: TextDirection.rtl,
///   child: ZIMKitMessageListPage(
///
///   ),
/// );
/// ```
class ZIMKitMessageListPage extends StatefulWidget {
  const ZIMKitMessageListPage({
    super.key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.config,
    this.style,
    this.events,
  });

  /// this page's conversationID
  final String conversationID;

  /// this page's conversationType
  final ZIMConversationType conversationType;

  /// Configuration for message list page
  final ZIMKitMessageListPageConfigs? config;

  /// Style for message list page
  final ZIMKitMessageListPageStyle? style;

  /// events.
  final ZIMKitMessageListPageEvent? events;

  @override
  State<ZIMKitMessageListPage> createState() => _ZIMKitMessageListPageState();
}

/// @nodoc
class _ZIMKitMessageListPageState extends State<ZIMKitMessageListPage> {
  final recordStatus = ZIMKitRecordStatus();
  final _closePanelNotifier = ValueNotifier<int>(0);
  final _repliedMessageNotifier = ValueNotifier<ZIMKitMessage?>(null);

  final defaultInputFocusNode = FocusNode();
  final defaultListScrollController = ScrollController();

  FocusNode get inputFocusNode =>
      widget.config?.inputFocusNode ?? defaultInputFocusNode;

  ScrollController get listScrollController =>
      widget.config?.messageListScrollController ?? defaultListScrollController;

  @override
  void initState() {
    super.initState();

    recordStatus.register();
  }

  @override
  void dispose() {
    recordStatus.unregister();
    _repliedMessageNotifier.dispose();

    // Dispose default focus node if no custom one provided
    if (widget.config?.inputFocusNode == null) {
      defaultInputFocusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZIMScreenUtilInit(
      designSize: ZIMKitScreenUtilConfig.designSize,
      builder: (context, child) {
        return Theme(
          data: widget.style?.theme ?? Theme.of(context),
          child: Scaffold(
            appBar: widget.style?.appBarBuilder?.call(
                  context,
                  buildAppBar(context),
                ) ??
                buildAppBar(context),
            body: SafeArea(
              child: ValueListenableBuilder<ZIMKitMessageListMultiModeData>(
                valueListenable:
                    ZIMKitMessageListMultiSelectProcessor().modeNotifier,
                builder: (context, multiSelectModeData, child) {
                  return Stack(
                    children: [
                      messageListView(multiSelectModeData),
                      if (!multiSelectModeData.isMultiMode) ...[
                        messageInput(),
                        messageRecordLocker(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Set the message to reply to
  void setReplyMessage(ZIMKitMessage? message) {
    _repliedMessageNotifier.value = message;
    if (message != null) {
      // Focus on input when replying
      inputFocusNode.requestFocus();
    }
  }

  /// Scroll to a specific message by messageID
  Future<void> scrollToMessage(String messageIDStr) async {
    debugPrint('[ZIMKit] scrollToMessage called with messageID: $messageIDStr');

    // Parse messageID from String to int
    final int? messageID = int.tryParse(messageIDStr);
    if (messageID == null) {
      debugPrint('[ZIMKit] Invalid messageID: $messageIDStr');
      return;
    }

    try {
      // Get the message list notifier
      final messageListNotifier = await ZIMKit().getMessageListNotifier(
        widget.conversationID,
        widget.conversationType,
      );

      // Get the current message list
      final messageList = messageListNotifier.value;

      // Find the index of the target message
      int targetIndex = -1;
      for (int i = 0; i < messageList.length; i++) {
        if (messageList[i].value.info.messageID == messageID) {
          targetIndex = i;
          break;
        }
      }

      if (targetIndex == -1) {
        debugPrint(
            '[ZIMKit] Message with ID $messageID not found in current list');
        // Show a toast to indicate message not found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ZIMKitCore.instance.innerText.messageNotFoundToast),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Calculate the scroll position
      // Since ListView.builder uses reverse: false by default in message_list.dart,
      // we need to scroll to the item position
      // Each item has variable height, so we use scrollToIndex approach

      // Use a simple approach: calculate approximate position
      // This is a simplified implementation - for better accuracy,
      // you would need to track actual item heights
      if (listScrollController.hasClients) {
        // Get the total scroll extent
        final maxScrollExtent = listScrollController.position.maxScrollExtent;
        final minScrollExtent = listScrollController.position.minScrollExtent;

        // Calculate approximate position (assuming uniform item height)
        // This is a rough estimate - actual implementation may vary
        final totalItems = messageList.length;
        final approximatePosition = minScrollExtent +
            (maxScrollExtent - minScrollExtent) * (targetIndex / totalItems);

        // Animate to the calculated position
        await listScrollController.animateTo(
          approximatePosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        debugPrint(
            '[ZIMKit] Scrolled to message at index $targetIndex (position: $approximatePosition)');
      } else {
        debugPrint('[ZIMKit] ScrollController has no clients');
      }
    } catch (e) {
      debugPrint('[ZIMKit] Error scrolling to message: $e');
    }
  }

  Widget messageRecordLocker() {
    return Positioned(
      bottom: widget.config?.messageInputHeight ??
          ZIMKitMessageStyle.inputHeight - 5,
      right: 5,
      child: SizedBox(
        width: ZIMKitRecordStyle.lockerIconSize,
        height: ZIMKitRecordStyle.lockerIconSize,
        child: ZIMKitRecordLocker(processor: recordStatus),
      ),
    );
  }

  Widget messageListView(ZIMKitMessageListMultiModeData multiModeData) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: multiModeData.isMultiMode
          ? 0
          : (widget.config?.messageInputHeight ??
              ZIMKitMessageStyle.inputHeight),
      child: GestureDetector(
        onTap: () {
          // Hide keyboard when tapping message list
          inputFocusNode.unfocus();
          // Close emoji/more panels when tapping message list
          _closePanelNotifier.value++;
        },
        child: ZIMKitMessageListView(
          key: ValueKey(
            'ZIMKitMessageListView:${Object.hash(widget.conversationID, widget.conversationType)}',
          ),
          conversationID: widget.conversationID,
          conversationType: widget.conversationType,
          config: ZIMKitMessageListConfigs(
            scrollController: listScrollController,
            inputFocusNode: inputFocusNode,
          ),
          events:
              (widget.events?.messageListEvents ?? ZIMKitMessageListEvents())
                  .copyWith(
            onReplyMessageTap: scrollToMessage,
            onReplyMessage: setReplyMessage,
          ),
          style: (widget.style?.messageListStyles ?? ZIMKitMessageListStyles())
              .copyWith(
            theme: widget.style?.theme,
          ),
        ),
      ),
    );
  }

  Widget messageInput() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ValueListenableBuilder<ZIMKitMessage?>(
        valueListenable: _repliedMessageNotifier,
        builder: (context, repliedMessage, child) {
          return ZIMKitMessageInput(
            recordStatus: recordStatus,
            conversationID: widget.conversationID,
            conversationType: widget.conversationType,
            config: (widget.config?.messageInputConfigs ??
                    const ZIMKitMessageInputConfigs())
                .copyWith(
              inputFocusNode: inputFocusNode,
              listScrollController: listScrollController,
              closePanelNotifier: _closePanelNotifier,
              repliedMessage: repliedMessage,
            ),
            events: (widget.events?.messageInputEvents ??
                    const ZIMKitMessageInputEvents())
                .copyWith(
              onReplyCancelled: () {
                _repliedMessageNotifier.value = null;
              },
            ),
            style: (widget.style?.messageInputStyles ??
                    const ZIMKitMessageInputStyles())
                .copyWith(
              theme: widget.style?.theme,
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: ValueListenableBuilder<ZIMKitConversation>(
        valueListenable: ZIMKit().getConversation(
          widget.conversationID,
          widget.conversationType,
        ),
        builder: (context, conversation, child) {
          const avatarNameFontSize = 16.0;
          return Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                child: ZIMKitAvatar(
                  userID: conversation.id,
                  width: 80.zW,
                  height: 80.zH,
                ),
              ),
              child!,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: const TextStyle(fontSize: avatarNameFontSize),
                    overflow: TextOverflow.clip,
                  ),
                  // Text(conversation.id,
                  //     style: const TextStyle(fontSize: 12),
                  //     overflow: TextOverflow.clip)
                ],
              ),
            ],
          );
        },
        child: SizedBox(width: (20 * 0.75).zW),
      ),
      actions: widget.style?.appBarActions,
    );
  }
}
