# Components

基准：ZIMKit Flutter v2.0.1（2026-10-15 与源码核对）

This document describes the main UI components (Widgets) in ZIMKit.

- [ZIMKitConversationListView](#zimkitconversationlistview)
- [ZIMKitMessageListPage](#zimkitmessagelistpage)
- [ZIMKitGroupDetailPage](#zimkitgroupdetailpage)
- [ZIMKitConversationListConfigs](#zimkitconversationlistconfigs)
- [ZIMKitConversationListEvents](#zimkitconversationlistevents)
- [ZIMKitConversationListStyles](#zimkitconversationliststyles)
- [ZIMKitMessageListPageConfigs](#zimkitmessageListpageconfigs)
- [ZIMKitMessageListPageStyles](#zimkitmessageListpagestyles)
- [ZIMKitMessageListPageEvents](#zimkitmessageListpageevents)
- [ZIMKitMessageListConfigs](#zimkitmessagelistconfigs)
- [ZIMKitMessageListStyles](#zimkitmessagestyles)
- [ZIMKitMessageListEvents](#zimkitmessagelistevents)
- [ZIMKitMessageInputConfigs](#zimkitmessageinputconfigs)
- [ZIMKitMessageInputStyles](#zimkitmessageinputstyles)
- [ZIMKitMessageInputEvents](#zimkitmessageinputevents)
- [Audio Recording Components](#audio-recording-components)
- [Video Message Components](#video-message-components)
- [Message Style Configuration](#message-style-configuration)
- [ZIMKitStyle](#zimkitstyle)
- [ZIMKitAvatar](#zimkitavatar)
- [ZIMKitMessageInput](#zimkitmessageinput)
- [ZIMKitMessageListView](#zimkitmessagelistview)
- [ZIMKitMessageWidget](#zimkitmessagewidget)
- [ZIMKitTextMessage](#zimkittextmessage)
- [ZIMKitImageMessage](#zimkitimagemessage)
- [ZIMKitFileMessage](#zimkitfilemessage)
- [ZIMKitAudioMessage](#zimkitaudiomessage)
- [ZIMKitVideoMessage](#zimkitvideomessage)
- [ZIMKitCombineMessage](#zimkitcombinemessage)
- [ZIMKitRevokeMessage](#zimkitrevokemessage)
- [ZIMKitMultiSelectToolbarWidget](#zimkitmultiselecttoolbarwidget)

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
    messageInput: ZIMKitMessageInputConfigs(
      showEmojiButton: true,
      showPickMediaButton: true,
    ),
  ),
)
```

Global toolbar buttons, expansion actions, placeholder text, and emojis are configured in `ZIMKitConfig.inputConfig` during `ZIMKit.init`.

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

## ZIMKitGroupDetailPage

SDK-owned group details and member management page. The host supplies a member picker callback because user search belongs to the host application.

```dart
ZIMKitGroupDetailPage(
  groupID: groupID,
  onInviteMembers: (context, currentMembers) async {
    return showYourMemberPicker(context, currentMembers);
  },
)
```

The page displays group name, ID, notice, member count, and members. It exposes member actions allowed for the current user's group role, plus shared pin and do-not-disturb settings. The callback returns selected user IDs; the SDK page performs the group invite.

---

## ZIMKitStyle

Style configuration class for customizing the visual appearance of ZIMKit.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **primaryColor** | Primary color | `Color?` | `null` |
| **backgroundColor** | Background color | `Color?` | `null` |
| **textColor** | Main text color | `Color?` | `null` |
| **secondaryTextColor** | Secondary text color | `Color?` | `null` |
| **dividerColor** | Divider color | `Color?` | `null` |
| **messageBubbleColor** | Message bubble color (general) | `Color?` | `null` |
| **receivedMessageBubbleColor** | Received message bubble color | `Color?` | `null` |
| **sentMessageBubbleColor** | Sent message bubble color | `Color?` | `null` |

### Example

```dart
ZIMKitStyle(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  textColor: Colors.black,
  messageBubbleColor: Colors.grey[200],
)
```

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

---

## ZIMKitStyle

Style configuration class for customizing the visual appearance of ZIMKit.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **primaryColor** | Primary color | `Color?` | `null` |
| **backgroundColor** | Background color | `Color?` | `null` |
| **textColor** | Main text color | `Color?` | `null` |
| **secondaryTextColor** | Secondary text color | `Color?` | `null` |
| **dividerColor** | Divider color | `Color?` | `null` |
| **messageBubbleColor** | Message bubble color (general) | `Color?` | `null` |
| **receivedMessageBubbleColor** | Received message bubble color | `Color?` | `null` |
| **sentMessageBubbleColor** | Sent message bubble color | `Color?` | `null` |

### Example

```dart
ZIMKitStyle(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  textColor: Colors.black,
  messageBubbleColor: Colors.grey[200],
)
```

---

## ZIMKitAvatar

Avatar widget for displaying user or conversation avatars.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **avatarUrl** | Avatar image URL | `String` | Required |
| **avatarSize** | Size of the avatar | `double` | `40` |
| **borderRadius** | Border radius | `double` | `20` |

### Example

```dart
ZIMKitAvatar(
  avatarUrl: 'https://example.com/avatar.png',
  avatarSize: 50,
)
```

---

## ZIMKitMessageInput

Input widget for composing and sending messages.

The built-in camera picker uses the current Flutter `Localizations` locale to select its text delegate. This applies to the camera buttons in both the input toolbar and the more actions panel. Locales without a matching delegate use the picker package's Chinese fallback.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **conversationID** | Conversation ID | `String` | Required |
| **conversationType** | Conversation type | `ZIMConversationType` | `peer` |
| **configs** | Input configuration | `ZIMKitMessageInputConfigs?` | `null` |
| **styles** | Input styles | `ZIMKitMessageInputStyles?` | `null` |
| **events** | Input events | `ZIMKitMessageInputEvents?` | `null` |
| **inputConfig** | Global input toolbar configuration. Usually supplied by `ZIMKitConfig.inputConfig`. | `ZIMKitInputConfig?` | `null` |

---

## ZIMKitMessageListView

Widget for displaying a list of messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **conversationID** | Conversation ID | `String` | Required |
| **conversationType** | Conversation type | `ZIMConversationType` | `peer` |
| **configs** | List configuration | `ZIMKitMessageListConfigs?` | `null` |
| **styles** | List styles | `ZIMKitMessageListStyles?` | `null` |
| **events** | List events | `ZIMKitMessageListEvents?` | `null` |

---

## ZIMKitMessageWidget

General message widget for rendering different message types.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |
| **isShowAvatar** | Whether to show avatar | `bool` | `true` |
| **isShowNickname** | Whether to show nickname | `bool` | `true` |

---

## ZIMKitTextMessage

Widget for displaying text messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |

---

## ZIMKitImageMessage

Widget for displaying image messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |

---

## ZIMKitFileMessage

Widget for displaying file messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |

---

## ZIMKitAudioMessage

Widget for displaying and playing audio messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |

---

## ZIMKitVideoMessage

Widget for displaying video messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |

---

## ZIMKitCombineMessage

Widget for displaying combined/forwarded messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |

---

## ZIMKitRevokeMessage

Widget for displaying revoked messages.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message to display | `ZIMKitMessage` | Required |

---

## ZIMKitMultiSelectToolbarWidget

Toolbar widget for multi-select mode in message list.

### Parameters

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **selectedMessages** | List of selected messages | `List<ZIMKitMessage>` | Required |
| **onForward** | Forward callback | `void Function()?` | `null` |
| **onDelete** | Delete callback | `void Function()?` | `null` |

---

## ZIMKitMessageInputConfigs

Configuration for the message input widget.

The default send button stays visible when the input is empty and uses a disabled gray appearance. It becomes active when the input contains non-whitespace text.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **showPickFileButton** | Show the file button | `bool` | `true` |
| **showPickMediaButton** | Show picture and camera buttons | `bool` | `true` |
| **showMoreButton** | Show the expansion panel button | `bool` | `true` |
| **showRecordButton** | Show the voice recording button | `bool` | `true` |
| **showEmojiButton** | Show the emoji button | `bool` | `true` |
| **actions** | Additional actions in the input panel | `List<ZIMKitMessageInputAction>` | `[]` |
| **maxLines** | Maximum input lines | `int?` | `null` |
| **repliedMessage** | Message currently being replied to | `ZIMKitMessage?` | `null` |

Global button order, overflow behavior, emojis, and placeholder text come from `ZIMKitConfig.inputConfig`. Page-level visibility flags filter the built-in buttons.

---

## ZIMKitMessageInputEvents

Input callbacks include message send hooks and a typed call action callback.

```dart
ZIMKitMessageInputEvents(
  onCallTap: (button) {
    if (button == ZIMKitInputButtonName.voiceCall) {
      // Start or present a voice call.
    }
  },
)
```

`onCallTap` receives `voiceCall` or `videoCall`. The host application owns call handling.

---

## ZIMKitMessageListConfigs

Configuration for the message list widget.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **scrollController** | Scroll controller | `ScrollController?` | `null` |
| **enableTypingIndicator** | Show typing indicator | `bool` | `true` |

---

## ZIMKitMessageListPageConfigs

Configuration for the message list page.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **messageInput** | Page-level input visibility and behavior | `ZIMKitMessageInputConfigs?` | `null` |
| **messageListScrollController** | Message list scroll controller | `ScrollController?` | `null` |
| **inputFocusNode** | Input focus node | `FocusNode?` | `null` |

---

## ZIMKitConversationListConfigs

Configuration for the conversation list widget.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **filter** | Filter function | `List<ZIMKitConversation> Function(BuildContext, List<ZIMKitConversation>)?` | `null` |
| **sorter** | Sort function | `int Function(ZIMKitConversation, ZIMKitConversation)?` | `null` |

---

## ZIMKitConversationListEvents

Events for the conversation list widget.

| Name | Description | Type |
| :--- | :--- | :--- |
| **onPressed** | Item tap event | `void Function(BuildContext, ZIMKitConversation, VoidCallback)?` |
| **onLongPressed** | Item long press event | `void Function(BuildContext, ZIMKitConversation)?` |
