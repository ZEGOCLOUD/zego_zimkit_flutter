part of '../zimkit.dart';

/// Service mixin for message-related operations
///
/// Provides methods for sending, receiving, and managing messages.
/// Supports text, media (image, audio, video, file), custom, and combine messages.
/// Use with [ZIMKit] to access message functionality.
mixin ZIMKitMessageService {
  // Event
  Future<ZIMKitMessageListNotifier> getMessageListNotifier(
    String conversationID,
    ZIMConversationType type,
  ) {
    return ZIMKitCore.instance.getMessageListNotifier(conversationID, type);
  }

  ValueNotifier<ZIMKitReceivedMessages?> getOnMessageReceivedNotifier() {
    return ZIMKitCore().messageArrivedNotifier;
  }

  // API
  Future<int> loadMoreMessage(
    String conversationID,
    ZIMConversationType conversationType,
  ) async {
    return ZIMKitCore.instance.loadMoreMessage(
      conversationID,
      conversationType,
    );
  }

  Future<void> sendTextMessage(
    String conversationID,
    ZIMConversationType type,
    String text, {
    ZIMKitMessage? repliedMessage,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    return ZIMKitCore.instance.sendTextMessage(
      conversationID,
      type,
      text,
      repliedMessage: repliedMessage,
      preMessageSending: preMessageSending,
      onMessageSent: onMessageSent,
    );
  }

  Future<void> replyMessage(
    String conversationID,
    ZIMConversationType type,
    ZIMKitMessage repliedMessage,
    String text, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    return ZIMKitCore.instance.sendTextMessage(
      conversationID,
      type,
      text,
      repliedMessage: repliedMessage,
      preMessageSending: preMessageSending,
      onMessageSent: onMessageSent,
    );
  }

  Future<void> sendFileMessage(
    String conversationID,
    ZIMConversationType type,
    List<ZIMKitPlatformFile> files, {
    bool autoDetectType = true,
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    for (final file in files) {
      ZIMKitCore.instance.sendMediaMessage(
        conversationID,
        type,
        file.path!,
        ZIMMessageType.file,
        preMessageSending: preMessageSending,
        onMessageSent: onMessageSent,
      );
    }
  }

  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType type,
    List<ZIMKitPlatformFile> files, {
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    ZIMKitLogger.logInfo(
      'sendMediaMessage: ${DateTime.now().millisecondsSinceEpoch}',
    );
    for (final file in files) {
      await ZIMKitCore.instance.sendMediaMessage(
        conversationID,
        type,
        file.path!,
        ZIMKit().getMessageTypeByFileExtension(file),
        preMessageSending: preMessageSending,
        onMessageSent: onMessageSent,
      );
    }
    return;
  }

  Future<void> sendCustomMessage(
    String conversationID,
    ZIMConversationType type, {
    required int customType,
    required String customMessage,
    String? searchedContent,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    return ZIMKitCore.instance.sendCustomMessage(
      conversationID,
      type,
      customMessage: customMessage,
      customType: customType,
      searchedContent: searchedContent,
      preMessageSending: preMessageSending,
      onMessageSent: onMessageSent,
    );
  }

  Future<void> sendCombineMessage(
    String conversationID,
    ZIMConversationType type, {
    required String title,
    required String summary,
    required List<ZIMKitMessage> messageList,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  }) async {
    return ZIMKitCore.instance.sendCombineMessage(
      conversationID,
      type,
      title: title,
      summary: summary,
      messageList: messageList,
      preMessageSending: preMessageSending,
      onMessageSent: onMessageSent,
    );
  }

  Future<List<ZIMKitMessage>> queryCombineMessageDetail(
    ZIMKitMessage message,
  ) async {
    return ZIMKitCore.instance.queryCombineMessageDetail(message);
  }

  Future<void> deleteMessage(List<ZIMKitMessage> messages) async {
    return ZIMKitCore.instance.deleteMessage(messages);
  }

  Future<void> deleteAllMessage({
    required String conversationID,
    required ZIMConversationType conversationType,
    required bool isAlsoDeleteServerMessage,
  }) async {
    return ZIMKitCore.instance.deleteAllMessage(
      conversationID: conversationID,
      conversationType: conversationType,
      isAlsoDeleteServerMessage: isAlsoDeleteServerMessage,
    );
  }

  Future<void> recallMessage(ZIMKitMessage message) async {
    return ZIMKitCore.instance.recallMessage(message);
  }

  Future<void> updateLocalExtendedData(
    ZIMKitMessage message,
    String localExtendedData,
  ) {
    return ZIMKitCore.instance.updateLocalExtendedData(
      message,
      localExtendedData,
    );
  }

  Future<void> addMessageReaction(
    ZIMKitMessage message,
    String reactionType,
  ) async {
    return ZIMKitCore.instance.addMessageReaction(message, reactionType);
  }

  Future<void> deleteMessageReaction(
    ZIMKitMessage message,
    String reactionType,
  ) async {
    return ZIMKitCore.instance.deleteMessageReaction(message, reactionType);
  }

  void downloadMediaFile(ZIMKitMessage message) {
    return ZIMKitCore.instance.downloadMediaFile(message);
  }
}
