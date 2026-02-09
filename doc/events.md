# Events

This document describes the event callback classes in ZIMKit. These classes are used to listen to various events occurring in ZIMKit.

- [ZIMKitEvents](#zimkitevents)
- [ZIMKitMessageEvents](#zimkitmessageevents)
- [ZIMKitConversationEvents](#zimkitconversationevents)
- [ZIMKitUserEvents](#zimkituserevents)
- [ZIMKitGroupEvents](#zimkitgroupevents)
- [ZIMKitConnectionEvents](#zimkitconnectionevents)

---

## ZIMKitEvents

ZIMKit Event Callback Class. Used to listen to various events occurring in ZIMKit.

| Name | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **message** | Message-related events | [ZIMKitMessageEvents](#zimkitmessageevents) | `ZIMKitMessageEvents()` |
| **conversation** | Conversation-related events | [ZIMKitConversationEvents](#zimkitconversationevents) | `ZIMKitConversationEvents()` |
| **user** | User-related events | [ZIMKitUserEvents](#zimkituserevents) | `ZIMKitUserEvents()` |
| **group** | Group-related events | [ZIMKitGroupEvents](#zimkitgroupevents) | `ZIMKitGroupEvents()` |
| **connection** | Connection-related events | [ZIMKitConnectionEvents](#zimkitconnectionevents) | `ZIMKitConnectionEvents()` |
| **onError** | Error event callback | `void Function(ZIMKitErrorEvent event)?` | `null` |

**Example:**
```dart
ZIMKitEvents(
  message: ZIMKitMessageEvents(
    onMessageReceived: (event) {
      print('Received message: ${event.message}');
    },
    onMessageSent: (event) {
      print('Sent message: ${event.message}');
    },
  ),
  conversation: ZIMKitConversationEvents(
    onConversationChanged: (event) {
      print('Conversation changed: ${event.conversation}');
    },
  ),
)
```

---

## ZIMKitMessageEvents

Message-related events.

### onMessageReceived

- **Description**
  Triggered when a message is received.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageEvent event)? onMessageReceived;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageReceived: (event) {
      print('Message received from ${event.message.info.senderUserID}');
    },
  )
  ```

### onMessageSent

- **Description**
  Triggered when a message is sent successfully.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageEvent event)? onMessageSent;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageSent: (event) {
      print('Message sent to ${event.message.info.conversationID}');
    },
  )
  ```

### onMessageSendFailed

- **Description**
  Triggered when a message fails to send.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageEvent event)? onMessageSendFailed;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageSendFailed: (event) {
      print('Message failed to send');
    },
  )
  ```

### onMessageDeleted

- **Description**
  Triggered when a message is deleted.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageEvent event)? onMessageDeleted;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageDeleted: (event) {
      print('Message deleted');
    },
  )
  ```

### onMessageRevoked

- **Description**
  Triggered when a message is revoked.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageEvent event)? onMessageRevoked;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageRevoked: (event) {
      print('Message revoked');
    },
  )
  ```

### onMessageReplied

- **Description**
  Triggered when a message is replied to.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageEvent event)? onMessageReplied;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageReplied: (event) {
      print('Message replied');
    },
  )
  ```

### onMessageForwarded

- **Description**
  Triggered when a message is forwarded.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageEvent event)? onMessageForwarded;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageForwarded: (event) {
      print('Message forwarded');
    },
  )
  ```

### onMessageReactionAdded

- **Description**
  Triggered when a reaction is added to a message.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageReactionEvent event)? onMessageReactionAdded;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageReactionAdded: (event) {
      print('${event.user.name} added ${event.reaction}');
    },
  )
  ```

### onMessageReactionDeleted

- **Description**
  Triggered when a reaction is removed from a message.

- **Prototype**
  ```dart
  final void Function(ZIMKitMessageReactionEvent event)? onMessageReactionDeleted;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMessageReactionDeleted: (event) {
      print('${event.user.name} removed ${event.reaction}');
    },
  )
  ```

### onMediaTransferProgress

- **Description**
  Triggered during media upload/download progress.

- **Prototype**
  ```dart
  final void Function(ZIMKitMediaTransferProgressEvent event)? onMediaTransferProgress;
  ```

- **Example**
  ```dart
  ZIMKitMessageEvents(
    onMediaTransferProgress: (event) {
      print('Progress: ${(event.progress * 100).toStringAsFixed(0)}%');
    },
  )
  ```

---

## ZIMKitConversationEvents

Conversation-related events.

### onConversationChanged

- **Description**
  Triggered when conversation information changes.

- **Prototype**
  ```dart
  final void Function(ZIMKitConversationEvent event)? onConversationChanged;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onConversationChanged: (event) {
      print('Conversation changed: ${event.conversation.id}');
    },
  )
  ```

### onConversationAdded

- **Description**
  Triggered when a new conversation is added.

- **Prototype**
  ```dart
  final void Function(ZIMKitConversationEvent event)? onConversationAdded;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onConversationAdded: (event) {
      print('New conversation: ${event.conversation.id}');
    },
  )
  ```

### onConversationDeleted

- **Description**
  Triggered when a conversation is deleted.

- **Prototype**
  ```dart
  final void Function(ZIMKitConversationEvent event)? onConversationDeleted;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onConversationDeleted: (event) {
      print('Conversation deleted');
    },
  )
  ```

### onConversationPinned

- **Description**
  Triggered when a conversation is pinned.

- **Prototype**
  ```dart
  final void Function(ZIMKitConversationEvent event)? onConversationPinned;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onConversationPinned: (event) {
      print('Conversation pinned');
    },
  )
  ```

### onConversationUnpinned

- **Description**
  Triggered when a conversation is unpinned.

- **Prototype**
  ```dart
  final void Function(ZIMKitConversationEvent event)? onConversationUnpinned;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onConversationUnpinned: (event) {
      print('Conversation unpinned');
    },
  )
  ```

### onConversationMuted

- **Description**
  Triggered when a conversation is muted.

- **Prototype**
  ```dart
  final void Function(ZIMKitConversationEvent event)? onConversationMuted;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onConversationMuted: (event) {
      print('Conversation muted');
    },
  )
  ```

### onConversationUnmuted

- **Description**
  Triggered when a conversation is unmuted.

- **Prototype**
  ```dart
  final void Function(ZIMKitConversationEvent event)? onConversationUnmuted;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onConversationUnmuted: (event) {
      print('Conversation unmuted');
    },
  )
  ```

### onTotalUnreadCountChanged

- **Description**
  Triggered when the total unread count changes.

- **Prototype**
  ```dart
  final void Function(int totalUnreadCount)? onTotalUnreadCountChanged;
  ```

- **Example**
  ```dart
  ZIMKitConversationEvents(
    onTotalUnreadCountChanged: (count) {
      print('Total unread: $count');
    },
  )
  ```

---

## ZIMKitUserEvents

User-related events.

### onUserInfoUpdated

- **Description**
  Triggered when user information is updated.

- **Prototype**
  ```dart
  final void Function(ZIMKitUserEvent event)? onUserInfoUpdated;
  ```

- **Example**
  ```dart
  ZIMKitUserEvents(
    onUserInfoUpdated: (event) {
      print('User info updated: ${event.user.name}');
    },
  )
  ```

### onUserAvatarUpdated

- **Description**
  Triggered when user avatar is updated.

- **Prototype**
  ```dart
  final void Function(ZIMKitUserEvent event)? onUserAvatarUpdated;
  ```

- **Example**
  ```dart
  ZIMKitUserEvents(
    onUserAvatarUpdated: (event) {
      print('User avatar updated');
    },
  )
  ```

---

## ZIMKitGroupEvents

Group-related events.

### onGroupCreated

- **Description**
  Triggered when a group is created.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event)? onGroupCreated;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupCreated: (event) {
      print('Group created');
    },
  )
  ```

### onGroupDismissed

- **Description**
  Triggered when a group is dismissed.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event)? onGroupDismissed;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupDismissed: (event) {
      print('Group dismissed');
    },
  )
  ```

### onGroupJoined

- **Description**
  Triggered when the current user joins a group.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event)? onGroupJoined;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupJoined: (event) {
      print('Joined group');
    },
  )
  ```

### onGroupLeft

- **Description**
  Triggered when the current user leaves a group.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event)? onGroupLeft;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupLeft: (event) {
      print('Left group');
    },
  )
  ```

### onGroupInfoUpdated

- **Description**
  Triggered when group information is updated.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event)? onGroupInfoUpdated;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupInfoUpdated: (event) {
      print('Group info updated');
    },
  )
  ```

### onGroupMemberJoined

- **Description**
  Triggered when a member joins a group.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event, List<ZIMKitUser> members)? onGroupMemberJoined;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupMemberJoined: (event, members) {
      for (final user in members) {
        print('${user.name} joined the group');
      }
    },
  )
  ```

### onGroupMemberLeft

- **Description**
  Triggered when a member leaves a group.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event, List<ZIMKitUser> members)? onGroupMemberLeft;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupMemberLeft: (event, members) {
      for (final user in members) {
        print('${user.name} left the group');
      }
    },
  )
  ```

### onGroupMemberInfoUpdated

- **Description**
  Triggered when a group member's information is updated.

- **Prototype**
  ```dart
  final void Function(ZIMKitGroupEvent event, ZIMKitUser member)? onGroupMemberInfoUpdated;
  ```

- **Example**
  ```dart
  ZIMKitGroupEvents(
    onGroupMemberInfoUpdated: (event, member) {
      print('Member info updated: ${member.name}');
    },
  )
  ```

---

## ZIMKitConnectionEvents

Connection-related events.

### onConnectionStateChanged

- **Description**
  Triggered when the connection state changes.

- **Prototype**
  ```dart
  final void Function(ZIMKitConnectionStateEvent event)? onConnectionStateChanged;
  ```

- **Example**
  ```dart
  ZIMKitConnectionEvents(
    onConnectionStateChanged: (event) {
      print('Connection state: ${event.state}');
    },
  )
  ```

### onTokenWillExpire

- **Description**
  Triggered when the token will expire (notified 30 seconds in advance).

- **Prototype**
  ```dart
  final void Function(ZIMKitTokenExpiredEvent event)? onTokenWillExpire;
  ```

- **Example**
  ```dart
  ZIMKitConnectionEvents(
    onTokenWillExpire: (event) {
      print('Token will expire in ${event.remainSeconds} seconds');
    },
  )
  ```

### onTokenExpired

- **Description**
  Triggered when the token has expired.

- **Prototype**
  ```dart
  final void Function()? onTokenExpired;
  ```

- **Example**
  ```dart
  ZIMKitConnectionEvents(
    onTokenExpired: () {
      print('Token expired, please re-login');
    },
  )
  ```
