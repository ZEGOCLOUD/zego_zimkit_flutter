/// Events configuration class for audio recording
class ZIMKitAudioRecordEvents {
  /// Creates an audio record events instance
  /// 
  /// [onFailed] Callback when audio recording fails
  /// [onCountdownTick] Callback for countdown tick during recording
  ZIMKitAudioRecordEvents({
    this.onFailed,
    this.onCountdownTick,
  });

  final void Function(int errorCode)? onFailed;
  final void Function(int remainingSecond)? onCountdownTick;
}
