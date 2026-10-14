part of 'core.dart';

mixin ZIMKitAudioEventService {
  void registerEvents() {
    ZIMAudioEventHandler.onError = onError;
    ZIMAudioEventHandler.onRecorderStarted = onRecorderStarted;
    ZIMAudioEventHandler.onRecorderCompleted = onRecorderCompleted;
    ZIMAudioEventHandler.onRecorderCancelled = onRecorderCancelled;
    ZIMAudioEventHandler.onRecorderProgress = onRecorderProgress;
    ZIMAudioEventHandler.onRecorderFailed = onRecorderFailed;
    ZIMAudioEventHandler.onPlayerStarted = onPlayerStarted;
    ZIMAudioEventHandler.onPlayerEnded = onPlayerEnded;
    ZIMAudioEventHandler.onPlayerStopped = onPlayerStopped;
    ZIMAudioEventHandler.onPlayerProgress = onPlayerProgress;
    ZIMAudioEventHandler.onPlayerInterrupted = onPlayerInterrupted;
    ZIMAudioEventHandler.onPlayerFailed = onPlayerFailed;
  }

  void unregisterEvents() {
    ZIMAudioEventHandler.onError = null;
    ZIMAudioEventHandler.onRecorderStarted = null;
    ZIMAudioEventHandler.onRecorderCompleted = null;
    ZIMAudioEventHandler.onRecorderCancelled = null;
    ZIMAudioEventHandler.onRecorderProgress = null;
    ZIMAudioEventHandler.onRecorderFailed = null;
    ZIMAudioEventHandler.onPlayerStarted = null;
    ZIMAudioEventHandler.onPlayerEnded = null;
    ZIMAudioEventHandler.onPlayerStopped = null;
    ZIMAudioEventHandler.onPlayerProgress = null;
    ZIMAudioEventHandler.onPlayerInterrupted = null;
    ZIMAudioEventHandler.onPlayerFailed = null;
  }

  void onError(ZIMAudioError errorInfo) {
    ZIMKitLogger.logInfo('ZIMAudio, onError, errorInfo:$errorInfo');
  }

  void onRecorderStarted() {
    ZIMKitLogger.logInfo('ZIMAudio, onRecorderStarted');

    final audio = ZIMKitAudioInstance();
    final recording = audio._markRecorderStarted();
    if (recording == null) {
      return;
    }

    if (recording.cancelWhenStarted) {
      // cancelRecord logs and reports failures through the recording callback.
      unawaited(audio.cancelRecord().catchError((_) {}));
      return;
    }

    try {
      recording.onStarted?.call();
    } catch (error, stackTrace) {
      unawaited(
        ZIMKitLogger.logError(
          'audio record start callback failed: $error\n$stackTrace',
        ),
      );
    }

    audio.data.recordDurationNotifier.value = 0;
    audio.data.recordCountDownNotifier.value =
        audio.data.getTopRecordedFile().maxDuration ~/ 1000;
  }

  void onRecorderCompleted(int totalDuration) {
    ZIMKitLogger.logInfo(
      'ZIMAudio, onRecorderCompleted, totalDuration:$totalDuration',
    );

    final audio = ZIMKitAudioInstance();
    if (audio._shouldIgnoreRecorderEvent()) {
      ZIMKitLogger.logInfo('ZIMAudio, ignore late recorder completion');
      return;
    }

    final data = audio.data;
    if (data.recordingCache.isEmpty) {
      return;
    }

    final currentRecordData = data.removeTopRecordingFile();
    currentRecordData.duration = totalDuration;
    data.recordCompleteStreamCtrl?.add(currentRecordData);
    unawaited(_notifyRecordCompleted(currentRecordData));

    data.recordDurationNotifier.value = 0;
    audio._completeRecordingTerminal(currentRecordData);
  }

  void onRecorderCancelled() {
    ZIMKitLogger.logInfo('ZIMAudio, onRecorderCancelled');

    final audio = ZIMKitAudioInstance();
    if (audio._shouldIgnoreRecorderEvent()) {
      ZIMKitLogger.logInfo('ZIMAudio, ignore late recorder cancellation');
      return;
    }

    if (audio.data.recordingCache.isEmpty) {
      return;
    }

    final recording = audio.data.removeTopRecordingFile();
    audio.data.recordDurationNotifier.value = 0;
    audio._completeRecordingTerminal(recording);
  }

  void onRecorderProgress(int currentDuration) {
    final audio = ZIMKitAudioInstance();
    if (audio._shouldIgnoreRecorderEvent() ||
        audio.data.recordingCache.isEmpty) {
      return;
    }

    audio.data.recordDurationNotifier.value = currentDuration;
    audio.data.recordCountDownNotifier.value =
        (audio.data.getTopRecordedFile().maxDuration - currentDuration) ~/ 1000;
  }

  void onRecorderFailed(int errorCode) {
    ZIMKitLogger.logInfo('ZIMAudio, onRecorderFailed, errorCode:$errorCode');

    final audio = ZIMKitAudioInstance();
    if (audio._shouldIgnoreRecorderEvent()) {
      ZIMKitLogger.logInfo('ZIMAudio, ignore late recorder failure');
      return;
    }

    final data = audio.data;
    if (data.recordingCache.isEmpty) {
      return;
    }

    final recording = data.removeTopRecordingFile();
    _notifyRecordFailed(recording, errorCode);
    data.recordDurationNotifier.value = 0;

    data.recordFailedStreamCtrl?.add(errorCode);
    audio._completeRecordingTerminal(recording);
  }

  Future<void> _notifyRecordCompleted(ZIMKitAudioRecordData recording) async {
    try {
      await recording.onCompleted?.call(recording);
    } catch (error, stackTrace) {
      await ZIMKitLogger.logError(
        'audio record completion callback failed: $error\n$stackTrace',
      );
    }
  }

  void _notifyRecordFailed(ZIMKitAudioRecordData recording, int errorCode) {
    try {
      recording.onFailed?.call(errorCode);
    } catch (error, stackTrace) {
      unawaited(
        ZIMKitLogger.logError(
          'audio record failure callback failed: $error\n$stackTrace',
        ),
      );
    }
  }

  void onPlayerStarted(int totalDuration) {
    ZIMKitLogger.logInfo(
      'ZIMAudio, onPlayerStarted, totalDuration:$totalDuration',
    );
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;
  }

  void onPlayerEnded() {
    ZIMKitLogger.logInfo('ZIMAudio, onPlayerEnded');
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;

    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );
  }

  void onPlayerStopped() {
    ZIMKitLogger.logInfo('ZIMAudio, onPlayerStopped');
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;

    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );

    if (ZIMKitAudioInstance().data.cachePlayingData != null) {
      /// exist cache play, play now
      final pendingPlayData = ZIMKitAudioInstance().data.cachePlayingData!;
      ZIMKitAudioInstance().data.cachePlayingData = null;

      ZIMKitAudioInstance().startPlay(
        pendingPlayData.id,
        pendingPlayData.filePath,
        routeType: pendingPlayData.routeType,
      );
    }
  }

  void onPlayerProgress(int currentDuration) {
    ZIMKitLogger.logInfo(
      'ZIMAudio, onPlayerProgress, currentDuration:$currentDuration',
    );
    ZIMKitAudioInstance().data.playProcessNotifier.value = currentDuration;
  }

  void onPlayerInterrupted() {
    ZIMKitLogger.logInfo('ZIMAudio, onPlayerInterrupted');
    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );
  }

  void onPlayerFailed(int errorCode) {
    ZIMKitLogger.logInfo('ZIMAudio, onPlayerFailed, errorCode:$errorCode');
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;

    ZIMKitAudioInstance().data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );
  }
}
