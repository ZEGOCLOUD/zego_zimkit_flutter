# Events

- [ZIMKitMessageEvent](#zimkitmessageevent)
- [ZIMKitConversationEvent](#zimkitconversationevent)
- [ZIMKitUserEvent](#zimkituserevent)
- [ZIMKitGroupEvent](#zimkitgroupevent)
- [ZIMKitMessageReactionEvent](#zimkitmessagereactionevent)
- [ZIMKitMediaTransferProgressEvent](#zimkitmediatransferprogressevent)
- [ZIMKitConnectionStateEvent](#zimkitconnectionstateevent)
- [ZIMKitTokenExpiredEvent](#zimkittokenexpiredevent)
- [ZIMKitErrorEvent](#zimkiterrorevent)

---

## ZIMKitMessageEvent

Contains detailed information about message-related events.

| Field | Type | Description |
| :--- | :--- | :--- |
| message | [ZIMKitMessage](#zimkitmessage) | Message object |
| reason | [ZIMKitEventReason](#zimkiteventreason)? | Event reason/type |

### ZIMKitMessage

Message class for ZIMKit.

| Field | Type | Description |
| :--- | :--- | :--- |
| type | [ZIMKitMessageType](#zimkitmessagetype) | Type of the message |
| info | [ZIMKitMessageBaseInfo](#zimkitmessagebaseinfo) | Basic message info |
| textContent | [ZIMKitMessageTextContent](#zimkitmessagetextcontent)? | Text message content |
| imageContent | [ZIMKitMessageImageContent](#zimkitmessageimagecontent)? | Image message content |
| audioContent | [ZIMKitMessageAudioContent](#zimkitmessageaudiocontent)? | Audio message content |
| videoContent | [ZIMKitMessageVideoContent](#zimkitmessagevideocontent)? | Video message content |
| fileContent | [ZIMKitMessageFileContent](#zimkitmessagefilecontent)? | File message content |
| systemContent | [ZIMKitMessageSystemContent](#zimkitmessagesystemcontent)? | System message content |
| customContent | [ZIMKitMessageCustomContent](#zimkitmessagecustomcontent)? | Custom message content |
| combineContent | [ZIMKitMessageCombineContent](#zimkitmessagecombinecontent)? | Combine message content |
| revokeContent | [ZIMKitMessageRevokeContent](#zimkitmessagerevokecontent)? | Revoke message content |
| tipsContent | [ZIMKitMessageTipsContent](#zimkitmessagetipscontent)? | Tips message content |
| replyInfo | [ZIMKitReplyMessageInfo](#zimkitreplymessageinfo)? | Reply message info |
| reactions | ListNotifier<ZIMMessageReaction> | List of reactions |
| localExtendedData | ValueNotifier<String> | Local extended data |

### ZIMKitMessageBaseInfo

| Field | Type | Description |
| :--- | :--- | :--- |
| messageID | int | Message ID |
| localMessageID | int | Local message ID |
| senderUserID | String | Sender user ID |
| senderUserName | String | Sender user name |
| conversationID | String | Conversation ID |
| direction | ZIMMessageDirection | Message direction (send/receive) |
| sentStatus | ZIMMessageSentStatus | Message sent status |
| conversationType | [ZIMKitConversationType](#zimkitconversationtype) | Conversation type |
| timestamp | int | Message timestamp |
| conversationSeq | int | Conversation sequence |
| orderKey | int | Order key |
| isUserInserted | bool | Whether inserted by user |
| receiptStatus | ZIMMessageReceiptStatus | Message receipt status |

### ZIMKitMessageTextContent

| Field | Type | Description |
| :--- | :--- | :--- |
| text | String | Text content |

### ZIMKitMessageImageContent

| Field | Type | Description |
| :--- | :--- | :--- |
| fileLocalPath | String | Local file path |
| fileDownloadUrl | String | Download URL |
| fileName | String | File name |
| fileSize | int | File size |
| thumbnailDownloadUrl | String | Thumbnail download URL |
| thumbnailLocalPath | String | Thumbnail local path |
| largeImageDownloadUrl | String | Large image download URL |
| largeImageLocalPath | String | Large image local path |
| originalImageWidth | int | Original image width |
| originalImageHeight | int | Original image height |

### ZIMKitMessageAudioContent

| Field | Type | Description |
| :--- | :--- | :--- |
| fileLocalPath | String | Local file path |
| fileDownloadUrl | String | Download URL |
| fileName | String | File name |
| fileSize | int | File size |
| audioDuration | int | Audio duration |

### ZIMKitMessageVideoContent

| Field | Type | Description |
| :--- | :--- | :--- |
| fileLocalPath | String | Local file path |
| fileDownloadUrl | String | Download URL |
| fileName | String | File name |
| fileSize | int | File size |
| videoDuration | int | Video duration |
| videoFirstFrameDownloadUrl | String | First frame download URL |
| videoFirstFrameLocalPath | String | First frame local path |
| videoFirstFrameWidth | int | First frame width |
| videoFirstFrameHeight | int | First frame height |

### ZIMKitMessageFileContent

| Field | Type | Description |
| :--- | :--- | :--- |
| fileLocalPath | String | Local file path |
| fileDownloadUrl | String | Download URL |
| fileName | String | File name |
| fileSize | int | File size |

### ZIMKitMessageSystemContent

| Field | Type | Description |
| :--- | :--- | :--- |
| info | String | System info |

### ZIMKitMessageCustomContent

| Field | Type | Description |
| :--- | :--- | :--- |
| message | String | Custom message content |
| type | int | Custom message type |
| searchedContent | String | Content for search |

### ZIMKitMessageCombineContent

| Field | Type | Description |
| :--- | :--- | :--- |
| title | String | Title |
| summary | List<String> | Summary list |
| combineID | String | Combine ID |
| messageList | List<[ZIMKitMessage](#zimkitmessage)>? | Message list |

### ZIMKitMessageRevokeContent

| Field | Type | Description |
| :--- | :--- | :--- |
| operatorID | String | Revoker ID |
| operatorName | String | Revoker name |
| revokeTimestamp | int | Revoke timestamp |
| originalType | [ZIMKitMessageType](#zimkitmessagetype) | Original message type |
| canReEdit | bool | Whether can re-edit |

### ZIMKitMessageTipsContent

| Field | Type | Description |
| :--- | :--- | :--- |
| type | [ZIMKitTipsType](#zimkittipstype) | Tips type |
| content | String | Tips content |
| extendedData | Map<String, dynamic>? | Extended data |

### ZIMKitReplyMessageInfo

| Field | Type | Description |
| :--- | :--- | :--- |
| messageID | int | Original message ID |
| senderUserID | String | Sender user ID |
| senderUserName | String | Sender user name |
| messageType | [ZIMKitMessageType](#zimkitmessagetype) | Original message type |
| contentSummary | String | Content summary |
| originalMessage | [ZIMKitMessage](#zimkitmessage)? | Original message object |

### ZIMKitEventReason

Event reason enumeration.

| Enum Value | Description |
| :--- | :--- |
| normal | Normal operation |
| userAction | User-initiated action |
| systemAction | System automatic action |
| networkError | Network issue |
| permissionDenied | Permission issue |
| other | Other reasons |

### ZIMKitMessageType

Enum: text, image, audio, video, file, system, custom, combine, revoke, tips, unknown

### ZIMKitTipsType

Enum: groupNotice, memberJoined, memberLeft, memberKicked, groupInfoChanged, other

---

## ZIMKitConversationEvent

Contains detailed information about conversation-related events.

| Field | Type | Description |
| :--- | :--- | :--- |
| conversation | [ZIMKitConversation](#zimkitconversation) | Conversation object |
| reason | [ZIMKitEventReason](#zimkiteventreason)? | Event reason/type |

### ZIMKitConversation

Conversation information class for ZIMKit.

| Field | Type | Description |
| :--- | :--- | :--- |
| type | [ZIMKitConversationType](#zimkitconversationtype) | Conversation type (peer/group) |
| id | String | Conversation ID |
| name | String | Conversation name |
| avatarUrl | String | Avatar URL |
| notificationStatus | ZIMConversationNotificationStatus | Notification status |
| unreadMessageCount | int | Unread message count |
| orderKey | int | Order key |
| disable | bool | Whether disabled |
| isPinned | bool | Whether pinned |
| lastMessage | [ZIMKitMessage](#zimkitmessage)? | Last message |

### ZIMKitConversationType

Enum: peer, group, room, unknown

---

## ZIMKitUserEvent

Contains detailed information about user-related events.

| Field | Type | Description |
| :--- | :--- | :--- |
| user | [ZIMKitUser](#zimkituser) | User object |
| reason | [ZIMKitEventReason](#zimkiteventreason)? | Event reason/type |

### ZIMKitUser

User Information Class.

| Field | Type | Description |
| :--- | :--- | :--- |
| id | String | User ID |
| name | String | User name |
| avatarUrl | String | User avatar URL |

---

## ZIMKitGroupEvent

Contains detailed information about group-related events.

| Field | Type | Description |
| :--- | :--- | :--- |
| group | [ZIMKitGroupInfo](#zimkitgroupinfo) | Group object |
| reason | [ZIMKitEventReason](#zimkiteventreason)? | Event reason/type |

### ZIMKitGroupInfo

Group information class for ZIMKit.

| Field | Type | Description |
| :--- | :--- | :--- |
| notice | String | Group notice |
| attributes | Map<String, String> | Group attributes |
| state | ZIMGroupState | Group state |
| event | ZIMGroupEvent | Group event |

---

## ZIMKitMessageReactionEvent

Contains detailed information about message reaction events.

| Field | Type | Description |
| :--- | :--- | :--- |
| message | [ZIMKitMessage](#zimkitmessage) | Message object |
| reaction | String | Reaction emoji |
| user | [ZIMKitUser](#zimkituser) | User who performed the action |
| isAdded | bool | Whether it's an addition |

---

## ZIMKitMediaTransferProgressEvent

Contains detailed information about upload/download progress of media messages.

| Field | Type | Description |
| :--- | :--- | :--- |
| message | [ZIMKitMessage](#zimkitmessage) | Message object |
| currentSize | int | Currently transferred size |
| totalSize | int | Total size |
| isUploading | bool | Whether it's uploading |
| progress | double | Progress percentage (0.0 - 1.0) |

---

## ZIMKitConnectionStateEvent

Contains detailed information about connection state changes.

| Field | Type | Description |
| :--- | :--- | :--- |
| state | [ZIMConnectionState](#zimconnectionstate) | Connection state |
| event | [ZIMConnectionEvent](#zimconnectionevent) | Connection event |
| extendedData | Map<String, dynamic>? | Extended data |

### ZIMConnectionState

Enum: disconnected, connecting, connected, reconnecting

### ZIMConnectionEvent

Enum: success, activeLogin, kickedOut, tokenExpired, networkInterrupted, networkDisconnected

---

## ZIMKitTokenExpiredEvent

| Field | Type | Description |
| :--- | :--- | :--- |
| remainSeconds | int | Remaining seconds |

---

## ZIMKitErrorEvent

| Field | Type | Description |
| :--- | :--- | :--- |
| code | int | Error code |
| message | String | Error message |
| method | String? | Method that triggered the error |
