# ZIMKit 快速开始

基准：ZIMKit Flutter v2.0.0（2026-10-14 与源码核对）

本文档将引导您快速集成并使用 ZIMKit。

## 目录

1. [前提条件](#前提条件)
2. [添加依赖](#添加依赖)
3. [初始化 ZIMKit](#初始化-zimkit)
4. [用户登录](#用户登录)
5. [显示会话列表](#显示会话列表)
6. [显示消息页面](#显示消息页面)
7. [配置自定义](#配置自定义)
8. [高级功能](#高级功能)

---

## 前提条件

在开始之前，请确保：

1. **已创建 ZEGO 项目**
   - 前往 [ZEGO 控制台](https://console.zego.im/) 创建项目
   - 获取 `AppID` 和 `AppSign`

2. **环境要求**
   - Flutter 2.0 或更高版本
   - Dart 2.12 或更高版本
   - iOS 11.0 或更高版本
   - Android minSdkVersion 21 或更高版本

---

## 添加依赖

在 `pubspec.yaml` 中添加 ZIMKit 依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  zego_zimkit: ^latest_version  # 请替换为最新版本号
```

运行命令安装依赖：

```bash
flutter pub get
```

---

## 初始化 ZIMKit

在应用启动时初始化 ZIMKit。

### 基本初始化

```dart
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 ZIMKit
  await ZIMKit().init(
    appID: yourAppID,        // 替换为您的 AppID
    appSign: yourAppSign,    // 替换为您的 AppSign
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZIMKit Demo',
      home: HomePage(),
    );
  }
}
```

### 带配置的初始化

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 创建配置
  final config = ZIMKitConfig(
    inputConfig: ZIMKitInputConfig(
      smallButtons: [
        ZIMKitInputButtonName.audio,
        ZIMKitInputButtonName.emoji,
        ZIMKitInputButtonName.picture,
        ZIMKitInputButtonName.expand,
      ],
    ),
    messageConfig: ZIMKitMessageConfig(
      messageReactions: ['👍', '❤️', '😂', '😮', '😢', '🙏'],
    ),
  );

  // 创建事件监听
  final events = ZIMKitEvents(
    message: ZIMKitMessageEvents(
      onReceived: (List<ZIMKitMessageEvent> events) {
        print('收到 ${events.length} 条新消息');
      },
    ),
    connection: ZIMKitConnectionEvents(
      onStateChanged: (ZIMConnectionState state) {
        print('连接状态: $state');
      },
    ),
  );

  // 初始化 ZIMKit
  await ZIMKit().init(
    appID: yourAppID,
    appSign: yourAppSign,
    config: config,
    events: events,
  );

  runApp(MyApp());
}
```

---

## 用户登录

在使用 ZIMKit 功能前，需要先登录用户。

### 连接用户

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    connectUser();
  }

  Future<void> connectUser() async {
    try {
      // 连接用户
      await ZIMKit().connectUser(
        id: 'user_001',           // 用户 ID
        name: 'John Doe',         // 用户名
        avatarUrl: 'https://...',  // 用户头像 URL（可选）
        // 启用 Token 鉴权时传入服务端签发的 token
        // token: tokenFromYourServer,
      );
      print('用户连接成功');
    } catch (e) {
      print('用户连接失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ZIMKit Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 导航到会话列表
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ZIMKitConversationListPage(),
              ),
            );
          },
          child: Text('打开会话列表'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 断开用户连接
    ZIMKit().disconnectUser();
    super.dispose();
  }
}
```

---

## 显示会话列表

使用 `ZIMKitConversationListPage` 显示会话列表。

### 基本用法

```dart
import 'package:zego_zimkit/zego_zimkit.dart';

class ConversationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('会话列表')),
      body: ZIMKitConversationListPage(
        onPressed: (context, conversation, defaultAction) {
          // 点击会话时，跳转到消息页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZIMKitMessageListPage(
                conversationID: conversation.id,
                conversationType: conversation.type,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 自定义会话列表

```dart
ZIMKitConversationListPage(
  // 自定义空状态
  emptyBuilder: (context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无会话', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  },
  
  // 自定义加载状态
  loadingBuilder: (context) {
    return Center(child: CircularProgressIndicator());
  },
  
  // 自定义错误状态
  errorBuilder: (context, error) {
    return Center(child: Text('加载失败: $error'));
  },
  
  // 点击事件
  onPressed: (context, conversation, defaultAction) {
    // 自定义点击逻辑
    print('点击了会话: ${conversation.id}');
    defaultAction.call(); // 调用默认行为
  },
  
  // 长按事件
  onLongPress: (context, conversation, defaultAction) {
    // 自定义长按逻辑
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('会话操作'),
        content: Text('删除会话 ${conversation.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ZIMKit().deleteConversation(conversation.id);
              Navigator.pop(context);
            },
            child: Text('删除'),
          ),
        ],
      ),
    );
  },
  
  // 自定义列表项构建器
  itemBuilder: (context, conversation, defaultWidget) {
    // 完全自定义列表项
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(conversation.avatarUrl ?? ''),
      ),
      title: Text(conversation.name ?? ''),
      subtitle: Text(conversation.lastMessage?.message ?? ''),
      trailing: conversation.unreadMessageCount > 0
          ? CircleBadge(count: conversation.unreadMessageCount)
          : null,
    );
  },
);
```

---

## 显示消息页面

使用 `ZIMKitMessageListPage` 显示消息列表。

### 基本用法

```dart
import 'package:zego_zimkit/zego_zimkit.dart';

class MessageScreen extends StatelessWidget {
  final String conversationID;
  final ZIMConversationType conversationType;

  const MessageScreen({
    Key? key,
    required this.conversationID,
    required this.conversationType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('聊天')),
      body: ZIMKitMessageListPage(
        conversationID: conversationID,
        conversationType: conversationType,
      ),
    );
  }
}
```

### 自定义消息页面

```dart
ZIMKitMessageListPage(
  conversationID: conversationID,
  conversationType: conversationType,
  
  // 自定义空状态
  emptyBuilder: (context) {
    return Center(
      child: Text('发送你的第一条消息吧！'),
    );
  },
  
  // 自定义消息项构建器
  messageItemBuilder: (context, message, defaultWidget) {
    // 自定义消息显示
    if (message.type == ZIMMessageType.text) {
      return CustomTextMessageWidget(message: message);
    }
    return defaultWidget; // 使用默认显示
  },
  
  // 自定义输入框
  inputBarBuilder: (context, defaultInputBar) {
    return Column(
      children: [
        CustomToolBar(), // 自定义工具栏
        defaultInputBar, // 默认输入框
      ],
    );
  },
  
  // 消息长按事件
  onMessageLongPress: (context, message, defaultAction) {
    // 自定义长按逻辑
    showMessageOptions(context, message);
  },
  
  // 预发送消息钩子
  onPreSendMessage: (message) {
    // 在消息发送前执行自定义逻辑
    print('准备发送消息: ${message.message}');
    return true; // 返回 false 可阻止发送
  },
);
```

---

## 配置自定义

### 样式配置

```dart
final style = ZIMKitStyle(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  textColor: Colors.black,
  sentMessageBubbleColor: Colors.blue[100],
  receivedMessageBubbleColor: Colors.grey[200],
);

// 应用样式
ZIMKitTheme(
  data: style,
  child: ZIMKitMessageListPage(
    conversationID: conversationID,
    conversationType: conversationType,
  ),
);
```

### 国际化配置

```dart
final innerText = ZIMKitInnerText(
  // 中文配置
  messageInputPlaceholder: '消息',
  copyMenuText: '复制',
  replyMenuText: '回复',
  forwardMenuText: '转发',
  revokeMenuText: '撤回',
  deleteMenuText: '删除',
  copySuccessToast: '已复制到剪贴板',
  imageMessageText: '[图片]',
  videoMessageText: '[视频]',
  audioMessageText: '[语音]',
);

// 应用国际化文本
await ZIMKit().init(
  appID: yourAppID,
  appSign: yourAppSign,
  config: ZIMKitConfig(
    innerText: innerText,
  ),
);
```

---

## 高级功能

### 1. 发送自定义消息

```dart
// 发送文本消息
await ZIMKit().sendTextMessage(
  conversationID: 'user_002',
  conversationType: ZIMConversationType.peer,
  text: 'Hello!',
);

// 发送图片消息
await ZIMKit().sendImageMessage(
  conversationID: 'user_002',
  conversationType: ZIMConversationType.peer,
  imagePath: '/path/to/image.jpg',
);

// 发送文件消息
await ZIMKit().sendFileMessage(
  conversationID: 'user_002',
  conversationType: ZIMConversationType.peer,
  filePath: '/path/to/file.pdf',
);
```

### 2. 消息操作

```dart
// 撤回消息
await ZIMKit().revokeMessage(message);

// 删除消息
await ZIMKit().deleteMessage(messageID);

// 转发消息
await ZIMKit().forwardMessage(
  message: message,
  targetConversationID: 'user_003',
  targetConversationType: ZIMConversationType.peer,
);

// 添加消息反应
await ZIMKit().addMessageReaction(
  message: message,
  reaction: '👍',
);
```

### 3. 会话操作

```dart
// 删除会话
await ZIMKit().deleteConversation(conversationID);

// 清空会话消息
await ZIMKit().clearConversationMessages(conversationID);

// 设置会话免打扰
await ZIMKit().setConversationNotificationStatus(
  conversationID: conversationID,
  status: ZIMConversationNotificationStatus.doNotDisturb,
);

// 置顶会话
await ZIMKit().pinConversation(
  conversationID: conversationID,
  isPinned: true,
);
```

### 4. 群组管理

```dart
// 创建群组
final groupInfo = await ZIMKit().createGroup(
  groupName: 'My Group',
  userIDs: ['user_001', 'user_002', 'user_003'],
);

// 加入群组
await ZIMKit().joinGroup(groupID: 'group_001');

// 离开群组
await ZIMKit().leaveGroup(groupID: 'group_001');

// 邀请成员
await ZIMKit().inviteUsersToGroup(
  groupID: 'group_001',
  userIDs: ['user_004', 'user_005'],
);

// 移除成员
await ZIMKit().removeUsersFromGroup(
  groupID: 'group_001',
  userIDs: ['user_002'],
);
```

### 5. 消息回执

```dart
// 发送已读回执
await ZIMKit().sendMessageReadReceipt(
  conversationID: conversationID,
  conversationType: conversationType,
);

// 监听消息已读状态
ZIMKitEvents(
  message: ZIMKitMessageEvents(
    onReceiptReceived: (String conversationID, List<String> messageIDs) {
      print('消息已读: $messageIDs');
    },
  ),
);
```

### 6. 输入状态

```dart
// 发送正在输入状态
await ZIMKit().sendTypingStatus(
  conversationID: conversationID,
  conversationType: conversationType,
);

// 监听输入状态
ZIMKitEvents(
  conversation: ZIMKitConversationEvents(
    onTypingStatusChanged: (String conversationID, List<String> userIDs) {
      print('用户 $userIDs 正在输入...');
    },
  ),
);
```

### 7. 集成通话功能

```dart
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

void main() async {
  // 初始化 ZIMKit
  await ZIMKit().init(appID: yourAppID, appSign: yourAppSign);

  // 使用 ZIM 作为信令插件
  ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
    [ZegoUIKitSignalingPlugin()],
  );

  // 配置输入框按钮，添加语音/视频通话按钮
  final config = ZIMKitConfig(
    inputConfig: ZIMKitInputConfig(
      smallButtons: [
        ZIMKitInputButtonName.audio,
        ZIMKitInputButtonName.emoji,
        ZIMKitInputButtonName.voiceCall,  // 语音通话按钮
        ZIMKitInputButtonName.videoCall,  // 视频通话按钮
      ],
    ),
  );

  runApp(MyApp());
}
```

---

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化配置
  final config = ZIMKitConfig(
    inputConfig: ZIMKitInputConfig(
      smallButtons: [
        ZIMKitInputButtonName.audio,
        ZIMKitInputButtonName.emoji,
        ZIMKitInputButtonName.picture,
        ZIMKitInputButtonName.expand,
      ],
    ),
    messageConfig: ZIMKitMessageConfig(
      messageReactions: ['👍', '❤️', '😂', '😮', '😢', '🙏'],
    ),
  );

  // 初始化事件
  final events = ZIMKitEvents(
    message: ZIMKitMessageEvents(
      onReceived: (events) => print('收到新消息'),
      onSent: (message) => print('消息发送成功'),
    ),
    connection: ZIMKitConnectionEvents(
      onStateChanged: (state) => print('连接状态: $state'),
    ),
  );

  // 初始化 ZIMKit
  await ZIMKit().init(
    appID: yourAppID,
    appSign: yourAppSign,
    config: config,
    events: events,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZIMKit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _userIDController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userIDController,
              decoration: InputDecoration(labelText: '用户 ID'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: '用户名'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ZIMKit().connectUser(
                    id: _userIDController.text,
                    name: _userNameController.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationListPage(),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('登录失败: $e')),
                  );
                }
              },
              child: Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('会话列表'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              ZIMKit().disconnectUser();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: ZIMKitConversationListPage(
        onPressed: (context, conversation, defaultAction) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagePage(
                conversationID: conversation.id,
                conversationType: conversation.type,
                conversationName: conversation.name ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessagePage extends StatelessWidget {
  final String conversationID;
  final ZIMConversationType conversationType;
  final String conversationName;

  const MessagePage({
    Key? key,
    required this.conversationID,
    required this.conversationType,
    required this.conversationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(conversationName)),
      body: ZIMKitMessageListPage(
        conversationID: conversationID,
        conversationType: conversationType,
      ),
    );
  }
}
```

---

## 下一步

- [查看完整 API 文档](apis.md)
- [了解配置选项](configs.md)
- [查看事件回调](events.md)
- [访问示例项目](https://github.com/ZEGOCLOUD/zego_inapp_chat_uikit_flutter)

---

**需要帮助？**

- [ZEGO 文档中心](https://docs.zegocloud.com/)
- [技术支持](https://www.zegocloud.com/talk-to-us)
- [GitHub Issues](https://github.com/ZEGOCLOUD/zego_inapp_chat_uikit_flutter/issues)

