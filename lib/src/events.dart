import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/events.defines.dart';

/// ZIMKit Event Callback Class
///
/// Used to listen to various events occurring in ZIMKit.
///
/// Example:
/// ```dart
/// ZIMKitEvents(
///   message: ZIMKitMessageEvents(
///     onMessageReceived: (event) {
///       print('Received message: ${event.message}');
///     },
///     onMessageSent: (event) {
///       print('Sent message: ${event.message}');
///     },
///   ),
/// )
/// ```
class ZIMKitEvents {
  ZIMKitEvents({
    ZIMKitMessageEvents? message,
    ZIMKitConversationEvents? conversation,
    ZIMKitUserEvents? user,
    ZIMKitGroupEvents? group,
    ZIMKitConnectionEvents? connection,
    this.onError,
  })  : message = message ?? ZIMKitMessageEvents(),
        conversation = conversation ?? ZIMKitConversationEvents(),
        user = user ?? ZIMKitUserEvents(),
        group = group ?? ZIMKitGroupEvents(),
        connection = connection ?? ZIMKitConnectionEvents();

  /// Message-related events
  final ZIMKitMessageEvents message;

  /// Conversation-related events
  final ZIMKitConversationEvents conversation;

  /// User-related events
  final ZIMKitUserEvents user;

  /// Group-related events
  final ZIMKitGroupEvents group;

  /// Connection-related events
  final ZIMKitConnectionEvents connection;

  /// Error event
  final void Function(ZIMKitErrorEvent event)? onError;

  @override
  String toString() {
    return 'ZIMKitEvents{'
        'message:$message, '
        'conversation:$conversation, '
        'user:$user, '
        'group:$group, '
        'connection:$connection, '
        'onError:$onError'
        '}';
  }
}

/// Message-related events
class ZIMKitMessageEvents {
  ZIMKitMessageEvents({
    this.onMessageReceived,
    this.onMessageSent,
    this.onMessageSendFailed,
    this.onMessageDeleted,
    this.onMessageRevoked,
    this.onMessageReplied,
    this.onMessageForwarded,
    this.onMessageReactionAdded,
    this.onMessageReactionDeleted,
    this.onMediaTransferProgress,
  });

  /// Message received
  final void Function(ZIMKitMessageEvent event)? onMessageReceived;

  /// Message sent successfully
  final void Function(ZIMKitMessageEvent event)? onMessageSent;

  /// Message failed to send
  final void Function(ZIMKitMessageEvent event)? onMessageSendFailed;

  /// Message deleted
  final void Function(ZIMKitMessageEvent event)? onMessageDeleted;

  /// Message revoked
  final void Function(ZIMKitMessageEvent event)? onMessageRevoked;

  /// Message replied to
  final void Function(ZIMKitMessageEvent event)? onMessageReplied;

  /// Message forwarded
  final void Function(ZIMKitMessageEvent event)? onMessageForwarded;

  /// Message reaction added
  final void Function(ZIMKitMessageReactionEvent event)? onMessageReactionAdded;

  /// Message reaction deleted
  final void Function(ZIMKitMessageReactionEvent event)?
      onMessageReactionDeleted;

  /// Media transfer progress updated
  final void Function(ZIMKitMediaTransferProgressEvent event)?
      onMediaTransferProgress;

  @override
  String toString() {
    return 'ZIMKitMessageEvents{...}';
  }
}

/// Conversation-related events
class ZIMKitConversationEvents {
  ZIMKitConversationEvents({
    this.onConversationChanged,
    this.onConversationAdded,
    this.onConversationDeleted,
    this.onConversationPinned,
    this.onConversationUnpinned,
    this.onConversationMuted,
    this.onConversationUnmuted,
    this.onTotalUnreadCountChanged,
  });

  /// Conversation information changed
  final void Function(ZIMKitConversationEvent event)? onConversationChanged;

  /// Conversation added
  final void Function(ZIMKitConversationEvent event)? onConversationAdded;

  /// Conversation deleted
  final void Function(ZIMKitConversationEvent event)? onConversationDeleted;

  /// Conversation pinned
  final void Function(ZIMKitConversationEvent event)? onConversationPinned;

  /// Conversation unpinned
  final void Function(ZIMKitConversationEvent event)? onConversationUnpinned;

  /// Conversation muted
  final void Function(ZIMKitConversationEvent event)? onConversationMuted;

  /// Conversation unmuted
  final void Function(ZIMKitConversationEvent event)? onConversationUnmuted;

  /// Total unread count changed
  final void Function(int totalUnreadCount)? onTotalUnreadCountChanged;

  @override
  String toString() {
    return 'ZIMKitConversationEvents{...}';
  }
}

/// User-related events
class ZIMKitUserEvents {
  ZIMKitUserEvents({
    this.onUserInfoUpdated,
    this.onUserAvatarUpdated,
  });

  /// User information updated
  final void Function(ZIMKitUserEvent event)? onUserInfoUpdated;

  /// User avatar updated
  final void Function(ZIMKitUserEvent event)? onUserAvatarUpdated;

  @override
  String toString() {
    return 'ZIMKitUserEvents{...}';
  }
}

/// Group-related events
class ZIMKitGroupEvents {
  ZIMKitGroupEvents({
    this.onGroupCreated,
    this.onGroupDismissed,
    this.onGroupJoined,
    this.onGroupLeft,
    this.onGroupInfoUpdated,
    this.onGroupMemberJoined,
    this.onGroupMemberLeft,
    this.onGroupMemberInfoUpdated,
  });

  /// Group created
  final void Function(ZIMKitGroupEvent event)? onGroupCreated;

  /// Group dismissed
  final void Function(ZIMKitGroupEvent event)? onGroupDismissed;

  /// Joined group
  final void Function(ZIMKitGroupEvent event)? onGroupJoined;

  /// Left group
  final void Function(ZIMKitGroupEvent event)? onGroupLeft;

  /// Group information updated
  final void Function(ZIMKitGroupEvent event)? onGroupInfoUpdated;

  /// Group member joined
  final void Function(ZIMKitGroupEvent event, List<ZIMKitUser> members)?
      onGroupMemberJoined;

  /// Group member left
  final void Function(ZIMKitGroupEvent event, List<ZIMKitUser> members)?
      onGroupMemberLeft;

  /// Group member information updated
  final void Function(ZIMKitGroupEvent event, ZIMKitUser member)?
      onGroupMemberInfoUpdated;

  @override
  String toString() {
    return 'ZIMKitGroupEvents{...}';
  }
}

/// Connection-related events
class ZIMKitConnectionEvents {
  ZIMKitConnectionEvents({
    this.onConnectionStateChanged,
    this.onTokenWillExpire,
    this.onTokenExpired,
  });

  /// Connection state changed
  final void Function(ZIMKitConnectionStateEvent event)?
      onConnectionStateChanged;

  /// Token will expire (notified 30 seconds in advance)
  final void Function(ZIMKitTokenExpiredEvent event)? onTokenWillExpire;

  /// Token has expired
  final void Function()? onTokenExpired;

  @override
  String toString() {
    return 'ZIMKitConnectionEvents{...}';
  }
}
