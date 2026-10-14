import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_uikit_signaling_plugin/src/internal/core.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/components/toolbar/more/panel.dart';
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
