import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/components/defines/style.dart';
import 'package:zego_zimkit/src/components/messages/combine_message.dart';
import 'package:zego_zimkit/src/components/messages/file_message.dart';
import 'package:zego_zimkit/src/components/messages/image_message.dart';
import 'package:zego_zimkit/src/components/messages/revoke_message.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/zimkit.dart';

class ZIMKitMessageWidget extends StatelessWidget {
  const ZIMKitMessageWidget({
    super.key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.onReplyMessageTap,
    this.statusBuilder,
    this.avatarBuilder,
    this.timestampBuilder,
    this.messageContentBuilder,
  });

  final ZIMKitMessage message;

  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? avatarBuilder;
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? statusBuilder;
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? timestampBuilder;
  final Widget Function(
    BuildContext context,
    ZIMKitMessage message,
    Widget defaultWidget,
  )? messageContentBuilder;
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

  Widget buildMessageContent(BuildContext context) {
    late Widget defaultMessageContent;

    switch (message.type) {
      case ZIMMessageType.text:
        defaultMessageContent = ZIMKitTextMessage(
          onLongPress: onLongPress,
          onPressed: onPressed,
          onReplyMessageTap: onReplyMessageTap,
          message: message,
        );
        break;
      case ZIMMessageType.audio:
        defaultMessageContent = ZIMKitAudioMessage(
          onLongPress: onLongPress,
          onPressed: onPressed,
          onReplyMessageTap: onReplyMessageTap,
          message: message,
        );
        break;
      case ZIMMessageType.video:
        defaultMessageContent = ZIMKitVideoMessage(
          onLongPress: onLongPress,
          onPressed: onPressed,
          onReplyMessageTap: onReplyMessageTap,
          message: message,
        );
        break;
      case ZIMMessageType.file:
        defaultMessageContent = ZIMKitFileMessage(
          onLongPress: onLongPress,
          onPressed: onPressed,
          onReplyMessageTap: onReplyMessageTap,
          message: message,
        );
        break;
      case ZIMMessageType.image:
        defaultMessageContent = ZIMKitImageMessage(
          onLongPress: onLongPress,
          onPressed: onPressed,
          onReplyMessageTap: onReplyMessageTap,
          message: message,
        );
        break;
      case ZIMMessageType.revoke:
        defaultMessageContent = ZIMKitRevokeMessage(message: message);
        break;
      case ZIMMessageType.combine:
        defaultMessageContent = ZIMKitCombineMessage(
          onLongPress: onLongPress,
          onPressed: onPressed,
          onReplyMessageTap: onReplyMessageTap,
          message: message,
        );
        break;
      case ZIMMessageType.custom:
        defaultMessageContent = const Flexible(
          child: Text(
            'This is a customMessage, please use messageContentBuilder to build it.',
          ),
        );
        break;
      default:
        return Text(message.toString());
    }
    return messageContentBuilder?.call(
          context,
          message,
          defaultMessageContent,
        ) ??
        defaultMessageContent;
  }

  Widget buildStatus(BuildContext context) {
    final Widget defaultStatusWidget = ZIMKitMessageStatusDot(message);
    return statusBuilder?.call(context, message, defaultStatusWidget) ??
        defaultStatusWidget;
  }

  Widget buildAvatar(BuildContext context) {
    final Widget defaultAvatarWidget = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(avatarWidth)),
      child: ZIMKitAvatar(
        userID: message.info.senderUserID,
        width: avatarWidth,
        height: avatarHeight,
      ),
    );

    return avatarBuilder?.call(context, message, defaultAvatarWidget) ??
        defaultAvatarWidget;
  }

  Widget localMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMessageContent(context),
        buildStatus(context),
      ],
    );
  }

  Widget remoteMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildAvatar(context),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [buildNickName(context), buildMessageContent(context)],
          ),
        ),
      ],
    );
  }

  Widget buildNickName(BuildContext context) {
    if (message.isMine ||
        message.info.conversationType != ZIMConversationType.group) {
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: ZIMKit().queryGroupMemberInfo(
        message.info.conversationID,
        message.info.senderUserID,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userInfo = snapshot.data!;
          return Text(
            userInfo.memberNickname.isNotEmpty
                ? userInfo.memberNickname
                : userInfo.userName,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color?.withValues(alpha: 0.6),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.23;

    final textDirection = Directionality.of(context);

    return Padding(
      padding: message.type == ZIMMessageType.revoke
          ? EdgeInsets.symmetric(vertical: itemVerticalMargin)
          : EdgeInsets.fromLTRB(
              TextDirection.ltr == textDirection
                  ? (message.isMine ? horizontalPadding : 0)
                  : (message.isMine ? 0 : horizontalPadding),
              itemVerticalMargin,
              TextDirection.ltr == textDirection
                  ? (message.isMine ? 0 : horizontalPadding)
                  : (message.isMine ? horizontalPadding : 0),
              itemVerticalMargin,
            ),
      child: FractionallySizedBox(
        widthFactor: 1,
        alignment:
            message.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: message.isMine ? localMessage(context) : remoteMessage(context),
      ),
    );
  }
}
