part of 'core.dart';

extension ZIMKitCoreNotification on ZIMKitCore {
  void onZPNsRegistered(
    ZPNsRegisterMessage registerMessage,
  ) {
    ZIMKitLogger.logInfo('onZPNsRegistered, '
        'pushID:${registerMessage.pushID}, '
        'errorCode:${registerMessage.errorCode}, '
        'errorMessage:${registerMessage.errorMessage}, '
        'pushSourceType:${registerMessage.pushSourceType}, '
        'commandResult:${registerMessage.commandResult}, ');
  }

  void onZPNsNotificationArrived(
    ZPNsMessage message,
  ) {
    ZIMKitLogger.logInfo('onZPNsNotificationArrived, '
        'title:${message.title}, '
        'content:${message.content}, '
        'payload:${message.payload}, '
        'extras:${message.extras}, '
        'pushSourceType:${message.pushSourceType}, ');
  }

  Future<void> onZPNsNotificationClicked(
    ZPNsMessage message,
  ) async {
    ZIMKitLogger.logInfo('onZPNsNotificationClicked, '
        'title:${message.title}, '
        'content:${message.content}, '
        'payload:${message.payload}, '
        'extras:${message.extras}, '
        'pushSourceType:${message.pushSourceType}, ');

    final parser = ZIMKitIOSIMMessageDataParser();
    await parser.parse(message).then((ZIMKitIOSIMMessageData imMessage) async {
      ZIMKitLogger.logInfo('onZPNsNotificationClicked, '
          'message parser:$imMessage, ');
      await setOfflineMessageConversationInfo(
        ZegoZIMKitOfflineMessageCacheInfo(
          conversationID: imMessage.conversationID,
          conversationTypeIndex: imMessage.conversationTypeIndex,
          senderID: imMessage.senderID,
        ),
      );
    });
  }
}
