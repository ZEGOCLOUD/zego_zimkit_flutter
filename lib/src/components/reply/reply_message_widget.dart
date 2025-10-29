import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/services.dart';

/// Widget to display reply message info above the actual message content
class ZIMKitReplyMessageWidget extends StatelessWidget {
  const ZIMKitReplyMessageWidget({
    super.key,
    required this.replyInfo,
    required this.isMine,
  });

  final ZIMKitReplyMessageInfo replyInfo;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.zH,
      margin: EdgeInsets.only(bottom: 4.zH),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left vertical line (matching Android's reply line)
          Container(
            width: 1.zW,
            margin: EdgeInsets.symmetric(vertical: 4.zH),
            color: (isMine
                ? Colors.white.withValues(alpha: 0.7) // #b3ffffff (70% white)
                : const Color(0xFF646A73)), // #646A73 gray
          ),
          SizedBox(width: 3.zW),
          // Reply content
          Expanded(
            child: Text(
              _getReplyContent(),
              style: TextStyle(
                fontSize: 13.zSP,
                color: (isMine
                    ? Colors.white
                        .withValues(alpha: 0.7) // #b3ffffff (70% white)
                    : const Color(0xFF646A73)), // #646A73 gray
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getReplyContent() {
    // Format: "Name: content" or "Name: [媒体类型]"
    final userName = replyInfo.senderUserName.isNotEmpty
        ? replyInfo.senderUserName
        : replyInfo.senderUserID;

    String content;
    if (replyInfo.contentSummary.isNotEmpty) {
      content = replyInfo.contentSummary;
    } else {
      // Fallback to message type description
      switch (replyInfo.messageType) {
        case ZIMMessageType.image:
          content = ZIMKitCore.instance.innerText.imageMessageText;
          break;
        case ZIMMessageType.video:
          content = ZIMKitCore.instance.innerText.videoMessageText;
          break;
        case ZIMMessageType.audio:
          content = ZIMKitCore.instance.innerText.audioMessageText;
          break;
        case ZIMMessageType.file:
          content = ZIMKitCore.instance.innerText.fileMessageText;
          break;
        case ZIMMessageType.combine:
          content = ZIMKitCore.instance.innerText.combineMessageText;
          break;
        case ZIMMessageType.custom:
          content = ZIMKitCore.instance.innerText.customMessageText;
          break;
        default:
          content = '';
      }
    }

    return '$userName: $content';
  }
}
