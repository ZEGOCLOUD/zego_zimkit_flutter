import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';

class ZIMKitLogger {
  static bool isZimKitLoggerInit = false;

  Future<void> initLog({String folderName = 'uikit'}) async {
    if (isZimKitLoggerInit) {
      return;
    }

    try {
      await FlutterLogs.initLogs(
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
              logsWriteDirectoryName: 'zego_prebuilt/$folderName',
              logsExportDirectoryName: 'zego_prebuilt/$folderName/Exported',
              debugFileOperations: true,
              isDebuggable: true)
          .then((value) {
        FlutterLogs.setDebugLevel(0);
        FlutterLogs.logInfo(
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
    FlutterLogs.clearLogs();
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

    return FlutterLogs.logInfo(tag, subTag, logMessage);
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

    return FlutterLogs.logWarn(tag, subTag, logMessage);
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

    return FlutterLogs.logError(tag, subTag, logMessage);
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

    return FlutterLogs.logErrorTrace(tag, subTag, logMessage, e);
  }
}
