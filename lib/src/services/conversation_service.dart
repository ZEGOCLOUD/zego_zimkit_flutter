part of '../zimkit.dart';

/// Service mixin for conversation-related operations
///
/// Provides methods for managing conversations including:
/// - Listing conversations
/// - Deleting conversations
/// - Managing conversation settings (pinned, notification status)
/// Use with [ZIMKit] to access conversation functionality.
mixin ZIMKitConversationService {
  Future<ZIMKitConversationListNotifier> getConversationListNotifier() {
    return ZIMKitCore.instance.getConversationListNotifier();
  }

  ValueNotifier<ZIMKitConversation> getConversation(
    String id,
    ZIMConversationType type,
  ) {
    return ZIMKitCore.instance.db.conversations.get(id, type);
  }

  ValueNotifier<int> getTotalUnreadMessageCount() {
    return ZIMKitCore().totalUnreadMessageCountNotifier;
  }

  Future<void> deleteConversation(
    String id,
    ZIMConversationType type, {
    bool isAlsoDeleteMessages = false,
    bool isAlsoDeleteFromServer = true,
  }) async {
    await ZIMKitCore.instance.deleteConversation(
      id,
      type,
      isAlsoDeleteMessages: isAlsoDeleteMessages,
      isAlsoDeleteFromServer: isAlsoDeleteFromServer,
    );
  }

  Future<void> deleteAllConversation({
    bool isAlsoDeleteFromServer = true,
    bool isAlsoDeleteMessages = false,
  }) async {
    await ZIMKitCore.instance.deleteAllConversation(
        isAlsoDeleteFromServer: isAlsoDeleteFromServer,
        isAlsoDeleteMessages: isAlsoDeleteMessages);
  }

  Future<void> clearUnreadCount(
      String conversationID, ZIMConversationType conversationType) async {
    ZIMKitCore.instance.clearUnreadCount(conversationID, conversationType);
  }

  Future<int> loadMoreConversation() async {
    return ZIMKitCore.instance.loadMoreConversation();
  }

  Future<ZegoZIMKitOfflineMessageCacheInfo> getOfflineConversationInfo({
    bool selfDestructing = true,
  }) async {
    return ZIMKitCore.instance.getOfflineConversationInfo(
      selfDestructing: selfDestructing,
    );
  }

  Future<void> updateConversationPinnedState(
    String conversationID,
    ZIMConversationType conversationType,
    bool isPinned,
  ) async {
    await ZIM.getInstance()!.updateConversationPinnedState(
          isPinned,
          conversationID,
          conversationType,
        );
  }

  Future<void> setConversationNotificationStatus(
    String conversationID,
    ZIMConversationType conversationType,
    ZIMConversationNotificationStatus status,
  ) async {
    await ZIM.getInstance()!.setConversationNotificationStatus(
          status,
          conversationID,
          conversationType,
        );
  }

  Future<ZIMUserFullInfo> queryUser(String userID) async {
    return ZIMKitCore.instance.queryUser(userID);
  }
}
