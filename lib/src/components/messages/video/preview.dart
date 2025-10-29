import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

class ZIMKitVideoMessagePreview extends StatelessWidget {
  const ZIMKitVideoMessagePreview(this.message, {super.key});

  final ZIMKitMessage message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.zR),
          child: message.videoContent!.videoFirstFrameLocalPath.isNotEmpty
              ? Image.file(
                  File(message.videoContent!.videoFirstFrameLocalPath),
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  key: ValueKey(message.info.messageID),
                  imageUrl: message.videoContent!.videoFirstFrameDownloadUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, _, __) => SizedBox(
                    width: 160.zW,
                    height: 90.zH,
                    child: const Icon(Icons.error),
                  ),
                  placeholder: (context, url) => SizedBox(
                    width: 160.zW,
                    height: 90.zH,
                    child: const Icon(Icons.video_file_outlined),
                  ),
                ),
        ),
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            size: 16,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}
