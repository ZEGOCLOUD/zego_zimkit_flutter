import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Widget to display revoked message
class ZIMKitRevokeMessage extends StatelessWidget {
  const ZIMKitRevokeMessage({super.key, required this.message});

  final ZIMKitMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.zH),
      padding: EdgeInsets.symmetric(horizontal: 12.zW, vertical: 6.zH),
      child: Text(
        _getRevokeText(),
        style: TextStyle(
          fontSize: 12.zSP,
          color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)
              .withValues(alpha: 0.5),
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  String _getRevokeText() {
    final currentUserID = ZIMKit().currentUser()?.id ?? '';
    final innerText = ZIMKitCore.instance.innerText;
    if (message.info.senderUserID == currentUserID) {
      return innerText.youRevokedMessage;
    } else {
      // Try to get user name, fallback to user ID
      final senderName = message.info.senderUserName.isNotEmpty
          ? message.info.senderUserName
          : message.info.senderUserID;
      return innerText.someoneRevokedMessageFormat.replaceAll('%s', senderName);
    }
  }
}
