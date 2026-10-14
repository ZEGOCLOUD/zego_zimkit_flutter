import 'dart:async';

import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zim_audio/zego_zim_audio.dart';

import 'package:zego_zimkit/src/services/logger_service.dart';
import 'data.dart';

part 'event.dart';

const _recordingTeardownTimeout = Duration(seconds: 2);

/// Singleton class for managing audio recording and playback
///
/// Provides functionality for recording voice messages and playing audio files.
/// Used internally by ZIMKit for audio message handling.
class ZIMKitAudioInstance with ZIMKitAudioEventService {
  factory ZIMKitAudioInstance() => instance;

  ZIMKitAudioInstance._internal() {
    data.init();
  }

  static final ZIMKitAudioInstance instance = ZIMKitAudioInstance._internal();
  var data = ZIMKitAudioData();
  Future<void>? _recordingStartFuture;
  Future<void>? _uninitFuture;
  bool _recordingEndRequested = false;
  bool _recordingEventsQuarantined = false;

  Future<void> init({String license = '', String absFileRoot = ''}) async {
    ZIMKitLogger.logInfo('ZIMAudio init');

    await data.init();

    await ZIMAudio.getInstance().init(license);
    registerEvents();
  }

  Future<void> uninit() {
    final inProgress = _uninitFuture;
    if (inProgress != null) {
      return inProgress;
    }

    final uninitFuture = _performUninit();
    late final Future<void> trackedFuture;
    trackedFuture = uninitFuture.whenComplete(() {
      if (identical(_uninitFuture, trackedFuture)) {
        _uninitFuture = null;
      }
    });
    _uninitFuture = trackedFuture;
    return trackedFuture;
  }

  Future<void> _performUninit() async {
    ZIMKitLogger.logInfo('ZIMAudio uninit');

    try {
      final recording = data.recordingCache.isEmpty
          ? null
          : data.recordingCache.first;
      final startFuture = _recordingStartFuture;
      if (recording != null && startFuture != null) {
        try {
          await startFuture.timeout(_recordingTeardownTimeout);
        } catch (error, stackTrace) {
          await ZIMKitLogger.logError(
            'ZIMAudio start recording during uninit failed: $error\n$stackTrace',
          );
        }
      }

      if (recording != null &&
          data.recordingCache.contains(recording) &&
          !_recordingEndRequested) {
        try {
          if (await ZIMAudio.getInstance().isRecording().timeout(
            _recordingTeardownTimeout,
          )) {
            await cancelRecord().timeout(_recordingTeardownTimeout);
          }
        } catch (error, stackTrace) {
          await ZIMKitLogger.logError(
            'ZIMAudio cancel recording during uninit failed: $error\n$stackTrace',
          );
        }
      }

      if (recording != null && data.recordingCache.contains(recording)) {
        try {
          await recording.terminalCompleter.future.timeout(
            _recordingTeardownTimeout,
          );
        } on TimeoutException catch (error, stackTrace) {
          _recordingEventsQuarantined = true;
          await ZIMKitLogger.logError(
            'ZIMAudio terminal event during uninit timed out: $error\n$stackTrace',
          );
        }
      }
    } finally {
      unregisterEvents();
    }

    var nativeUninitSucceeded = false;
    try {
      await ZIMAudio.getInstance().uninit().timeout(_recordingTeardownTimeout);
      nativeUninitSucceeded = true;
    } on TimeoutException catch (error, stackTrace) {
      await ZIMKitLogger.logError(
        'ZIMAudio uninit timed out: $error\n$stackTrace',
      );
    } finally {
      data.uninit();
      _recordingStartFuture = null;
      _recordingEndRequested = false;
      // Only a successful native teardown is a barrier for the previous event
      // source. A failed uninit must quarantine even when no session was queued.
      _recordingEventsQuarantined = !nativeUninitSucceeded;
    }
  }

  Future<void> startRecord(
    String conversationID,
    ZIMConversationType conversationType, {
    String? filePath,

    /// The maximum recording time, the default is 60000 ms, which is 60s. The unit of this parameter is milliseconds, and the maximum value does not exceed 120000.
    int maxDuration = 60 * 1000,
    void Function()? onStarted,
    Future<void> Function(ZIMKitAudioRecordData recordData)? onCompleted,
    void Function(int errorCode)? onFailed,
  }) async {
    if (_uninitFuture != null || _recordingEventsQuarantined) {
      throw StateError(
        'The audio recorder is being torn down or was not safely released.',
      );
    }

    if (data.recordingCache.isNotEmpty) {
      throw StateError('The previous recording session has not finished.');
    }

    filePath ??= data.generateRecordFilePath();

    ZIMKitLogger.logInfo(
      'ZIMAudio startRecord,'
      'conversationID:$conversationID, '
      'conversationType:$conversationType, '
      'filePath:$filePath, '
      'maxDuration:$maxDuration, ',
    );

    final recording = data.addRecording(
      filePath,
      conversationID,
      conversationType,
      maxDuration,
      onStarted: onStarted,
      onCompleted: onCompleted,
      onFailed: onFailed,
    );
    _recordingEndRequested = false;

    final startFuture = ZIMAudio.getInstance().startRecord(
      ZIMAudioRecordConfig(filePath, maxDuration: maxDuration),
    );
    _recordingStartFuture = startFuture;
    try {
      await startFuture;
    } catch (_) {
      data.removeRecordingByFilePath(filePath);
      recording.markTerminal();
      _recordingEndRequested = false;
      rethrow;
    } finally {
      if (identical(_recordingStartFuture, startFuture)) {
        _recordingStartFuture = null;
      }
    }
  }

  Future<void> completeRecord() async {
    ZIMKitLogger.logInfo('ZIMAudio completeRecord');
    final recording = data.recordingCache.isEmpty
        ? null
        : data.recordingCache.first;
    _recordingEndRequested = true;
    try {
      await ZIMAudio.getInstance().completeRecord();
    } catch (error, stackTrace) {
      await _handleRecordingEndFailure(
        operation: 'completeRecord',
        recording: recording,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> cancelRecord() async {
    ZIMKitLogger.logInfo('ZIMAudio cancelRecord');

    final recording = data.recordingCache.isEmpty
        ? null
        : data.recordingCache.first;
    if (recording != null && !recording.hasStarted) {
      recording.cancelWhenStarted = true;
      _recordingEndRequested = true;
      return;
    }
    if (recording != null) {
      recording.cancelWhenStarted = false;
    }

    _recordingEndRequested = true;
    try {
      await ZIMAudio.getInstance().cancelRecord();
    } catch (error, stackTrace) {
      await _handleRecordingEndFailure(
        operation: 'cancelRecord',
        recording: recording,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _handleRecordingEndFailure({
    required String operation,
    required ZIMKitAudioRecordData? recording,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    _recordingEndRequested = false;
    if (recording != null && data.recordingCache.contains(recording)) {
      _recordingEventsQuarantined = true;
      data.removeRecordingByFilePath(recording.absFilePath);
      data.recordDurationNotifier.value = 0;
      recording.markTerminal();

      final errorCode = ZIMAudioErrorCode.unknownFailed;
      final failedController = data.recordFailedStreamCtrl;
      if (failedController != null && !failedController.isClosed) {
        failedController.add(errorCode);
      }
      try {
        recording.onFailed?.call(errorCode);
      } catch (callbackError, callbackStackTrace) {
        unawaited(
          ZIMKitLogger.logError(
            'audio record failure callback failed: '
            '$callbackError\n$callbackStackTrace',
          ),
        );
      }
    }
    await ZIMKitLogger.logError(
      'ZIMAudio $operation failed: $error\n$stackTrace',
    );
  }

  void _completeRecordingTerminal(ZIMKitAudioRecordData recording) {
    recording.markTerminal();
    _recordingEndRequested = false;
  }

  bool _shouldIgnoreRecorderEvent() {
    return _recordingEventsQuarantined;
  }

  ZIMKitAudioRecordData? _markRecorderStarted() {
    if (_shouldIgnoreRecorderEvent() || data.recordingCache.isEmpty) {
      return null;
    }

    final recording = data.recordingCache.first;
    recording.markStarted();
    return recording;
  }

  Future<bool> isRecording() async {
    return ZIMAudio.getInstance().isRecording();
  }

  Future<void> startPlay(
    int id,
    String filePath, {
    ZIMAudioRouteType? routeType,
  }) async {
    if (data.playStatusNotifier.value.id == id) {
      ZIMKitLogger.logInfo('ZIMAudio startPlay, target id($id) is playing');
      return;
    }

    if (data.playStatusNotifier.value.isPlaying) {
      /// playing another audio
      ZIMKitLogger.logInfo(
        'ZIMAudio startPlay, '
        'current is playing:${data.playStatusNotifier.value.id}, '
        'cache target:$id, waiting stop',
      );

      data.cachePlayingData = ZIMKitAudioPlayData(
        id: id,
        filePath: filePath,
        routeType: routeType,
      );

      /// playing other audio, stop first
      await stopPlay();

      /// update data
      data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
        id: id,
        isPlaying: true,
      );

      return;
    }

    ZIMKitLogger.logInfo(
      'ZIMAudio startPlay, '
      'current playing:${data.playStatusNotifier.value.id}, '
      'target, id:$id, filePath:$filePath, routeType:$routeType',
    );

    /// update data
    data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: id,
      isPlaying: true,
    );
    return ZIMAudio.getInstance().startPlay(
      ZIMAudioPlayConfig(filePath, routeType: routeType),
    );
  }

  Future<void> stopPlay() async {
    ZIMKitLogger.logInfo(
      'ZIMAudio stopPlay, current playing:${data.playStatusNotifier.value.id}',
    );

    /// update data
    ZIMKitAudioInstance().data.playProcessNotifier.value = 0;
    data.playStatusNotifier.value = ZIMKitAudioPlayStatus(
      id: -1,
      isPlaying: false,
    );

    return ZIMAudio.getInstance().stopPlay();
  }

  Future<bool> isPlaying() async {
    return ZIMAudio.getInstance().isPlaying();
  }

  Future<String> getVersion() async {
    return ZIMAudio.getVersion();
  }
}
