import 'package:flutter/cupertino.dart';

import 'package:zego_zimkit/src/audio/core.dart';
import 'defines.dart';

/// Status management class for audio recording
class ZIMKitRecordStatus {
  /// Notifier for recording state changes
  final stateNotifier =
      ValueNotifier<ZIMKitRecordState>(ZIMKitRecordState.idle);

  /// Notifier for locker state changes
  final lockerStateNotifier =
      ValueNotifier<ZIMKitRecordLockerState>(ZIMKitRecordLockerState.idle);

  void register() {
    stateNotifier.addListener(_onStateChanged);
  }

  void unregister() {
    stateNotifier.removeListener(_onStateChanged);
  }

  void _onStateChanged() {
    switch (stateNotifier.value) {
      case ZIMKitRecordState.idle:
        break;
      case ZIMKitRecordState.recording:
        break;
      case ZIMKitRecordState.cancel:
        ZIMKitAudioInstance().cancelRecord();
        break;
      case ZIMKitRecordState.complete:
        ZIMKitAudioInstance().completeRecord();
        break;
    }
  }
}
