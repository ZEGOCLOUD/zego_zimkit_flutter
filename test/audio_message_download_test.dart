import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/src/internal/zim_engine.dart';
import 'package:zego_zim/src/internal/zim_manager.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

const _zimChannel = MethodChannel('zego_zim_plugin');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final methodCalls = <MethodCall>[];

  setUp(() {
    methodCalls.clear();
    ZIMManager.instanceHandle = 'audio-message-download-test';
    ZIMManager.engineMap[ZIMManager.instanceHandle!] = ZIMEngine(
      handle: ZIMManager.instanceHandle!,
      appID: 1,
      appSign: 'test',
      channel: _zimChannel,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_zimChannel, (call) async {
          methodCalls.add(call);
          if (call.method == 'downloadMediaFile') {
            final downloadedAudio = ZIMAudioMessage(
              '/tmp/received-audio.mp3',
              audioDuration: 2,
            );
            return {'message': downloadedAudio.toMap()};
          }
          return null;
        });
  });

  tearDown(() {
    ZIMManager.engineMap.clear();
    ZIMManager.instanceHandle = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_zimChannel, null);
    ZIMKitCore.instance.db.clear();
  });

  test('received audio message requests its original file download', () async {
    const conversationID = 'audio-download-peer';
    final audioMessage = ZIMAudioMessage('', audioDuration: 2)
      ..conversationID = conversationID
      ..conversationType = ZIMConversationType.peer
      ..messageID = 17
      ..localMessageID = 23
      ..fileUID = 'remote-audio-uid'
      ..direction = ZIMMessageDirection.receive;

    final messages = ZIMKitCore.instance.db.messages(
      conversationID,
      ZIMConversationType.peer,
    )..init([audioMessage]);

    ZIMKitCore.instance.downloadMediaFile(messages.notifier.value.single.value);
    await Future<void>.delayed(Duration.zero);

    final downloadCalls = methodCalls
        .where((call) => call.method == 'downloadMediaFile')
        .toList();
    expect(downloadCalls, hasLength(1));
    expect(
      downloadCalls.single.arguments['fileType'],
      ZIMMediaFileType.originalFile.value,
    );
  });
}
