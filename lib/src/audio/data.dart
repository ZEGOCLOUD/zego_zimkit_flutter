import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zim_audio/zego_zim_audio.dart';

/// Audio recording data class for storing audio recording related information
class ZIMKitAudioRecordData {
  /// Creates an audio recording data instance
  ///
  /// [absFilePath] Absolute path of the audio file
  /// [conversationID] Conversation ID
  /// [conversationType] Conversation type
  /// [duration] Recording duration in milliseconds, defaults to 0
  /// [maxDuration] Maximum recording duration in milliseconds, defaults to 60 seconds
  ZIMKitAudioRecordData({
    required this.absFilePath,
    required this.conversationID,
    required this.conversationType,
    this.duration = 0,
    this.maxDuration = 60 * 1000,
    this.onStarted,
    this.onCompleted,
    this.onFailed,
  });

  static ZIMKitAudioRecordData empty() {
    return ZIMKitAudioRecordData(
      absFilePath: '',
      conversationID: '',
      conversationType: ZIMConversationType.unknown,
    );
  }

  /// milliseconds
  int duration;
  int maxDuration;
  String absFilePath;
  String conversationID;
  ZIMConversationType conversationType;
  final Future<void> Function(ZIMKitAudioRecordData recordData)? onCompleted;
  final void Function()? onStarted;
  final void Function(int errorCode)? onFailed;
  final terminalCompleter = Completer<void>();
  bool hasStarted = false;
  bool cancelWhenStarted = false;

  void markStarted() {
    hasStarted = true;
  }

  void markTerminal() {
    if (!terminalCompleter.isCompleted) {
      terminalCompleter.complete();
    }
  }

  @override
  String toString() {
    return '{[ZIMKitAudioPlayStatus]'
        'duration:$duration, '
        'maxDuration:$maxDuration, '
        'absFilePath:$absFilePath, '
        'conversationID:$conversationID, '
        'conversationType:$conversationType, '
        '}';
  }
}

/// Audio playback data class for storing audio playback related information
class ZIMKitAudioPlayData {
  /// Creates an audio playback data instance
  ///
  /// [id] Unique identifier for audio playback
  /// [filePath] Audio file path
  /// [routeType] Audio route type, optional parameter
  ZIMKitAudioPlayData({
    required this.id,
    required this.filePath,
    this.routeType,
  });

  /// milliseconds
  int id;
  String filePath;
  ZIMAudioRouteType? routeType;

  @override
  String toString() {
    return '{[ZIMKitAudioPlayStatus]id:$id, filePath:$filePath, routeType:$routeType}';
  }
}

/// Audio playback status class for storing audio playback status information
class ZIMKitAudioPlayStatus {
  /// Creates an audio playback status instance
  ///
  /// [id] Unique identifier for audio playback
  /// [isPlaying] Whether the audio is currently playing
  ZIMKitAudioPlayStatus({required this.id, required this.isPlaying});

  /// milliseconds
  int id;
  bool isPlaying;

  @override
  String toString() {
    return '{[ZIMKitAudioPlayStatus]id:$id, isPlaying:$isPlaying}';
  }
}

class ZIMKitAudioData {
  StreamController<ZIMKitAudioRecordData>? recordCompleteStreamCtrl;
  StreamController<int>? recordFailedStreamCtrl;
  //  unit: milliseconds
  final recordDurationNotifier = ValueNotifier<int>(0);
  //  unit:seconds
  final recordCountDownNotifier = ValueNotifier<int>(0);

  ZIMKitAudioPlayData? cachePlayingData;
  final playProcessNotifier = ValueNotifier<int>(0);
  final playStatusNotifier = ValueNotifier<ZIMKitAudioPlayStatus>(
    ZIMKitAudioPlayStatus(id: -1, isPlaying: false),
  );

  bool isInit = false;
  String absFileRoot = '';
  var recordingCache = Queue<ZIMKitAudioRecordData>();

  Future<void> init() async {
    if (isInit) {
      return;
    }

    isInit = true;
    recordCompleteStreamCtrl ??=
        StreamController<ZIMKitAudioRecordData>.broadcast();
    recordFailedStreamCtrl ??= StreamController<int>.broadcast();

    await getApplicationDocumentsDirectory().then((directory) {
      absFileRoot = directory.path;
    });
  }

  void uninit() {
    recordingCache.clear();
    recordDurationNotifier.value = 0;
    recordCountDownNotifier.value = 0;

    if (!isInit) {
      return;
    }

    isInit = false;

    recordCompleteStreamCtrl?.close();
    recordCompleteStreamCtrl = null;
    recordFailedStreamCtrl?.close();
    recordFailedStreamCtrl = null;
  }

  String generateRecordFilePath() {
    return '$absFileRoot${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch.toString()}.mp3';
  }

  ZIMKitAudioRecordData addRecording(
    String absFilePath,
    String conversationID,
    ZIMConversationType conversationType,
    int maxDuration, {
    void Function()? onStarted,
    Future<void> Function(ZIMKitAudioRecordData recordData)? onCompleted,
    void Function(int errorCode)? onFailed,
  }) {
    final recording = ZIMKitAudioRecordData(
      absFilePath: absFilePath,
      conversationID: conversationID,
      conversationType: conversationType,
      maxDuration: maxDuration,
      onStarted: onStarted,
      onCompleted: onCompleted,
      onFailed: onFailed,
    );
    recordingCache.add(recording);
    return recording;
  }

  ZIMKitAudioRecordData getTopRecordedFile() {
    if (recordingCache.isEmpty) {
      return ZIMKitAudioRecordData.empty();
    }

    var data = recordingCache.first;
    data.duration = recordDurationNotifier.value;
    return data;
  }

  ZIMKitAudioRecordData removeTopRecordingFile() {
    if (recordingCache.isEmpty) {
      return ZIMKitAudioRecordData.empty();
    }

    var data = recordingCache.removeFirst();
    data.duration = recordDurationNotifier.value;
    return data;
  }

  /// Removes a failed recording request without affecting a newer session.
  void removeRecordingByFilePath(String absFilePath) {
    recordingCache.removeWhere(
      (recording) => recording.absFilePath == absFilePath,
    );
  }
}
