import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/components/messages/widgets/reactions.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Widget for displaying file messages
///
/// Renders a file message with file icon, name, and size information.
class ZIMKitFileMessage extends StatelessWidget {
  const ZIMKitFileMessage({
    super.key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.onReplyMessageTap,
  });

  final ZIMKitMessage message;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onPressed;
  final void Function(BuildContext context, LongPressStartDetails details,
      ZIMKitMessage message, Function defaultAction)? onLongPress;
  final void Function(String repliedMessageID)? onReplyMessageTap;

  @override
  Widget build(BuildContext context) {
    final color = message.isMine
        ? ZIMKitMessageStyle.sentMessageTextColor
        : ZIMKitMessageStyle.receivedMessageTextColor(context);
    final textStyle = TextStyle(color: color);

    return Flexible(
      child: GestureDetector(
        // TODO download file
        onTap: () => onPressed?.call(context, message, () {}),
        onLongPressStart: (details) =>
            onLongPress?.call(context, details, message, () {}),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // File content with reactions inside
            Container(
              padding: EdgeInsets.all(8.zR),
              decoration: BoxDecoration(
                color: message.isMine
                    ? ZIMKitMessageStyle.sentMessageBubbleColor(context)
                    : ZIMKitMessageStyle.receivedMessageBubbleColor,
                borderRadius: BorderRadius.circular(8.zR),
                boxShadow: message.isMine
                    ? null
                    : ZIMKitMessageStyle.getReceivedMessageBubbleShadow(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File info
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_copy, color: color),
                      SizedBox(width: 8.zW),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: message.isNetworkUrl
                              ? [
                                  Text(message.fileContent!.fileName,
                                      style: textStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ]
                              : [
                                  Text(message.fileContent!.fileName,
                                      style: textStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                    fileSizeFormat(
                                        message.fileContent!.fileSize),
                                    style: textStyle,
                                    maxLines: 1,
                                  ),
                                ],
                        ),
                      ),
                      const Icon(Icons.download),
                    ],
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

  String fileSizeFormat(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).ceil()} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).ceil()} MB';
    } else {
      return '${(size / 1024 / 1024 / 1024).ceil()} GB';
    }
  }
}
