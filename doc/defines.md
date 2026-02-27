# Defines

This document describes the type definitions (Enums and Data Classes) in ZIMKit.

## Enums

### ZIMKitInputButtonName

Input Box Button Type. Used to configure the buttons displayed at the bottom of the input box and in the expansion panel.

| Name | Description | Value |
| :--- | :--- | :--- |
| **audio** | Voice button | `0` |
| **emoji** | Emoji button | `1` |
| **picture** | Picture button | `2` |
| **takePhoto** | Take photo button | `3` |
| **voiceCall** | Voice call button | `4` |
| **videoCall** | Video call button | `5` |
| **file** | File button | `6` |
| **expand** | More button (expand the expansion panel) | `7` |

### ZIMKitMessageOperationName

Message Operation Type. Used to configure the operation menu items displayed when long-pressing a message.

| Name | Description | Value |
| :--- | :--- | :--- |
| **copy** | Copy message (text messages only) | `0` |
| **reply** | Reply to message | `1` |
| **forward** | Forward message | `2` |
| **revoke** | Revoke message | `3` |
| **delete** | Delete message | `4` |
| **multipleChoice** | Multiple selection mode | `5` |
| **reaction** | Emoji reaction | `6` |
| **speaker** | Speaker mode (audio messages) | `7` |

### ZIMKitForwardType

Message Forward Type.

| Name | Description | Value |
| :--- | :--- | :--- |
| **single** | Forward single message | `0` |
| **oneByOne** | Forward multiple messages one by one | `1` |
| **merge** | Merge multiple messages and forward | `2` |

### ZIMKitTipsType

Tips message type enumeration. Used to display system prompts, such as group announcements, joining/leaving groups, etc.

| Name | Description | Value |
| :--- | :--- | :--- |
| **groupNotice** | Group announcement | `0` |
| **memberJoined** | User joined the group | `1` |
| **memberLeft** | User left the group | `2` |
| **memberKicked** | User was kicked out of the group | `3` |
| **groupInfoChanged** | Group information changed | `4` |
| **other** | Other tips | `5` |

### ZIMKitInvitationProtocolKey

Invitation Protocol Key. Used for identifying invitation-related operations.

| Name | Description | Type |
| :--- | :--- | :--- |
| **operationType** | Operation type key | `String` |

### ZIMKitEventReason

Event reason enumeration. Used to identify the reason for an event occurrence.

| Name | Description | Value |
| :--- | :--- | :--- |
| **normal** | Normal operation | `0` |
| **userAction** | User-initiated action | `1` |
| **systemAction** | System automatic action | `2` |
| **networkError** | Network issue | `3` |
| **permissionDenied** | Permission issue | `4` |
| **other** | Other reasons | `5` |

### ZIMConnectionState

Connection state enumeration (from ZIM SDK).

| Name | Description | Value |
| :--- | :--- | :--- |
| **disconnected** | Not connected | `0` |
| **connecting** | Connecting | `1` |
| **connected** | Connected | `2` |
| **reconnecting** | Reconnecting | `3` |

### ZIMConnectionEvent

Connection event enumeration (from ZIM SDK).

| Name | Description | Value |
| :--- | :--- | :--- |
| **success** | Connection successful | `0` |
| **activeLogin** | Active login | `1` |
| **kickedOut** | Kicked out | `2` |
| **tokenExpired** | Token expired | `3` |
| **networkInterrupted** | Network temporarily interrupted | `4` |
| **networkDisconnected** | Network disconnected | `5` |

---

## Data Classes

### ZIMKitConversation

Conversation information class for ZIMKit.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **type** | Type of the conversation (peer or group) | [ZIMKitConversationType](#zimkitconversationtype) | `peer` |
| **id** | Conversation ID | `String` | `''` |
| **name** | Conversation name | `String` | `''` |
| **avatarUrl** | Avatar URL | `String` | `''` |
| **notificationStatus** | Notification status | `ZIMConversationNotificationStatus` | `notify` |
| **unreadMessageCount** | Unread message count | `int` | `0` |
| **orderKey** | Order key for sorting | `int` | `0` |
| **disable** | Whether disabled | `bool` | `false` |
| **isPinned** | Whether pinned | `bool` | `false` |
| **lastMessage** | Last message in conversation | [ZIMKitMessage](#zimkitmessage)? | `null` |

### ZIMKitMessage

Message class for ZIMKit.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **type** | Type of the message | [ZIMKitMessageType](#zimkitmessagetype) | `unknown` |
| **info** | Basic message info | [ZIMKitMessageBaseInfo](#zimkitmessagebaseinfo) | - |
| **textContent** | Text message content | [ZIMKitMessageTextContent](#zimkitmessagetextcontent)? | `null` |
| **imageContent** | Image message content | [ZIMKitMessageImageContent](#zimkitmessageimagecontent)? | `null` |
| **audioContent** | Audio message content | [ZIMKitMessageAudioContent](#zimkitmessageaudiocontent)? | `null` |
| **videoContent** | Video message content | [ZIMKitMessageVideoContent](#zimkitmessagevideocontent)? | `null` |
| **fileContent** | File message content | [ZIMKitMessageFileContent](#zimkitmessagefilecontent)? | `null` |
| **systemContent** | System message content | [ZIMKitMessageSystemContent](#zimkitmessagesystemcontent)? | `null` |
| **customContent** | Custom message content | [ZIMKitMessageCustomContent](#zimkitmessagecustomcontent)? | `null` |
| **combineContent** | Combine message content | [ZIMKitMessageCombineContent](#zimkitmessagecombinecontent)? | `null` |
| **revokeContent** | Revoke message content | [ZIMKitMessageRevokeContent](#zimkitmessagerevokecontent)? | `null` |
| **tipsContent** | Tips message content | [ZIMKitMessageTipsContent](#zimkitmessagetipscontent)? | `null` |
| **replyInfo** | Reply message info | [ZIMKitReplyMessageInfo](#zimkitreplymessageinfo)? | `null` |
| **reactions** | List of reactions | `ListNotifier<ZIMMessageReaction>` | `[]` |
| **localExtendedData** | Local extended data | `ValueNotifier<String>` | `''` |

### ZIMKitGroupInfo

Group information class for ZIMKit.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **notice** | Group notice text | `String` | `''` |
| **attributes** | Group attributes map | `Map<String, String>` | `{}` |
| **state** | Current group state | `ZIMGroupState` | `enter` |
| **event** | Current group event | `ZIMGroupEvent` | `created` |

### ZIMKitUser

User Information Class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **id** | User ID | `String` | Required |
| **name** | User name | `String` | `''` |
| **avatarUrl** | User avatar URL | `String` | `''` |

### ZIMKitMessageBaseInfo

Basic message information class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **messageID** | Message ID | `int` | `0` |
| **localMessageID** | Local message ID | `int` | `0` |
| **senderUserID** | Sender user ID | `String` | `''` |
| **senderUserName** | Sender user name | `String` | `''` |
| **conversationID** | Conversation ID | `String` | `''` |
| **direction** | Message direction (send/receive) | `ZIMMessageDirection` | `send` |
| **sentStatus** | Message sent status | `ZIMMessageSentStatus` | `sending` |
| **conversationType** | Conversation type | [ZIMKitConversationType](#zimkitconversationtype) | `peer` |
| **timestamp** | Message timestamp | `int` | `0` |
| **conversationSeq** | Conversation sequence | `int` | `0` |
| **orderKey** | Order key | `int` | `0` |
| **isUserInserted** | Whether inserted by user | `bool` | `false` |
| **receiptStatus** | Message receipt status | `ZIMMessageReceiptStatus` | `none` |

### ZIMKitMessageTextContent

Text message content class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **text** | Text content | `String` | Required |

### ZIMKitMessageImageContent

Image message content class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **fileLocalPath** | Local file path | `String` | Required |
| **fileDownloadUrl** | Download URL | `String` | `''` |
| **fileUID** | File UID | `String` | `''` |
| **fileName** | File name | `String` | `''` |
| **fileSize** | File size | `int` | `0` |
| **thumbnailDownloadUrl** | Thumbnail download URL | `String` | `''` |
| **thumbnailLocalPath** | Thumbnail local path | `String` | `''` |
| **largeImageDownloadUrl** | Large image download URL | `String` | `''` |
| **largeImageLocalPath** | Large image local path | `String` | `''` |
| **originalImageWidth** | Original image width | `int` | `0` |
| **originalImageHeight** | Original image height | `int` | `0` |

### ZIMKitMessageAudioContent

Audio message content class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **fileLocalPath** | Local file path | `String` | Required |
| **fileDownloadUrl** | Download URL | `String` | `''` |
| **fileUID** | File UID | `String` | `''` |
| **fileName** | File name | `String` | `''` |
| **fileSize** | File size | `int` | `0` |
| **audioDuration** | Audio duration in seconds | `int` | `0` |

---

## Audio Recording Enums and Classes

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

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **stateNotifier** | Notifier for recording state changes | `ValueNotifier<ZIMKitRecordState>` | `ZIMKitRecordState.idle` |
| **lockerStateNotifier** | Notifier for locker state changes | `ValueNotifier<ZIMKitRecordLockerState>` | `ZIMKitRecordLockerState.idle` |

### formatAudioRecordDuration

Formats audio recording duration from milliseconds to MM:SS format.

```dart
String formatAudioRecordDuration(int milliseconds)
```

---

### ZIMKitMessageVideoContent

Video message content class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **fileLocalPath** | Local file path | `String` | Required |
| **fileDownloadUrl** | Download URL | `String` | `''` |
| **fileUID** | File UID | `String` | `''` |
| **fileName** | File name | `String` | `''` |
| **fileSize** | File size | `int` | `0` |
| **videoDuration** | Video duration in seconds | `int` | `0` |
| **videoFirstFrameDownloadUrl** | First frame download URL | `String` | `''` |
| **videoFirstFrameLocalPath** | First frame local path | `String` | `''` |
| **videoFirstFrameWidth** | First frame width | `int` | `0` |
| **videoFirstFrameHeight** | First frame height | `int` | `0` |

### ZIMKitMessageFileContent

File message content class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **fileLocalPath** | Local file path | `String` | Required |
| **fileDownloadUrl** | Download URL | `String` | `''` |
| **fileUID** | File UID | `String` | `''` |
| **fileName** | File name | `String` | `''` |
| **fileSize** | File size | `int` | `0` |

### ZIMKitMessageSystemContent

System message content class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **info** | System info text | `String` | Required |

### ZIMKitMessageCustomContent

Custom message content class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Custom message content | `String` | Required |
| **type** | Custom message type | `int` | Required |
| **searchedContent** | Content for search | `String` | Required |

### ZIMKitMessageCombineContent

Combined Message Content Class. Used for combining and forwarding multiple messages.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **title** | Combined message title | `String` | Required |
| **summary** | Combined message summary | `List<String>` | Required |
| **combineID** | Combined message ID | `String` | Required |
| **messageList** | Combined message list | `List<[ZIMKitMessage](#zimkitmessage)>?` | `null` |

### ZIMKitMessageRevokeContent

Revoked Message Content Class. Contains relevant information about message revocation.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **operatorID** | Revoker ID | `String` | Required |
| **operatorName** | Revoker name | `String` | Required |
| **revokeTimestamp** | Revocation timestamp | `int` | Required |
| **originalType** | Original message type | [ZIMKitMessageType](#zimkitmessagetype) | Required |
| **canReEdit** | Whether re-editing is allowed | `bool` | `false` |

### ZIMKitMessageTipsContent

Tips Message Content Class. Used to display system prompts, such as group announcements, joining/leaving groups, etc.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **type** | Tips type | [ZIMKitTipsType](#zimkittipstype) | Required |
| **content** | Tips text content | `String` | Required |
| **extendedData** | Extended information | `Map<String, dynamic>?` | `null` |

### ZIMKitReplyMessageInfo

Reply Message Information Class. Contains basic information of the replied message.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **messageID** | Original message ID | `int` | Required |
| **senderUserID** | Original message sender ID | `String` | Required |
| **senderUserName** | Original message sender name | `String` | Required |
| **messageType** | Original message type | [ZIMKitMessageType](#zimkitmessagetype) | Required |
| **contentSummary** | Content summary | `String` | Required |
| **originalMessage** | Original message object | [ZIMKitMessage](#zimkitmessage)? | `null` |

### MediaTransferProgress

Media transfer progress class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **totalSize** | Total size in bytes | `int` | `0` |
| **transferredSize** | Transferred size in bytes | `int` | `0` |
| **progress** | Progress percentage | `double` | `0.0` |

### ZIMKitFileType

File type enumeration (from file_picker package).

| Name | Description | Value |
| :--- | :--- | :--- |
| **any** | Any file type | `0` |
| **image** | Image files | `1` |
| **video** | Video files | `2` |
| **audio** | Audio files | `3` |

### ZIMKitPlatformFile

Platform file class (from file_picker package).

| Name | Description | Type |
| :--- | :--- | :--- |
| **name** | File name | `String` |
| **path** | File path | `String?` |
| **size** | File size in bytes | `int` |
| **bytes** | File bytes | `Uint8List?` |
| **extension** | File extension | `String?` |

### ZegoZIMKitOfflineMessageCacheInfo

Offline message cache information class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **conversationID** | Conversation ID | `String` | Required |
| **conversationTypeIndex** | Conversation type index | `int` | Required |
| **senderID** | Sender ID | `String` | Required |
| **valid** | Whether valid | `bool` | - |
| **conversionType** | Conversation type | [ZIMKitConversationType](#zimkitconversationtype) | - |

### ZIMKitReceivedMessages

Class for storing received messages information.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **id** | Conversation ID | `String` | Required |
| **type** | Conversation type | [ZIMKitConversationType](#zimkitconversationtype) | Required |
| **receiveMessages** | List of received messages | `List<[ZIMKitMessage](#zimkitmessage)>` | Required |

### ZIMKitReactions

Message reaction class.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **reaction** | Reaction emoji | `String` | `''` |
| **userList** | List of users who reacted | `List<ZIMMessageReactionUserInfo>` | `[]` |
| **totalCount** | Total count | `int` | `0` |
| **reactionType** | Reaction type | `String` | `''` |
| **isSelfIncluded** | Whether self is included | `bool` | `false` |
