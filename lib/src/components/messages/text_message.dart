import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/components/messages/widgets/pointer.dart';
import 'package:zego_zimkit/src/components/messages/widgets/reactions.dart';
import 'package:zego_zimkit/src/components/reply/reply_message_widget.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Widget for displaying text messages
///
/// Renders a text message bubble with support for reactions, replies, and click interactions.
class ZIMKitTextMessage extends StatelessWidget {
  const ZIMKitTextMessage({
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
    return Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          debugPrint('[ZIMKit] Outer GestureDetector tapped');
          onPressed?.call(context, message, () {});
        },
        onLongPressStart: (details) =>
            onLongPress?.call(context, details, message, () {
          final text = message.textContent?.text;
          if (text != null) {
            Clipboard.setData(ClipboardData(text: text));
          }
        }),
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
                    decoration: BoxDecoration(
                      color: message.isMine
                          ? ZIMKitMessageStyle.sentMessageBubbleColor(context)
                          : ZIMKitMessageStyle.receivedMessageBubbleColor,
                      borderRadius: BorderRadius.circular(
                        ZIMKitMessageStyle.messageBubbleRadius.zR,
                      ),
                      boxShadow: message.isMine
                          ? null
                          : ZIMKitMessageStyle.getReceivedMessageBubbleShadow(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ZIMKitMessageStyle.messageBubblePaddingHorizontal.zW,
                      vertical:
                          ZIMKitMessageStyle.messageBubblePaddingVertical.zH,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show reply info if exists
                        if (message.replyInfo != null)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              debugPrint(
                                  '[ZIMKit] Reply widget tapped in text_message');
                              // Scroll to replied message
                              if (onReplyMessageTap != null) {
                                onReplyMessageTap!(
                                    message.replyInfo!.messageID.toString());
                              } else {
                                debugPrint(
                                    '[ZIMKit] onReplyMessageTap is null!');
                              }
                            },
                            child: ZIMKitReplyMessageWidget(
                              replyInfo: message.replyInfo!,
                              isMine: message.isMine,
                            ),
                          ),
                        // Actual message content
                        if (message.textContent?.text != null)
                          Text(
                            message.textContent!.text,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: message.isMine
                                  ? ZIMKitMessageStyle.sentMessageTextColor
                                  : ZIMKitMessageStyle.receivedMessageTextColor(
                                      context),
                              fontSize:
                                  ZIMKitMessageStyle.messageTextSize(context),
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

  Future<void> _handleReactionTap(String reactionType) async {
    final currentUserID = ZIMKit().currentUser()?.baseInfo.userID;
    if (currentUserID == null) return;

    final reactions = message.reactions.value;

    // Check if current user already reacted with this type
    final existingReaction = reactions.firstWhere(
      (r) => r.reactionType == reactionType,
      orElse: () => throw StateError('Reaction not found'),
    );

    try {
      final hasReacted = existingReaction.userList.any(
        (user) => user.userID == currentUserID,
      );

      if (hasReacted) {
        // Remove reaction
        await ZIMKit().deleteMessageReaction(message, reactionType);
      } else {
        // Add reaction
        await ZIMKit().addMessageReaction(message, reactionType);
      }
    } catch (e) {
      // Reaction not found, do nothing
    }
  }
}
