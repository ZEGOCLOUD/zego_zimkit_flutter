import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/services.dart';

/// Widget to display reply state in message input area
class ZIMKitInputReplyWidget extends StatelessWidget {
  const ZIMKitInputReplyWidget({
    super.key,
    required this.repliedMessage,
    required this.onCancel,
  });

  final ZIMKitMessage repliedMessage;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.zW, vertical: 8.zH),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        border: Border(
          bottom:
              BorderSide(color: Theme.of(context).dividerColor, width: 1.zW),
        ),
      ),
      child: Row(
        children: [
          // Reply indicator line
          Container(
            width: 3.zW,
            height: 40.zH,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(1.5.zR),
            ),
          ),
          SizedBox(width: 12.zW),
          // Reply content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Replied user
                Text(
                  ZIMKitCore.instance.innerText.replyToText
                      .replaceAll('%s', repliedMessage.info.senderUserID),
                  style: TextStyle(
                    fontSize: 12.zSP,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.zH),
                // Replied message content
                Text(
                  _getMessageContent(),
                  style: TextStyle(
                    fontSize: 13.zSP,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Cancel button
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20.zW,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _getMessageContent() {
    switch (repliedMessage.type) {
      case ZIMMessageType.text:
        return repliedMessage.textContent?.text ?? '';
      case ZIMMessageType.image:
        return ZIMKitCore.instance.innerText.imageMessageText;
      case ZIMMessageType.video:
        return ZIMKitCore.instance.innerText.videoMessageText;
      case ZIMMessageType.audio:
        return ZIMKitCore.instance.innerText.audioMessageText;
      case ZIMMessageType.file:
        return ZIMKitCore.instance.innerText.fileMessageText;
      case ZIMMessageType.combine:
        return ZIMKitCore.instance.innerText.combineMessageText;
      case ZIMMessageType.custom:
        return ZIMKitCore.instance.innerText.customMessageText;
      default:
        return '';
    }
  }
}
