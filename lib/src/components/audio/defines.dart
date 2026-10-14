enum ZIMKitRecordState { idle, recording, cancel, complete }

enum ZIMKitRecordLockerState { idle, testing, locked }

/// The gesture currently suggested by the pointer movement during recording.
enum ZIMKitRecordGestureAction { none, cancelPreview, lockCandidate }

/// Result of releasing the hold-to-talk gesture.
enum ZIMKitRecordFinishResult { ignored, sent, canceled, locked }

/// Resolves a recording drag into a cancel preview or a lock candidate.
///
/// Diagonal movements only select an action when one axis clearly dominates,
/// so a single drag cannot accidentally mean both cancel and lock.
ZIMKitRecordGestureAction resolveRecordGestureAction({
  required double horizontalOffset,
  required double verticalOffset,
  required double cancelThreshold,
  required double lockThreshold,
  required double lockHorizontalTolerance,
}) {
  final leftDistance = horizontalOffset < 0 ? -horizontalOffset : 0.0;
  final upDistance = verticalOffset < 0 ? -verticalOffset : 0.0;

  if (leftDistance >= cancelThreshold && leftDistance > upDistance) {
    return ZIMKitRecordGestureAction.cancelPreview;
  }

  if (upDistance >= lockThreshold &&
      upDistance > leftDistance &&
      horizontalOffset.abs() <= lockHorizontalTolerance) {
    return ZIMKitRecordGestureAction.lockCandidate;
  }

  return ZIMKitRecordGestureAction.none;
}

String formatAudioRecordDuration(int milliseconds) {
  final seconds = (milliseconds / 1000).floor();
  final minutes = (seconds / 60).floor();
  final remainingSeconds = seconds % 60;

  final formattedMinutes = minutes.toString().padLeft(2, '0');
  final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

  return '$formattedMinutes:$formattedSeconds';
}
