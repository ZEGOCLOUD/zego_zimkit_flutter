import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_zimkit/src/utils/screen_util/core/size_extension.dart';

enum ZIMKitMoreActionsPanelAction {
  takePhoto,
  pickImages,
  pickFiles,
}

Widget buildZIMKitInputMoreActionItem(
  BuildContext context, {
  required String label,
  required VoidCallback onTap,
  TextStyle? textStyle,

  /// icon abouts
  required IconData? icon,
  Color? iconColor,
  Color? backgroundColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 55.zW,
          height: 55.zH,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12.zR),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.zW,
            ),
          ),
          child: Icon(
            icon,
            size: 28.zW,
            color: iconColor ?? Colors.grey[700],
          ),
        ),
        SizedBox(height: 6.zH),
        Text(
          label,
          style: textStyle ??
              TextStyle(
                fontSize: 11.zSP,
                color: Colors.grey[700],
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
