# Components

This document describes the main UI components (Widgets) in ZIMKit.

- [ZIMKitConversationListView](#zimkitconversationlistview)
- [ZIMKitMessageListPage](#zimkitmessagelistpage)

---

## ZIMKitConversationListView

A widget that displays a list of conversations with customizable configuration, events, and styles.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **configs** | Configuration for conversation list | [ZIMKitConversationListConfigs](#zimkitconversationlistconfigs)? | `null` |
| **events** | Events for conversation list | [ZIMKitConversationListEvents](#zimkitconversationlistevents)? | `null` |
| **styles** | Style for conversation list | [ZIMKitConversationListStyles](#zimkitconversationliststyles)? | `null` |

### Example

```dart
ZIMKitConversationListView(
  configs: ZIMKitConversationListConfigs(
    filter: (context, conversationList) {
      return conversationList.where((conv) {
        return conv.value.type == ZIMConversationType.peer;
      }).toList();
    },
  ),
  events: ZIMKitConversationListEvents(
    onPressed: (context, conversation, onPressed) {
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
)
```

---

## ZIMKitMessageListPage

A page widget that displays a chat conversation with message list and input box.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **conversationID** | Conversation ID | `String` | Required |
| **conversationType** | Conversation type | `ZIMConversationType` | `ZIMConversationType.peer` |
| **config** | Configuration for message list page | [ZIMKitMessageListPageConfigs](#zimkitmessageListpageconfigs)? | `null` |
| **style** | Style for message list page | [ZIMKitMessageListPageStyles](#zimkitmessageListpagestyles)? | `null` |
| **events** | Events for message list page | [ZIMKitMessageListPageEvents](#zimkitmessageListpageevents)? | `null` |

### Example

```dart
ZIMKitMessageListPage(
  conversationID: 'user_123',
  conversationType: ZIMConversationType.peer,
  config: ZIMKitMessageListPageConfigs(
    inputConfig: ZIMKitInputConfig(
      smallButtons: [
        ZIMKitInputButtonName.emoji,
        ZIMKitInputButtonName.picture,
      ],
    ),
  ),
)
```

### Methods

#### setReplyMessage

Sets the message to reply to.

```dart
void setReplyMessage(ZIMKitMessage? message)
```

#### scrollToMessage

Scrolls to a specific message by messageID.

```dart
Future<void> scrollToMessage(String messageIDStr)
```
