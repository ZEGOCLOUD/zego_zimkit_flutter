import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/services/file_message_type.dart';

void main() {
  test('auto detection maps supported extensions to media message types', () {
    expect(
      resolveZIMKitFileMessageType('JPEG', autoDetectType: true),
      ZIMMessageType.image,
    );
    expect(
      resolveZIMKitFileMessageType('MP4', autoDetectType: true),
      ZIMMessageType.video,
    );
    expect(
      resolveZIMKitFileMessageType('m4a', autoDetectType: true),
      ZIMMessageType.audio,
    );
    expect(
      resolveZIMKitFileMessageType('unknown', autoDetectType: true),
      ZIMMessageType.file,
    );
  });

  test('disabling auto detection always sends a file message', () {
    expect(
      resolveZIMKitFileMessageType('png', autoDetectType: false),
      ZIMMessageType.file,
    );
  });
}
