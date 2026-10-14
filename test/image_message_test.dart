import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/components/messages/image_message.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/core/screen_util.dart';

void main() {
  setUp(() {
    ZIMScreenUtil.configure(
      data: const MediaQueryData(size: Size(400, 800)),
      designSize: const Size(400, 800),
      minTextAdapt: false,
      splitScreenMode: false,
    );
  });

  testWidgets('received network image builds without an OctoImage assertion', (
    tester,
  ) async {
    final message = ZIMKitMessage()
      ..type = ZIMMessageType.image
      ..info.direction = ZIMMessageDirection.receive
      ..imageContent = (ZIMKitMessageImageContent()
        ..fileLocalPath = ''
        ..largeImageDownloadUrl = 'https://example.invalid/image.png'
        ..originalImageWidth = 200
        ..originalImageHeight = 200);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: Column(children: [ZIMKitImageMessage(message: message)]),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
