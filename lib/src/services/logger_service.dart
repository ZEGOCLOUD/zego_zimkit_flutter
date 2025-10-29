import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_logs_yoer/flutter_logs_yoer.dart';

class ZIMKitLogger {
  static bool isZimKitLoggerInit = false;

  Future<void> initLog() async {
    if (isZimKitLoggerInit) {
      return;
    }

    try {
      await FlutterLogsYoer.initLogs(
              logLevelsEnabled: [
                LogLevel.INFO,
                LogLevel.WARNING,
                LogLevel.ERROR,
                LogLevel.SEVERE
              ],
              timeStampFormat: TimeStampFormat.TIME_FORMAT_24_FULL,
              directoryStructure: DirectoryStructure.SINGLE_FILE_FOR_DAY,
              logTypesEnabled: ['device', 'network', 'errors'],
              logFileExtension: LogFileExtension.LOG,
              logsWriteDirectoryName: 'ZegoUIKits',
              logsExportDirectoryName: 'ZegoUIKits/Exported',
              debugFileOperations: true,
              isDebuggable: true)
          .then((value) {
        FlutterLogsYoer.setDebugLevel(0);
        FlutterLogsYoer.logInfo(
          'zimkit',
          'log init done',
          '==========================================',
        );
      });

      isZimKitLoggerInit = true;
    } catch (e) {
      debugPrint('zimkit init logger error:$e');
    }
  }

  Future<void> clearLogs() async {
    FlutterLogsYoer.clearLogs();
  }

  static Future<void> logInfo(
    String logMessage, {
    String tag = 'zimkit',
    String subTag = 'info',
  }) async {
    if (!isZimKitLoggerInit) {
      debugPrint('[INFO] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logInfo(tag, subTag, logMessage);
  }

  static Future<void> logWarn(
    String logMessage, {
    String tag = 'zimkit',
    String subTag = 'warn',
  }) async {
    if (!isZimKitLoggerInit) {
      debugPrint('[WARN] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logWarn(tag, subTag, logMessage);
  }

  static Future<void> logError(
    String logMessage, {
    String tag = 'zimkit',
    String subTag = 'error',
  }) async {
    if (!isZimKitLoggerInit) {
      debugPrint('[ERROR] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logError(tag, subTag, logMessage);
  }

  static Future<void> logErrorTrace(
    String logMessage,
    Error e, {
    String tag = 'zimkit',
    String subTag = 'trace',
  }) async {
    if (!isZimKitLoggerInit) {
      debugPrint('[ERROR] ${DateTime.now()} [$tag] [$subTag] $logMessage');
      return;
    }

    return FlutterLogsYoer.logErrorTrace(tag, subTag, logMessage, e);
  }
}
