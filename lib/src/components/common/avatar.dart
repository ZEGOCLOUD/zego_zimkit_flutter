import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/zimkit.dart';

class ZIMKitAvatar extends StatelessWidget {
  const ZIMKitAvatar({
    super.key,
    required this.userID,
    this.name = '',
    this.height,
    this.width,
  });
  final String userID;
  final String name;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 40.zW,
      height: height ?? 40.zH,
      child: FutureBuilder(
        // TODO auto update user's avatar
        future: ZIMKit().queryUser(userID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.icon;
          } else {
            return CircleAvatar(
                child: Text(name.isNotEmpty ? name[0] : userID[0]));
          }
        },
      ),
    );
  }
}
