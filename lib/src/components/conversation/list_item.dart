import 'dart:math';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

/// TODO config/style/event
class ZIMKitConversationWidget extends StatelessWidget {
  const ZIMKitConversationWidget({
    super.key,
    required this.conversation,
    required this.onPressed,
    this.lastMessageTimeBuilder,
    this.lastMessageTextBuilder,
    required this.onLongPress,
  });

  final ZIMKitConversation conversation;

  // ui builder
  final Widget Function(
    BuildContext context,
    DateTime? messageTime,
    Widget defaultWidget,
  )? lastMessageTimeBuilder;
  final Widget Function(
    BuildContext context,
    ZIMKitMessage? message,
    Widget defaultWidget,
  )? lastMessageTextBuilder;

  // event
  final Function(BuildContext context) onPressed;
  final Function(
    BuildContext context,
    LongPressStartDetails longPressDetails,
  ) onLongPress;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => onPressed(context),
      onLongPressStart: (longPressDetails) => onLongPress(
        context,
        longPressDetails,
      ),
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: min(screenWidth / 10, 20.zW),
            vertical: 15.zH,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              avatarWidget(),
              if (screenWidth >= 100)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.zW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        conversationNameWidget(),
                        SizedBox(height: 8.zH),
                        lastMessageTextWidget(),
                      ],
                    ),
                  ),
                ),
              if (screenWidth >= 250)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    lastMessageTimeWidget(),
                    SizedBox(height: 8.zH),
                    unreadWidget(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget avatarWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(25.zR)),
      child: SizedBox(
        width: 50.zW,
        height: 50.zH,
        child: ZIMKitAvatar(
          userID: conversation.id,
          width: 50.zW,
          height: 50.zH,
        ),
      ),
    );
  }

  Widget conversationNameWidget() {
    return Text(
      conversation.name.isNotEmpty ? conversation.name : conversation.id,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16.zSP),
    );
  }

  Widget lastMessageTextWidget() {
    return Builder(
      builder: (context) {
        final defaultWidget = defaultMessageTextBuilder(
          conversation.lastMessage,
        );
        return lastMessageTextBuilder?.call(
              context,
              conversation.lastMessage,
              defaultWidget,
            ) ??
            defaultWidget;
      },
    );
  }

  Widget lastMessageTimeWidget() {
    return Builder(
      builder: (context) {
        final messageTime = conversation.lastMessage != null
            ? DateTime.fromMillisecondsSinceEpoch(
                conversation.lastMessage!.info.timestamp,
              )
            : null;
        final defaultWidget = defaultMessageTimeBuilder(messageTime);
        return lastMessageTimeBuilder?.call(
              context,
              messageTime,
              defaultWidget,
            ) ??
            defaultWidget;
      },
    );
  }

  Widget unreadWidget() {
    return Badge(
      alignment: AlignmentDirectional.bottomEnd,
      backgroundColor: Colors.red,
      isLabelVisible: conversation.unreadMessageCount != 0,
      label: Text(
        '${conversation.unreadMessageCount > 9999 ? ZIMKitCore.instance.innerText.maxBadgeCountText : conversation.unreadMessageCount}',
        style: TextStyle(fontSize: 12.zSP),
      ),
    );
  }

  Widget defaultMessageTextBuilder(ZIMKitMessage? message) {
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: 0.64,
      child: Text(
        message.toStringValue(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.zSP),
      ),
    );
  }

  Widget defaultMessageTimeBuilder(DateTime? messageTime) {
    if (messageTime == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final duration = DateTime.now().difference(messageTime);

    String timeFormatString = '';

    if (duration.inMinutes < 1) {
      timeFormatString = ZIMKitCore.instance.innerText.justNowText;
    } else if (duration.inHours < 1) {
      timeFormatString =
          ZIMKitCore.instance.innerText.minutesAgoFormat.replaceFirst(
        '%d',
        '${duration.inMinutes}',
      );
    } else if (duration.inDays < 1) {
      timeFormatString =
          ZIMKitCore.instance.innerText.hoursAgoFormat.replaceFirst(
        '%d',
        '${duration.inHours}',
      );
    } else if (now.year == messageTime.year) {
      timeFormatString =
          '${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    } else {
      timeFormatString =
          ' ${messageTime.year}/${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    }

    return Opacity(
      opacity: 0.64,
      child: Text(
        timeFormatString,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(fontSize: 12.zSP),
      ),
    );
  }
}
