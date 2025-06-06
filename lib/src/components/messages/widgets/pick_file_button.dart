import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/services/services.dart';

class ZIMKitPickFileButton extends StatelessWidget {
  const ZIMKitPickFileButton({
    Key? key,
    required this.onFilePicked,
    this.type = ZIMKitFileType.any,
    this.icon,
  }) : super(key: key);

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
            color:
                Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.64),
          ),
    );
  }
}
