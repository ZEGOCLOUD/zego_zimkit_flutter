import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Button widget for picking media (images and videos) to send
///
/// Displays a button that triggers the media picker when pressed.
/// Used in the message input toolbar.
class ZIMKitPickMediaButton extends StatelessWidget {
  const ZIMKitPickMediaButton({
    super.key,
    required this.onFilePicked,
    this.icon,
  });

  final Function(List<ZIMKitPlatformFile> files) onFilePicked;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ZIMKit().pickFiles(type: ZIMKitFileType.media).then(onFilePicked);
      },
      child: icon ??
          Icon(
            Icons.photo_library,
            color: Theme.of(context)
                .textTheme
                .bodyLarge!
                .color!
                .withValues(alpha: 0.64),
          ),
    );
  }
}
