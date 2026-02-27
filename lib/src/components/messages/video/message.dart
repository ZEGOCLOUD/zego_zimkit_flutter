import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/messages/widgets/reactions.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/zimkit.dart';

import 'player.dart';
import 'preview.dart';

/// Widget for displaying video messages
///
/// Renders a video message with a thumbnail preview and play functionality.
class ZIMKitVideoMessage extends StatelessWidget {
  const ZIMKitVideoMessage({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.onReplyMessageTap,
    required this.message,
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

  void _onPressed(BuildContext context, ZIMKitMessage msg) {
    void defaultAction() => playVideo(context);
    if (onPressed != null) {
      onPressed!.call(context, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  void _onLongPress(
    BuildContext context,
    LongPressStartDetails details,
    ZIMKitMessage msg,
  ) {
    void defaultAction() {
      // TODO popup menu
    }
    if (onLongPress != null) {
      onLongPress!.call(context, details, msg, defaultAction);
    } else {
      defaultAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => _onPressed(context, message),
        onLongPressStart: (details) => _onLongPress(context, details, message),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video preview
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.zH,
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                child: ZIMKitVideoMessagePreview(
                  message,
                  key: ValueKey(message.info.messageID),
                ),
              ),
            ),
            // Reactions
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

  void playVideo(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) => ZIMKitVideoMessagePlayer(message,
          key: ValueKey(message.info.messageID)),
    ).closed.then((value) {
      ZIMKitLogger.logInfo('ZIMKitVideoMessage: playVideo end');
    });
  }
}
