import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/audio/core.dart';
import 'package:zego_zimkit/src/components/audio/defines.dart';
import 'package:zego_zimkit/src/components/audio/record_overlay.dart';
import 'package:zego_zimkit/src/components/audio/status.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => '/tmp',
        );
  });

  test('releasing a recording shorter than 500ms cancels it', () {
    final durationNotifier = ZIMKitAudioInstance().data.recordDurationNotifier;
    addTearDown(() => durationNotifier.value = 0);
    durationNotifier.value = 499;

    final recordStatus = ZIMKitRecordStatus();
    final generation = recordStatus.startRecording();
    recordStatus.markRecordingStarted(generation);
    final stateChanges = <ZIMKitRecordState>[];
    recordStatus.stateNotifier.addListener(
      () => stateChanges.add(recordStatus.stateNotifier.value),
    );

    expect(
      recordStatus.releaseHoldGesture(),
      ZIMKitRecordFinishResult.canceled,
    );
    expect(stateChanges, contains(ZIMKitRecordState.cancel));
    expect(stateChanges, isNot(contains(ZIMKitRecordState.complete)));
    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
  });

  test(
    'direct send discards a zero-duration recording instead of completing',
    () {
      final durationNotifier =
          ZIMKitAudioInstance().data.recordDurationNotifier;
      addTearDown(() => durationNotifier.value = 0);
      durationNotifier.value = 0;

      final recordStatus = ZIMKitRecordStatus();
      final generation = recordStatus.startRecording(locked: true);
      recordStatus.markRecordingStarted(generation);
      final stateChanges = <ZIMKitRecordState>[];
      recordStatus.stateNotifier.addListener(
        () => stateChanges.add(recordStatus.stateNotifier.value),
      );

      recordStatus.sendRecording();

      expect(stateChanges, contains(ZIMKitRecordState.cancel));
      expect(stateChanges, isNot(contains(ZIMKitRecordState.complete)));
      expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
    },
  );

  test('direct send discards a recording shorter than 500ms', () {
    final durationNotifier = ZIMKitAudioInstance().data.recordDurationNotifier;
    addTearDown(() => durationNotifier.value = 0);
    durationNotifier.value = 499;

    final recordStatus = ZIMKitRecordStatus();
    final generation = recordStatus.startRecording(locked: true);
    recordStatus.markRecordingStarted(generation);
    final stateChanges = <ZIMKitRecordState>[];
    recordStatus.stateNotifier.addListener(
      () => stateChanges.add(recordStatus.stateNotifier.value),
    );

    recordStatus.sendRecording();

    expect(stateChanges, contains(ZIMKitRecordState.cancel));
    expect(stateChanges, isNot(contains(ZIMKitRecordState.complete)));
    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
  });

  test('direct send completes at the 500ms minimum duration', () {
    final durationNotifier = ZIMKitAudioInstance().data.recordDurationNotifier;
    addTearDown(() => durationNotifier.value = 0);
    durationNotifier.value = 500;

    final recordStatus = ZIMKitRecordStatus();
    final generation = recordStatus.startRecording(locked: true);
    recordStatus.markRecordingStarted(generation);
    final stateChanges = <ZIMKitRecordState>[];
    recordStatus.stateNotifier.addListener(
      () => stateChanges.add(recordStatus.stateNotifier.value),
    );

    recordStatus.sendRecording();

    expect(stateChanges, contains(ZIMKitRecordState.complete));
    expect(stateChanges, isNot(contains(ZIMKitRecordState.cancel)));
    expect(recordStatus.stateNotifier.value, ZIMKitRecordState.idle);
  });

  testWidgets('locked recording overlay blocks background semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final recordStatus = ZIMKitRecordStatus()..startRecording(locked: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            Semantics(
              button: true,
              label: 'Background action',
              child: SizedBox(width: 48, height: 48),
            ),
            ZIMKitRecordOverlay(
              status: recordStatus,
              onSend: () {},
              onDiscard: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.semantics.byLabel('Background action'), findsNothing);
    expect(
      find.semantics.byLabel(
        ZIMKitCore.instance.innerText.discardRecordingLabelText,
      ),
      findsOneWidget,
    );
    expect(
      find.semantics.byLabel(ZIMKitCore.instance.innerText.sendRecordingText),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('locked send waits for readiness and a sendable duration', (
    tester,
  ) async {
    final durationNotifier = ZIMKitAudioInstance().data.recordDurationNotifier;
    addTearDown(() => durationNotifier.value = 0);
    durationNotifier.value = 0;
    final recordStatus = ZIMKitRecordStatus();
    final generation = recordStatus.startRecording(locked: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            ZIMKitRecordOverlay(
              status: recordStatus,
              onSend: () {},
              onDiscard: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.text('Starting recording…'), findsNothing);
    expect(find.text('00:00'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('record-discard-button')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('record-send-button')),
          )
          .onPressed,
      isNull,
    );

    recordStatus.markRecordingStarted(generation);
    await tester.pump();

    expect(find.text('Recording locked'), findsNothing);
    expect(find.text('00:00'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('record-discard-button')),
          )
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('record-send-button')),
          )
          .onPressed,
      isNull,
    );

    durationNotifier.value = 499;
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('record-send-button')),
          )
          .onPressed,
      isNull,
    );

    durationNotifier.value = 500;
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('record-send-button')),
          )
          .onPressed,
      isNotNull,
    );
  });
}
