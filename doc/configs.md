# Configs

基准：ZIMKit Flutter v2.0.0（2026-10-14 与源码核对）

This document describes the configuration classes in ZIMKit.

- [ZIMKitConfig](#zimkitconfig)
- [ZIMKitInputConfig](#zimkitinputconfig)
- [ZIMKitMessageConfig](#zimmessageconfig)
- [ZIMKitConversationConfig](#zimconversationconfig)
- [ZIMKitInnerText](#zimkitinnertext)
- [ZegoZIMKitNotificationConfig](#zegozimmkitnotificationconfig)

---

## ZIMKitConfig

ZIMKit Configuration Class. Used to configure various functions of ZIMKit, including input box, messages, conversations, etc.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **inputConfig** | Input box configuration | [ZIMKitInputConfig](#zimkitinputconfig) | `ZIMKitInputConfig()` |
| **messageConfig** | Message configuration | [ZIMKitMessageConfig](#zimmessageconfig) | `ZIMKitMessageConfig()` |
| **conversationConfig** | Conversation configuration | [ZIMKitConversationConfig](#zimconversationconfig) | `ZIMKitConversationConfig()` |
| **innerText** | Internal text configuration | [ZIMKitInnerText](#zimkitinnertext) | `ZIMKitInnerText()` |
| **notificationConfig** | Push notification configuration | [ZegoZIMKitNotificationConfig](#zegozimmkitnotificationconfig)? | `null` |
| **advancedConfig** | Advanced configuration | `Map<String, dynamic>?` | `null` |

### defaultConfig

Factory method to get the default configuration.

```dart
factory ZIMKitConfig.defaultConfig()
```

### Example

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

Input Box Configuration. Used to configure input box buttons, emojis, etc.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **smallButtons** | Ordered buttons in the input toolbar. Overflow buttons move into the expansion panel. | `List<ZIMKitInputButtonName>` | `[audio, emoji, picture, expand]` |
| **expandButtons** | Ordered buttons in the expansion panel. The SDK shows the expand control when this list or overflow contains actions. | `List<ZIMKitInputButtonName>` | `[takePhoto, file]` |
| **emojis** | Emojis shown in the input panel. `null` uses the full picker; an empty list shows no quick emojis. | `List<String>?` | `null` |
| **maxSmallButtonCount** | Maximum number of toolbar buttons, including the expand control when shown. | `int` | `4` |
| **placeholder** | Input box placeholder. An explicit input style hint takes precedence. | `String?` | `null` |
| **customButtonBuilders** | Custom button builders for configured toolbar and expansion buttons. | `Map<ZIMKitInputButtonName, Widget Function(BuildContext)>?` | `null` |

---

## ZIMKitMessageConfig

Message Configuration. Used to configure operation items and message reactions for various message types.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **textMessageConfig** | Text message configuration | [ZIMKitTextMessageConfig](#zimtextmessageconfig) | `ZIMKitTextMessageConfig()` |
| **imageMessageConfig** | Image message configuration | [ZIMKitImageMessageConfig](#zimimagemessageconfig) | `ZIMKitImageMessageConfig()` |
| **audioMessageConfig** | Audio message configuration | [ZIMKitAudioMessageConfig](#zimaudiomessageconfig) | `ZIMKitAudioMessageConfig()` |
| **videoMessageConfig** | Video message configuration | [ZIMKitVideoMessageConfig](#zimvideomessageconfig) | `ZIMKitVideoMessageConfig()` |
| **fileMessageConfig** | File message configuration | [ZIMKitFileMessageConfig](#zimfilemessageconfig) | `ZIMKitFileMessageConfig()` |
| **combineMessageConfig** | Combine message configuration | [ZIMKitCombineMessageConfig](#zimcombinemessageconfig) | `ZIMKitCombineMessageConfig()` |
| **messageReactions** | Quick reactions in the message menu. `null` uses the defaults; an empty list hides the quick reaction bar. | `List<String>?` | `null` |

### getOperationsByMessageType

Gets the operations list by message type.

```dart
List<ZIMKitMessageOperationName> getOperationsByMessageType(ZIMMessageType type)
```

---

## ZIMKitTextMessageConfig

Text Message Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **operations** | Supported operations list | `List<ZIMKitMessageOperationName>` | `[copy, reply, forward, multipleChoice, delete, revoke, reaction]` |

---

## ZIMKitImageMessageConfig

Image Message Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **operations** | Supported operations list | `List<ZIMKitMessageOperationName>` | `[reply, forward, multipleChoice, delete, revoke, reaction]` |

---

## ZIMKitAudioMessageConfig

Audio Message Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **operations** | Supported operations list | `List<ZIMKitMessageOperationName>` | `[speaker, reply, forward, multipleChoice, delete, revoke, reaction]` |

---

## ZIMKitVideoMessageConfig

Video Message Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **operations** | Supported operations list | `List<ZIMKitMessageOperationName>` | `[reply, forward, multipleChoice, delete, revoke, reaction]` |

---

## ZIMKitFileMessageConfig

File Message Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **operations** | Supported operations list | `List<ZIMKitMessageOperationName>` | `[reply, forward, multipleChoice, delete, revoke, reaction]` |

---

## ZIMKitCombineMessageConfig

Combine Message Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **operations** | Supported operations list | `List<ZIMKitMessageOperationName>` | `[forward, multipleChoice, delete, reaction]` |

---

## ZIMKitConversationConfig

Conversation Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **showPinned** | Whether to show the pinned indicator | `bool` | `true` |
| **showNotificationStatus** | Whether to show the do-not-disturb indicator | `bool` | `true` |

---

## ZIMKitInnerText

Internal Text Configuration. Used to configure the internationalization of all visible texts in ZIMKit. All texts can be customized through this class.

### Message Input Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **messageEmptyText** | Hint text when message is empty | `String` | `'Say something...'` |

### Message Operation Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **copyMenuText** | Copy menu text | `String` | `'Copy'` |
| **replyMenuText** | Reply menu text | `String` | `'Reply'` |
| **forwardMenuText** | Forward menu text | `String` | `'Forward'` |
| **revokeMenuText** | Revoke menu text | `String` | `'Revoke'` |
| **deleteMenuText** | Delete menu text | `String` | `'Delete'` |
| **multipleChoiceMenuText** | Multiple selection menu text | `String` | `'Select'` |
| **reactionMenuText** | Reaction menu text | `String` | `'React'` |
| **speakerMenuText** | Speaker menu text | `String` | `'Speaker'` |
| **cancelMenuText** | Cancel menu text | `String` | `'Cancel'` |

### Toast Notifications

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **copySuccessToast** | Copy success notification | `String` | `'Copied to clipboard'` |
| **revokeSuccessToast** | Revoke success notification | `String` | `'Message revoked'` |
| **deleteSuccessToast** | Delete success notification | `String` | `'Message deleted'` |
| **deletedToast** | Deleted notification | `String` | `'Deleted'` |
| **forwardSuccessToast** | Forward success notification | `String` | `'Message forwarded'` |
| **networkErrorToast** | Network error notification | `String` | `'Network error'` |

### Confirmation Dialogs

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **deleteMessageTitle** | Delete message dialog title | `String` | `'Delete Message'` |
| **deleteMessageContent** | Delete message dialog content | `String` | `'Are you sure to delete this message?'` |
| **deleteMessagesTitle** | Delete multiple messages dialog title | `String` | `'Delete Messages'` |
| **deleteMessagesContentFormat** | Delete multiple messages dialog content | `String` | `'Delete %d messages?'` |
| **revokeMessageTitle** | Revoke message dialog title | `String` | `'Revoke Message'` |
| **revokeMessageContent** | Revoke message dialog content | `String` | `'Are you sure to revoke this message?'` |
| **confirmButtonText** | Confirm button text | `String` | `'Confirm'` |
| **cancelButtonText** | Cancel button text | `String` | `'Cancel'` |

### Multiple Selection Mode

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **selectedCountText** | Selected count text | `String` | `'%d selected'` |
| **selectAllText** | Select all text | `String` | `'Select All'` |
| **deselectAllText** | Deselect all text | `String` | `'Deselect All'` |

### Forward Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **forwardTitle** | Forward title | `String` | `'Forward'` |
| **forwardSeparatelyText** | Forward separately text | `String` | `'Forward Separately'` |
| **forwardCombinedText** | Forward as combined text | `String` | `'Forward as Combined'` |
| **forwardSelectTitle** | Select conversation title | `String` | `'Select Conversation'` |
| **forwardConfirmTitle** | Confirm forward title | `String` | `'Confirm Forward'` |
| **forwardToText** | Forward to text | `String` | `'Forward to:'` |

### Reply Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **replyToText** | Reply to text | `String` | `'Reply to %s'` |
| **replyMessageDeletedText** | Original message deleted text | `String` | `'Original message deleted'` |

### Conversation Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **conversationPinText** | Pin text | `String` | `'Pin'` |
| **conversationUnpinText** | Unpin text | `String` | `'Unpin'` |
| **conversationDeleteText** | Delete conversation text | `String` | `'Delete'` |
| **conversationMuteText** | Mute text | `String` | `'Mute'` |
| **conversationUnmuteText** | Unmute text | `String` | `'Unmute'` |

### Group Chat Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **groupNameText** | Group name text | `String` | `'Group Name'` |
| **groupMembersText** | Group members text | `String` | `'Members'` |
| **groupNoticeText** | Group notice text | `String` | `'Notice'` |
| **groupLeaveText** | Leave group text | `String` | `'Leave Group'` |
| **groupDismissText** | Dismiss group text | `String` | `'Dismiss Group'` |
| **groupDetailTitle** | Group details page title | `String` | `'Group details'` |
| **groupAddMemberText** | Add member button | `String` | `'Add'` |
| **groupOwnerRoleText** | Group owner role | `String` | `'Owner'` |
| **groupAdminRoleText** | Group admin role | `String` | `'Admin'` |
| **groupMemberRoleText** | Regular member role | `String` | `'Member'` |
| **groupRemoveMemberText** | Remove member action | `String` | `'Remove member'` |
| **groupMakeAdminText** | Make admin action | `String` | `'Make admin'` |
| **groupRemoveAdminText** | Remove admin action | `String` | `'Remove admin'` |
| **groupTransferOwnershipText** | Transfer ownership action | `String` | `'Transfer ownership'` |
| **groupNoMembersText** | Empty member list message | `String` | `'No members found'` |
| **groupRetryText** | Retry button text after loading group members fails | `String` | `'Retry'` |
| **groupPickerUnavailableText** | Missing host member picker message | `String` | `'The host app has not provided a member picker.'` |

### Message Type Display

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **imageMessageText** | Image message text | `String` | `'[Image]'` |
| **videoMessageText** | Video message text | `String` | `'[Video]'` |
| **audioMessageText** | Audio message text | `String` | `'[Audio]'` |
| **fileMessageText** | File message text | `String` | `'[File]'` |
| **combineMessageText** | Combined message text | `String` | `'[Chat History]'` |
| **customMessageText** | Custom message text | `String` | `'[Custom Message]'` |
| **revokeMessageText** | Revoked message text | `String` | `'Message revoked'` |

### Revoked Message Display

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **youRevokedMessage** | You recalled a message | `String` | `'You recalled a message'` |
| **someoneRevokedMessageFormat** | Someone recalled a message | `String` | `'%s recalled a message'` |

### Conversation Operation Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **deleteConversationTitle** | Delete conversation dialog title | `String` | `'Delete Conversation'` |
| **deleteConversationContent** | Delete conversation dialog content | `String` | `'Do you want to delete this conversation?'` |
| **leaveGroupTitle** | Leave group dialog title | `String` | `'Leave Group'` |
| **leaveGroupContent** | Leave group dialog content | `String` | `'Do you want to leave this group?'` |
| **quitGroupText** | Quit group text | `String` | `'Quit'` |
| **okButtonText** | OK button text | `String` | `'OK'` |

### Dialog Titles

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **newChatTitle** | New chat dialog title | `String` | `'New Chat'` |
| **newGroupTitle** | New group dialog title | `String` | `'New Group'` |
| **joinGroupTitle** | Join group dialog title | `String` | `'Join Group'` |

### Input Field Labels

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **userIdLabel** | User ID input field label | `String` | `'User ID'` |
| **groupNameLabel** | Group name input field label | `String` | `'Group Name'` |
| **groupIdOptionalLabel** | Group ID (optional) input field label | `String` | `'ID(optional)'` |
| **groupIdLabel** | Group ID input field label | `String` | `'Group ID'` |
| **inviteUserIdsLabel** | Invite User IDs input field label | `String` | `'Invite User IDs'` |
| **inviteUserIdsHint** | Invite User IDs input field hint | `String` | `'separate by comma, e.g. 123,987,229'` |

### Error Notifications

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **loadCombineMessageError** | Failed to load combined message notification | `String` | `'Failed to load chat history'` |
| **loadMessageListError** | Failed to load message list notification | `String` | `'Load failed, please click to retry'` |
| **messageNotFoundToast** | Message not found notification | `String` | `'Message not found in current conversation'` |

### Chat Settings Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **chatSettingsTitle** | Chat settings title | `String` | `'Chat Settings'` |
| **chatPinnedTitle** | Chat pin title | `String` | `'Pin Chat'` |
| **chatNotDisturbTitle** | Chat do not disturb title | `String` | `'Mute Notifications'` |
| **pinnedToast** | Pin success notification | `String` | `'Pinned'` |
| **unpinnedToast** | Unpin success notification | `String` | `'Unpinned'` |
| **notDisturbEnabledToast** | Do not disturb enabled notification | `String` | `'Muted'` |
| **notDisturbDisabledToast** | Do not disturb disabled notification | `String` | `'Unmuted'` |
| **operationFailedFormat** | Operation failed format | `String` | `'Operation failed: %s'` |

### Time Display

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **justNowText** | Just now | `String` | `'just now'` |
| **minutesAgoFormat** | X minutes ago format | `String` | `'%d minutes ago'` |
| **hoursAgoFormat** | X hours ago format | `String` | `'%d hours ago'` |

### Voice Recording Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **slideToCancelText** | Slide to cancel text | `String` | `'slide to cancel'` |

### More Operation Panel

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **takePhotoText** | Take photo text | `String` | `'Take Photo'` |
| **photoText** | Photo album text | `String` | `'Photo'` |
| **fileText** | File text | `String` | `'File'` |
| **voiceInputText** | Voice input action label | `String` | `'Voice'` |
| **emojiInputText** | Emoji input action label | `String` | `'Emoji'` |
| **voiceCallInputText** | Voice call action label | `String` | `'Voice call'` |
| **videoCallInputText** | Video call action label | `String` | `'Video call'` |

### Badge Related

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **maxBadgeCountText** | Maximum badge count text | `String` | `'9999+'` |

### Example

```dart
ZIMKitInnerText(
  messageEmptyText: 'Say something...',
  copySuccessToast: 'Copied to clipboard',
  forwardTitle: 'Forward',
)
```

---

## ZIMKitInnerTextZhCN

Chinese (Simplified) Text Configuration. Extends ZIMKitInnerText with default Chinese translations.

### Usage

```dart
ZIMKitConfig(
  innerText: ZIMKitInnerTextZhCN(),
)
```

All properties are inherited from [ZIMKitInnerText](#zimkitinnertext) with default Chinese values.

---

## ZegoZIMKitNotificationConfig

Notification Configuration Class. Used to configure offline push notifications.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **resourceID** | Resource ID for notifications | `String?` | `null` |
| **supportOfflineMessage** | Whether to support offline messages | `bool` | `true` |
| **androidNotificationConfig** | Android-specific notification configuration | [ZegoZIMKitAndroidNotificationConfig](#zegozimmkitandroidnotificationconfig)? | `null` |
| **iosNotificationConfig** | iOS-specific notification configuration | [ZegoZIMKitIOSNotificationConfig](#zegozimmkitiosnotificationconfig)? | `null` |

---

## ZegoZIMKitAndroidNotificationConfig

Android Notification Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **channelID** | Notification channel ID | `String` | `'ZIM Message'` |
| **channelName** | Notification channel name | `String` | `'Message'` |
| **icon** | Icon file name | `String?` | `''` |
| **sound** | Sound file name | `String?` | `''` |
| **vibrate** | Whether to enable vibration | `bool` | `false` |
| **enable** | Whether to enable notifications | `bool` | `true` |

---

## ZegoZIMKitIOSNotificationConfig

iOS Notification Configuration.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **isSandboxEnvironment** | Whether running in iOS sandbox environment | `bool?` | `null` |
| **certificateIndex** | Certificate index for push notifications | `ZegoSignalingPluginMultiCertificate` | `firstCertificate` |

---

## ZegoZIMKitPluginLocalNotificationConfig

Local Notification Configuration. Used to configure local notifications for incoming calls. (Android only)

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **id** | Notification ID | `int?` | `null` |
| **channelID** | Notification channel ID | `String` | Required |
| **title** | Notification title | `String` | Required |
| **content** | Notification content | `String` | Required |
| **iconSource** | Icon source path | `String?` | `null` |
| **soundSource** | Sound source path | `String?` | `null` |
| **vibrate** | Whether to enable vibration | `bool` | `false` |
| **clickCallback** | Callback when notification is clicked | `VoidCallback?` | `null` |

---

## ZegoZIMKitPluginLocalNotificationChannelConfig

Local Notification Channel Configuration. Used to configure notification channels for local notifications. (Android only)

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **channelID** | Notification channel ID | `String` | Required |
| **channelName** | Notification channel name | `String` | Required |
| **soundSource** | Sound source path | `String?` | `null` |
| **vibrate** | Whether to enable vibration | `bool` | `false` |
