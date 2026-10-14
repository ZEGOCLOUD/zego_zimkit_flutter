import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/components/messages/image_message.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
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

  testWidgets('outgoing image uses local dimensions before upload', (
    tester,
  ) async {
    final imageFile = await tester.runAsync(_createWideImageFile);
    expect(imageFile, isNotNull);
    final file = imageFile!;
    final imageDimensions = await tester.runAsync(
      () => readZIMKitImageDimensions(file.path),
    );
    expect(imageDimensions?.width, 200);
    expect(imageDimensions?.height, 100);

    final imageMessage = ZIMImageMessage(file.path);
    imageDimensions!.applyTo(imageMessage);
    expect(imageMessage.toKIT().imageContent!.aspectRatio, closeTo(2, 0.01));

    await tester.runAsync(() => file.parent.delete(recursive: true));
  });
}

Future<File> _createWideImageFile() async {
  final recorder = ui.PictureRecorder();
  Canvas(
    recorder,
  ).drawRect(const Rect.fromLTWH(0, 0, 200, 100), Paint()..color = Colors.blue);
  final image = await recorder.endRecording().toImage(200, 100);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  final directory = await Directory.systemTemp.createTemp(
    'zimkit-image-message-test-',
  );
  final file = File('${directory.path}/wide.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List());
  return file;
}
