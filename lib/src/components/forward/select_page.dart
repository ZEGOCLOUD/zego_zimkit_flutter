import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/conversation/events.dart';
import 'package:zego_zimkit/src/components/conversation/list.dart';
import 'package:zego_zimkit/src/config.defines.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util_config.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Forward selection page for choosing target conversation
/// Similar to iOS ZIMKitRecentChatListVC and Android ForwardSelectActivity
class ZIMKitForwardSelectPage extends StatelessWidget {
  const ZIMKitForwardSelectPage({
    super.key,
    required this.messages,
    required this.forwardType,
    this.conversationName = '',
  });

  final List<ZIMKitMessage> messages;
  final ZIMKitForwardType forwardType;
  final String conversationName;

  @override
  Widget build(BuildContext context) {
    return ZIMScreenUtilInit(
      designSize: ZIMKitScreenUtilConfig.designSize,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(ZIMKitCore.instance.innerText.forwardSelectTitle),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ZIMKitConversationListView(
            events: ZIMKitConversationListEvents(
              onPressed: (itemContext, conversation, defaultAction) async {
                // Show confirmation dialog
                final confirmed = await _showConfirmDialog(
                  context,
                  conversation,
                );

                if (confirmed == true) {
                  // Forward messages
                  await _forwardMessages(context, conversation);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    ZIMKitConversation conversation,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ZIMKitCore.instance.innerText.forwardToText),
        content: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: Text(
                conversation.name.isNotEmpty
                    ? conversation.name[0].toUpperCase()
                    : '?',
              ),
            ),
            SizedBox(width: 12.zW),
            Expanded(
              child: Text(
                conversation.name,
                style: TextStyle(fontSize: 16.zSP),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ZIMKitCore.instance.innerText.cancelButtonText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(ZIMKitCore.instance.innerText.confirmButtonText),
          ),
        ],
      ),
    );
  }

  Future<void> _forwardMessages(
    BuildContext context,
    ZIMKitConversation targetConversation,
  ) async {
    try {
      switch (forwardType) {
        case ZIMKitForwardType.single:
          await _forwardSingleMessage(targetConversation);
          break;
        case ZIMKitForwardType.oneByOne:
          await _forwardOneByOne(targetConversation);
          break;
        case ZIMKitForwardType.merge:
          await _forwardMerge(targetConversation);
          break;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ZIMKitCore.instance.innerText.forwardSuccessToast)),
        );
        // Pop twice: confirmation dialog and forward select page
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('[ZIMKit] Forward failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${ZIMKitCore.instance.innerText.operationFailedFormat.replaceFirst('%s', '$e')}')),
        );
      }
    }
  }

  Future<void> _forwardSingleMessage(ZIMKitConversation target) async {
    if (messages.isEmpty) return;
    await _sendMessage(messages.first, target);
  }

  Future<void> _forwardOneByOne(ZIMKitConversation target) async {
    for (final message in messages) {
      await _sendMessage(message, target);
      // Small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _forwardMerge(ZIMKitConversation target) async {
    if (messages.isEmpty) return;

    // Build title (similar to Android implementation)
    // Android format: "%s会话记录" where %s is either "群聊" or "UserA 和 UserB 的"
    String title;
    final firstMessage = messages.first;

    if (firstMessage.info.conversationType == ZIMConversationType.group) {
      // For group: "Group Chat History" or "[Chat History]"
      title = ZIMKitCore.instance.innerText.combineMessageText;
    } else {
      // For peer: "UserA and UserB's Chat History"
      final currentUser = ZIMKit().currentUser();
      final currentUserName =
          currentUser?.baseInfo.userName ?? currentUser?.baseInfo.userID ?? '';

      // Get the other user's name from first message
      final otherUserName = firstMessage.info.senderUserName.isNotEmpty
          ? firstMessage.info.senderUserName
          : firstMessage.info.senderUserID;

      // Format: "UserA and UserB's Chat History"
      title =
          '$currentUserName and $otherUserName\'s ${ZIMKitCore.instance.innerText.combineMessageText}';
    }

    // Build summary (max 3 lines, similar to Android)
    final summaryLines = <String>[];
    final maxLines = 3;

    for (int i = 0; i < messages.length && i < maxLines; i++) {
      final message = messages[i];
      final senderName = message.info.senderUserName.isNotEmpty
          ? message.info.senderUserName
          : message.info.senderUserID;

      String content;
      switch (message.type) {
        case ZIMMessageType.text:
          content = message.textContent!.text
              .replaceAll('\n', ' ')
              .replaceAll('\r', ' ');
          break;
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
        default:
          content = '[Unknown]';
      }

      // Limit line length (similar to Android's 164 bytes limit)
      const maxLineLength = 50; // characters
      if (content.length > maxLineLength) {
        content = '${content.substring(0, maxLineLength)}...';
      }

      summaryLines.add('$senderName: $content');
    }

    final summary = summaryLines.join('\n');

    // Send combine message using proper API
    await ZIMKit().sendCombineMessage(
      target.id,
      target.type,
      title: title,
      summary: summary,
      messageList: messages,
    );
  }

  Future<void> _sendMessage(
    ZIMKitMessage message,
    ZIMKitConversation target,
  ) async {
    switch (message.type) {
      case ZIMMessageType.text:
        await ZIMKit().sendTextMessage(
          target.id,
          target.type,
          message.textContent!.text,
        );
        break;

      case ZIMMessageType.image:
        if (message.imageContent?.fileLocalPath != null) {
          await ZIMKit().sendMediaMessage(
            target.id,
            target.type,
            [
              ZIMKitPlatformFile(
                path: message.imageContent!.fileLocalPath,
                name: message.imageContent!.fileName,
                size: message.imageContent!.fileSize,
              ),
            ],
          );
        }
        break;

      case ZIMMessageType.video:
        if (message.videoContent?.fileLocalPath != null) {
          await ZIMKit().sendMediaMessage(
            target.id,
            target.type,
            [
              ZIMKitPlatformFile(
                path: message.videoContent!.fileLocalPath,
                name: message.videoContent!.fileName,
                size: message.videoContent!.fileSize,
              ),
            ],
          );
        }
        break;

      case ZIMMessageType.file:
        if (message.fileContent?.fileLocalPath != null) {
          await ZIMKit().sendFileMessage(
            target.id,
            target.type,
            [
              ZIMKitPlatformFile(
                path: message.fileContent!.fileLocalPath,
                name: message.fileContent!.fileName,
                size: message.fileContent!.fileSize,
              ),
            ],
          );
        }
        break;

      case ZIMMessageType.audio:
        if (message.audioContent?.fileLocalPath != null) {
          await ZIMKit().sendMediaMessage(
            target.id,
            target.type,
            [
              ZIMKitPlatformFile(
                path: message.audioContent!.fileLocalPath,
                name: message.audioContent!.fileName,
                size: message.audioContent!.fileSize,
              ),
            ],
          );
        }
        break;

      default:
        debugPrint(
            '[ZIMKit] Unsupported message type for forward: ${message.type}');
    }
  }
}
