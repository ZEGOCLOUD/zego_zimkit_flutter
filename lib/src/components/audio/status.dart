import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:zego_zimkit/src/audio/core.dart';
import 'defines.dart';

/// Status management class for audio recording
class ZIMKitRecordStatus {
  /// Notifier for recording state changes
  final stateNotifier = ValueNotifier<ZIMKitRecordState>(
    ZIMKitRecordState.idle,
  );

  /// Notifier for locker state changes
  final lockerStateNotifier = ValueNotifier<ZIMKitRecordLockerState>(
    ZIMKitRecordLockerState.idle,
  );

  /// Whether the pointer is currently showing the cancel preview.
  final cancelPreviewNotifier = ValueNotifier<bool>(false);
  final recorderReadyNotifier = ValueNotifier<bool>(false);
  int _recordingGeneration = 0;

  bool get isRecordingReady => recorderReadyNotifier.value;

  /// Whether the recording has reached the minimum sendable duration.
  bool get canSendRecording =>
      isRecordingReady &&
      ZIMKitAudioInstance().data.recordDurationNotifier.value >= 500;

  void register() {
    stateNotifier.addListener(_onStateChanged);
  }

  void unregister() {
    stateNotifier.removeListener(_onStateChanged);
  }

  /// Starts a new hold-to-talk recording session.
  int startRecording({bool locked = false}) {
    resetGestureState();
    final generation = ++_recordingGeneration;
    if (locked) {
      lockerStateNotifier.value = ZIMKitRecordLockerState.locked;
    }
    stateNotifier.value = ZIMKitRecordState.recording;
    return generation;
  }

  /// Whether [generation] still owns the active recording session.
  bool isRecordingGenerationActive(int generation) {
    return generation == _recordingGeneration &&
        stateNotifier.value == ZIMKitRecordState.recording;
  }

  /// Marks the active generation ready after ZIMAudio confirms recording began.
  bool markRecordingStarted(int generation) {
    if (!isRecordingGenerationActive(generation)) {
      return false;
    }

    recorderReadyNotifier.value = true;
    return true;
  }

  /// Returns to idle if the active recording failed to start.
  bool failStartingRecording(int generation) {
    return failRecording(generation);
  }

  /// Returns to idle if the active recording session failed.
  bool failRecording(int generation) {
    if (generation != _recordingGeneration ||
        stateNotifier.value != ZIMKitRecordState.recording) {
      return false;
    }

    resetGestureState();
    stateNotifier.value = ZIMKitRecordState.idle;
    return true;
  }

  /// Stops an active recording when its owning chat page is disposed.
  void cancelIfRecording() {
    if (stateNotifier.value == ZIMKitRecordState.recording) {
      _finishRecording(ZIMKitRecordState.cancel, force: true);
    }
  }

  /// Updates the visual gesture state while the user is holding the button.
  void updateGestureAction(ZIMKitRecordGestureAction action) {
    if (stateNotifier.value != ZIMKitRecordState.recording ||
        lockerStateNotifier.value == ZIMKitRecordLockerState.locked) {
      return;
    }

    cancelPreviewNotifier.value =
        action == ZIMKitRecordGestureAction.cancelPreview;
    lockerStateNotifier.value =
        action == ZIMKitRecordGestureAction.lockCandidate
        ? ZIMKitRecordLockerState.testing
        : ZIMKitRecordLockerState.idle;
  }

  /// Applies the release action: send, cancel, or keep recording locked.
  ZIMKitRecordFinishResult releaseHoldGesture() {
    if (stateNotifier.value != ZIMKitRecordState.recording ||
        !isRecordingReady) {
      return ZIMKitRecordFinishResult.ignored;
    }

    if (lockerStateNotifier.value == ZIMKitRecordLockerState.locked) {
      return ZIMKitRecordFinishResult.locked;
    }

    if (cancelPreviewNotifier.value) {
      cancelRecording();
      return ZIMKitRecordFinishResult.canceled;
    }

    if (lockerStateNotifier.value == ZIMKitRecordLockerState.testing) {
      cancelPreviewNotifier.value = false;
      lockerStateNotifier.value = ZIMKitRecordLockerState.locked;
      return ZIMKitRecordFinishResult.locked;
    }

    if (!canSendRecording) {
      cancelRecording();
      return ZIMKitRecordFinishResult.canceled;
    }

    sendRecording();
    return ZIMKitRecordFinishResult.sent;
  }

  /// Sends the active recording, including from the locked recording UI.
  void sendRecording() {
    if (!isRecordingReady) {
      return;
    }
    if (!canSendRecording) {
      cancelRecording();
      return;
    }

    _finishRecording(ZIMKitRecordState.complete);
  }

  /// Discards the active recording, including from the locked recording UI.
  void cancelRecording() {
    _finishRecording(ZIMKitRecordState.cancel);
  }

  void _finishRecording(ZIMKitRecordState terminalState, {bool force = false}) {
    if (stateNotifier.value != ZIMKitRecordState.recording ||
        (!force && !isRecordingReady)) {
      return;
    }

    resetGestureState();
    stateNotifier.value = terminalState;
    stateNotifier.value = ZIMKitRecordState.idle;
  }

  void _onStateChanged() {
    switch (stateNotifier.value) {
      case ZIMKitRecordState.idle:
        break;
      case ZIMKitRecordState.recording:
        break;
      case ZIMKitRecordState.cancel:
        resetGestureState();
        unawaited(_cancelAudioRecording());
        break;
      case ZIMKitRecordState.complete:
        resetGestureState();
        unawaited(_completeAudioRecording());
        break;
    }
  }

  Future<void> _completeAudioRecording() async {
    try {
      await ZIMKitAudioInstance().completeRecord();
    } catch (_) {
      // The audio instance logs the failure and reports it to the session.
    }
  }

  Future<void> _cancelAudioRecording() async {
    try {
      await ZIMKitAudioInstance().cancelRecord();
    } catch (_) {
      // The audio instance logs the failure and reports it to the session.
    }
  }

  /// Clears transient gesture and lock states after a recording ends.
  void resetGestureState() {
    cancelPreviewNotifier.value = false;
    lockerStateNotifier.value = ZIMKitRecordLockerState.idle;
    recorderReadyNotifier.value = false;
  }
}
