import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

/// Widget to display message reactions (emoji reactions)
class ZIMKitMessageReactionsWidget extends StatelessWidget {
  const ZIMKitMessageReactionsWidget({
    super.key,
    required this.message,
    required this.isMine,
    this.onReactionTap,
  });

  final ZIMKitMessage message;
  final bool isMine;
  final void Function(String reactionType)? onReactionTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ZIMMessageReaction>>(
      valueListenable: message.reactions,
      builder: (context, reactions, child) {
        if (reactions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.only(top: ZIMKitMessageStyle.reactionTopMargin.zH),
          child: Wrap(
            spacing: ZIMKitMessageStyle.reactionSpacing,
            runSpacing: ZIMKitMessageStyle.reactionSpacing,
            children: reactions.map(
              (reaction) {
                return _buildReactionChip(context, reaction);
              },
            ).toList(),
          ),
        );
      },
    );
  }

  Widget _buildReactionChip(BuildContext context, ZIMMessageReaction reaction) {
    // Get user names for reaction (like Android's getMemoryUserInfo)
    final userNames = reaction.userList
        .map((user) {
          // Try to get user info from cache
          final userInfo = ZIMKitCore.instance.getMemoryUserInfo(user.userID);
          if (userInfo != null && userInfo.baseInfo.userName.isNotEmpty) {
            return userInfo.baseInfo.userName;
          }
          return user.userID; // Fallback to userID if not cached
        })
        .take(3) // Limit to 3 names for display
        .join(', ');

    return GestureDetector(
      onTap: () {
        onReactionTap?.call(reaction.reactionType);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ZIMKitMessageStyle.reactionChipPaddingHorizontal.zW,
          vertical: ZIMKitMessageStyle.reactionChipPaddingVertical.zH,
        ),
        decoration: BoxDecoration(
          color: ZIMKitMessageStyle.getReactionBackgroundColor(isMine),
          borderRadius:
              BorderRadius.circular(ZIMKitMessageStyle.reactionChipRadius.zR),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji
            Text(
              reaction.reactionType,
              style: TextStyle(
                fontSize: ZIMKitMessageStyle.reactionEmojiSize.zSP,
              ),
            ),
            SizedBox(width: 4.zW),
            // Divider line
            Container(
              width: 1.zW,
              height: 14.zH,
              color: ZIMKitMessageStyle.getReactionDividerColor(isMine),
            ),
            SizedBox(width: 5.zW),
            // User names
            Flexible(
              child: Text(
                userNames,
                style: TextStyle(
                  fontSize: ZIMKitMessageStyle.reactionUserNameSize.zSP,
                  color: ZIMKitMessageStyle.getReactionTextColor(isMine),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
