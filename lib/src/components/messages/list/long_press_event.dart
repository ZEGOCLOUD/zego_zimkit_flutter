import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zego_zim_audio/zego_zim_audio.dart';

import 'package:zego_zimkit/src/components/forward/select_page.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ZIMKitMessageListViewItemLongPressEvent {
  BuildContext context;
  void Function(ZIMKitMessage message)? onReplyMessage;

  ZIMKitMessageListViewItemLongPressEvent({
    required this.context,
    this.onReplyMessage,
  });

  void onMessageItemLongPress(
    BuildContext context,
    LongPressStartDetails details,
    ZIMKitMessage message,
    Function defaultAction,
  ) {
    // Check if message is sent by current user
    final currentUserID = ZIMKit().currentUser()?.baseInfo.userID ?? '';
    final isSentByMe = message.info.senderUserID == currentUserID;

    showZIMKitMessageOptionsMenu(
      context,
      message,
      details.globalPosition,
      isSentByMe,
      (action) async {
        // Note: Menu widget already pops itself, no need to pop again here
        switch (action) {
          case ZIMKitMessageOperation.copy:
            await _handleCopy(message);
            break;
          case ZIMKitMessageOperation.reply:
            _handleReply(message);
            break;
          case ZIMKitMessageOperation.forward:
            _handleForward(message);
            break;
          case ZIMKitMessageOperation.select:
            _handleSelect(message);
            break;
          case ZIMKitMessageOperation.delete:
            await _handleDelete(message);
            break;
          case ZIMKitMessageOperation.revoke:
            await _handleRevoke(message);
            break;
          case ZIMKitMessageOperation.turnOffSpeaker:
            _handleSpeakerToggle();
            break;
        }
      },
    );
  }

  Future<void> _handleCopy(ZIMKitMessage message) async {
    if (message.textContent != null) {
      await Clipboard.setData(ClipboardData(text: message.textContent!.text));
    }
  }

  void _handleSelect(ZIMKitMessage message) {
    ZIMKitMessageListMultiSelectProcessor().appleMultiSelect(message);
  }

  void _handleSpeakerToggle() {
    ZIMAudio.getInstance().setAudioRouteType(ZIMAudioRouteType.receiver);
  }

  void _handleReply(ZIMKitMessage message) {
    // Call the callback if provided
    if (onReplyMessage != null) {
      onReplyMessage!(message);
    } else {
      ZIMKitLogger.logInfo('Reply callback not set');
    }
  }

  Future<void> _handleForward(ZIMKitMessage message) async {
    // Use SDK's forward page
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ZIMKitForwardSelectPage(
          messages: [message],
          forwardType: ZIMKitForwardType.single,
        ),
      ),
    );

    ZIMKitLogger.logInfo('_handleForward result:$result');
  }

  Future<void> _handleDelete(ZIMKitMessage message) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(ZIMKitCore.instance.innerText.deleteMessageTitle),
        content: Text(ZIMKitCore.instance.innerText.deleteMessageContent),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ZIMKitCore.instance.innerText.cancelButtonText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(ZIMKitCore.instance.innerText.confirmButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ZIMKit().deleteMessage([message]);
      } catch (error) {
        ZIMKitLogger.logError('_handleDelete error:$error');
      }
    }
  }

  Future<void> _handleRevoke(ZIMKitMessage message) async {
    try {
      await ZIMKit().recallMessage(message);
    } catch (error) {
      ZIMKitLogger.logError('_handleRevoke error:$error');
    }
  }
}
