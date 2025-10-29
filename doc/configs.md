# ZIMKit 配置文档

本文档介绍 ZIMKit 的所有配置选项。

## 目录

- [ZIMKitConfig](#zimkitconfig) - 主配置类
- [ZIMKitInputConfig](#zimkitinputconfig) - 输入框配置
- [ZIMKitMessageConfig](#zimkitmessageconfig) - 消息配置
- [ZIMKitConversationConfig](#zimkitconversationconfig) - 会话配置
- [ZIMKitStyle](#zimkitstyle) - 样式配置
- [ZIMKitInnerText](#zimkitinnertext) - 国际化文本

---

## ZIMKitConfig

主配置类，包含所有子配置项。

### 构造函数

```dart
ZIMKitConfig({
  ZIMKitInputConfig? inputConfig,
  ZIMKitMessageConfig? messageConfig,
  ZIMKitConversationConfig? conversationConfig,
  Map<String, dynamic>? advancedConfig,
})
```

### 属性

| 属性 | 类型 | 描述 | 默认值 |
|-----|------|------|--------|
| inputConfig | ZIMKitInputConfig | 输入框配置 | ZIMKitInputConfig() |
| messageConfig | ZIMKitMessageConfig | 消息配置 | ZIMKitMessageConfig() |
| conversationConfig | ZIMKitConversationConfig | 会话配置 | ZIMKitConversationConfig() |
| advancedConfig | Map<String, dynamic>? | 高级配置 | null |

### 工厂方法

#### defaultConfig

返回默认配置。

```dart
factory ZIMKitConfig.defaultConfig()
```

### 示例

```dart
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
    textMessageConfig: ZIMKitTextMessageConfig(
      operations: [
        ZIMKitMessageOperationName.copy,
        ZIMKitMessageOperationName.reply,
        ZIMKitMessageOperationName.forward,
      ],
    ),
  ),
);
```

---

## ZIMKitInputConfig

输入框配置，用于自定义输入框的按钮和表情。

### 构造函数

```dart
ZIMKitInputConfig({
  List<ZIMKitInputButtonName>? smallButtons,
  List<ZIMKitInputButtonName>? expandButtons,
  List<String>? emojis,
  int maxSmallButtonCount = 4,
  String? placeholder,
  Map<ZIMKitInputButtonName, Widget Function(BuildContext)>? customButtonBuilders,
})
```

### 属性

| 属性 | 类型 | 描述 | 默认值 |
|-----|------|------|--------|
| smallButtons | List<ZIMKitInputButtonName> | 底部显示的按钮 | [audio, emoji, picture, expand] |
| expandButtons | List<ZIMKitInputButtonName> | 扩展面板中的按钮 | [takePhoto, file] |
| emojis | List<String> | 表情列表 | 默认表情列表 |
| maxSmallButtonCount | int | 底部最大按钮数量 | 4 |
| placeholder | String? | 输入框占位符 | null |
| customButtonBuilders | Map | 自定义按钮构建器 | null |

### 枚举：ZIMKitInputButtonName

```dart
enum ZIMKitInputButtonName {
  audio,      // 语音按钮
  emoji,      // 表情按钮
  picture,    // 图片按钮
  takePhoto,  // 拍照按钮
  voiceCall,  // 语音通话按钮
  videoCall,  // 视频通话按钮
  file,       // 文件按钮
  expand,     // 更多按钮
}
```

### 示例

```dart
ZIMKitInputConfig(
  smallButtons: [
    ZIMKitInputButtonName.audio,
    ZIMKitInputButtonName.emoji,
    ZIMKitInputButtonName.picture,
    ZIMKitInputButtonName.expand,
  ],
  expandButtons: [
    ZIMKitInputButtonName.takePhoto,
    ZIMKitInputButtonName.voiceCall,
    ZIMKitInputButtonName.videoCall,
    ZIMKitInputButtonName.file,
  ],
  emojis: ['😀', '😃', '😄', '😁', '😆'],
  placeholder: 'Type a message...',
)
```

---

## ZIMKitMessageConfig

消息配置，用于自定义各类型消息的操作项。

### 构造函数

```dart
ZIMKitMessageConfig({
  ZIMKitTextMessageConfig? textMessageConfig,
  ZIMKitImageMessageConfig? imageMessageConfig,
  ZIMKitAudioMessageConfig? audioMessageConfig,
  ZIMKitVideoMessageConfig? videoMessageConfig,
  ZIMKitFileMessageConfig? fileMessageConfig,
  ZIMKitCombineMessageConfig? combineMessageConfig,
  List<String>? messageReactions,
})
```

### 属性

| 属性 | 类型 | 描述 | 默认值 |
|-----|------|------|--------|
| textMessageConfig | ZIMKitTextMessageConfig | 文本消息配置 | ZIMKitTextMessageConfig() |
| imageMessageConfig | ZIMKitImageMessageConfig | 图片消息配置 | ZIMKitImageMessageConfig() |
| audioMessageConfig | ZIMKitAudioMessageConfig | 音频消息配置 | ZIMKitAudioMessageConfig() |
| videoMessageConfig | ZIMKitVideoMessageConfig | 视频消息配置 | ZIMKitVideoMessageConfig() |
| fileMessageConfig | ZIMKitFileMessageConfig | 文件消息配置 | ZIMKitFileMessageConfig() |
| combineMessageConfig | ZIMKitCombineMessageConfig | 合并消息配置 | ZIMKitCombineMessageConfig() |
| messageReactions | List<String> | 消息反应表情列表 | ['👍', '❤️', '😂', '😮', '😢', '🙏'] |

### 枚举：ZIMKitMessageOperationName

```dart
enum ZIMKitMessageOperationName {
  copy,            // 复制消息（文本消息）
  reply,           // 回复消息
  forward,         // 转发消息
  revoke,          // 撤回消息
  delete,          // 删除消息
  multipleChoice,  // 多选模式
  reaction,        // 表情反应
  speaker,         // 扬声器模式（音频消息）
}
```

### 子配置类

#### ZIMKitTextMessageConfig

文本消息配置。

```dart
ZIMKitTextMessageConfig({
  List<ZIMKitMessageOperationName>? operations,
})
```

默认操作：`[copy, reply, forward, multipleChoice, delete, revoke, reaction]`

#### ZIMKitImageMessageConfig

图片消息配置。

```dart
ZIMKitImageMessageConfig({
  List<ZIMKitMessageOperationName>? operations,
})
```

默认操作：`[reply, forward, multipleChoice, delete, revoke, reaction]`

#### ZIMKitAudioMessageConfig

音频消息配置。

```dart
ZIMKitAudioMessageConfig({
  List<ZIMKitMessageOperationName>? operations,
})
```

默认操作：`[speaker, reply, forward, multipleChoice, delete, revoke, reaction]`

#### ZIMKitVideoMessageConfig

视频消息配置。

```dart
ZIMKitVideoMessageConfig({
  List<ZIMKitMessageOperationName>? operations,
})
```

默认操作：`[reply, forward, multipleChoice, delete, revoke, reaction]`

#### ZIMKitFileMessageConfig

文件消息配置。

```dart
ZIMKitFileMessageConfig({
  List<ZIMKitMessageOperationName>? operations,
})
```

默认操作：`[reply, forward, multipleChoice, delete, revoke, reaction]`

#### ZIMKitCombineMessageConfig

合并消息配置。

```dart
ZIMKitCombineMessageConfig({
  List<ZIMKitMessageOperationName>? operations,
})
```

默认操作：`[forward, multipleChoice, delete, reaction]`

### 示例

```dart
ZIMKitMessageConfig(
  textMessageConfig: ZIMKitTextMessageConfig(
    operations: [
      ZIMKitMessageOperationName.copy,
      ZIMKitMessageOperationName.reply,
      ZIMKitMessageOperationName.forward,
      ZIMKitMessageOperationName.delete,
    ],
  ),
  messageReactions: ['👍', '❤️', '😂', '🎉', '👏'],
)
```

---

## ZIMKitConversationConfig

会话配置。

### 构造函数

```dart
ZIMKitConversationConfig({
  bool showPinned = true,
  bool showNotificationStatus = true,
})
```

### 属性

| 属性 | 类型 | 描述 | 默认值 |
|-----|------|------|--------|
| showPinned | bool | 是否显示置顶标识 | true |
| showNotificationStatus | bool | 是否显示免打扰标识 | true |

### 示例

```dart
ZIMKitConversationConfig(
  showPinned: true,
  showNotificationStatus: true,
)
```

---

## ZIMKitStyle

样式配置，用于自定义视觉样式。

### 构造函数

```dart
ZIMKitStyle({
  Color? primaryColor,
  Color? backgroundColor,
  Color? textColor,
  Color? secondaryTextColor,
  Color? dividerColor,
  Color? messageBubbleColor,
  Color? receivedMessageBubbleColor,
  Color? sentMessageBubbleColor,
})
```

### 属性

| 属性 | 类型 | 描述 | 默认值 |
|-----|------|------|--------|
| primaryColor | Color? | 主题色 | null |
| backgroundColor | Color? | 背景色 | null |
| textColor | Color? | 主文本颜色 | null |
| secondaryTextColor | Color? | 次要文本颜色 | null |
| dividerColor | Color? | 分隔线颜色 | null |
| messageBubbleColor | Color? | 消息气泡颜色（通用） | null |
| receivedMessageBubbleColor | Color? | 接收消息气泡颜色 | null |
| sentMessageBubbleColor | Color? | 发送消息气泡颜色 | null |

### 示例

```dart
ZIMKitStyle(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  textColor: Colors.black,
  sentMessageBubbleColor: Colors.blue[100],
  receivedMessageBubbleColor: Colors.grey[200],
)
```

---

## ZIMKitInnerText

国际化文本配置，用于自定义所有界面文本。

### 构造函数

```dart
ZIMKitInnerText({
  // 消息输入相关
  String? messageInputPlaceholder,
  String? messageEmptyText,
  // 消息操作相关
  String? copyMenuText,
  String? replyMenuText,
  String? forwardMenuText,
  String? revokeMenuText,
  String? deleteMenuText,
  String? multipleChoiceMenuText,
  String? reactionMenuText,
  String? speakerMenuText,
  String? cancelMenuText,
  // Toast 提示
  String? copySuccessToast,
  String? revokeSuccessToast,
  String? deleteSuccessToast,
  String? forwardSuccessToast,
  String? networkErrorToast,
  // 确认对话框
  String? deleteMessageTitle,
  String? deleteMessageContent,
  String? revokeMessageTitle,
  String? revokeMessageContent,
  String? confirmButtonText,
  String? cancelButtonText,
  // 更多...
})
```

### 常用属性

| 属性 | 默认值（英文） | 说明 |
|-----|---------------|------|
| messageInputPlaceholder | "Message" | 输入框占位符 |
| copyMenuText | "Copy" | 复制菜单文本 |
| replyMenuText | "Reply" | 回复菜单文本 |
| forwardMenuText | "Forward" | 转发菜单文本 |
| revokeMenuText | "Revoke" | 撤回菜单文本 |
| deleteMenuText | "Delete" | 删除菜单文本 |
| copySuccessToast | "Copied to clipboard" | 复制成功提示 |
| imageMessageText | "[Image]" | 图片消息显示文本 |
| videoMessageText | "[Video]" | 视频消息显示文本 |
| audioMessageText | "[Audio]" | 音频消息显示文本 |

### 示例（中文）

```dart
ZIMKitInnerText(
  messageInputPlaceholder: '消息',
  messageEmptyText: '说点什么...',
  copyMenuText: '复制',
  replyMenuText: '回复',
  forwardMenuText: '转发',
  revokeMenuText: '撤回',
  deleteMenuText: '删除',
  copySuccessToast: '已复制到剪贴板',
  revokeSuccessToast: '消息已撤回',
  deleteSuccessToast: '消息已删除',
  forwardSuccessToast: '消息已转发',
  imageMessageText: '[图片]',
  videoMessageText: '[视频]',
  audioMessageText: '[语音]',
  fileMessageText: '[文件]',
  combineMessageText: '[聊天记录]',
)
```

---

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 创建完整配置
  final config = ZIMKitConfig(
    // 输入框配置
    inputConfig: ZIMKitInputConfig(
      smallButtons: [
        ZIMKitInputButtonName.audio,
        ZIMKitInputButtonName.emoji,
        ZIMKitInputButtonName.picture,
        ZIMKitInputButtonName.expand,
      ],
      expandButtons: [
        ZIMKitInputButtonName.takePhoto,
        ZIMKitInputButtonName.file,
      ],
      placeholder: 'Type a message...',
    ),
    
    // 消息配置
    messageConfig: ZIMKitMessageConfig(
      textMessageConfig: ZIMKitTextMessageConfig(
        operations: [
          ZIMKitMessageOperationName.copy,
          ZIMKitMessageOperationName.reply,
          ZIMKitMessageOperationName.forward,
          ZIMKitMessageOperationName.delete,
          ZIMKitMessageOperationName.revoke,
        ],
      ),
      messageReactions: ['👍', '❤️', '😂', '😮', '😢', '🙏'],
    ),
    
    // 会话配置
    conversationConfig: ZIMKitConversationConfig(
      showPinned: true,
      showNotificationStatus: true,
    ),
  );

  // 样式配置
  final style = ZIMKitStyle(
    primaryColor: Colors.blue,
    sentMessageBubbleColor: Colors.blue[100],
    receivedMessageBubbleColor: Colors.grey[200],
  );

  // 国际化文本（中文）
  final innerText = ZIMKitInnerText(
    messageInputPlaceholder: '消息',
    copyMenuText: '复制',
    replyMenuText: '回复',
    forwardMenuText: '转发',
    deleteMenuText: '删除',
  );

  // 初始化 ZIMKit
  await ZIMKit().init(
    appID: yourAppID,
    appSign: yourAppSign,
    config: config,
  );

  runApp(MyApp(
    style: style,
    innerText: innerText,
  ));
}
```

---

**相关文档**：
- [API 文档](apis.md)
- [事件文档](events.md)
- [快速开始](get-started.md)

