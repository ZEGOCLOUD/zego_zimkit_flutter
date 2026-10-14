import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/components/audio/defines.dart';
import 'package:zego_zimkit/src/components/audio/status.dart';

void main() {
  group('resolveRecordGestureAction', () {
    const cancelThreshold = 100.0;
    const lockThreshold = 80.0;

    test('classifies a dominant left drag as cancel preview', () {
      expect(
        resolveRecordGestureAction(
          horizontalOffset: -120,
          verticalOffset: -20,
          cancelThreshold: cancelThreshold,
          lockThreshold: lockThreshold,
          lockHorizontalTolerance: 90,
        ),
        ZIMKitRecordGestureAction.cancelPreview,
      );
    });

    test('classifies a dominant upward drag as lock candidate', () {
      expect(
        resolveRecordGestureAction(
          horizontalOffset: -20,
          verticalOffset: -100,
          cancelThreshold: cancelThreshold,
          lockThreshold: lockThreshold,
          lockHorizontalTolerance: 90,
        ),
        ZIMKitRecordGestureAction.lockCandidate,
      );
    });

    test(
      'returns to neutral when the pointer moves back inside thresholds',
      () {
        expect(
          resolveRecordGestureAction(
            horizontalOffset: -40,
            verticalOffset: -30,
            cancelThreshold: cancelThreshold,
            lockThreshold: lockThreshold,
            lockHorizontalTolerance: 90,
          ),
          ZIMKitRecordGestureAction.none,
        );
      },
    );

    test('does not choose an action for an ambiguous diagonal drag', () {
      expect(
        resolveRecordGestureAction(
          horizontalOffset: -100,
          verticalOffset: -100,
          cancelThreshold: cancelThreshold,
          lockThreshold: lockThreshold,
          lockHorizontalTolerance: 90,
        ),
        ZIMKitRecordGestureAction.none,
      );
    });

    test('does not lock when the pointer is outside the lock target width', () {
      expect(
        resolveRecordGestureAction(
          horizontalOffset: 120,
          verticalOffset: -140,
          cancelThreshold: cancelThreshold,
          lockThreshold: lockThreshold,
          lockHorizontalTolerance: 90,
        ),
        ZIMKitRecordGestureAction.none,
      );
    });
  });

  group('ZIMKitRecordStatus', () {
    test('releasing on the lock target keeps recording active', () {
      final status = ZIMKitRecordStatus();
      final generation = status.startRecording();
      status.markRecordingStarted(generation);
      status.updateGestureAction(ZIMKitRecordGestureAction.lockCandidate);

      expect(status.releaseHoldGesture(), ZIMKitRecordFinishResult.locked);
      expect(status.stateNotifier.value, ZIMKitRecordState.recording);
      expect(status.lockerStateNotifier.value, ZIMKitRecordLockerState.locked);
    });

    test('releasing a cancel preview discards the recording', () {
      final status = ZIMKitRecordStatus();
      final generation = status.startRecording();
      status.markRecordingStarted(generation);
      status.updateGestureAction(ZIMKitRecordGestureAction.cancelPreview);

      expect(status.releaseHoldGesture(), ZIMKitRecordFinishResult.canceled);
      expect(status.stateNotifier.value, ZIMKitRecordState.idle);
      expect(status.cancelPreviewNotifier.value, isFalse);
    });

    test('cancel action in locked state stops the recording', () {
      final status = ZIMKitRecordStatus();
      final generation = status.startRecording();
      status.markRecordingStarted(generation);
      status.updateGestureAction(ZIMKitRecordGestureAction.lockCandidate);
      status.releaseHoldGesture();

      status.cancelRecording();

      expect(status.stateNotifier.value, ZIMKitRecordState.idle);
      expect(status.lockerStateNotifier.value, ZIMKitRecordLockerState.idle);
    });

    test('send action in locked state completes the recording', () {
      final status = ZIMKitRecordStatus();
      final generation = status.startRecording();
      status.markRecordingStarted(generation);
      status.updateGestureAction(ZIMKitRecordGestureAction.lockCandidate);
      status.releaseHoldGesture();

      status.sendRecording();

      expect(status.stateNotifier.value, ZIMKitRecordState.idle);
      expect(status.lockerStateNotifier.value, ZIMKitRecordLockerState.idle);
    });

    test('cannot send or discard before the SDK starts recording', () {
      final status = ZIMKitRecordStatus();
      final generation = status.startRecording(locked: true);

      status.sendRecording();
      status.cancelRecording();

      expect(status.stateNotifier.value, ZIMKitRecordState.recording);
      expect(status.isRecordingReady, isFalse);

      expect(status.markRecordingStarted(generation), isTrue);
      expect(status.isRecordingReady, isTrue);
      status.sendRecording();

      expect(status.stateNotifier.value, ZIMKitRecordState.idle);
      expect(status.isRecordingReady, isFalse);
    });

    test('a stale recording failure does not reset a newer recording', () {
      final status = ZIMKitRecordStatus();
      final oldGeneration = status.startRecording();
      status.markRecordingStarted(oldGeneration);
      status.cancelRecording();
      final currentGeneration = status.startRecording();

      expect(status.failRecording(oldGeneration), isFalse);
      expect(status.isRecordingGenerationActive(currentGeneration), isTrue);
      expect(status.stateNotifier.value, ZIMKitRecordState.recording);
    });
  });
}
