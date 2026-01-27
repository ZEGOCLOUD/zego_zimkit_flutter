part of 'zimkit_services.dart';

mixin ZIMKitInputService {
  Future<List<ZIMKitPlatformFile>> pickFiles(
      {ZIMKitFileType type = ZIMKitFileType.any,
      bool allowMultiple = true}) async {
    try {
      await requestPermission();
      ZIMKitLogger.logInfo(
          'pickFiles: start, ${DateTime.now().millisecondsSinceEpoch}');
      // see https://github.com/miguelpruivo/flutter_file_picker/wiki/API#-filepickerpickfiles
      final ret = (await FilePicker.platform.pickFiles(
            type: FileType.values[type.index],
            allowMultiple: allowMultiple,
            onFileLoading: (p0) {
              ZIMKitLogger.logInfo('onFileLoading: '
                  '$p0,${DateTime.now().millisecondsSinceEpoch}');
            },
          ))
              ?.files ??
          [];
      ZIMKitLogger.logInfo(
          'pickFiles: $ret, ${DateTime.now().millisecondsSinceEpoch}');
      return ret
          .map((file) => ZIMKitPlatformFile(
                name: file.name,
                path: file.path,
                bytes: file.bytes,
                readStream: file.readStream,
                size: file.size,
                identifier: file.identifier,
              ))
          .toList();
    } on PlatformException catch (e) {
      ZIMKitLogger.logError('Unsupported operation $e');
    } catch (e) {
      ZIMKitLogger.logError(e.toString());
    }
    return [];
  }

  ZIMMessageType getMessageTypeByFileExtension(ZIMKitPlatformFile file) {
    const supportImageList = <String>[
      'jpg',
      'jpeg',
      'png',
      'bmp',
      'gif',
      'tiff',
      'webp',
    ]; // <10M
    const supportVideoList = <String>['mp4', 'mov']; // <100M
    const supportAudioList = <String>['mp3', 'm4a']; // <300s, <6M

    var messageType = ZIMMessageType.file;

    if (file.extension == null) {
      return messageType;
    }
    if (supportImageList.contains(file.extension!.toLowerCase())) {
      messageType = ZIMMessageType.image;
    } else if (supportVideoList.contains(file.extension!.toLowerCase())) {
      messageType = ZIMMessageType.video;
    } else if (supportAudioList.contains(file.extension!.toLowerCase())) {
      messageType = ZIMMessageType.audio;
    }

    // TODO check file limit
    return messageType;
  }

  Future<void> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return;
    }
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      ZIMKitLogger.logError('Warn: Permission.storage not granted, $status');
      if (Platform.isAndroid) {
        ZIMKitLogger.logError(
            'Warn: On Android TIRAMISU and higher this permission is deprecrated and always returns `PermissionStatus.denied`');
      }
    }

    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (status != PermissionStatus.granted) {
        ZIMKitLogger.logError('Error: Permission.storage not granted, $status');
      }
    }

    if (Platform.isAndroid) {
      final status = await Permission.audio.request();
      if (status != PermissionStatus.granted) {
        ZIMKitLogger.logError('Error: Permission.storage not granted, $status');
      }
    }
    if (Platform.isAndroid) {
      final status = await Permission.videos.request();
      if (status != PermissionStatus.granted) {
        ZIMKitLogger.logError('Error: Permission.storage not granted, $status');
      }
    }
  }
}
