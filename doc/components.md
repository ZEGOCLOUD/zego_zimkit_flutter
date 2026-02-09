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

---

## Audio Recording Components

### ZIMKitRecordState

Enum representing the state of audio recording.

| Name | Description | Value |
| :--- | :--- | :--- |
| **idle** | Recording is idle | `0` |
| **recording** | Currently recording | `1` |
| **cancel** | Recording was cancelled | `2` |
| **complete** | Recording completed | `3` |

### ZIMKitRecordLockerState

Enum representing the state of the record locker (slide-to-cancel feature).

| Name | Description | Value |
| :--- | :--- | :--- |
| **idle** | Locker is idle | `0` |
| **testing** | User is testing the locker area | `1` |
| **locked** | Recording is locked (slide complete) | `2` |

### ZIMKitRecordStyle

Style configuration class for audio recording components.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **lockerIconSize** | Size of the locker icon in pixels | `double` | `50` |

### ZIMKitRecordStatus

Status management class for audio recording.

| Name | Description | Type |
| :--- | :--- | :--- |
| **stateNotifier** | Notifier for recording state changes | `ValueNotifier<ZIMKitRecordState>` |
| **lockerStateNotifier** | Notifier for locker state changes | `ValueNotifier<ZIMKitRecordLockerState>` |

### ZIMKitRecordButton

A button widget for recording audio messages with slide-to-cancel functionality.

#### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **conversationID** | Conversation ID for sending the message | `String` | Required |
| **conversationType** | Conversation type | `ZIMConversationType` | `peer` |
| **status** | Recording status management | `ZIMKitRecordStatus` | Required |
| **icon** | Custom icon widget | `Widget?` | `null` |
| **padding** | Button padding | `EdgeInsetsGeometry` | `EdgeInsets.all(32.0)` |
| **onMessageSent** | Callback when message is sent | `void Function(ZIMKitMessage)?` | `null` |
| **events** | Event callbacks | `ZIMKitMessageListPageEvents?` | `null` |
| **preMessageSending** | Callback before message is sent | `FutureOr<ZIMKitMessage> Function(ZIMKitMessage)?` | `null` |

### ZIMKitRecordCancelSlider

A slider widget for cancelling audio recording by sliding.

#### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **status** | Recording status management | `ZIMKitRecordStatus` | Required |
| **stopIcon** | Custom stop icon widget | `Widget?` | `null` |
| **sendButtonWidget** | Custom send button widget | `Widget?` | `null` |
| **onMessageSent** | Callback when message is sent | `void Function(ZIMKitMessage)?` | `null` |
| **preMessageSending** | Callback before message is sent | `FutureOr<ZIMKitMessage> Function(ZIMKitMessage)?` | `null` |

### ZIMKitRecordLocker

A locker indicator widget that appears when sliding during recording.

#### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **processor** | Recording status management | `ZIMKitRecordStatus` | Required |
| **icon** | Custom icon widget | `Widget?` | `null` |

---

## Video Message Components

### ZIMKitVideoMessagePlayer

A video player widget for playing video messages.

#### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | The video message to play | `ZIMKitMessage` | Required |

### ZIMKitCustomControls

Custom video player controls widget.

#### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **showPlayButton** | Whether to show the play button | `bool` | `true` |

---

## Message Style Configuration

### ZIMKitMessageStyle

Style configuration class for message components.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **height** | Default height of message items in pixels | `double` | `70` |
| **iconSize** | Default size of message icons in pixels | `double` | `32` |
