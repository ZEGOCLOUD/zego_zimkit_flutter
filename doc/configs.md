# Configs

- [ZIMKitInputConfig](#zimkitinputconfig)
- [ZIMKitMessageConfig](#zimkitmessageconfig)
- [ZIMKitConversationConfig](#zimkitconversationconfig)

---

## ZIMKitInputConfig

Used to configure input box buttons, emojis, etc.

| Field | Type | Description |
| :--- | :--- | :--- |
| smallButtons | List<[ZIMKitInputButtonName](#zimkitinputbuttonname)> | List of small buttons displayed at the bottom |
| expandButtons | List<[ZIMKitInputButtonName](#zimkitinputbuttonname)> | List of buttons displayed in the expansion panel |
| maxSmallButtonCount | int | Maximum number of buttons at the bottom |
| placeholder | String? | Input box placeholder |
| customButtonBuilders | Map<[ZIMKitInputButtonName](#zimkitinputbuttonname), Widget Function(BuildContext)>? | Custom button builders |

### ZIMKitInputButtonName

Input Box Button Type. Used to configure the buttons displayed at the bottom of the input box and in the expansion panel.

| Enum Value | Description |
| :--- | :--- |
| audio | Voice button |
| emoji | Emoji button |
| picture | Picture button |
| takePhoto | Take photo button |
| voiceCall | Voice call button |
| videoCall | Video call button |
| file | File button |
| expand | More button (expand the expansion panel) |

---

## ZIMKitMessageConfig

Used to configure operation items and message reactions for various message types.

| Field | Type | Description |
| :--- | :--- | :--- |
| textMessageConfig | [ZIMKitTextMessageConfig](#zimkittextmessageconfig) | Text message configuration |
| imageMessageConfig | [ZIMKitImageMessageConfig](#zimkitimagemessageconfig) | Image message configuration |
| audioMessageConfig | [ZIMKitAudioMessageConfig](#zimkitaudiomessageconfig) | Audio message configuration |
| videoMessageConfig | [ZIMKitVideoMessageConfig](#zimkitvideomessageconfig) | Video message configuration |
| fileMessageConfig | [ZIMKitFileMessageConfig](#zimkitfilemessageconfig) | File message configuration |
| combineMessageConfig | [ZIMKitCombineMessageConfig](#zimkitcombinemessageconfig) | Combine message configuration |
| messageReactions | List<String>? | List of reaction emojis |

### ZIMKitTextMessageConfig

| Field | Type | Description |
| :--- | :--- | :--- |
| operations | List<[ZIMKitMessageOperationName](#zimkitmessageoperationname)> | Supported operations list |

### ZIMKitImageMessageConfig

| Field | Type | Description |
| :--- | :--- | :--- |
| operations | List<[ZIMKitMessageOperationName](#zimkitmessageoperationname)> | Supported operations list |

### ZIMKitAudioMessageConfig

| Field | Type | Description |
| :--- | :--- | :--- |
| operations | List<[ZIMKitMessageOperationName](#zimkitmessageoperationname)> | Supported operations list |

### ZIMKitVideoMessageConfig

| Field | Type | Description |
| :--- | :--- | :--- |
| operations | List<[ZIMKitMessageOperationName](#zimkitmessageoperationname)> | Supported operations list |

### ZIMKitFileMessageConfig

| Field | Type | Description |
| :--- | :--- | :--- |
| operations | List<[ZIMKitMessageOperationName](#zimkitmessageoperationname)> | Supported operations list |

### ZIMKitCombineMessageConfig

| Field | Type | Description |
| :--- | :--- | :--- |
| operations | List<[ZIMKitMessageOperationName](#zimkitmessageoperationname)> | Supported operations list |

### ZIMKitMessageOperationName

Message Operation Type. Used to configure the operation menu items displayed when long-pressing a message.

| Enum Value | Description |
| :--- | :--- |
| copy | Copy message (text messages only) |
| reply | Reply to message |
| forward | Forward message |
| revoke | Revoke message |
| delete | Delete message |
| multipleChoice | Multiple selection mode |
| reaction | Emoji reaction |
| speaker | Speaker mode (audio messages) |

---

## ZIMKitConversationConfig

| Field | Type | Description |
| :--- | :--- | :--- |
| showPinned | bool | Whether to show the pinned indicator |
| showNotificationStatus | bool | Whether to show the do-not-disturb indicator |
