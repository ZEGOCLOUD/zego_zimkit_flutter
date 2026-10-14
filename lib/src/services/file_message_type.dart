import 'package:zego_zim/zego_zim.dart';

ZIMMessageType resolveZIMKitFileMessageType(
  String? extension, {
  required bool autoDetectType,
}) {
  if (!autoDetectType || extension == null) {
    return ZIMMessageType.file;
  }

  final normalizedExtension = extension
      .trim()
      .replaceFirst(RegExp(r'^\.'), '')
      .toLowerCase();
  const imageExtensions = {'jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff', 'webp'};
  const videoExtensions = {'mp4', 'mov'};// <100M
  const audioExtensions = {'mp3', 'm4a'};// <300s, <6M

  if (imageExtensions.contains(normalizedExtension)) {
    return ZIMMessageType.image;
  }
  if (videoExtensions.contains(normalizedExtension)) {
    return ZIMMessageType.video;
  }
  if (audioExtensions.contains(normalizedExtension)) {
    return ZIMMessageType.audio;
  }
  return ZIMMessageType.file;
}
