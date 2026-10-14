import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/audio/core.dart';
import 'package:zego_zimkit/src/components/audio/defines.dart';
import 'package:zego_zimkit/src/components/audio/status.dart';
import 'package:zego_zimkit/src/components/messages/input/configs.dart';
import 'package:zego_zimkit/src/components/messages/input/widget.dart';
import 'package:zego_zimkit/src/config.defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

const audioChannel = MethodChannel('zego_zim_audio');
const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  final audioCalls = <String>[];

  setUp(() {
    audioCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(audioChannel, (call) async {
        audioCalls.add(call.method);
        return null;
      })
      ..setMockMethodCallHandler(pathProviderChannel, (call) async {
        return '/tmp';
      });

    ZIMScreenUtil.configure(
      data: const MediaQueryData(size: Size(400, 800)),
      designSize: const Size(400, 800),
      minTextAdapt: false,
      splitScreenMode: false,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(audioChannel, null)
      ..setMockMethodCallHandler(pathProviderChannel, null);
  });

  testWidgets(
    'voice mode toggle does not record and returning to text keeps the draft',
    (tester) async {
      final controller = TextEditingController(text: 'draft message');
      final focusNode = FocusNode();
      final recordStatus = ZIMKitRecordStatus()..register();
      addTearDown(() {
        recordStatus.unregister();
        focusNode.dispose();
        controller.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZIMKitMessageInput(
              conversationID: 'peer-1',
              recordStatus: recordStatus,
              inputConfig: ZIMKitInputConfig(
                smallButtons: const [ZIMKitInputButtonName.audio],
                expandButtons: const [],
              ),
              config: ZIMKitMessageInputConfigs(
                showMoreButton: false,
                editingController: controller,
                inputFocusNode: focusNode,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pumpAndSettle();

      expect(audioCalls, isEmpty);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Hold to talk'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.keyboard));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(controller.text, 'draft message');
      expect(focusNode.hasFocus, isTrue);
    },
  );

  testWidgets('pressing the voice input button starts recording', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(recordStatus.unregister);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMessageInput(
            conversationID: 'peer-1',
            recordStatus: recordStatus,
            inputConfig: ZIMKitInputConfig(
              smallButtons: const [ZIMKitInputButtonName.audio],
              expandButtons: const [],
            ),
            config: const ZIMKitMessageInputConfigs(showMoreButton: false),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();
    expect(audioCalls, isEmpty);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(audioCalls, contains('startRecord'));

    await gesture.up();
    await tester.pump();
    expect(audioCalls, contains('completeRecord'));
  });

  testWidgets('voice action in the more panel only switches input mode', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(recordStatus.unregister);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMessageInput(
            conversationID: 'peer-1',
            recordStatus: recordStatus,
            inputConfig: ZIMKitInputConfig(
              smallButtons: const [ZIMKitInputButtonName.expand],
              expandButtons: const [ZIMKitInputButtonName.audio],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();

    expect(audioCalls, isEmpty);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Hold to talk'), findsOneWidget);
  });

  testWidgets('locked recording cannot switch back to text mode', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(recordStatus.unregister);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMessageInput(
            conversationID: 'peer-1',
            recordStatus: recordStatus,
            inputConfig: ZIMKitInputConfig(
              smallButtons: const [ZIMKitInputButtonName.audio],
              expandButtons: const [],
            ),
            config: const ZIMKitMessageInputConfigs(showMoreButton: false),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();
    recordStatus.lockerStateNotifier.value = ZIMKitRecordLockerState.locked;
    await tester.pump();

    await tester.tap(find.byIcon(Icons.keyboard));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Hold to talk'), findsOneWidget);
  });

  testWidgets('failed locked recording releases the voice mode switch', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(recordStatus.unregister);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMessageInput(
            conversationID: 'peer-1',
            recordStatus: recordStatus,
            inputConfig: ZIMKitInputConfig(
              smallButtons: const [ZIMKitInputButtonName.audio],
              expandButtons: const [],
            ),
            config: const ZIMKitMessageInputConfigs(showMoreButton: false),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();
    recordStatus.stateNotifier.value = ZIMKitRecordState.recording;
    recordStatus.lockerStateNotifier.value = ZIMKitRecordLockerState.locked;
    await tester.pump();

    ZIMKitAudioInstance().onRecorderFailed(1001);
    await tester.pump();

    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
    expect(
      recordStatus.lockerStateNotifier.value,
      ZIMKitRecordLockerState.idle,
    );
    await tester.tap(find.byIcon(Icons.keyboard));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('voice mode preserves custom toolbar buttons', (tester) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(recordStatus.unregister);

    var inputConfig = ZIMKitInputConfig(
      smallButtons: const [ZIMKitInputButtonName.audio],
      expandButtons: const [],
    );
    var showMoreButton = false;
    late StateSetter updateInput;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateInput = setState;
              return ZIMKitMessageInput(
                conversationID: 'peer-1',
                recordStatus: recordStatus,
                inputConfig: inputConfig,
                config: ZIMKitMessageInputConfigs(
                  showMoreButton: showMoreButton,
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();

    updateInput(() {
      inputConfig = ZIMKitInputConfig(
        smallButtons: const [ZIMKitInputButtonName.expand],
        expandButtons: const [ZIMKitInputButtonName.audio],
        customButtonBuilders: {
          ZIMKitInputButtonName.expand: (context) => const SizedBox(
            width: 40,
            height: 40,
            child: Center(child: Text('custom expand')),
          ),
        },
      );
      showMoreButton = true;
    });
    await tester.pumpAndSettle();

    expect(find.text('custom expand'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });
}
