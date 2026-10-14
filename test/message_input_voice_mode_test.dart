import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zim_audio/zego_zim_audio.dart';
import 'package:zego_zimkit/src/audio/core.dart';
import 'package:zego_zimkit/src/components/audio/defines.dart';
import 'package:zego_zimkit/src/components/audio/events.dart';
import 'package:zego_zimkit/src/components/audio/status.dart';
import 'package:zego_zimkit/src/components/messages/input/configs.dart';
import 'package:zego_zimkit/src/components/messages/input/events.dart';
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
        if (call.method == 'isRecording') {
          return false;
        }
        return null;
      })
      ..setMockMethodCallHandler(pathProviderChannel, (call) async {
        return '/tmp';
      });
    ZIMKitAudioInstance().data.recordingCache.clear();

    ZIMScreenUtil.configure(
      data: const MediaQueryData(size: Size(400, 800)),
      designSize: const Size(400, 800),
      minTextAdapt: false,
      splitScreenMode: false,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  test('generic audio errors do not consume an active recording', () async {
    final audio = ZIMKitAudioInstance();
    var completed = 0;
    final failed = <int>[];
    audio.data.recordingCache.clear();
    audio.data.addRecording(
      '/tmp/generic-error.mp3',
      'peer-1',
      ZIMConversationType.peer,
      60000,
      onCompleted: (_) async {
        completed++;
      },
      onFailed: failed.add,
    );

    audio.onError(
      ZIMAudioError(ZIMAudioErrorCode.unknownFailed, 'diagnostic error'),
    );
    audio.onRecorderCompleted(1000);
    await Future<void>.delayed(Duration.zero);

    expect(completed, 1);
    expect(failed, isEmpty);
  });

  test('uninit drops callbacks from the previous recording session', () async {
    final audio = ZIMKitAudioInstance();
    var oldCompleted = false;
    var newCompleted = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call.method);
          if (call.method == 'startRecord') {
            audio.onRecorderStarted();
          }
          if (call.method == 'isRecording') {
            return true;
          }
          if (call.method == 'cancelRecord') {
            audio.onRecorderCancelled();
          }
          return null;
        });

    await audio.startRecord(
      'old-peer',
      ZIMConversationType.peer,
      onCompleted: (_) async {
        oldCompleted = true;
      },
    );
    await audio.uninit();
    expect(audio.data.recordingCache, isEmpty);
    expect(
      audioCalls.indexOf('cancelRecord'),
      lessThan(audioCalls.indexOf('uninit')),
    );

    await audio.init();
    await audio.startRecord(
      'new-peer',
      ZIMConversationType.peer,
      onCompleted: (_) async {
        newCompleted = true;
      },
    );
    audio.onRecorderCompleted(1000);
    await Future<void>.delayed(Duration.zero);

    expect(oldCompleted, isFalse);
    expect(newCompleted, isTrue);
    await audio.uninit();
  });

  test('uninit waits for an already requested recording completion', () async {
    final audio = ZIMKitAudioInstance();
    var completed = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call.method);
          if (call.method == 'startRecord') {
            audio.onRecorderStarted();
          }
          if (call.method == 'isRecording') {
            return false;
          }
          return null;
        });

    await audio.startRecord(
      'peer-1',
      ZIMConversationType.peer,
      onCompleted: (_) async {
        completed = true;
      },
    );
    await audio.completeRecord();
    final uninitFuture = audio.uninit();
    await Future<void>.delayed(Duration.zero);

    expect(completed, isFalse);
    audio.onRecorderCompleted(1000);
    await uninitFuture;

    expect(completed, isTrue);
  });

  test(
    'a new recording is rejected until the prior session reaches a terminal event',
    () async {
      final audio = ZIMKitAudioInstance();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'startRecord') {
              audio.onRecorderStarted();
            }
            return null;
          });

      await audio.startRecord('old-peer', ZIMConversationType.peer);
      await audio.cancelRecord();

      await expectLater(
        audio.startRecord('new-peer', ZIMConversationType.peer),
        throwsStateError,
      );
      audio.onRecorderCancelled();
      await audio.startRecord('new-peer', ZIMConversationType.peer);
      audio.onRecorderStarted();
      audio.onRecorderCompleted(1000);
      await audio.uninit();
    },
  );

  test(
    'uninit releases the recorder when a terminal event is missing',
    () async {
      final audio = ZIMKitAudioInstance();
      var startCallCount = 0;
      var newSessionCompleted = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'startRecord' && startCallCount++ == 0) {
              audio.onRecorderStarted();
            }
            if (call.method == 'isRecording') {
              return true;
            }
            return null;
          });

      await audio.startRecord('peer-1', ZIMConversationType.peer);

      await expectLater(
        audio.uninit().timeout(const Duration(seconds: 3)),
        completes,
      );
      expect(audio.data.recordingCache, isEmpty);

      await audio.init();
      audio.onRecorderStarted();
      audio.onRecorderFailed(ZIMAudioErrorCode.unknownFailed);
      expect(audio.data.recordingCache, isEmpty);

      await audio.startRecord(
        'new-peer',
        ZIMConversationType.peer,
        onCompleted: (_) async {
          newSessionCompleted = true;
        },
      );
      audio.onRecorderStarted();
      audio.onRecorderCompleted(1000);

      expect(newSessionCompleted, isTrue);
      await audio.uninit();
    },
  );

  test(
    'recorder events cannot clear quarantine after native uninit fails',
    () async {
      final audio = ZIMKitAudioInstance();
      var failNativeUninit = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'startRecord') {
              audio.onRecorderStarted();
            }
            if (call.method == 'isRecording') {
              return true;
            }
            if (call.method == 'uninit' && failNativeUninit) {
              throw PlatformException(code: 'uninit_failed');
            }
            return null;
          });

      await audio.startRecord('old-peer', ZIMConversationType.peer);
      await expectLater(audio.uninit(), throwsA(isA<PlatformException>()));

      await audio.init();
      await expectLater(
        audio.startRecord('new-peer', ZIMConversationType.peer),
        throwsStateError,
      );

      audio.onRecorderStarted();
      audio.onRecorderFailed(ZIMAudioErrorCode.unknownFailed);
      await expectLater(
        audio.startRecord('new-peer', ZIMConversationType.peer),
        throwsStateError,
      );

      failNativeUninit = false;
      await audio.uninit();
      await audio.init();
      await audio.startRecord('new-peer', ZIMConversationType.peer);
      audio.onRecorderStarted();
      audio.onRecorderCompleted(1000);
      await audio.uninit();
    },
  );

  test('native uninit failure quarantines an idle recorder', () async {
    final audio = ZIMKitAudioInstance();
    var failNativeUninit = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call.method);
          if (call.method == 'uninit' && failNativeUninit) {
            throw PlatformException(code: 'uninit_failed');
          }
          return null;
        });

    await expectLater(audio.uninit(), throwsA(isA<PlatformException>()));
    expect(audio.data.recordingCache, isEmpty);

    await audio.init();
    await expectLater(
      audio.startRecord('peer-1', ZIMConversationType.peer),
      throwsStateError,
    );

    failNativeUninit = false;
    await audio.uninit();
    await audio.init();
    await audio.startRecord('peer-1', ZIMConversationType.peer);
    audio.onRecorderStarted();
    audio.onRecorderCompleted(1000);
    await audio.uninit();
  });

  test(
    'uninit rejects recording starts until native teardown completes',
    () async {
      final audio = ZIMKitAudioInstance();
      final nativeUninitGate = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'uninit') {
              await nativeUninitGate.future;
            }
            return null;
          });

      final uninitFuture = audio.uninit();
      await Future<void>.delayed(Duration.zero);
      expect(audioCalls, contains('uninit'));

      await expectLater(
        audio.startRecord('peer-1', ZIMConversationType.peer),
        throwsStateError,
      );

      nativeUninitGate.complete();
      await uninitFuture;
    },
  );

  test(
    'cancel requested before recorder starts waits for started event',
    () async {
      final audio = ZIMKitAudioInstance();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'cancelRecord') {
              audio.onRecorderCancelled();
            }
            return null;
          });

      await audio.startRecord('peer-1', ZIMConversationType.peer);
      await audio.cancelRecord();

      expect(audioCalls, ['startRecord']);
      expect(audio.data.recordingCache, hasLength(1));

      audio.onRecorderStarted();
      await Future<void>.delayed(Duration.zero);

      expect(audioCalls, ['startRecord', 'cancelRecord']);
      expect(audio.data.recordingCache, isEmpty);
      await audio.uninit();
    },
  );

  test('cancel failure quarantines the recorder until native uninit', () async {
    final audio = ZIMKitAudioInstance();
    final errorCodes = <int>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call.method);
          if (call.method == 'cancelRecord') {
            throw PlatformException(code: 'cancel_failed');
          }
          return null;
        });

    await audio.startRecord(
      'peer-1',
      ZIMConversationType.peer,
      onFailed: errorCodes.add,
    );
    audio.onRecorderStarted();

    await expectLater(audio.cancelRecord(), throwsA(isA<PlatformException>()));

    expect(errorCodes, [ZIMAudioErrorCode.unknownFailed]);
    expect(audio.data.recordingCache, isEmpty);
    await expectLater(
      audio.startRecord('new-peer', ZIMConversationType.peer),
      throwsStateError,
    );

    await audio.uninit();
    await audio.init();
    await audio.startRecord('new-peer', ZIMConversationType.peer);
    audio.onRecorderStarted();
    audio.onRecorderCompleted(1000);
    await audio.uninit();
  });

  test(
    'discard handles native cancellation failure without an uncaught error',
    () async {
      final audio = ZIMKitAudioInstance();
      final errorCodes = <int>[];
      final recordStatus = ZIMKitRecordStatus()..register();
      addTearDown(recordStatus.unregister);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'cancelRecord') {
              throw PlatformException(code: 'cancel_failed');
            }
            return null;
          });

      final generation = recordStatus.startRecording();
      await audio.startRecord(
        'peer-1',
        ZIMConversationType.peer,
        onStarted: () => recordStatus.markRecordingStarted(generation),
        onFailed: errorCodes.add,
      );
      audio.onRecorderStarted();

      recordStatus.cancelRecording();
      await Future<void>.delayed(Duration.zero);

      expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
      expect(errorCodes, [ZIMAudioErrorCode.unknownFailed]);
      expect(audio.data.recordingCache, isEmpty);
      await audio.uninit();
    },
  );

  test(
    'send handles native completion failure without leaving a stuck session',
    () async {
      final audio = ZIMKitAudioInstance();
      final errorCodes = <int>[];
      final recordStatus = ZIMKitRecordStatus()..register();
      addTearDown(recordStatus.unregister);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'completeRecord') {
              throw PlatformException(code: 'complete_failed');
            }
            return null;
          });

      final generation = recordStatus.startRecording();
      await audio.startRecord(
        'peer-1',
        ZIMConversationType.peer,
        onStarted: () => recordStatus.markRecordingStarted(generation),
        onFailed: errorCodes.add,
      );
      audio.onRecorderStarted();

      recordStatus.sendRecording();
      await Future<void>.delayed(Duration.zero);

      expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
      expect(errorCodes, [ZIMAudioErrorCode.unknownFailed]);
      expect(audio.data.recordingCache, isEmpty);
      await expectLater(
        audio.startRecord('new-peer', ZIMConversationType.peer),
        throwsStateError,
      );

      await audio.uninit();
      await audio.init();
      await audio.startRecord('new-peer', ZIMConversationType.peer);
      audio.onRecorderStarted();
      audio.onRecorderCompleted(1000);
      await audio.uninit();
    },
  );

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
    ZIMKitAudioInstance().onRecorderStarted();
    await tester.pump();

    await gesture.up();
    await tester.pump();
    expect(audioCalls, contains('completeRecord'));
  });

  testWidgets('quick release waits for the recorder started event', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(() {
      recordStatus.cancelIfRecording();
      recordStatus.unregister();
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
            config: const ZIMKitMessageInputConfigs(showMoreButton: false),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pump();

    expect(audioCalls, contains('startRecord'));
    expect(audioCalls, isNot(contains('completeRecord')));

    ZIMKitAudioInstance().onRecorderStarted();
    await tester.pump();
    expect(audioCalls, contains('completeRecord'));
  });

  testWidgets('screen reader tap starts a locked voice recording', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(() {
      recordStatus.cancelIfRecording();
      recordStatus.unregister();
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
            config: const ZIMKitMessageInputConfigs(showMoreButton: false),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();

    final semanticsButton = find.semantics.byLabel('Start voice recording');
    expect(semanticsButton, findsOneWidget);
    tester.semantics.tap(semanticsButton);
    await tester.pump();

    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.recording);
    expect(
      recordStatus.lockerStateNotifier.value,
      ZIMKitRecordLockerState.locked,
    );
    expect(audioCalls, contains('startRecord'));
    expect(recordStatus.isRecordingReady, isFalse);

    ZIMKitAudioInstance().onRecorderStarted();
    expect(recordStatus.isRecordingReady, isTrue);
    semantics.dispose();
  });

  testWidgets('disposing the message input cancels an active recording', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    addTearDown(() {
      recordStatus.unregister();
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
            config: const ZIMKitMessageInputConfigs(showMoreButton: false),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.recording);
    expect(audioCalls, isNot(contains('cancelRecord')));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
    expect(audioCalls, isNot(contains('cancelRecord')));

    ZIMKitAudioInstance().onRecorderStarted();
    await tester.pump();
    expect(audioCalls, contains('cancelRecord'));
    ZIMKitAudioInstance().onRecorderCancelled();
    await gesture.cancel();
  });

  testWidgets('sends a completed recording after the input is disposed', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    var preSendCalled = false;
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
            events: ZIMKitMessageInputEvents(
              preMessageSending: (message) {
                preSendCalled = true;
                return message;
              },
            ),
            config: const ZIMKitMessageInputConfigs(showMoreButton: false),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    ZIMKitAudioInstance().onRecorderStarted();
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final audio = ZIMKitAudioInstance();
    final filePath = audio.data.getTopRecordedFile().absFilePath;
    File(filePath).writeAsBytesSync([1]);
    await tester.pumpWidget(const SizedBox());
    audio.onRecorderCompleted(1000);
    await tester.pump();
    await tester.pump();

    expect(preSendCalled, isTrue);
    File(filePath).deleteSync();
  });

  testWidgets('late cancelled start does not cancel a newer recording', (
    tester,
  ) async {
    final pendingOldStart = Completer<void>();
    var startCallCount = 0;
    final audio = ZIMKitAudioInstance();
    Future<Object?> mockAudioCall(MethodCall call) async {
      audioCalls.add(call.method);
      if (call.method == 'startRecord' && startCallCount++ == 0) {
        await pendingOldStart.future;
      }
      if (call.method == 'cancelRecord') {
        audio.onRecorderCancelled();
      }
      return null;
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, mockAudioCall);

    final oldStatus = ZIMKitRecordStatus()..register();
    addTearDown(oldStatus.unregister);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMessageInput(
            conversationID: 'old-peer',
            recordStatus: oldStatus,
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
    final oldGesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    audio.onRecorderStarted();
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    final newStatus = ZIMKitRecordStatus()..register();
    addTearDown(() {
      if (newStatus.stateNotifier.value == ZIMKitRecordState.recording) {
        newStatus.cancelRecording();
      }
      newStatus.unregister();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMessageInput(
            conversationID: 'new-peer',
            recordStatus: newStatus,
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
    final newGesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));

    pendingOldStart.complete();
    await tester.pump();
    expect(newStatus.stateNotifier.value, ZIMKitRecordState.recording);
    expect(
      audioCalls.where((method) => method == 'cancelRecord'),
      hasLength(1),
    );

    await oldGesture.cancel();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await newGesture.cancel();
  });

  testWidgets(
    'recording start errors reset the voice input and report failure',
    (tester) async {
      final recordStatus = ZIMKitRecordStatus()..register();
      final errorCodes = <int>[];
      addTearDown(() {
        if (recordStatus.stateNotifier.value == ZIMKitRecordState.recording) {
          recordStatus.cancelRecording();
        }
        recordStatus.unregister();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZIMKitMessageInput(
              conversationID: 'peer-1',
              recordStatus: recordStatus,
              recordEvents: ZIMKitAudioRecordEvents(onFailed: errorCodes.add),
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
      final recordingsBeforeStart = List.of(
        ZIMKitAudioInstance().data.recordingCache,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async {
            audioCalls.add(call.method);
            if (call.method == 'startRecord') {
              throw PlatformException(
                code: '${ZIMAudioErrorCode.noPermission}',
                message: 'Microphone denied',
              );
            }
            return null;
          });

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Hold to talk')),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
      expect(errorCodes, [ZIMAudioErrorCode.noPermission]);
      expect(ZIMKitAudioInstance().data.recordingCache, recordingsBeforeStart);
      expect(
        find.text('Recording could not start. Please try again.'),
        findsOneWidget,
      );

      await gesture.up();
      await tester.pump();
      expect(audioCalls, contains('startRecord'));
      expect(audioCalls, isNot(contains('completeRecord')));
    },
  );

  testWidgets('reports recorder failures delivered after send returns idle', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus()..register();
    final errorCodes = <int>[];
    addTearDown(() {
      recordStatus.unregister();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZIMKitMessageInput(
            conversationID: 'peer-1',
            recordStatus: recordStatus,
            recordEvents: ZIMKitAudioRecordEvents(onFailed: errorCodes.add),
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

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    ZIMKitAudioInstance().onRecorderStarted();
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
    ZIMKitAudioInstance().onRecorderFailed(
      ZIMAudioErrorCode.recorderTimeTooShort,
    );
    await tester.pump();

    expect(errorCodes, [ZIMAudioErrorCode.recorderTimeTooShort]);
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

  testWidgets('disposing locked voice input cancels the recording', (
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
    recordStatus.startRecording(locked: true);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(audioCalls, contains('cancelRecord'));
    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
    expect(
      recordStatus.lockerStateNotifier.value,
      ZIMKitRecordLockerState.idle,
    );
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
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to talk')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    recordStatus.lockerStateNotifier.value = ZIMKitRecordLockerState.locked;
    await tester.pump();

    ZIMKitAudioInstance().onRecorderFailed(
      ZIMAudioErrorCode.recorderTimeTooShort,
    );
    await tester.pump();

    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
    expect(
      recordStatus.lockerStateNotifier.value,
      ZIMKitRecordLockerState.idle,
    );
    await tester.tap(find.byIcon(Icons.keyboard));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await gesture.cancel();
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
