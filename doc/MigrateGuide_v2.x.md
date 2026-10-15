基准：ZIMKit Flutter v2.0.0（2026-10-15 与源码核对）

# ZIMKit 1.x 升级到 2.x 指引

本文以本地提供的 ZIMKit 1.20.1 源码和当前 2.0.0 源码为准，说明公开接口、参数和组件配置方式的变化。早于 1.20.1 的版本可能已有不同接口，请结合实际使用版本核对。

## 2.0.0

### 主要变化

- 初始化时，通知配置从 `init` 的独立参数移入 `ZIMKitConfig`；新增全局事件入口 `events`。
- 会话列表、消息列表、消息页和输入框的参数分别整理到 `config/configs`、`style/styles`、`events` 对象中。
- `ZIMKit` 的核心服务接口大多保留原用法；新增 Token、回复消息、合并转发、会话置顶和免打扰等接口。
- `ZIMKitMessageInput.recordStatus` 在 1.20.1 中已经是必填项，升级到 2.0 不需要为此新增参数。

### 初始化

1.x 将通知设置直接传给 `init`：

~~~dart
await ZIMKit().init(
  appID: yourAppID,
  appSign: yourAppSign,
  appSecret: yourAppSecret,
  notificationConfig: ZegoZIMKitNotificationConfig(
    androidNotificationConfig: ZegoZIMKitAndroidNotificationConfig(
      channelName: 'Message',
    ),
  ),
);
~~~

2.0 将通知设置放入 `ZIMKitConfig.notificationConfig`。其他全局选项也通过 `ZIMKitConfig` 配置；全局事件通过 `ZIMKitEvents` 传入：

~~~dart
await ZIMKit().init(
  appID: yourAppID,
  appSign: yourAppSign,
  appSecret: yourAppSecret,
  config: ZIMKitConfig(
    notificationConfig: ZegoZIMKitNotificationConfig(
      androidNotificationConfig: ZegoZIMKitAndroidNotificationConfig(
        channelName: 'Message',
      ),
    ),
  ),
  events: ZIMKitEvents(
    message: ZIMKitMessageEvents(
      onMessageReceived: (event) {},
    ),
  ),
);
~~~

通知配置类型本身没有改名，变化的是传入位置。配置项详见 [configs.md](configs.md)，事件类型详见 [events.md](events.md)。

### 组件参数分组

2.0 按用途分组参数：

- `config` 或 `configs`：行为配置、控制器和输入参数。
- `style` 或 `styles`：主题、UI builder 和自定义按钮。
- `events`：点击、发送消息等回调。

组件属性名有单复数区别：`ZIMKitConversationListView` 使用 `configs` 和 `styles`；消息列表、消息页、消息输入框使用 `config` 和 `style`。以下示例以 2.0.0 当前源码为准。

#### `ZIMKitConversationListView`

~~~dart
ZIMKitConversationListView(
  configs: ZIMKitConversationListConfigs(
    filter: (context, conversations) => conversations,
    scrollController: myScrollController,
  ),
  events: ZIMKitConversationListEvents(
    onPressed: (context, conversation, defaultAction) {
      defaultAction();
    },
  ),
  styles: ZIMKitConversationListStyles(
    theme: ThemeData(),
    emptyBuilder: (context, defaultWidget) => defaultWidget,
  ),
)
~~~

| 1.x 参数 | 2.0 参数 |
| --- | --- |
| `filter`、`sorter`、`scrollController` | `configs.filter`、`configs.sorter`、`configs.scrollController` |
| `onPressed`、`onLongPress` | `events.onPressed`、`events.onLongPress` |
| `itemBuilder`、`lastMessageBuilder`、`lastMessageTimeBuilder` | `styles.itemBuilder`、`styles.lastMessageBuilder`、`styles.lastMessageTimeBuilder` |
| `loadingBuilder`、`emptyBuilder`、`errorBuilder`、`theme` | `styles.loadingBuilder`、`styles.emptyBuilder`、`styles.errorBuilder`、`styles.theme` |

#### `ZIMKitMessageListView`

1.x 要求直接传入 `scrollController`。2.0 将它放入必填的 `config` 对象；即使使用默认控制器，也要传入空配置对象。

~~~dart
ZIMKitMessageListView(
  conversationID: 'conversation-id',
  config: const ZIMKitMessageListConfigs(),
  events: ZIMKitMessageListEvents(
    onPressed: (context, message, defaultAction) {
      defaultAction();
    },
  ),
  style: ZIMKitMessageListStyles(
    theme: ThemeData(),
  ),
)
~~~

| 1.x 参数 | 2.0 参数 |
| --- | --- |
| `scrollController` | `config.scrollController` |
| `onPressed`、`onLongPress` | `events.onPressed`、`events.onLongPress` |
| `itemBuilder`、`messageContentBuilder`、`avatarBuilder`、`statusBuilder`、`backgroundBuilder` | 对应移入 `style`，如 `style.itemBuilder`、`style.messageContentBuilder` |
| `loadingBuilder`、`errorBuilder`、`theme` | `style.loadingBuilder`、`style.errorBuilder`、`style.theme` |

#### `ZIMKitMessageListPage`

消息页的参数按“输入/列表配置、视觉样式、事件回调”拆分。下表列出 1.20.1 中的直接参数及 2.0 的位置：

| 1.x 参数 | 2.0 参数 |
| --- | --- |
| `messageInputActions`、`showPickFileButton`、`showPickMediaButton`、`showMoreButton`、`showRecordButton` | `config.messageInput.actions`、`config.messageInput.showPickFileButton` 等 |
| — | 新增 `config.messageInput.showEmojiButton`，可控制表情按钮 |
| `messageInputHeight` | `config.messageInput.height` |
| `editingController` | `config.messageInput.editingController` |
| `messageListScrollController` | `config.messageListScrollController` |
| `inputFocusNode` | `config.inputFocusNode` |
| `messageInputKeyboardType`、`messageInputMaxLines`、`messageInputMinLines` | `config.messageInput.keyboardType`、`config.messageInput.maxLines`、`config.messageInput.minLines` |
| `messageInputTextInputAction`、`messageInputTextCapitalization` | `config.messageInput.textInputAction`、`config.messageInput.textCapitalization` |
| `appBarBuilder`、`appBarActions`、`theme` | `style.appBarBuilder`、`style.appBarActions`、`style.theme` |
| `inputDecoration`、`inputBackgroundDecoration` | `style.messageInput.inputDecoration`、`style.messageInput.inputBackgroundDecoration` |
| `messageInputContainerPadding`、`messageInputContainerDecoration` | `style.messageInput.containerPadding`、`style.messageInput.containerDecoration` |
| `sendButtonWidget`、`pickMediaButtonWidget`、`pickFileButtonWidget` | `style.messageInput.sendButtonWidget`、`style.messageInput.pickMediaButtonWidget`、`style.messageInput.pickFileButtonWidget` |
| `messageItemBuilder`、`messageContentBuilder`、`messageListErrorBuilder`、`messageListLoadingBuilder`、`messageListBackgroundBuilder` | `style.messageList.itemBuilder`、`style.messageList.messageContentBuilder`、`style.messageList.errorBuilder`、`style.messageList.loadingBuilder`、`style.messageList.backgroundBuilder` |
| `onMessageSent`、`preMessageSending`、`onMediaFilesPicked` | `events.messageInput.onMessageSent`、`events.messageInput.preMessageSending`、`events.messageInput.onMediaFilesPicked` |
| `onMessageItemPressed`、`onMessageItemLongPress` | `events.messageList.onPressed`、`events.messageList.onLongPress` |
| `events.onTextFieldTap` | `events.messageInput.onTextFieldTap` |
| `events.audioRecord` | `events.audioRecord`（位置不变） |

2.0 的参数结构示例：

~~~dart
ZIMKitMessageListPage(
  conversationID: 'conversation-id',
  config: ZIMKitMessageListPageConfigs(
    messageInput: ZIMKitMessageInputConfigs(
      actions: [],
      showRecordButton: true,
    ),
    messageListScrollController: myScrollController,
    inputFocusNode: myFocusNode,
  ),
  style: ZIMKitMessageListPageStyles(
    appBarBuilder: (context, defaultAppBar) => defaultAppBar,
    messageInput: ZIMKitMessageInputStyles(
      inputDecoration: const InputDecoration(),
    ),
    messageList: ZIMKitMessageListStyles(),
  ),
  events: ZIMKitMessageListPageEvents(
    messageInput: ZIMKitMessageInputEvents(
      onMessageSent: (message) {},
      onTextFieldTap: () {},
    ),
    messageList: ZIMKitMessageListEvents(
      onPressed: (context, message, defaultAction) {},
    ),
    audioRecord: ZIMKitAudioRecordEvents(),
  ),
)
~~~

#### `ZIMKitMessageInput`

直接使用输入框时，1.x 的按钮、控制器和样式参数也分别移入 `config`、`style`、`events`。`recordStatus` 仍然必填。

| 1.x 参数 | 2.0 参数 |
| --- | --- |
| `actions`、`showPickFileButton`、`showPickMediaButton`、`showMoreButton`、`showRecordButton` | `config.actions`、`config.showPickFileButton` 等 |
| — | 新增 `inputConfig`（全局输入配置）和 `config.showEmojiButton` |
| `editingController`、`inputFocusNode`、`listScrollController` | `config.editingController`、`config.inputFocusNode`、`config.listScrollController` |
| `keyboardType`、`maxLines`、`minLines`、`textInputAction`、`textCapitalization` | 对应移入 `config` |
| `onMessageSent`、`preMessageSending`、`onMediaFilesPicked` | 对应移入 `events` |
| `inputDecoration`、`inputBackgroundDecoration`、`containerPadding`、`containerDecoration` | 对应移入 `style` |
| `sendButtonWidget`、`pickMediaButtonWidget`、`pickFileButtonWidget`、`theme` | 对应移入 `style` |
| `events.audioRecord` | `recordEvents` |
| — | `events.onReplyCancelled`、`events.onCallTap` 为新增回调 |
| `recordStatus` | 仍为必填参数；不是 2.0 新增要求 |

~~~dart
ZIMKitMessageInput(
  conversationID: 'conversation-id',
  recordStatus: recordStatus,
  config: ZIMKitMessageInputConfigs(
    actions: [],
    showRecordButton: false,
  ),
  events: ZIMKitMessageInputEvents(
    onMessageSent: (message) {},
  ),
  style: ZIMKitMessageInputStyles(
    inputDecoration: const InputDecoration(),
  ),
)
~~~

### `ZIMKit` 服务 API 变化

| API | 1.20.1 到 2.0 的变化 |
| --- | --- |
| `connectUser` | 新增可选命名参数 `token`，用于传入登录 Token。原有 `id`、`name`、`avatarUrl` 参数不变。 |
| `renewToken(String token)` | 新增方法，用于续期当前用户的 Token。 |
| `sendTextMessage` | 新增可选命名参数 `repliedMessage`，可把文本消息作为回复发送。 |
| `replyMessage` | 新增方法，参数包含会话 ID、会话类型、被回复消息和回复文本。 |
| `sendCombineMessage`、`queryCombineMessageDetail` | 新增合并消息发送和读取接口。 |
| `updateConversationPinnedState` | 新增会话置顶状态设置接口。 |
| `setConversationNotificationStatus` | 新增会话通知状态设置接口。 |
| `queryGroupMemberList` | 新增可选命名参数 `onError`，用于接收成员列表查询错误。 |
| `setForwardMessages`、`getForwardMessages`、`getForwardType`、`clearForwardMessages` | 新增转发消息暂存与读取接口。 |
| `ZIMKitConversation.isPinned` | 新增会话置顶状态字段；`notificationStatus` 在 1.20.1 中已存在。 |
| `ZIMKitMessage` | 新增 `combineContent`、`revokeContent`、`tipsContent` 和 `replyInfo` 消息数据字段。 |
| `ZIMKitMessageListEvents` | 新增 `onMultiSelectChanged`、`onReplyMessageTap`、`onReplyMessage` 回调。 |

示例：

~~~dart
await ZIMKit().connectUser(
  id: userID,
  name: userName,
  token: token,
);

await ZIMKit().renewToken(refreshedToken);

await ZIMKit().sendTextMessage(
  conversationID,
  ZIMConversationType.peer,
  '回复内容',
  repliedMessage: originalMessage,
);
~~~

### 公共组件导出

1.x 的公共入口还导出了若干独立低层组件；2.0 不再从 `zego_zimkit.dart` 导出 `ZIMKitConversationWidget`、`ZIMKitPickFileButton`、`ZIMKitPickMediaButton` 和 `ZIMKitMoreButton`。

- 会话项外观可通过 `ZIMKitConversationListView.styles.itemBuilder` 自定义。
- 输入区按钮可通过 `ZIMKitMessageInput` 的配置、样式和 `ZIMKitMessageInputAction` 扩展。
- 如果业务直接依赖上述独立组件，需要改用公开的高层组件或在应用内实现对应 UI。

推荐继续通过公开入口导入：

~~~dart
import 'package:zego_zimkit/zego_zimkit.dart';
~~~

### 升级后检查

在应用项目根目录运行静态分析，并按错误提示逐项调整旧参数的位置：

~~~shell
flutter analyze
~~~

如应用直接创建 `ZIMKitPlatformFile`，请检查实际解析到的 `file_picker` 版本和对应 API。本文核对的 1.20.1 与 2.0.0 源码都将 `ZIMKitPlatformFile` 定义为 `PlatformFile` 类型别名；2.0.0 内部另有用于本地路径文件的实现，但它不是包的公共入口 API。
