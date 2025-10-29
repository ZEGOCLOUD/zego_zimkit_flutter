import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/zimkit.dart';

class ZIMKitPickFileButton extends StatelessWidget {
  const ZIMKitPickFileButton({
    super.key,
    required this.onFilePicked,
    this.type = ZIMKitFileType.any,
    this.icon,
  });

  final Function(List<ZIMKitPlatformFile> files) onFilePicked;
  final Widget? icon;
  final ZIMKitFileType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ZIMKit().pickFiles(type: type).then(onFilePicked);
      },
      child: icon ??
          Icon(
            Icons.attach_file,
            color: Theme.of(context)
                .textTheme
                .bodyLarge!
                .color!
                .withValues(alpha: 0.64),
          ),
    );
  }
}
