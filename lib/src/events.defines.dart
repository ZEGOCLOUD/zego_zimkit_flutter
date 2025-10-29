import 'package:zego_zimkit/src/defines.dart';

/// Message event data
///
/// Contains detailed information about message-related events
class ZIMKitMessageEvent {
  ZIMKitMessageEvent({
    required this.message,
    this.reason,
  });

  /// Message object
  final ZIMKitMessage message;

  /// Event reason/type
  final ZIMKitEventReason? reason;

  @override
  String toString() {
    return 'ZIMKitMessageEvent{message:$message, reason:$reason}';
  }
}

/// Conversation event data
///
/// Contains detailed information about conversation-related events
class ZIMKitConversationEvent {
  ZIMKitConversationEvent({
    required this.conversation,
    this.reason,
  });

  /// Conversation object
  final ZIMKitConversation conversation;

  /// Event reason/type
  final ZIMKitEventReason? reason;

  @override
  String toString() {
    return 'ZIMKitConversationEvent{conversation:$conversation, reason:$reason}';
  }
}

/// User event data
///
/// Contains detailed information about user-related events
class ZIMKitUserEvent {
  ZIMKitUserEvent({
    required this.user,
    this.reason,
  });

  /// User object
  final ZIMKitUser user;

  /// Event reason/type
  final ZIMKitEventReason? reason;

  @override
  String toString() {
    return 'ZIMKitUserEvent{user:$user, reason:$reason}';
  }
}

/// Group event data
///
/// Contains detailed information about group-related events
class ZIMKitGroupEvent {
  ZIMKitGroupEvent({
    required this.group,
    this.reason,
  });

  /// Group object
  final ZIMKitGroupInfo group;

  /// Event reason/type
  final ZIMKitEventReason? reason;

  @override
  String toString() {
    return 'ZIMKitGroupEvent{group:$group, reason:$reason}';
  }
}

/// Message reaction event data
///
/// Contains detailed information about message reaction events
class ZIMKitMessageReactionEvent {
  ZIMKitMessageReactionEvent({
    required this.message,
    required this.reaction,
    required this.user,
    required this.isAdded,
  });

  /// Message object
  final ZIMKitMessage message;

  /// Reaction emoji
  final String reaction;

  /// User who performed the action
  final ZIMKitUser user;

  /// Whether it's an addition (true: added, false: removed)
  final bool isAdded;

  @override
  String toString() {
    return 'ZIMKitMessageReactionEvent{'
        'message:$message, '
        'reaction:$reaction, '
        'user:$user, '
        'isAdded:$isAdded'
        '}';
  }
}

/// Media transfer progress event data
///
/// Contains detailed information about upload/download progress of media messages
class ZIMKitMediaTransferProgressEvent {
  ZIMKitMediaTransferProgressEvent({
    required this.message,
    required this.currentSize,
    required this.totalSize,
    required this.isUploading,
  });

  /// Message object
  final ZIMKitMessage message;

  /// Currently transferred size (in bytes)
  final int currentSize;

  /// Total size (in bytes)
  final int totalSize;

  /// Whether it's uploading (true: uploading, false: downloading)
  final bool isUploading;

  /// Progress percentage (0.0 - 1.0)
  double get progress => totalSize > 0 ? currentSize / totalSize : 0.0;

  @override
  String toString() {
    return 'ZIMKitMediaTransferProgressEvent{'
        'message:$message, '
        'currentSize:$currentSize, '
        'totalSize:$totalSize, '
        'progress:${(progress * 100).toStringAsFixed(1)}%, '
        'isUploading:$isUploading'
        '}';
  }
}

/// Connection state event data
///
/// Contains detailed information about connection state changes
class ZIMKitConnectionStateEvent {
  ZIMKitConnectionStateEvent({
    required this.state,
    required this.event,
    this.extendedData,
  });

  /// Connection state
  final ZIMConnectionState state;

  /// Connection event
  final ZIMConnectionEvent event;

  /// Extended data
  final Map<String, dynamic>? extendedData;

  @override
  String toString() {
    return 'ZIMKitConnectionStateEvent{'
        'state:$state, '
        'event:$event, '
        'extendedData:$extendedData'
        '}';
  }
}

/// Token expired event data
class ZIMKitTokenExpiredEvent {
  ZIMKitTokenExpiredEvent({
    required this.remainSeconds,
  });

  /// Remaining seconds
  final int remainSeconds;

  @override
  String toString() {
    return 'ZIMKitTokenExpiredEvent{remainSeconds:$remainSeconds}';
  }
}

/// Error event data
class ZIMKitErrorEvent {
  ZIMKitErrorEvent({
    required this.code,
    required this.message,
    this.method,
  });

  /// Error code
  final int code;

  /// Error message
  final String message;

  /// Name of the method that triggered the error
  final String? method;

  @override
  String toString() {
    return 'ZIMKitErrorEvent{'
        'code:$code, '
        'message:$message, '
        'method:$method'
        '}';
  }
}

/// Event reason enumeration
///
/// Used to identify the reason for an event occurrence
enum ZIMKitEventReason {
  /// Normal operation
  normal,

  /// User-initiated action
  userAction,

  /// System automatic action
  systemAction,

  /// Network issue
  networkError,

  /// Permission issue
  permissionDenied,

  /// Other reasons
  other,
}

/// Connection state enumeration (from ZIM SDK)
enum ZIMConnectionState {
  /// Not connected
  disconnected,

  /// Connecting
  connecting,

  /// Connected
  connected,

  /// Reconnecting
  reconnecting,
}

/// Connection event enumeration (from ZIM SDK)
enum ZIMConnectionEvent {
  /// Connection successful
  success,

  /// Active login
  activeLogin,

  /// Kicked out
  kickedOut,

  /// Token expired
  tokenExpired,

  /// Network temporarily interrupted
  networkInterrupted,

  /// Network disconnected
  networkDisconnected,
}
