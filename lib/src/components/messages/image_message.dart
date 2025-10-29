import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:zego_zimkit/src/components/messages/widgets/reactions.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/zimkit.dart';

class ZIMKitImageMessage extends StatelessWidget {
  const ZIMKitImageMessage({
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
        // TODO save image
        onTap: () => onPressed?.call(
          context,
          message,
          () {},
        ), // TODO default onPressed
        onLongPressStart: (details) => onLongPress?.call(
          context,
          details,
          message,
          () {},
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image content
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.zH,
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                child: AspectRatio(
                  aspectRatio: message.imageContent!.aspectRatio,
                  child: LayoutBuilder(
                      builder: (context, BoxConstraints constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.zR),
                      child: message.isMine
                          ? FutureBuilder(
                              future: File(message.imageContent!.fileLocalPath)
                                  .exists(),
                              builder: (context, snapshot) {
                                return snapshot.hasData && snapshot.data!
                                    ? Image.file(
                                        File(message
                                            .imageContent!.fileLocalPath),
                                        cacheHeight:
                                            constraints.maxHeight.floor(),
                                        cacheWidth:
                                            constraints.maxWidth.floor(),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: message.isNetworkUrl
                                            ? message
                                                .imageContent!.fileDownloadUrl
                                            : message.imageContent!
                                                .largeImageDownloadUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, _, __) =>
                                            const Icon(Icons
                                                .image_not_supported_outlined),
                                        placeholder: (context, url) =>
                                            const Icon(Icons.image_outlined),
                                        memCacheHeight:
                                            constraints.maxHeight.floor(),
                                        memCacheWidth:
                                            constraints.maxWidth.floor(),
                                      );
                              },
                            )
                          : CachedNetworkImage(
                              imageUrl: message.isNetworkUrl
                                  ? message.imageContent!.fileDownloadUrl
                                  : message.imageContent!.largeImageDownloadUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, _, __) => const Icon(
                                  Icons.image_not_supported_outlined),
                              placeholder: (context, url) =>
                                  const Icon(Icons.image_outlined),
                              memCacheHeight: constraints.maxHeight.floor(),
                              memCacheWidth: constraints.maxWidth.floor(),
                            ),
                    );
                  }),
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
}
