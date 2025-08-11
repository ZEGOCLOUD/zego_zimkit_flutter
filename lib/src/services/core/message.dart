part of 'core.dart';

extension ZIMKitCoreMessage on ZIMKitCore {
  Future<ZIMKitMessageListNotifier> getMessageListNotifier(
    String conversationID,
    ZIMKitConversationType conversationType,
  ) async {
    await waitForLoginOrNot();

    final dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.inited) {
      return dbMessages.notifier;
    }

    // start load
    dbMessages.loading = true;
    final config = ZIMMessageQueryConfig()
      ..reverse = true
      ..count = kDefaultLoadCount;
    return ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZIMKitLogger.logInfo(
          'queryHistoryMessage: ${zimResult.messageList.length}');

      dbMessages.init(zimResult.messageList);
      autoDownloadMessage(dbMessages.notifier.value);
      if (zimResult.messageList.isEmpty ||
          zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;

      return dbMessages.notifier;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        dbMessages.loading = false;
        if (retryCode == 0) {
          ZIMKitLogger.logInfo('relogin success, retry loadMessageList');
          return getMessageListNotifier(conversationID, conversationType);
        } else {
          ZIMKitLogger.logError('loadMessageList failed:$error');
          throw error;
        }
      });
    });
  }

  Future<int> loadMoreMessage(
    String conversationID,
    ZIMKitConversationType conversationType,
  ) async {
    await waitForLoginOrNot();
    final dbMessages = db.messages(conversationID, conversationType);
    if (dbMessages.notInited) {
      await getMessageListNotifier(conversationID, conversationType);
    }

    if (dbMessages.noMore || dbMessages.loading) {
      return 0;
    }

    dbMessages.loading = true;
    ZIMKitLogger.logInfo('loadMoreMessage start');

    final config = ZIMMessageQueryConfig()
      ..count = kDefaultLoadCount
      ..reverse = true
      ..nextMessage = dbMessages.notifier.value.first.value.zim;
    return ZIM
        .getInstance()!
        .queryHistoryMessage(conversationID, conversationType, config)
        .then((ZIMMessageQueriedResult zimResult) {
      ZIMKitLogger.logInfo(
          'queryHistoryMessage: ${zimResult.messageList.length}');

      dbMessages.insertAll(zimResult.messageList);
      autoDownloadMessage(dbMessages.notifier.value);

      ZIMKitLogger.logInfo(
          'loadMoreMessage success, length ${zimResult.messageList.length}');

      if (zimResult.messageList.isEmpty ||
          zimResult.messageList.length < config.count) {
        dbMessages.noMore = true;
      }
      dbMessages.loading = false;

      return zimResult.messageList.length;
    }).catchError((error) {
      return checkNeedReloginOrNot(error).then((retryCode) {
        dbMessages.loading = false;
        if (retryCode == 0) {
          ZIMKitLogger.logInfo('relogin success, retry loadMessageList');
          return loadMoreMessage(conversationID, conversationType);
        } else {
          ZIMKitLogger.logError('loadMessageList failed:$error');
          throw error;
        }
      });
    });
  }

  Future<void> sendTextMessage(
    String conversationID,
    ZIMKitConversationType conversationType,
    String text, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage message)? preMessageSending,
    Function(ZIMKitMessage message)? onMessageSent,
  }) async {
    if (text.isEmpty) {
      ZIMKitLogger.logWarn('sendTextMessage: message is empty');
      return;
    }
    if (conversationID.isEmpty) {
      ZIMKitLogger.logWarn('sendTextMessage: conversationID is empty');
      return;
    }

    // 1. create message
    var kitMessage = ZIMTextMessage(message: text).toKIT();
    final sendConfig = ZIMMessageSendConfig()..hasReceipt = true;

    if (ZegoZIMKitNotificationManager.instance.resourceID?.isNotEmpty ??
        false) {
      final pushConfig = ZIMPushConfig()
        ..resourcesID = ZegoZIMKitNotificationManager.instance.resourceID!
        ..title = ZIMKit().currentUser()?.baseInfo.userName ?? ''
        ..content = text
        ..payload = const JsonEncoder().convert(
          {
            ZIMKitInvitationProtocolKey.operationType:
                BackgroundMessageType.textMessage.text,
            'id': conversationID,
            'sender': {
              'id': ZIMKit().currentUser()?.baseInfo.userID ?? '',
              'name': ZIMKit().currentUser()?.baseInfo.userName ?? '',
            },
            'type': conversationType.index,
            'image_attachment' : 'https://dummyimage.com/600x400/000/fff',
          },
        );
      sendConfig.pushConfig = pushConfig;
    }

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;
    ZIMKitLogger.logInfo('sendTextMessage: $text');

    // 3. re-generate zim
    kitMessage.reGenerateZIMMessage();

    // 3. call service
    late ZIMKitMessageNotifier kitMessageNotifier;
    await ZIM.getInstance()!.sendMessage(
      kitMessage.zim,
      conversationID,
      conversationType,
      sendConfig,
      ZIMMessageSendNotification(
        onMessageAttached: (zimMessage) {
          kitMessageNotifier = db
              .messages(conversationID, conversationType)
              .onAttach(zimMessage);
        },
      ),
    ).then((result) {
      ZIMKitLogger.logInfo('sendTextMessage: success, $text');
      kitMessageNotifier.value = result.message.toKIT();
      onMessageSent?.call(kitMessageNotifier.value);
    }).catchError((error) {
      kitMessageNotifier.value =
          (kitMessageNotifier.value.clone()..sendFailed(error));

      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.logInfo('relogin success, retry sendTextMessage');
          sendTextMessage(
            conversationID,
            conversationType,
            text,
            preMessageSending: preMessageSending,
            onMessageSent: onMessageSent,
          );
        } else {
          ZIMKitLogger.logError('sendTextMessage: failed, $text,error:$error');
          onMessageSent?.call(kitMessageNotifier.value);
          throw error;
        }
      });
    });
  }

  Future<void> sendCustomMessage(
    String conversationID,
    ZIMKitConversationType conversationType, {
    required int customType,
    required String customMessage,
    String? searchedContent,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    if (conversationID.isEmpty) {
      ZIMKitLogger.logWarn('sendCustomMessage: conversationID is empty');
      return;
    }

    // 1. create message
    var kitMessage =
        (ZIMCustomMessage(subType: customType, message: customMessage, searchedContent: '')
              ..searchedContent = searchedContent ?? '')
            .toKIT();
    final sendConfig = ZIMMessageSendConfig()..hasReceipt = true;

    // 2. preMessageSending
    kitMessage = (await preMessageSending?.call(kitMessage)) ?? kitMessage;
    ZIMKitLogger.logInfo(
        'sendCustomMessage: customType: $customType, message: $customMessage');

    // 3. re-generate zim
    kitMessage.reGenerateZIMMessage();

    // 3. call service
    late ZIMKitMessageNotifier kitMessageNotifier;
    await ZIM.getInstance()!.sendMessage(
      kitMessage.zim,
      conversationID,
      conversationType,
      sendConfig,
      ZIMMessageSendNotification(
        onMessageAttached: (zimMessage) {
          kitMessageNotifier = db
              .messages(conversationID, conversationType)
              .onAttach(zimMessage);
        },
      ),
    ).then((result) {
      ZIMKitLogger.logInfo(
          'sendCustomMessage: success, customType: $customType, message: $customMessage');
      kitMessageNotifier.value = result.message.toKIT();
      onMessageSent?.call(kitMessageNotifier.value);
    }).catchError((error) {
      kitMessageNotifier.value =
          (kitMessageNotifier.value.clone()..sendFailed(error));

      return checkNeedReloginOrNot(error).then((retryCode) {
        if (retryCode == 0) {
          ZIMKitLogger.logInfo('relogin success, retry sendCustomMessage');
          sendCustomMessage(
            conversationID,
            conversationType,
            customMessage: customMessage,
            customType: customType,
            searchedContent: searchedContent,
            preMessageSending: preMessageSending,
            onMessageSent: onMessageSent,
          );
        } else {
          ZIMKitLogger.logError(
              'sendCustomMessage: failed, error:$error, customType: $customType, message: $customMessage');
          onMessageSent?.call(kitMessageNotifier.value);
          throw error;
        }
      });
    });
  }

  Future<void> deleteAllMessage({
    required String conversationID,
    required ZIMKitConversationType conversationType,
    required bool isAlsoDeleteServerMessage,
  }) async {
    if (conversationID.isEmpty) return;

    await ZIM
        .getInstance()!
        .deleteAllMessage(
            conversationID,
            conversationType,
            ZIMMessageDeleteConfig()
              ..isAlsoDeleteServerMessage = isAlsoDeleteServerMessage)
        .then((result) {
      ZIMKitLogger.logInfo(
          'deleteAllMessage: success, conversationID:$conversationID, conversationType: ${conversationType.name}');
      db.messages(conversationID, conversationType).deleteAll();
    }).catchError((error) {
      ZIMKitLogger.logError(
          'deleteAllMessage: failed, error:$error, conversationID:$conversationID, conversationType: ${conversationType.name}');
      throw error;
    });
  }

  Future<void> deleteMessage(List<ZIMKitMessage> messages) async {
    if (messages.isEmpty) {
      return;
    }

    final conversationType = messages.first.info.conversationType;
    final conversationID = messages.first.info.conversationID;
    final config = ZIMMessageDeleteConfig()..isAlsoDeleteServerMessage = true;
    final zimMessages = messages.map((e) => e.zim).toList();

    db.messages(conversationID, conversationType).delete(messages);

    await ZIM
        .getInstance()!
        .deleteMessages(zimMessages, conversationID, conversationType, config)
        .then((result) {
      ZIMKitLogger.logInfo('deleteMessage: success');
    }).catchError((error) {
      ZIMKitLogger.logError('deleteMessage: failed,error:$error');
      throw error;
    });
  }

  Future<void> updateLocalExtendedData(
      ZIMKitMessage message, String localExtendedData) async {
    ZIM
        .getInstance()!
        .updateMessageLocalExtendedData(localExtendedData, message.zim)
        .then((value) {
      message.localExtendedData.value = localExtendedData;
    }).catchError((error) {
      ZIMKitLogger.logError('updateLocalExtendedData: failed,error:$error');
      throw error;
    });
  }

  Future<void> recallMessage(ZIMKitMessage message) async {
    if (message.type == ZIMMessageType.revoke) return;
    final conversationType = message.info.conversationType;
    final conversationID = message.info.conversationID;
    final config = ZIMMessageRevokeConfig();
    final zimMessage = message.zim;

    ZIMKitLogger.logInfo('recallMessage: id:${zimMessage.messageID}');
    await ZIM.getInstance()!.revokeMessage(zimMessage, config).then((result) {
      final index = db
          .messages(conversationID, conversationType)
          .notifier
          .value
          .indexWhere((e) =>
              (e.value.info.messageID == message.info.messageID) ||
              (e.value.info.localMessageID == message.info.localMessageID));
      if (index == -1) {
        ZIMKitLogger.logWarn("recallMessage: can't find message");
      } else {
        db
            .messages(conversationID, conversationType)
            .notifier
            .value[index]
            .value = result.message.toKIT();
        ZIMKitLogger.logInfo('recallMessage: success');
      }
    }).catchError((error) {
      ZIMKitLogger.logError('recallMessage: failed,error:$error');
      throw error;
    });
  }

  void addMessage(String id, ZIMKitConversationType type, ZIMMessage message) {
    onReceiveMessage(id, type, [message]);
  }
}

extension ZIMKitCoreMessageEvent on ZIMKitCore {
  void onReceivePeerMessage(
    ZIM zim,
    List<ZIMMessage> messageList,
    String fromUserID,
  ) =>
      onReceiveMessage(fromUserID, ZIMKitConversationType.peer, messageList);

  void onReceiveRoomMessage(
    ZIM zim,
    List<ZIMMessage> messageList,
    String fromRoomID,
  ) =>
      onReceiveMessage(fromRoomID, ZIMKitConversationType.group, messageList);

  void onReceiveGroupMessage(
    ZIM zim,
    List<ZIMMessage> messageList,
    String fromGroupID,
  ) =>
      onReceiveMessage(fromGroupID, ZIMKitConversationType.group, messageList);

  void onMessageRevokeReceived(ZIM zim, List<ZIMRevokeMessage> messageList) =>
      onMessageRecalled(messageList);

  Future<void> onReceiveMessage(
    String fromUserID,
    ZIMKitConversationType type,
    List<ZIMMessage> receiveMessages,
  ) async {
    ZIMKitLogger.logInfo(
        'onReceiveMessage: $fromUserID, $type, ${receiveMessages.length}');

    if (db.conversations.notInited) {
      await getConversationListNotifier();
    }

    if (db.messages(fromUserID, type).notInited) {
      ZIMKitLogger.logInfo(
          'onReceiveMessage: notInited, loadMessageList first');
      await getMessageListNotifier(fromUserID, type);
    } else {
      db.messages(fromUserID, type).receive(receiveMessages);
    }

    messageArrivedNotifier.value = ZIMKitReceivedMessages(
      id: fromUserID,
      type: type,
      receiveMessages: receiveMessages.map((e) => e.toKIT()).toList(),
    );

    db.conversations.sort();

    autoDownloadMessage(db.messages(fromUserID, type).notifier.value);
  }

  Future<void> onMessageRecalled(
    List<ZIMRevokeMessage> recalledMessageList,
  ) async {
    ZIMKitLogger.logInfo('onMessageRecalled:  ${recalledMessageList.length}');

    for (final recalledMessage in recalledMessageList) {
      final conversationID = recalledMessage.conversationID;
      final conversationType = recalledMessage.conversationType;

      if (db.messages(conversationID, conversationType).notInited) {
        ZIMKitLogger.logInfo(
            'onMessageRecalled: notInited, loadMessageList first');
        await getMessageListNotifier(conversationID, conversationType);
      }

      final index = db
          .messages(conversationID, conversationType)
          .notifier
          .value
          .indexWhere((e) =>
              (e.value.info.messageID == recalledMessage.messageID) ||
              (e.value.info.localMessageID == recalledMessage.localMessageID));
      if (index == -1) {
        ZIMKitLogger.logWarn("onMessageRecalled: can't find message");
      } else {
        db
            .messages(conversationID, conversationType)
            .notifier
            .value[index]
            .value = recalledMessage.toKIT();
        ZIMKitLogger.logInfo('recallMessage: success');
      }
    }
  }
}
