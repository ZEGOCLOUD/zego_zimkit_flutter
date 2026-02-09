# Migration Guide V2.x

This guide provides instructions for upgrading from ZIMKit 1.x to 2.0.

## Overview

ZIMKit 2.0 introduces a structured configuration approach, consolidating scattered parameters into dedicated Config and Style objects. This improves code readability and maintainability.

## Major Interface Changes

### Initialization

The `init` method now uses `ZIMKitConfig` for configuration and `ZIMKitEvents` for global event handling, replacing the standalone `notificationConfig`.

**1.x Version Code**
```dart
ZIMKit().init(
  appID: yourAppID,
  appSign: yourAppSign,
  notificationConfig: ZegoZIMKitNotificationConfig(
    androidNotificationConfig: ZegoZIMKitAndroidNotificationConfig(
      channelName: 'Message',
    ),
  ),
);
```

**2.0 Version Code**
```dart
ZIMKit().init(
  appID: yourAppID,
  appSign: yourAppSign,
  config: ZIMKitConfig(
    notificationConfig: ZegoZIMKitNotificationConfig(
      androidNotificationConfig: ZegoZIMKitAndroidNotificationConfig(
        channelName: 'Message',
      ),
    ),
  ),
);
```

### UI Components Refactoring

Parameters for `ZIMKitConversationListView` and `ZIMKitMessageListPage` have been grouped into `config`, `style`, and `events` objects.

#### ZIMKitConversationListView

**1.x Version Code**
```dart
ZIMKitConversationListView(
  onPressed: (context, conversation, defaultAction) { ... },
  scrollController: myController,
  theme: ThemeData(...),
)
```

**2.0 Version Code**
```dart
ZIMKitConversationListView(
  events: ZIMKitConversationListEvents(
    onPressed: (context, conversation, defaultAction) { ... },
  ),
  configs: ZIMKitConversationListConfigs(
    scrollController: myController,
  ),
  styles: ZIMKitConversationListStyles(
    theme: ThemeData(...),
  ),
)
```

#### ZIMKitMessageListPage

**1.x Version Code**
```dart
ZIMKitMessageListPage(
  conversationID: 'id',
  messageInputActions: [...],
  appBarBuilder: (context, defaultAppBar) { ... },
  onMessageSent: (message) { ... },
)
```

**2.0 Version Code**
```dart
ZIMKitMessageListPage(
  conversationID: 'id',
  config: ZIMKitMessageListPageConfigs(
    messageInput: ZIMKitMessageInputConfigs(
      actions: [...],
    ),
  ),
  style: ZIMKitMessageListPageStyles(
    appBarBuilder: (context, defaultAppBar) { ... },
  ),
  events: ZIMKitMessageListPageEvents(
    onMessageSent: (message) { ... },
  ),
)
```

## Parameter Mapping Guide

### ZIMKitMessageListPage

| 1.x Parameter | 2.0 Replacement |
| :--- | :--- |
| `messageInputActions` | `config.messageInput.actions` |
| `showPickFileButton` | `config.messageInput.showPickFileButton` |
| `showPickMediaButton` | `config.messageInput.showPickMediaButton` |
| `showMoreButton` | `config.messageInput.showMoreButton` |
| `showRecordButton` | `config.messageInput.showRecordButton` |
| `editingController` | `config.messageInput.editingController` |
| `messageListScrollController` | `config.messageListScrollController` |
| `inputFocusNode` | `config.inputFocusNode` |
| `messageInputKeyboardType` | `config.messageInput.keyboardType` |
| `messageInputMaxLines` | `config.messageInput.maxLines` |
| `messageInputMinLines` | `config.messageInput.minLines` |
| `messageInputTextInputAction` | `config.messageInput.textInputAction` |
| `messageInputTextCapitalization` | `config.messageInput.textCapitalization` |
| `appBarBuilder` | `style.appBarBuilder` |
| `inputDecoration` | `style.messageInput.inputDecoration` |
| `inputBackgroundDecoration` | `style.messageInput.inputBackgroundDecoration` |
| `messageInputContainerPadding` | `style.messageInput.containerPadding` |
| `messageInputContainerDecoration` | `style.messageInput.containerDecoration` |
| `sendButtonWidget` | `style.messageInput.sendButton` |
| `pickMediaButtonWidget` | `style.messageInput.pickMediaButton` |
| `pickFileButtonWidget` | `style.messageInput.pickFileButton` |
| `theme` | `style.theme` |
| `onMessageSent` | `events.onMessageSent` |
| `preMessageSending` | `events.preMessageSending` |
| `onMessageItemPressed` | `events.onMessageItemPressed` |
| `onMessageItemLongPress` | `events.onMessageItemLongPress` |
| `onMediaFilesPicked` | `events.onMediaFilesPicked` |

### ZIMKitConversationListView

| 1.x Parameter | 2.0 Replacement |
| :--- | :--- |
| `scrollController` | `config.scrollController` |
| `filter` | `config.filter` |
| `sorter` | `config.sorter` |
| `theme` | `style.theme` |
| `loadingBuilder` | `style.loadingBuilder` |
| `emptyBuilder` | `style.emptyBuilder` |
| `errorBuilder` | `style.errorBuilder` |
| `onPressed` | `events.onPressed` |
| `onLongPress` | `events.onLongPress` |

### ZIMKitMessageInput

**1.x Version Code**
```dart
ZIMKitMessageInput(
  conversationID: 'id',
  actions: [...],
  onMessageSent: (message) { ... },
)
```

**2.0 Version Code**
```dart
ZIMKitMessageInput(
  conversationID: 'id',
  recordStatus: ZIMKitRecordStatus(), // New required parameter
  config: ZIMKitMessageInputConfigs(
    actions: [...],
  ),
  events: ZIMKitMessageInputEvents(
    onMessageSent: (message) { ... },
  ),
)
```

| 1.x Parameter | 2.0 Replacement |
| :--- | :--- |
| `actions` | `config.actions` |
| `onMessageSent` | `events.onMessageSent` |
| `inputDecoration` | `style.inputDecoration` |
| `editingController` | `config.editingController` |
| `focusNode` | `config.inputFocusNode` |
| (New Required) | `recordStatus` |

### ZIMKitMessageListView

**1.x Version Code**
```dart
ZIMKitMessageListView(
  conversationID: 'id',
  scrollController: myController,
)
```

**2.0 Version Code**
```dart
ZIMKitMessageListView(
  conversationID: 'id',
  config: ZIMKitMessageListConfigs(
    scrollController: myController,
  ),
)
```

| 1.x Parameter | 2.0 Replacement |
| :--- | :--- |
| `scrollController` | `config.scrollController` |
| `onPressed` | `events.onPressed` |
| `onLongPress` | `events.onLongPress` |
| `itemBuilder` | `style.itemBuilder` |
| `loadingBuilder` | `style.loadingBuilder` |
| `emptyBuilder` | `style.emptyBuilder` |
| `errorBuilder` | `style.errorBuilder` |
