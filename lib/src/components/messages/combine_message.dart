import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/components/messages/widgets/pointer.dart';
import 'package:zego_zimkit/src/components/messages/widgets/reactions.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Widget to display combine message (chat history)
class ZIMKitCombineMessage extends StatelessWidget {
  const ZIMKitCombineMessage({
    super.key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.onReplyMessageTap,
  });

  final ZIMKitMessage message;
  final void Function(
    BuildContext context,
    ZIMKitMessage message,
    Function defaultAction,
  )? onPressed;
  final void Function(
    BuildContext context,
    LongPressStartDetails details,
    ZIMKitMessage message,
    Function defaultAction,
  )? onLongPress;
  final void Function(String repliedMessageID)? onReplyMessageTap;

  @override
  Widget build(BuildContext context) {
    final combineMessage = message.zim as ZIMCombineMessage;

    return Flexible(
      child: GestureDetector(
        onTap: () => onPressed?.call(context, message, () {
          _openCombineMessageDetail(context);
        }),
        onLongPressStart: (details) =>
            onLongPress?.call(context, details, message, () {}),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message bubble
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                message.isMine
                    ? const SizedBox.shrink()
                    : ZIMKitTextMessagePointer(
                        messageType: message.type,
                        isMine: message.isMine,
                      ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                      minWidth: 200,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMine
                          ? ZIMKitMessageStyle.sentMessageBubbleColor(context)
                          : ZIMKitMessageStyle.receivedMessageBubbleColor,
                      borderRadius: BorderRadius.circular(12.zR),
                      boxShadow: message.isMine
                          ? null
                          : ZIMKitMessageStyle.getReceivedMessageBubbleShadow(),
                    ),
                    padding: EdgeInsets.all(12.zR),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          combineMessage.title,
                          style: TextStyle(
                            fontSize: 15.zSP,
                            fontWeight: FontWeight.w500,
                            color: message.isMine
                                ? ZIMKitMessageStyle.sentMessageTextColor
                                : ZIMKitMessageStyle.receivedMessageTextColor(
                                    context),
                          ),
                        ),
                        SizedBox(height: 10.zH),
                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            color: (message.isMine
                                    ? ZIMKitMessageStyle.sentMessageTextColor
                                    : ZIMKitMessageStyle
                                        .receivedMessageTextColor(context))
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Summary
                        Text(
                          combineMessage.summary,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: (message.isMine
                                    ? ZIMKitMessageStyle.sentMessageTextColor
                                    : ZIMKitMessageStyle
                                        .receivedMessageTextColor(context))
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        // Reactions inside bubble (like Android)
                        ZIMKitMessageReactionsWidget(
                          message: message,
                          isMine: message.isMine,
                          onReactionTap: (reactionType) async {
                            await _handleReactionTap(reactionType);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                message.isMine
                    ? ZIMKitTextMessagePointer(
                        messageType: message.type,
                        isMine: message.isMine,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCombineMessageDetail(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Query combine message detail
      final messageList = await ZIMKit().queryCombineMessageDetail(message);

      // Close loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to detail page
      if (context.mounted && messageList.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _CombineMessageDetailPage(
              title: (message.zim as ZIMCombineMessage).title,
              messageList: messageList,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        final innerText = ZIMKitCore.instance.innerText;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${innerText.loadCombineMessageError}: $e')),
        );
      }
    }
  }

  Future<void> _handleReactionTap(String reactionType) async {
    final currentUserID = ZIMKit().currentUser()?.baseInfo.userID;
    if (currentUserID == null) return;

    final reactions = message.reactions.value;

    try {
      final existingReaction = reactions.firstWhere(
        (r) => r.reactionType == reactionType,
        orElse: () => throw StateError('Reaction not found'),
      );

      final hasReacted = existingReaction.userList.any(
        (user) => user.userID == currentUserID,
      );

      if (hasReacted) {
        await ZIMKit().deleteMessageReaction(message, reactionType);
      } else {
        await ZIMKit().addMessageReaction(message, reactionType);
      }
    } catch (e) {
      // Reaction not found, do nothing
    }
  }
}

/// Detail page to display combine message content
class _CombineMessageDetailPage extends StatelessWidget {
  const _CombineMessageDetailPage({
    required this.title,
    required this.messageList,
  });

  final String title;
  final List<ZIMKitMessage> messageList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20.zR,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messageList.length,
        itemBuilder: (context, index) {
          final msg = messageList[index];
          return _buildMessageItem(context, msg);
        },
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ZIMKitMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (placeholder)
          Container(
            width: 40.zW,
            height: 40.zH,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3.zR),
              borderRadius: BorderRadius.circular(20.zR),
            ),
            child: Center(
              child: Text(
                message.info.senderUserID.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.zW),
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name
                Text(
                  message.info.senderUserName.isNotEmpty
                      ? message.info.senderUserName
                      : message.info.senderUserID,
                  style: TextStyle(
                    fontSize: 14.zR,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
                SizedBox(height: 4.zH),
                // Message content
                _buildMessageContent(context, message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ZIMKitMessage message) {
    switch (message.type) {
      case ZIMMessageType.text:
        return Text(
          message.textContent?.text ?? '',
          style: TextStyle(
            fontSize: 15.zR,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        );
      case ZIMMessageType.image:
        return Text(
          '[Image]',
          style: TextStyle(
            fontSize: 15.zR,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
          ),
        );
      case ZIMMessageType.video:
        return Text(
          '[Video]',
          style: TextStyle(
            fontSize: 15.zR,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
          ),
        );
      case ZIMMessageType.audio:
        return Text(
          '[Audio]',
          style: TextStyle(
            fontSize: 15.zR,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
          ),
        );
      case ZIMMessageType.file:
        return Text(
          '[File]',
          style: TextStyle(
            fontSize: 15.zR,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
          ),
        );
      default:
        return Text(
          '[Unknown message]',
          style: TextStyle(
            fontSize: 15.zR,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
          ),
        );
    }
  }
}
