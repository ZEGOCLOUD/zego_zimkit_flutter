import 'package:flutter/foundation.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

/// Handles camera controller errors that complete after the picker is disposed.
class ZIMKitCameraPickerState extends CameraPickerState {
  @override
  Future<T?> wrapControllerMethod<T>(
    String key,
    Future<T> Function() method, {
    CameraDescription? camera,
    VoidCallback? onError,
    T? fallback,
  }) async {
    try {
      return await super.wrapControllerMethod<T>(
        key,
        method,
        camera: camera,
        onError: onError,
        fallback: fallback,
      );
    } catch (error, stackTrace) {
      if (mounted) rethrow;

      debugPrint(
        'Camera method "$key" failed after picker dispose: '
        '$error\n$stackTrace',
      );
      return fallback;
    }
  }
}
