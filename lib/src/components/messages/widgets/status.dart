import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

/// Widget for displaying message send status indicator
///
/// Shows a colored dot indicating whether the message was sent, failed, or is sending.
class ZIMKitMessageStatusDot extends StatelessWidget {
  const ZIMKitMessageStatusDot(this.message, {super.key});
  final ZIMKitMessage message;

  Color dotColor(BuildContext context, ZIMMessageSentStatus status) {
    switch (status) {
      case ZIMMessageSentStatus.failed:
        return Theme.of(context).colorScheme.error;
      case ZIMMessageSentStatus.sending:
        return Theme.of(context)
            .textTheme
            .bodyLarge!
            .color!
            .withValues(alpha: 0.1);
      case ZIMMessageSentStatus.success:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.zR),
      height: 12.zH,
      width: 12.zW,
      decoration: BoxDecoration(
        color: dotColor(context, message.info.sentStatus),
        shape: BoxShape.circle,
      ),
      child: Icon(
        message.info.sentStatus == ZIMMessageSentStatus.failed
            ? Icons.close
            : Icons.done,
        size: 8.zW,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
