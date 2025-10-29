# ZIMKit 事件文档

本文档介绍 ZIMKit 的所有事件回调。

## 目录

- [ZIMKitEvents](#zimkitevents) - 事件回调类
- [ZIMKitMessageEvents](#zimkitmessageevents) - 消息事件
- [ZIMKitConversationEvents](#zimkitconversationevents) - 会话事件
- [ZIMKitUserEvents](#zimkituserevents) - 用户事件
- [ZIMKitGroupEvents](#zimkitgroupevents) - 群组事件
- [ZIMKitCallEvents](#zimkitcallevents) - 通话事件
- [ZIMKitConnectionEvents](#zimkitconnectionevents) - 连接事件
- [事件数据类型](#事件数据类型)

---

## ZIMKitEvents

事件回调容器类，包含所有子事件类别。

### 构造函数

```dart
ZIMKitEvents({
  ZIMKitMessageEvents? message,
  ZIMKitConversationEvents? conversation,
  ZIMKitUserEvents? user,
  ZIMKitGroupEvents? group,
  ZIMKitCallEvents? call,
  ZIMKitConnectionEvents? connection,
})
```

### 属性

| 属性 | 类型 | 描述 |
|-----|------|------|
| message | ZIMKitMessageEvents? | 消息相关事件 |
| conversation | ZIMKitConversationEvents? | 会话相关事件 |
| user | ZIMKitUserEvents? | 用户相关事件 |
| group | ZIMKitGroupEvents? | 群组相关事件 |
| call | ZIMKitCallEvents? | 通话相关事件 |
| connection | ZIMKitConnectionEvents? | 连接相关事件 |

### 示例

```dart
final events = ZIMKitEvents(
  message: ZIMKitMessageEvents(
    onReceived: (List<ZIMKitMessageEvent> events) {
      print('收到 ${events.length} 条新消息');
    },
    onSent: (ZIMKitMessage message) {
      print('消息发送成功: ${message.info.message.message}');
    },
  ),
  connection: ZIMKitConnectionEvents(
    onStateChanged: (ZIMConnectionState state) {
      print('连接状态变化: $state');
    },
  ),
);

await ZIMKit().init(
  appID: yourAppID,
  appSign: yourAppSign,
  events: events,
);
```

---

## ZIMKitMessageEvents

消息相关事件。

### 构造函数

```dart
ZIMKitMessageEvents({
  void Function(List<ZIMKitMessageEvent> events)? onReceived,
  void Function(ZIMKitMessage message)? onSent,
  void Function(String messageID, String error)? onSendFailed,
  void Function(List<ZIMKitMessageEvent> events)? onRevoked,
  void Function(List<ZIMKitMessageEvent> events)? onDeleted,
  void Function(ZIMKitMessage message)? onReactionAdded,
  void Function(ZIMKitMessage message)? onReactionRemoved,
  void Function(String messageID, int progress)? onMediaUploadProgress,
  void Function(String messageID, int progress)? onMediaDownloadProgress,
})
```

### 事件回调

#### onReceived

接收到新消息。

```dart
void Function(List<ZIMKitMessageEvent> events)? onReceived
```

**参数**：
- `events`: 消息事件列表

**示例**：
```dart
onReceived: (List<ZIMKitMessageEvent> events) {
  for (var event in events) {
    print('收到来自 ${event.conversationID} 的消息');
    print('消息内容: ${event.message.info.message.message}');
  }
}
```

#### onSent

消息发送成功。

```dart
void Function(ZIMKitMessage message)? onSent
```

**参数**：
- `message`: 发送成功的消息

**示例**：
```dart
onSent: (ZIMKitMessage message) {
  print('消息已发送: ${message.info.message.messageID}');
}
```

#### onSendFailed

消息发送失败。

```dart
void Function(String messageID, String error)? onSendFailed
```

**参数**：
- `messageID`: 消息 ID
- `error`: 错误信息

**示例**：
```dart
onSendFailed: (String messageID, String error) {
  print('消息发送失败: $messageID, 错误: $error');
}
```

#### onRevoked

消息被撤回。

```dart
void Function(List<ZIMKitMessageEvent> events)? onRevoked
```

**参数**：
- `events`: 被撤回的消息事件列表

**示例**：
```dart
onRevoked: (List<ZIMKitMessageEvent> events) {
  print('${events.length} 条消息被撤回');
}
```

#### onDeleted

消息被删除。

```dart
void Function(List<ZIMKitMessageEvent> events)? onDeleted
```

**参数**：
- `events`: 被删除的消息事件列表

**示例**：
```dart
onDeleted: (List<ZIMKitMessageEvent> events) {
  print('${events.length} 条消息被删除');
}
```

#### onReactionAdded

消息表情反应被添加。

```dart
void Function(ZIMKitMessage message)? onReactionAdded
```

**参数**：
- `message`: 更新后的消息

**示例**：
```dart
onReactionAdded: (ZIMKitMessage message) {
  print('消息收到新的表情反应');
}
```

#### onReactionRemoved

消息表情反应被移除。

```dart
void Function(ZIMKitMessage message)? onReactionRemoved
```

**参数**：
- `message`: 更新后的消息

**示例**：
```dart
onReactionRemoved: (ZIMKitMessage message) {
  print('消息表情反应被移除');
}
```

#### onMediaUploadProgress

媒体文件上传进度。

```dart
void Function(String messageID, int progress)? onMediaUploadProgress
```

**参数**：
- `messageID`: 消息 ID
- `progress`: 上传进度 (0-100)

**示例**：
```dart
onMediaUploadProgress: (String messageID, int progress) {
  print('消息 $messageID 上传进度: $progress%');
}
```

#### onMediaDownloadProgress

媒体文件下载进度。

```dart
void Function(String messageID, int progress)? onMediaDownloadProgress
```

**参数**：
- `messageID`: 消息 ID
- `progress`: 下载进度 (0-100)

**示例**：
```dart
onMediaDownloadProgress: (String messageID, int progress) {
  print('消息 $messageID 下载进度: $progress%');
}
```

---

## ZIMKitConversationEvents

会话相关事件。

### 构造函数

```dart
ZIMKitConversationEvents({
  void Function(List<ZIMKitConversationEvent> events)? onUpdated,
  void Function(List<ZIMKitConversationEvent> events)? onDeleted,
  void Function(String conversationID, int count)? onUnreadMessageCountChanged,
  void Function(int totalCount)? onTotalUnreadMessageCountChanged,
})
```

### 事件回调

#### onUpdated

会话列表更新。

```dart
void Function(List<ZIMKitConversationEvent> events)? onUpdated
```

**参数**：
- `events`: 会话事件列表

**示例**：
```dart
onUpdated: (List<ZIMKitConversationEvent> events) {
  print('${events.length} 个会话有更新');
}
```

#### onDeleted

会话被删除。

```dart
void Function(List<ZIMKitConversationEvent> events)? onDeleted
```

**参数**：
- `events`: 被删除的会话事件列表

**示例**：
```dart
onDeleted: (List<ZIMKitConversationEvent> events) {
  print('${events.length} 个会话被删除');
}
```

#### onUnreadMessageCountChanged

单个会话未读消息数变化。

```dart
void Function(String conversationID, int count)? onUnreadMessageCountChanged
```

**参数**：
- `conversationID`: 会话 ID
- `count`: 未读消息数

**示例**：
```dart
onUnreadMessageCountChanged: (String conversationID, int count) {
  print('会话 $conversationID 的未读消息数: $count');
}
```

#### onTotalUnreadMessageCountChanged

总未读消息数变化。

```dart
void Function(int totalCount)? onTotalUnreadMessageCountChanged
```

**参数**：
- `totalCount`: 总未读消息数

**示例**：
```dart
onTotalUnreadMessageCountChanged: (int totalCount) {
  print('总未读消息数: $totalCount');
}
```

---

## ZIMKitUserEvents

用户相关事件。

### 构造函数

```dart
ZIMKitUserEvents({
  void Function(List<ZIMKitUserEvent> events)? onInfoUpdated,
  void Function(List<ZIMKitUserEvent> events)? onAvatarUpdated,
})
```

### 事件回调

#### onInfoUpdated

用户信息更新。

```dart
void Function(List<ZIMKitUserEvent> events)? onInfoUpdated
```

**示例**：
```dart
onInfoUpdated: (List<ZIMKitUserEvent> events) {
  for (var event in events) {
    print('用户 ${event.user.id} 信息已更新');
  }
}
```

#### onAvatarUpdated

用户头像更新。

```dart
void Function(List<ZIMKitUserEvent> events)? onAvatarUpdated
```

**示例**：
```dart
onAvatarUpdated: (List<ZIMKitUserEvent> events) {
  print('${events.length} 个用户头像已更新');
}
```

---

## ZIMKitGroupEvents

群组相关事件。

### 构造函数

```dart
ZIMKitGroupEvents({
  void Function(ZIMKitGroupEvent event)? onInfoUpdated,
  void Function(ZIMKitGroupEvent event)? onMemberJoined,
  void Function(ZIMKitGroupEvent event)? onMemberLeft,
  void Function(ZIMKitGroupEvent event)? onMemberKicked,
  void Function(ZIMKitGroupEvent event)? onOwnerTransferred,
})
```

### 事件回调

#### onInfoUpdated

群组信息更新。

```dart
void Function(ZIMKitGroupEvent event)? onInfoUpdated
```

**示例**：
```dart
onInfoUpdated: (ZIMKitGroupEvent event) {
  print('群组 ${event.groupID} 信息已更新');
}
```

#### onMemberJoined

成员加入群组。

```dart
void Function(ZIMKitGroupEvent event)? onMemberJoined
```

**示例**：
```dart
onMemberJoined: (ZIMKitGroupEvent event) {
  print('用户 ${event.userIDs.join(", ")} 加入群组');
}
```

#### onMemberLeft

成员离开群组。

```dart
void Function(ZIMKitGroupEvent event)? onMemberLeft
```

**示例**：
```dart
onMemberLeft: (ZIMKitGroupEvent event) {
  print('用户 ${event.userIDs.join(", ")} 离开群组');
}
```

---

## ZIMKitCallEvents

通话相关事件（与 ZegoUIKitPrebuiltCallInvitationService 集成）。

### 构造函数

```dart
ZIMKitCallEvents({
  void Function(String callID, String caller)? onCallInvitationReceived,
  void Function(String callID)? onCallInvitationAccepted,
  void Function(String callID)? onCallInvitationRejected,
  void Function(String callID)? onCallInvitationCancelled,
  void Function(String callID)? onCallInvitationTimeout,
})
```

### 事件回调

#### onCallInvitationReceived

收到通话邀请。

```dart
void Function(String callID, String caller)? onCallInvitationReceived
```

**示例**：
```dart
onCallInvitationReceived: (String callID, String caller) {
  print('收到来自 $caller 的通话邀请');
}
```

---

## ZIMKitConnectionEvents

连接相关事件。

### 构造函数

```dart
ZIMKitConnectionEvents({
  void Function(ZIMConnectionState state)? onStateChanged,
  void Function(ZIMConnectionEvent event)? onEventReceived,
})
```

### 事件回调

#### onStateChanged

连接状态变化。

```dart
void Function(ZIMConnectionState state)? onStateChanged
```

**参数**：
- `state`: 连接状态

**示例**：
```dart
onStateChanged: (ZIMConnectionState state) {
  switch (state) {
    case ZIMConnectionState.disconnected:
      print('连接已断开');
      break;
    case ZIMConnectionState.connecting:
      print('连接中...');
      break;
    case ZIMConnectionState.connected:
      print('已连接');
      break;
    case ZIMConnectionState.reconnecting:
      print('重新连接中...');
      break;
  }
}
```

#### onEventReceived

连接事件接收。

```dart
void Function(ZIMConnectionEvent event)? onEventReceived
```

**参数**：
- `event`: 连接事件

**示例**：
```dart
onEventReceived: (ZIMConnectionEvent event) {
  switch (event) {
    case ZIMConnectionEvent.kickedOut:
      print('账号在其他设备登录');
      break;
    case ZIMConnectionEvent.tokenExpired:
      print('Token 已过期');
      break;
  }
}
```

---

## 事件数据类型

### ZIMKitMessageEvent

消息事件数据。

```dart
class ZIMKitMessageEvent {
  String conversationID;
  ZIMConversationType conversationType;
  ZIMKitMessage message;
  ZIMKitEventReason reason;
}
```

### ZIMKitConversationEvent

会话事件数据。

```dart
class ZIMKitConversationEvent {
  ZIMKitConversation conversation;
  ZIMKitEventReason reason;
}
```

### ZIMKitUserEvent

用户事件数据。

```dart
class ZIMKitUserEvent {
  ZIMKitUser user;
  ZIMKitEventReason reason;
}
```

### ZIMKitGroupEvent

群组事件数据。

```dart
class ZIMKitGroupEvent {
  String groupID;
  String groupName;
  List<String> userIDs;
  String operatorUserID;
  ZIMKitEventReason reason;
}
```

### ZIMKitEventReason

事件原因枚举。

```dart
enum ZIMKitEventReason {
  received,        // 接收到新数据
  sent,            // 发送成功
  updated,         // 更新
  deleted,         // 删除
  revoked,         // 撤回
  reactionAdded,   // 添加表情反应
  reactionRemoved, // 移除表情反应
}
```

### ZIMConnectionState

连接状态枚举。

```dart
enum ZIMConnectionState {
  disconnected,  // 断开连接
  connecting,    // 连接中
  connected,     // 已连接
  reconnecting,  // 重新连接中
}
```

### ZIMConnectionEvent

连接事件枚举。

```dart
enum ZIMConnectionEvent {
  kickedOut,      // 被踢下线
  tokenExpired,   // Token 过期
  roomDisconnected, // 房间断开连接
}
```

---

## 完整示例

```dart
import 'package:zego_zimkit/zego_zimkit.dart';

void main() async {
  final events = ZIMKitEvents(
    // 消息事件
    message: ZIMKitMessageEvents(
      onReceived: (List<ZIMKitMessageEvent> events) {
        for (var event in events) {
          print('收到新消息: ${event.message.info.message.message}');
        }
      },
      onSent: (ZIMKitMessage message) {
        print('消息发送成功');
      },
      onRevoked: (List<ZIMKitMessageEvent> events) {
        print('消息被撤回');
      },
      onMediaUploadProgress: (String messageID, int progress) {
        print('上传进度: $progress%');
      },
    ),

    // 会话事件
    conversation: ZIMKitConversationEvents(
      onUpdated: (List<ZIMKitConversationEvent> events) {
        print('会话列表更新');
      },
      onTotalUnreadMessageCountChanged: (int totalCount) {
        print('总未读消息数: $totalCount');
      },
    ),

    // 用户事件
    user: ZIMKitUserEvents(
      onInfoUpdated: (List<ZIMKitUserEvent> events) {
        print('用户信息更新');
      },
    ),

    // 群组事件
    group: ZIMKitGroupEvents(
      onMemberJoined: (ZIMKitGroupEvent event) {
        print('新成员加入群组');
      },
      onMemberLeft: (ZIMKitGroupEvent event) {
        print('成员离开群组');
      },
    ),

    // 连接事件
    connection: ZIMKitConnectionEvents(
      onStateChanged: (ZIMConnectionState state) {
        print('连接状态: $state');
      },
      onEventReceived: (ZIMConnectionEvent event) {
        if (event == ZIMConnectionEvent.kickedOut) {
          print('账号在其他设备登录');
        }
      },
    ),
  );

  await ZIMKit().init(
    appID: yourAppID,
    appSign: yourAppSign,
    events: events,
  );
}
```

---

**相关文档**：
- [API 文档](apis.md)
- [配置文档](configs.md)
- [快速开始](get-started.md)

