# ZIMKit Flutter API 参考文档

基准：ZIMKit Flutter v2.0.0（2026-10-14 与源码核对）

本文档列出了 ZIMKit Flutter 版本的所有公开 API。

---

## 目录

- [初始化与认证](#初始化与认证)
- [用户服务](#用户服务)
- [会话服务](#会话服务)
- [消息服务](#消息服务)
- [群组服务](#群组服务)
- [辅助服务](#辅助服务)

---

## 初始化与认证

### init

初始化 ZIMKit。

```dart
Future<void> init({
  required int appID,
  String appSign = '',
  String appSecret = '',
  ZIMKitConfig? config,
  ZIMKitEvents? events,
});
```

**参数**：
- `appID`: 应用 ID
- `appSign`: 应用签名（可选）
- `appSecret`: 应用密钥（可选，用于生成 token）
- `config`: ZIMKit 配置
- `events`: 事件回调

**示例**：
```dart
await ZIMKit().init(
  appID: yourAppID,
  appSecret: yourAppSecret,
  config: ZIMKitConfig.defaultConfig(),
  events: ZIMKitEvents(
    message: ZIMKitMessageEvents(
      onMessageReceived: (conversationID, type, messages) {
        print('Received ${messages.length} messages');
      },
    ),
  ),
);
```

---

### connectUser

连接用户到 ZIM 服务。

```dart
Future<int> connectUser({
  required String id,
  String name = '',
  String avatarUrl = '',
  String token = '',
});
```

`token` 是可选项。启用 Token 鉴权时由服务端生成，并在登录时传入。

### renewToken

续期当前登录用户的 Token。成功返回 `0`，失败返回 ZIM 错误码。

```dart
Future<int> renewToken(String token);
```

---

### disconnectUser

断开用户连接。

```dart
Future<void> disconnectUser();
```

---

## 用户服务

### currentUser

获取当前登录用户信息。

```dart
ZIMKitUser? currentUser();
```

---

### queryUserInfo

查询用户信息。

```dart
Future<List<ZIMKitUser>> queryUserInfo(List<String> userIDs);
```

---

### updateUserInfo

更新当前用户信息。

```dart
Future<void> updateUserInfo(String name, String avatarUrl);
```

---

## 会话服务

### getConversationListNotifier

获取会话列表监听器。

```dart
ValueNotifier<List<ZIMKitConversation>> getConversationListNotifier();
```

**示例**：
```dart
final notifier = ZIMKit().getConversationListNotifier();
notifier.addListener(() {
  print('Conversations: ${notifier.value.length}');
});
```

---

### loadMoreConversation

加载更多会话。

```dart
Future<void> loadMoreConversation();
```

---

### deleteConversation

删除会话。

```dart
Future<void> deleteConversation(
  String conversationID,
  ZIMConversationType type,
);
```

---

### clearUnreadCount

清除会话未读数。

```dart
Future<void> clearUnreadCount(
  String conversationID,
  ZIMConversationType type,
);
```

---

## 消息服务

### 发送消息

#### sendTextMessage

发送文本消息。

```dart
Future<void> sendTextMessage(
  String conversationID,
  ZIMConversationType type,
  String text, {
  ZIMKitMessage? repliedMessage,  // 可选：回复的消息
  FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
  Function(ZIMKitMessage)? onMessageSent,
});
```

**示例**：
```dart
await ZIMKit().sendTextMessage(
  'user123',
  ZIMConversationType.peer,
  'Hello!',
);
```

---

#### replyMessage

回复消息。

```dart
Future<void> replyMessage(
  String conversationID,
  ZIMConversationType type,
  ZIMKitMessage repliedMessage,
  String text, {
  FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
  Function(ZIMKitMessage)? onMessageSent,
});
```

**示例**：
```dart
await ZIMKit().replyMessage(
  'user123',
  ZIMConversationType.peer,
  originalMessage,
  'This is a reply',
);
```

---

#### sendMediaMessage

发送媒体消息（图片、视频、音频）。

```dart
Future<void> sendMediaMessage(
  String conversationID,
  ZIMConversationType type,
  List<ZIMKitPlatformFile> files, {
  ZIMMediaUploadingProgress? mediaUploadingProgress,
  FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
  Function(ZIMKitMessage)? onMessageSent,
});
```

---

#### sendFileMessage

发送文件消息。

```dart
Future<void> sendFileMessage(
  String conversationID,
  ZIMConversationType type,
  List<ZIMKitPlatformFile> files, {
  bool autoDetectType = true,
  ZIMMediaUploadingProgress? mediaUploadingProgress,
  FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
  Function(ZIMKitMessage)? onMessageSent,
});
```

---

#### sendCombineMessage

发送合并消息（聊天记录）。

```dart
Future<void> sendCombineMessage(
  String conversationID,
  ZIMConversationType type, {
  required String title,
  required String summary,
  required List<ZIMKitMessage> messageList,
  FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
  Function(ZIMKitMessage)? onMessageSent,
});
```

**示例**：
```dart
await ZIMKit().sendCombineMessage(
  'user123',
  ZIMConversationType.peer,
  title: 'Chat History',
  summary: 'User1: Hello\\nUser2: Hi',
  messageList: selectedMessages,
);
```

---

#### sendCustomMessage

发送自定义消息。

```dart
Future<void> sendCustomMessage(
  String conversationID,
  ZIMConversationType type, {
  required int customType,
  required String customMessage,
  String? searchedContent,
  FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
  Function(ZIMKitMessage)? onMessageSent,
});
```

---

### 消息操作

#### deleteMessage

删除消息。

```dart
Future<void> deleteMessage(List<ZIMKitMessage> messages);
```

---

#### deleteAllMessage

删除会话中的所有消息。

```dart
Future<void> deleteAllMessage({
  required String conversationID,
  required ZIMConversationType conversationType,
  required bool isAlsoDeleteServerMessage,
});
```

---

#### recallMessage

撤回消息。

```dart
Future<void> recallMessage(ZIMKitMessage message);
```

**示例**：
```dart
await ZIMKit().recallMessage(message);
```

---

#### queryCombineMessageDetail

查询合并消息详情。

```dart
Future<List<ZIMKitMessage>> queryCombineMessageDetail(
  ZIMKitMessage message,
);
```

**示例**：
```dart
final messages = await ZIMKit().queryCombineMessageDetail(combineMessage);
```

---

### 消息反应

#### addMessageReaction

添加消息反应。

```dart
Future<void> addMessageReaction(
  ZIMKitMessage message,
  String reactionType,
);
```

**示例**：
```dart
await ZIMKit().addMessageReaction(message, '👍');
```

---

#### deleteMessageReaction

删除消息反应。

```dart
Future<void> deleteMessageReaction(
  ZIMKitMessage message,
  String reactionType,
);
```

**示例**：
```dart
await ZIMKit().deleteMessageReaction(message, '👍');
```

---

### 消息监听

#### getMessageListNotifier

获取消息列表监听器。

```dart
Future<ZIMKitMessageListNotifier> getMessageListNotifier(
  String conversationID,
  ZIMConversationType type,
);
```

---

#### getOnMessageReceivedNotifier

获取消息接收监听器。

```dart
ValueNotifier<ZIMKitReceivedMessages?> getOnMessageReceivedNotifier();
```

---

#### loadMoreMessage

加载更多消息。

```dart
Future<int> loadMoreMessage(
  String conversationID,
  ZIMConversationType conversationType,
);
```

---

## 群组服务

### createGroup

创建群组。

```dart
Future<void> createGroup({
  required String groupName,
  List<String> inviteUserIDs = const [],
  String? groupID,
  String? groupAvatarUrl,
});
```

---

### joinGroup

加入群组。

```dart
Future<void> joinGroup(String groupID);
```

---

### leaveGroup

离开群组。

```dart
Future<void> leaveGroup(String groupID);
```

---

### inviteUsersToGroup

邀请用户加入群组。

```dart
Future<void> inviteUsersToGroup(
  List<String> userIDs,
  String groupID,
);
```

---

### removeUsersFromGroup

将用户移出群组。

```dart
Future<void> removeUsersFromGroup(
  List<String> userIDs,
  String groupID,
);
```

---

### queryGroupInfo

查询群组信息。

```dart
Future<ZIMKitGroupInfo?> queryGroupInfo(String groupID);
```

---

### queryGroupMemberList

查询群组成员列表。

```dart
ListNotifier<ZIMGroupMemberInfo> queryGroupMemberList(
  String groupID, {void Function(Object error)? onError});
```

---

## 辅助服务

### 转发消息管理

#### setForwardMessages

设置要转发的消息。

```dart
void setForwardMessages(
  List<ZIMKitMessage> messages,
  ZIMKitForwardType forwardType,
);
```

**示例**：
```dart
ZIMKit().setForwardMessages(
  selectedMessages,
  ZIMKitForwardType.single,
);
```

---

#### getForwardMessages

获取要转发的消息。

```dart
List<ZIMKitMessage> getForwardMessages();
```

---

#### getForwardType

获取转发类型。

```dart
ZIMKitForwardType? getForwardType();
```

---

#### clearForwardMessages

清除转发消息。

```dart
void clearForwardMessages();
```

---

## UI 组件

### ZIMKitConversationListView

会话列表视图。

```dart
ZIMKitConversationListView({
  Key? key,
  PreConversationListViewItemBuilder? preConversationListViewItemBuilder,
  ConversationListItemBuilder? conversationListItemBuilder,
});
```

**使用示例**：
```dart
ZIMKitConversationListView(
  conversationListItemBuilder: (context, conversation, defaultWidget) {
    return ListTile(
      title: Text(conversation.name),
      subtitle: Text(conversation.lastMessage?.getShortContent() ?? ''),
    );
  },
)
```

---

## 类型定义

### ZIMKitForwardType

转发类型枚举。

```dart
enum ZIMKitForwardType {
  single,      // 单条转发
  merge,       // 合并转发
  individual,  // 逐条转发
}
```

---

## 回调类型

### MessageSentCallback

消息发送回调。

```dart
typedef MessageSentCallback = void Function(ZIMKitMessage message);
```

---

### PreMessageSendingCallback

消息发送前回调。

```dart
typedef PreMessageSendingCallback = FutureOr<ZIMKitMessage> Function(
  ZIMKitMessage message,
);
```

---

## 更多信息

- [配置文档](configs.md)
- [事件文档](events.md)
- [快速开始](get-started.md)
- [架构进度](../ARCHITECTURE_PROGRESS.md)

---

最后更新：2024-10-28

