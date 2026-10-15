import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:zego_uikit_signaling_plugin/src/internal/core.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/audio/status.dart';
import 'package:zego_zimkit/src/components/messages/input/widget.dart';
import 'package:zego_zimkit/src/components/messages/list/configs.dart';
import 'package:zego_zimkit/src/components/messages/list/styles.dart';
import 'package:zego_zimkit/src/components/messages/list/widget.dart';
import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/components/toolbar/more/panel.dart';
import 'package:zego_zimkit/src/config.defines.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/utils/screen_util/core/screen_util.dart';

void main() {
  final core = ZIMKitCore.instance;
  final signalingCore = ZegoSignalingPluginCore();

  tearDown(() {
    core.clear();
    core.currentToken = '';
    core.loginCompleter = null;
    signalingCore.currentUser = null;
    signalingCore.eventCenter.connectionState = ZIMConnectionState.disconnected;
  });

  testWidgets(
    'chat message list hides history until initial scroll completes',
    (tester) async {
      const conversationID = 'peer-message-list';
      const messageCount = 12;
      final previousUser = core.currentUser;
      final scrollController = ScrollController();
      final messages =
          core.db.messages(conversationID, ZIMConversationType.peer)
            ..inited = true
            ..noMore = true
            ..notifier.value = List.generate(messageCount, (index) {
              final textContent = ZIMKitMessageTextContent()
                ..text = 'message-$index';
              final message = ZIMKitMessage()
                ..type = ZIMMessageType.text
                ..textContent = textContent
                ..info.timestamp =
                    DateTime.now().millisecondsSinceEpoch + index * 60000;
              return ValueNotifier<ZIMKitMessage>(message);
            });

      core.currentUser = ZIMUserFullInfo(
        baseInfo: ZIMUserInfo()..userID = 'current-user',
      );
      core.db.conversations.init([
        ZIMConversation()
          ..conversationID = conversationID
          ..type = ZIMConversationType.peer,
      ]);
      expect(messages.notifier.value.length, messageCount);

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                height: 300,
                child: ZIMKitMessageListView(
                  conversationID: conversationID,
                  config: ZIMKitMessageListConfigs(
                    scrollController: scrollController,
                  ),
                  style: ZIMKitMessageListStyles(
                    itemBuilder: (context, message, _) => SizedBox(
                      height: 80,
                      child: Text(message.textContent!.text),
                    ),
                    backgroundBuilder: (context, defaultWidget) => Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: Colors.transparent),
                        const Center(child: Text('custom-background-marker')),
                        defaultWidget,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final maskFinder = find.byType(Visibility);
        final mask = tester.widget<Visibility>(maskFinder);
        expect(mask.visible, isTrue);
        expect(tester.getSize(maskFinder), const Size(300, 300));
        expect(
          find.descendant(
            of: maskFinder,
            matching: find.text('custom-background-marker'),
          ),
          findsOneWidget,
        );
        final maskColors = tester
            .widgetList<ColoredBox>(
              find.descendant(
                of: maskFinder,
                matching: find.byType(ColoredBox),
              ),
            )
            .map((coloredBox) => coloredBox.color)
            .toList();
        expect(
          maskColors,
          contains(ZIMKitMessageStyle.messageListBackgroundColor),
        );

        await tester.pump();

        expect(tester.widget<Visibility>(maskFinder).visible, isFalse);
        final latestMessage = find.text('message-${messageCount - 1}');
        expect(latestMessage, findsOneWidget);
        expect(
          tester
              .getRect(latestMessage)
              .overlaps(tester.getRect(find.byType(ListView))),
          isTrue,
        );
        expect(scrollController.offset, greaterThan(0));
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        scrollController.dispose();
        core.currentUser = previousUser;
      }
    },
  );

  testWidgets('fallback more panel shows each extra action once', (
    tester,
  ) async {
    ZIMScreenUtil.configure(
      data: const MediaQueryData(size: Size(400, 800)),
      designSize: const Size(400, 800),
      minTextAdapt: false,
      splitScreenMode: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMoreActionsPanelWidget(
            conversationID: 'peer-1',
            conversationType: ZIMConversationType.peer,
            onActionSelected: null,
            extraActions: const [Text('extra-action')],
          ),
        ),
      ),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(grid.childrenDelegate.estimatedChildCount, 4);
  });

  testWidgets('more panel camera picker follows the app locale', (
    tester,
  ) async {
    ZIMScreenUtil.configure(
      data: const MediaQueryData(size: Size(400, 800)),
      designSize: const Size(400, 800),
      minTextAdapt: false,
      splitScreenMode: false,
    );

    await _expectEnglishCameraPicker(
      tester,
      home: Scaffold(
        body: ZIMKitMoreActionsPanelWidget(
          conversationID: 'peer-1',
          conversationType: ZIMConversationType.peer,
          onActionSelected: null,
        ),
      ),
      cameraButton: find.byIcon(Icons.camera_alt),
    );
  });

  testWidgets('message input camera picker follows the app locale', (
    tester,
  ) async {
    await _expectEnglishCameraPicker(
      tester,
      home: Scaffold(
        body: ZIMKitMessageInput(
          conversationID: 'peer-1',
          recordStatus: ZIMKitRecordStatus(),
          inputConfig: ZIMKitInputConfig(
            smallButtons: const [ZIMKitInputButtonName.takePhoto],
            expandButtons: const [],
          ),
        ),
      ),
      cameraButton: find.byIcon(Icons.camera_alt_outlined),
    );
  });

  test('disconnect waits for the signaling plugin to finish', () async {
    core.currentUser = ZIMUserFullInfo(
      baseInfo: ZIMUserInfo()
        ..userID = 'user-1'
        ..userName = 'User One',
    );
    signalingCore.currentUser = ZIMUserInfo()..userID = 'user-1';
    signalingCore.eventCenter.connectionState = ZIMConnectionState.connected;

    var completed = false;
    final disconnect = core.disconnectUser().then((_) => completed = true);

    try {
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);
    } finally {
      signalingCore.eventCenter.connectionState =
          ZIMConnectionState.disconnected;
    }

    await disconnect;
    expect(completed, isTrue);
  });
}

Future<void> _expectEnglishCameraPicker(
  WidgetTester tester, {
  required Widget home,
  required Finder cameraButton,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      home: home,
    ),
  );

  expect(cameraButton, findsOneWidget);
  await tester.tap(cameraButton);
  await tester.pumpAndSettle();

  final picker = tester.widget<CameraPicker>(find.byType(CameraPicker));
  expect(picker.locale, const Locale('en'));
  expect(
    tester
        .state<CameraPickerState>(find.byType(CameraPicker))
        .textDelegate
        .confirm,
    'Confirm',
  );

  await tester.pumpWidget(const SizedBox.shrink());
}
