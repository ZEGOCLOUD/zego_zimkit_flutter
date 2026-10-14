part of 'core.dart';

/// Dimensions decoded from a local image before it is attached to the chat.
class ZIMKitImageDimensions {
  const ZIMKitImageDimensions({required this.width, required this.height});

  final int width;
  final int height;

  /// Fills image dimensions only when the SDK message does not have them yet.
  void applyTo(ZIMMessage message) {
    if (message is! ZIMImageMessage) {
      return;
    }

    if (message.originalImageWidth <= 0) {
      message.originalImageWidth = width;
    }
    if (message.originalImageHeight <= 0) {
      message.originalImageHeight = height;
    }
  }
}

/// Reads image dimensions from the encoded file without decoding its pixels.
Future<ZIMKitImageDimensions?> readZIMKitImageDimensions(String path) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  try {
    buffer = await ui.ImmutableBuffer.fromFilePath(path);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    if (descriptor.width <= 0 || descriptor.height <= 0) {
      return null;
    }

    return ZIMKitImageDimensions(
      width: descriptor.width,
      height: descriptor.height,
    );
  } catch (error) {
    await ZIMKitLogger.logWarn(
      'readZIMKitImageDimensions failed for $path: $error',
    );
    return null;
  } finally {
    descriptor?.dispose();
    buffer?.dispose();
  }
}

extension ZIMKitCoreMessageMedia on ZIMKitCore {
  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType conversationType,
    String mediaPath,
    ZIMMessageType messageType, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage message)? preMessageSending,
    Function(ZIMKitMessage message)? onMessageSent,
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    int audioDuration = 0,
  }) async {
    if (mediaPath.isEmpty || !File(mediaPath).existsSync()) {
      ZIMKitLogger.logWarn(
        "sendMediaMessage: mediaPath is empty or file doesn't exits",
      );
      return;
    }
    if (conversationID.isEmpty) {
      ZIMKitLogger.logWarn('sendCustomMessage: conversationID is empty');
      return;
    }

    final localImageDimensions = messageType == ZIMMessageType.image
        ? await readZIMKitImageDimensions(mediaPath)
        : null;

    // 1. create message
    var kitMessage = ZIMKitMessageUtils.mediaMessageFactory(
      mediaPath,
      messageType,
      audioDuration: audioDuration,
    ).toKIT();
    kitMessage.zim.conversationID = conversationID;
    kitMessage.zim.conversationType = conversationType;

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;

    // 3. re-generate zim
    // ignore: cascade_invocations
    kitMessage.reGenerateZIMMessage();

    final sendConfig = ZIMMessageSendConfig();
    if (ZegoZIMKitNotificationManager.instance.resourceID?.isNotEmpty ??
        false) {
      final pushConfig = ZIMPushConfig()
        ..resourcesID = ZegoZIMKitNotificationManager.instance.resourceID!
        ..title = ZIMKit().currentUser()?.baseInfo.userName ?? ''
        /// media only show [type] for offline message
        ..content = '[${messageType.name}]'
        ..payload = const JsonEncoder().convert({
          ZIMKitInvitationProtocolKey.operationType:
              BackgroundMessageType.mediaMessage.text,
          'id': conversationID,
          'sender': {
            'id': ZIMKit().currentUser()?.baseInfo.userID ?? '',
            'name': ZIMKit().currentUser()?.baseInfo.userName ?? '',
          },
          'type': conversationType.index,
        });
      sendConfig.pushConfig = pushConfig;
    }

    final mediaMessagePath =
        // ignore: avoid_dynamic_calls
        kitMessage.autoContent.fileDownloadUrl.isNotEmpty
        // ignore: avoid_dynamic_calls
        ? kitMessage.autoContent.fileDownloadUrl
        : mediaPath;
    ZIMKitLogger.logInfo('sendMediaMessage: $mediaMessagePath');

    // 3. call service
    late ZIMKitMessageNotifier kitMessageNotifier;
    await ZIM
        .getInstance()!
        .sendMessage(
          kitMessage.zim as ZIMMediaMessage,
          conversationID,
          conversationType,
          sendConfig,
          ZIMMessageSendNotification(
            onMessageAttached: (zimMessage) {
              localImageDimensions?.applyTo(zimMessage);
              ZIMKitLogger.logInfo(
                'sendMediaMessage.onMessageAttached: '
                '${(zimMessage as ZIMMediaMessage).fileName}',
              );
              kitMessageNotifier = db
                  .messages(conversationID, conversationType)
                  .onAttach(zimMessage);
            },
            onMediaUploadingProgress: (message, currentFileSize, totalFileSize) {
              final zimMessage = message;
              ZIMKitLogger.logInfo(
                'onMediaUploadingProgress: ${zimMessage.fileName}, $currentFileSize/$totalFileSize',
              );

              kitMessageNotifier.value = (kitMessageNotifier.value.clone()
                ..updateExtraInfo({
                  'upload': {
                    ZIMMediaFileType.originalFile.name: {
                      'currentFileSize': currentFileSize,
                      'totalFileSize': totalFileSize,
                    },
                  },
                }));
              dispatchZIMKitMediaTransferProgress(
                message: kitMessageNotifier.value,
                currentSize: currentFileSize,
                totalSize: totalFileSize,
                isUploading: true,
              );
              mediaUploadingProgress?.call(
                message,
                currentFileSize,
                totalFileSize,
              );
            },
          ),
        )
        .then<void>((result) {
          ZIMKitLogger.logInfo('sendMediaMessage: success, $mediaPath}');
          localImageDimensions?.applyTo(result.message);
          kitMessageNotifier.value = result.message.toKIT();
          onMessageSent?.call(kitMessageNotifier.value);
        })
        .catchError((error) {
          kitMessageNotifier.value = (kitMessageNotifier.value.clone()
            ..sendFailed(error));
          return checkNeedReloginOrNot(error).then((retryCode) {
            if (retryCode == 0) {
              ZIMKitLogger.logInfo('relogin success, retry sendMediaMessage');
              return sendMediaMessage(
                conversationID,
                conversationType,
                mediaPath,
                messageType,
                preMessageSending: preMessageSending,
                onMessageSent: onMessageSent,
                mediaUploadingProgress: mediaUploadingProgress,
                audioDuration: audioDuration,
              );
            } else {
              ZIMKitLogger.logError(
                'sendMediaMessage: failed, $mediaPath, error:$error',
              );
              onMessageSent?.call(kitMessageNotifier.value);
              throw error;
            }
          });
        });
  }

  // TODO use flutter cache manager.
  void downloadMediaFile(ZIMKitMessage kitMessage) {
    final kitMessageNotifier = db
        .messages(
          kitMessage.info.conversationID,
          kitMessage.info.conversationType,
        )
        .notifier
        .value
        .firstWhere(
          (element) =>
              element.value.info.localMessageID ==
              kitMessage.info.localMessageID,
        );
    _downloadMediaFile(kitMessageNotifier);
  }

  void _downloadMediaFile(ZIMKitMessageNotifier kitMessageNotifier) {
    if (kitMessageNotifier.value.zim is! ZIMMediaMessage) {
      ZIMKitLogger.logError(
        'downloadMediaFile: ${kitMessageNotifier.value.zim.runtimeType} '
        'is not ZIMMediaMessage',
      );
      return;
    }

    if (kitMessageNotifier.value.isNetworkUrl) {
      ZIMKitLogger.logError(
        'downloadMediaFile: ${kitMessageNotifier.value.zim.runtimeType} '
        'is network url.',
      );
      return;
    }

    final downloadTypes = <ZIMMediaFileType>[];

    switch (kitMessageNotifier.value.zim.runtimeType) {
      case ZIMVideoMessage _:
        if ((kitMessageNotifier.value.zim as ZIMVideoMessage)
            .videoFirstFrameLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.videoFirstFrame);
        }
        if ((kitMessageNotifier.value.zim as ZIMMediaMessage)
            .fileLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMImageMessage _:
        // just use flutter cache manager
        break;
      case ZIMAudioMessage _:
        if ((kitMessageNotifier.value.zim as ZIMMediaMessage)
            .fileLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;
      case ZIMFileMessage _:
        if ((kitMessageNotifier.value.zim as ZIMMediaMessage)
            .fileLocalPath
            .isEmpty) {
          downloadTypes.add(ZIMMediaFileType.originalFile);
        }
        break;

      default:
        ZIMKitLogger.logError(
          'not support download ${kitMessageNotifier.value.zim.runtimeType}',
        );
        return;
    }

    for (final downloadType in downloadTypes) {
      final zimMediaMessage = kitMessageNotifier.value.zim as ZIMMediaMessage;
      ZIMKitLogger.logInfo(
        'downloadMediaFile: ${zimMediaMessage.fileName} - '
        '${downloadType.name} start',
      );
      ZIM
          .getInstance()!
          .downloadMediaFile(
            kitMessageNotifier.value.zim as ZIMMediaMessage,
            downloadType,
            ZIMMediaDownloadConfig(),
            (ZIMMessage zimMessage, int currentFileSize, int totalFileSize) {
              ZIMKitLogger.logInfo(
                'downloadMediaFile: ${zimMediaMessage.fileName} - '
                '${downloadType.name} $currentFileSize/$totalFileSize',
              );

              kitMessageNotifier.value = (kitMessageNotifier.value.clone()
                ..updateExtraInfo({
                  'download': {
                    downloadType.name: {
                      'currentFileSize': currentFileSize,
                      'totalFileSize': totalFileSize,
                    },
                  },
                }));
              dispatchZIMKitMediaTransferProgress(
                message: kitMessageNotifier.value,
                currentSize: currentFileSize,
                totalSize: totalFileSize,
                isUploading: false,
              );
            },
          )
          .then((ZIMMediaDownloadedResult result) {
            ZIMKitLogger.logInfo(
              'downloadMediaFile: ${zimMediaMessage.fileName} - '
              '${downloadType.name} success',
            );
            kitMessageNotifier.value = (kitMessageNotifier.value.clone()
              ..downloadDone(downloadType, result.message));
          });
    }
  }

  void autoDownloadMessage(List<ZIMKitMessageNotifier> kitMessages) {
    if (!kEnableAutoDownload) {
      return;
    }

    for (final kitMessage in kitMessages) {
      if (kitMessage.value.zim is ZIMMediaMessage) {
        _downloadMediaFile(kitMessage);
      }
    }
  }
}
