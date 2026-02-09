# APIs

This document describes the APIs available in ZIMKit, including initialization, conversation management, messaging, group operations, and user management.

## Table of Contents

- [ZIMKit Singleton](#zimkit-singleton)
  - [init](#init)
  - [uninit](#uninit)
  - [getVersion](#getversion)
- [Conversation APIs](#conversation-apis)
  - [getConversationListNotifier](#getconversationlistnotifier)
  - [getConversation](#getconversation)
  - [getTotalUnreadMessageCount](#gettotalunreadmessagecount)
  - [deleteConversation](#deleteconversation)
  - [deleteAllConversation](#deleteallconversation)
  - [clearUnreadCount](#clearunreadcount)
  - [loadMoreConversation](#loadmoreconversation)
  - [getOfflineConversationInfo](#getofflineconversationinfo)
  - [updateConversationPinnedState](#updateconversationpinnedstate)
  - [setConversationNotificationStatus](#setconversationnotificationstatus)
  - [queryUser](#queryuser)
- [Message APIs](#message-apis)
  - [getMessageListNotifier](#getmessagelistnotifier)
  - [getOnMessageReceivedNotifier](#getonmessagereceivednotifier)
  - [loadMoreMessage](#loadmoremessage)
  - [sendTextMessage](#sendtextmessage)
  - [replyMessage](#replymessage)
  - [sendFileMessage](#sendfilemessage)
  - [sendMediaMessage](#sendmediamessage)
  - [sendCustomMessage](#sendcustommessage)
  - [sendCombineMessage](#sendcombinemessage)
  - [queryCombineMessageDetail](#querycombinemessagedetail)
  - [deleteMessage](#deletemessage)
  - [deleteAllMessage](#deleteallmessage)
  - [recallMessage](#recallmessage)
  - [updateLocalExtendedData](#updatelocalextendeddata)
  - [addMessageReaction](#addmessagereaction)
  - [deleteMessageReaction](#deletemessagereaction)
  - [downloadMediaFile](#downloadmediafile)
- [Group APIs](#group-apis)
  - [createGroup](#creategroup)
  - [joinGroup](#joingroup)
  - [addUsersToGroup](#adduserstogroup)
  - [removeUsersFromGroup](#removeusersfromgroup)
  - [leaveGroup](#leavegroup)
  - [queryGroupInfo](#querygroupinfo)
  - [disbandGroup](#disbandgroup)
  - [transferGroupOwner](#transfergroupowner)
  - [queryGroupMemberInfo](#querygroupmemberinfo)
  - [queryGroupOwner](#querygroupowner)
  - [queryGroupMemberList](#querygroupmemberlist)
  - [queryGroupMemberCount](#querygroupmembercount)
  - [setGroupMemberRole](#setgroupmemberrole)
  - [getGroupStateChangedEventStream](#getgroupstatechangedeventstream)
  - [getGroupNameUpdatedEventStream](#getgroupnameupdatedeventstream)
  - [getGroupAvatarUrlUpdatedEventStream](#getgroupavatarurlupdatedeventstream)
  - [getGroupNoticeUpdatedEventStream](#getgroupnoticeupdatedeventstream)
  - [getGroupAttributesUpdatedEventStream](#getgroupattributesupdatedeventstream)
  - [getGroupMemberStateChangedEventStream](#getgroupmemberstatechangedeventstream)
  - [getGroupMemberInfoUpdatedEventStream](#getgroupmemberinfoupdatedeventstream)
- [User APIs](#user-apis)
  - [connectUser](#connectuser)
  - [disconnectUser](#disconnectuser)
  - [currentUser](#currentuser)
  - [queryUser](#queryuser-1)
  - [updateUserInfo](#updateuserinfo)
  - [getConnectionStateChangedEventStream](#getconnectionstatechangedeventstream)
- [Helper APIs](#helper-apis)
  - [registerAppLifecycleStateChangedListener](#registerapplifecyclestatechangedlistener)
  - [unregisterAppLifecycleStateChangedListener](#unregisterapplifecyclestatechangedlistener)
  - [isAppLocked](#isapplocked)
  - [setForwardMessages](#setforwardmessages)
  - [getForwardMessages](#getforwardmessages)
  - [getForwardType](#getforwardtype)
  - [clearForwardMessages](#clearforwardmessages)

---

## ZIMKit Singleton

### init

- **Description**
  Initializes the ZIMKit SDK with the given app credentials and configuration.

- **Prototype**
  ```dart
  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    ZIMKitConfig? config,
    ZIMKitEvents? events,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().init(
    appID: yourAppID,
    appSign: yourAppSign,
    config: ZIMKitConfig(),
    events: ZIMKitEvents(),
  );
  ```

### uninit

- **Description**
  Uninitializes the ZIMKit SDK and releases all resources.

- **Prototype**
  ```dart
  Future<void> uninit()
  ```

- **Example**
  ```dart
  await ZIMKit().uninit();
  ```

### getVersion

- **Description**
  Returns the current version string of ZIMKit.

- **Prototype**
  ```dart
  String getVersion()
  ```

- **Example**
  ```dart
  final version = ZIMKit().getVersion();
  print('ZIMKit version: $version');
  ```

---

## Conversation APIs

### getConversationListNotifier

- **Description**
  Gets a Future that resolves to a notifier for the conversation list.

- **Prototype**
  ```dart
  Future<ZIMKitConversationListNotifier> getConversationListNotifier()
  ```

- **Example**
  ```dart
  final notifier = await ZIMKit().getConversationListNotifier();
  ```

### getConversation

- **Description**
  Gets a ValueNotifier for a specific conversation by ID and type.

- **Prototype**
  ```dart
  ValueNotifier<ZIMKitConversation> getConversation(
    String id,
    ZIMConversationType type,
  )
  ```

- **Example**
  ```dart
  final conversation = ZIMKit().getConversation('user123', ZIMConversationType.peer);
  ```

### getTotalUnreadMessageCount

- **Description**
  Gets a notifier for the total unread message count across all conversations.

- **Prototype**
  ```dart
  ValueNotifier<int> getTotalUnreadMessageCount()
  ```

- **Example**
  ```dart
  final unreadCount = ZIMKit().getTotalUnreadMessageCount();
  ```

### deleteConversation

- **Description**
  Deletes a conversation and optionally its messages.

- **Prototype**
  ```dart
  Future<void> deleteConversation(
    String id,
    ZIMConversationType type, {
    bool isAlsoDeleteMessages = false,
    bool isAlsoDeleteFromServer = true,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().deleteConversation(
    'conversation123',
    ZIMConversationType.peer,
    isAlsoDeleteMessages: true,
  );
  ```

### deleteAllConversation

- **Description**
  Deletes all conversations.

- **Prototype**
  ```dart
  Future<void> deleteAllConversation({
    bool isAlsoDeleteFromServer = true,
    bool isAlsoDeleteMessages = false,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().deleteAllConversation(isAlsoDeleteMessages: true);
  ```

### clearUnreadCount

- **Description**
  Clears the unread count for a specific conversation.

- **Prototype**
  ```dart
  Future<void> clearUnreadCount(
    String conversationID,
    ZIMConversationType conversationType,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().clearUnreadCount('user123', ZIMConversationType.peer);
  ```

### loadMoreConversation

- **Description**
  Loads more conversations from the server.

- **Prototype**
  ```dart
  Future<int> loadMoreConversation()
  ```

- **Example**
  ```dart
  final count = await ZIMKit().loadMoreConversation();
  ```

### getOfflineConversationInfo

- **Description**
  Gets information about offline message cache.

- **Prototype**
  ```dart
  Future<ZegoZIMKitOfflineMessageCacheInfo> getOfflineConversationInfo({
    bool selfDestructing = true,
  })
  ```

- **Example**
  ```dart
  final info = await ZIMKit().getOfflineConversationInfo();
  ```

### updateConversationPinnedState

- **Description**
  Updates the pinned state of a conversation.

- **Prototype**
  ```dart
  Future<void> updateConversationPinnedState(
    String conversationID,
    ZIMConversationType conversationType,
    bool isPinned,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().updateConversationPinnedState(
    'conversation123',
    ZIMConversationType.peer,
    true,
  );
  ```

### setConversationNotificationStatus

- **Description**
  Sets the notification status (mute/unmute) for a conversation.

- **Prototype**
  ```dart
  Future<void> setConversationNotificationStatus(
    String conversationID,
    ZIMConversationType conversationType,
    ZIMConversationNotificationStatus status,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().setConversationNotificationStatus(
    'conversation123',
    ZIMConversationType.peer,
    ZIMConversationNotificationStatus.notNotify,
  );
  ```

### queryUser

- **Description**
  Queries user information by user ID.

- **Prototype**
  ```dart
  Future<ZIMUserFullInfo> queryUser(String userID)
  ```

- **Example**
  ```dart
  final userInfo = await ZIMKit().queryUser('user123');
  ```

---

## Message APIs

### getMessageListNotifier

- **Description**
  Gets a notifier for the message list of a specific conversation.

- **Prototype**
  ```dart
  Future<ZIMKitMessageListNotifier> getMessageListNotifier(
    String conversationID,
    ZIMConversationType type,
  )
  ```

- **Example**
  ```dart
  final notifier = await ZIMKit().getMessageListNotifier('user123', ZIMConversationType.peer);
  ```

### getOnMessageReceivedNotifier

- **Description**
  Gets a notifier for receiving new messages.

- **Prototype**
  ```dart
  ValueNotifier<ZIMKitReceivedMessages?> getOnMessageReceivedNotifier()
  ```

- **Example**
  ```dart
  final notifier = ZIMKit().getOnMessageReceivedNotifier();
  ```

### loadMoreMessage

- **Description**
  Loads more messages for a conversation.

- **Prototype**
  ```dart
  Future<int> loadMoreMessage(
    String conversationID,
    ZIMConversationType conversationType,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().loadMoreMessage('user123', ZIMConversationType.peer);
  ```

### sendTextMessage

- **Description**
  Sends a text message to a conversation.

- **Prototype**
  ```dart
  Future<void> sendTextMessage(
    String conversationID,
    ZIMConversationType type,
    String text, {
    ZIMKitMessage? repliedMessage,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().sendTextMessage(
    'user123',
    ZIMConversationType.peer,
    'Hello!',
  );
  ```

### replyMessage

- **Description**
  Replies to a specific message with text.

- **Prototype**
  ```dart
  Future<void> replyMessage(
    String conversationID,
    ZIMConversationType type,
    ZIMKitMessage repliedMessage,
    String text, {
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().replyMessage(
    'user123',
    ZIMConversationType.peer,
    originalMessage,
    'This is a reply',
  );
  ```

### sendFileMessage

- **Description**
  Sends file messages to a conversation.

- **Prototype**
  ```dart
  Future<void> sendFileMessage(
    String conversationID,
    ZIMConversationType type,
    List<ZIMKitPlatformFile> files, {
    bool autoDetectType = true,
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().sendFileMessage(
    'user123',
    ZIMConversationType.peer,
    [file],
  );
  ```

### sendMediaMessage

- **Description**
  Sends media messages (images, videos, audio) to a conversation.

- **Prototype**
  ```dart
  Future<void> sendMediaMessage(
    String conversationID,
    ZIMConversationType type,
    List<ZIMKitPlatformFile> files, {
    ZIMMediaUploadingProgress? mediaUploadingProgress,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().sendMediaMessage(
    'user123',
    ZIMConversationType.peer,
    [imageFile],
  );
  ```

### sendCustomMessage

- **Description**
  Sends a custom message with user-defined type and content.

- **Prototype**
  ```dart
  Future<void> sendCustomMessage(
    String conversationID,
    ZIMConversationType type, {
    required int customType,
    required String customMessage,
    String? searchedContent,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().sendCustomMessage(
    'user123',
    ZIMConversationType.peer,
    customType: 1001,
    customMessage: '{"action": "like"}',
  );
  ```

### sendCombineMessage

- **Description**
  Sends a combined message containing multiple messages.

- **Prototype**
  ```dart
  Future<void> sendCombineMessage(
    String conversationID,
    ZIMConversationType type, {
    required String title,
    required String summary,
    required List<ZIMKitMessage> messageList,
    FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
    Function(ZIMKitMessage)? onMessageSent,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().sendCombineMessage(
    'user123',
    ZIMConversationType.peer,
    title: 'Chat History',
    summary: ['Message 1', 'Message 2'],
    messageList: messages,
  );
  ```

### queryCombineMessageDetail

- **Description**
  Queries the detail of a combined message.

- **Prototype**
  ```dart
  Future<List<ZIMKitMessage>> queryCombineMessageDetail(
    ZIMKitMessage message,
  )
  ```

- **Example**
  ```dart
  final messages = await ZIMKit().queryCombineMessageDetail(combineMessage);
  ```

### deleteMessage

- **Description**
  Deletes specified messages from a conversation.

- **Prototype**
  ```dart
  Future<void> deleteMessage(List<ZIMKitMessage> messages)
  ```

- **Example**
  ```dart
  await ZIMKit().deleteMessage([message1, message2]);
  ```

### deleteAllMessage

- **Description**
  Deletes all messages in a conversation.

- **Prototype**
  ```dart
  Future<void> deleteAllMessage({
    required String conversationID,
    required ZIMConversationType conversationType,
    required bool isAlsoDeleteServerMessage,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().deleteAllMessage(
    conversationID: 'user123',
    conversationType: ZIMConversationType.peer,
    isAlsoDeleteServerMessage: true,
  );
  ```

### recallMessage

- **Description**
  Recalls (deletes) a sent message within the time limit.

- **Prototype**
  ```dart
  Future<void> recallMessage(ZIMKitMessage message)
  ```

- **Example**
  ```dart
  await ZIMKit().recallMessage(message);
  ```

### updateLocalExtendedData

- **Description**
  Updates local extended data for a message.

- **Prototype**
  ```dart
  Future<void> updateLocalExtendedData(
    ZIMKitMessage message,
    String localExtendedData,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().updateLocalExtendedData(message, '{"key": "value"}');
  ```

### addMessageReaction

- **Description**
  Adds a reaction (emoji) to a message.

- **Prototype**
  ```dart
  Future<void> addMessageReaction(
    ZIMKitMessage message,
    String reactionType,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().addMessageReaction(message, '👍');
  ```

### deleteMessageReaction

- **Description**
  Deletes a reaction from a message.

- **Prototype**
  ```dart
  Future<void> deleteMessageReaction(
    ZIMKitMessage message,
    String reactionType,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().deleteMessageReaction(message, '👍');
  ```

### downloadMediaFile

- **Description**
  Downloads media file for a message (image, video, audio, file).

- **Prototype**
  ```dart
  void downloadMediaFile(ZIMKitMessage message)
  ```

- **Example**
  ```dart
  ZIMKit().downloadMediaFile(message);
  ```

---

## Group APIs

### createGroup

- **Description**
  Creates a new group with the specified name and initial members.

- **Prototype**
  ```dart
  Future<String?> createGroup(
    String name,
    List<String> inviteUserIDs, {
    String id = '',
  })
  ```

- **Example**
  ```dart
  final groupID = await ZIMKit().createGroup(
    'My Group',
    ['user1', 'user2'],
  );
  ```

### joinGroup

- **Description**
  Joins an existing group.

- **Prototype**
  ```dart
  Future<int> joinGroup(String conversationID)
  ```

- **Example**
  ```dart
  final errorCode = await ZIMKit().joinGroup('group123');
  ```

### addUsersToGroup

- **Description**
  Adds users to an existing group.

- **Prototype**
  ```dart
  Future<int> addUsersToGroup(
    String conversationID,
    List<String> userIDs,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().addUsersToGroup('group123', ['user4', 'user5']);
  ```

### removeUsersFromGroup

- **Description**
  Removes users from a group.

- **Prototype**
  ```dart
  Future<int> removeUsersFromGroup(
    String conversationID,
    List<String> userIDs,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().removeUsersFromGroup('group123', ['user4']);
  ```

### leaveGroup

- **Description**
  Leaves a group.

- **Prototype**
  ```dart
  Future<int> leaveGroup(String conversationID)
  ```

- **Example**
  ```dart
  await ZIMKit().leaveGroup('group123');
  ```

### queryGroupInfo

- **Description**
  Queries group information.

- **Prototype**
  ```dart
  ValueNotifier<ZIMKitGroupInfo> queryGroupInfo(String conversationID)
  ```

- **Example**
  ```dart
  final groupInfo = ZIMKit().queryGroupInfo('group123');
  ```

### disbandGroup

- **Description**
  Disbands (deletes) a group. Only the group owner can perform this action.

- **Prototype**
  ```dart
  Future<int> disbandGroup(String conversationID)
  ```

- **Example**
  ```dart
  await ZIMKit().disbandGroup('group123');
  ```

### transferGroupOwner

- **Description**
  Transfers group ownership to another member.

- **Prototype**
  ```dart
  Future<int> transferGroupOwner(
    String conversationID,
    String toUserID,
  )
  ```

- **Example**
  ```dart
  await ZIMKit().transferGroupOwner('group123', 'newOwnerID');
  ```

### queryGroupMemberInfo

- **Description**
  Queries information about a specific group member.

- **Prototype**
  ```dart
  Future<ZIMGroupMemberInfo?> queryGroupMemberInfo(
    String conversationID,
    String userID,
  )
  ```

- **Example**
  ```dart
  final memberInfo = await ZIMKit().queryGroupMemberInfo('group123', 'user123');
  ```

### queryGroupOwner

- **Description**
  Gets a notifier for the group owner information.

- **Prototype**
  ```dart
  ValueNotifier<ZIMGroupMemberInfo?> queryGroupOwner(String conversationID)
  ```

- **Example**
  ```dart
  final owner = ZIMKit().queryGroupOwner('group123');
  ```

### queryGroupMemberList

- **Description**
  Gets a notifier for the list of group members.

- **Prototype**
  ```dart
  ListNotifier<ZIMGroupMemberInfo> queryGroupMemberList(String conversationID)
  ```

- **Example**
  ```dart
  final memberList = ZIMKit().queryGroupMemberList('group123');
  ```

### queryGroupMemberCount

- **Description**
  Gets a notifier for the count of group members.

- **Prototype**
  ```dart
  ValueNotifier<int> queryGroupMemberCount(String conversationID)
  ```

- **Example**
  ```dart
  final count = ZIMKit().queryGroupMemberCount('group123');
  ```

### setGroupMemberRole

- **Description**
  Sets the role for a group member.

- **Prototype**
  ```dart
  Future<int> setGroupMemberRole({
    required String conversationID,
    required String userID,
    required int role,
  })
  ```

- **Example**
  ```dart
  await ZIMKit().setGroupMemberRole(
    conversationID: 'group123',
    userID: 'user123',
    role: ZIMGroupMemberRole.manager,
  );
  ```

### getGroupStateChangedEventStream

- **Description**
  Gets a stream for group state changed events.

- **Prototype**
  ```dart
  Stream<ZIMKitEventGroupStateChanged> getGroupStateChangedEventStream()
  ```

- **Example**
  ```dart
  ZIMKit().getGroupStateChangedEventStream().listen((event) {
    print('Group state changed: ${event.state}');
  });
  ```

### getGroupNameUpdatedEventStream

- **Description**
  Gets a stream for group name updated events.

- **Prototype**
  ```dart
  Stream<ZIMKitEventGroupNameUpdated> getGroupNameUpdatedEventStream()
  ```

### getGroupAvatarUrlUpdatedEventStream

- **Description**
  Gets a stream for group avatar URL updated events.

- **Prototype**
  ```dart
  Stream<ZIMKitEventGroupAvatarUrlUpdated> getGroupAvatarUrlUpdatedEventStream()
  ```

### getGroupNoticeUpdatedEventStream

- **Description**
  Gets a stream for group notice updated events.

- **Prototype**
  ```dart
  Stream<ZIMKitEventGroupNoticeUpdated> getGroupNoticeUpdatedEventStream()
  ```

### getGroupAttributesUpdatedEventStream

- **Description**
  Gets a stream for group attributes updated events.

- **Prototype**
  ```dart
  Stream<ZIMKitEventGroupAttributesUpdated> getGroupAttributesUpdatedEventStream()
  ```

### getGroupMemberStateChangedEventStream

- **Description**
  Gets a stream for group member state changed events (joined/left).

- **Prototype**
  ```dart
  Stream<ZIMKitEventGroupMemberStateChanged> getGroupMemberStateChangedEventStream()
  ```

### getGroupMemberInfoUpdatedEventStream

- **Description**
  Gets a stream for group member info updated events.

- **Prototype**
  ```dart
  Stream<ZIMKitEventGroupMemberInfoUpdated> getGroupMemberInfoUpdatedEventStream()
  ```

---

## User APIs

### connectUser

- **Description**
  Connects a user to the ZIM service with the given credentials.

- **Prototype**
  ```dart
  Future<int> connectUser({
    required String id,
    String name = '',
    String avatarUrl = '',
  })
  ```

- **Example**
  ```dart
  await ZIMKit().connectUser(
    id: 'user123',
    name: 'John Doe',
    avatarUrl: 'https://example.com/avatar.png',
  );
  ```

### disconnectUser

- **Description**
  Disconnects the current user from the ZIM service.

- **Prototype**
  ```dart
  Future<void> disconnectUser()
  ```

- **Example**
  ```dart
  await ZIMKit().disconnectUser();
  ```

### currentUser

- **Description**
  Gets the current user's information.

- **Prototype**
  ```dart
  ZIMUserFullInfo? currentUser()
  ```

- **Example**
  ```dart
  final user = ZIMKit().currentUser();
  ```

### queryUser

- **Description**
  Queries user information by user ID.

- **Prototype**
  ```dart
  Future<ZIMUserFullInfo> queryUser(String id)
  ```

- **Example**
  ```dart
  final userInfo = await ZIMKit().queryUser('user123');
  ```

### updateUserInfo

- **Description**
  Updates the current user's information.

- **Prototype**
  ```dart
  Future<int> updateUserInfo({
    String name = '',
    String avatarUrl = '',
  })
  ```

- **Example**
  ```dart
  await ZIMKit().updateUserInfo(
    name: 'New Name',
    avatarUrl: 'https://example.com/new_avatar.png',
  );
  ```

### getConnectionStateChangedEventStream

- **Description**
  Gets a stream for connection state changed events.

- **Prototype**
  ```dart
  Stream<ZegoSignalingPluginConnectionStateChangedEvent> getConnectionStateChangedEventStream()
  ```

- **Example**
  ```dart
  ZIMKit().getConnectionStateChangedEventStream().listen((event) {
    print('Connection state: ${event.state}');
  });
  ```

---

## Helper APIs

### registerAppLifecycleStateChangedListener

- **Description**
  Registers a message handler for app lifecycle state changes.

- **Prototype**
  ```dart
  void registerAppLifecycleStateChangedListener(
    ZegoPluginAdapterMessageHandler listener,
  )
  ```

- **Example**
  ```dart
  ZIMKit().registerAppLifecycleStateChangedListener((message) {
    print('Received message: $message');
  });
  ```

### unregisterAppLifecycleStateChangedListener

- **Description**
  Unregisters a previously registered message handler.

- **Prototype**
  ```dart
  void unregisterAppLifecycleStateChangedListener(
    ZegoPluginAdapterMessageHandler listener,
  )
  ```

- **Example**
  ```dart
  ZIMKit().unregisterAppLifecycleStateChangedListener(listener);
  ```

### isAppLocked

- **Description**
  Checks if the app is currently in a locked state.

- **Prototype**
  ```dart
  Future<bool> isAppLocked()
  ```

- **Example**
  ```dart
  final isLocked = await ZIMKit().isAppLocked();
  ```

### setForwardMessages

- **Description**
  Sets the messages to be forwarded and the forward type.

- **Prototype**
  ```dart
  void setForwardMessages(
    List<ZIMKitMessage> messages,
    ZIMKitForwardType forwardType,
  )
  ```

- **Example**
  ```dart
  ZIMKit().setForwardMessages(messages, ZIMKitForwardType.merge);
  ```

### getForwardMessages

- **Description**
  Gets the messages currently set for forwarding.

- **Prototype**
  ```dart
  List<ZIMKitMessage> getForwardMessages()
  ```

- **Example**
  ```dart
  final messages = ZIMKit().getForwardMessages();
  ```

### getForwardType

- **Description**
  Gets the current forward type.

- **Prototype**
  ```dart
  ZIMKitForwardType? getForwardType()
  ```

- **Example**
  ```dart
  final type = ZIMKit().getForwardType();
  ```

### clearForwardMessages

- **Description**
  Clears the forward messages and resets the forward type.

- **Prototype**
  ```dart
  void clearForwardMessages()
  ```

- **Example**
  ```dart
  ZIMKit().clearForwardMessages();
  ```
