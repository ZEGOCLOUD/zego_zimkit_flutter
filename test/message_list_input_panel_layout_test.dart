import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/components/audio/status.dart';
import 'package:zego_zimkit/src/components/messages/input/configs.dart';
import 'package:zego_zimkit/src/components/messages/input/widget.dart';
import 'package:zego_zimkit/src/components/messages/list_page/widget.dart';
import 'package:zego_zimkit/src/config.defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

void main() {
  setUp(() {
    ZIMScreenUtil.configure(
      data: const MediaQueryData(size: Size(400, 800)),
      designSize: const Size(400, 800),
      minTextAdapt: false,
      splitScreenMode: false,
    );
  });

  testWidgets('message list moves up when the emoji panel opens', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus();
    const messageListKey = ValueKey('message-list');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox.expand(
            child: ZIMKitMessageListPageLayout(
              inputHeight: 140,
              isMultiMode: false,
              messageList: const ColoredBox(
                key: messageListKey,
                color: Colors.white,
              ),
              messageInput: ZIMKitMessageInput(
                conversationID: 'peer-1',
                recordStatus: recordStatus,
                inputConfig: ZIMKitInputConfig(
                  smallButtons: [ZIMKitInputButtonName.emoji],
                  expandButtons: const [],
                  emojis: const ['😀'],
                ),
                config: const ZIMKitMessageInputConfigs(
                  showRecordButton: false,
                  showPickMediaButton: false,
                  showMoreButton: false,
                ),
              ),
              recordLocker: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    final listHeightBefore = tester.getSize(find.byKey(messageListKey)).height;

    await tester.tap(find.byIcon(Icons.sentiment_satisfied_outlined));
    await tester.pumpAndSettle();

    final listHeightAfter = tester.getSize(find.byKey(messageListKey)).height;
    expect(listHeightAfter, lessThan(listHeightBefore - 100));
  });
}
