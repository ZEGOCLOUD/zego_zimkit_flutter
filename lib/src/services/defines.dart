import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:zego_zimkit/src/services/extensions/extensions.dart';

typedef ZIMKitMessageNotifier = ValueNotifier<ZIMKitMessage>;
typedef ZIMKitMessageListNotifier = ListNotifier<ZIMKitMessageNotifier>;
typedef ZIMKitConversationNotifier = ValueNotifier<ZIMKitConversation>;
typedef ZIMKitConversationListNotifier =
    ListNotifier<ZIMKitConversationNotifier>;

typedef ZIMKitConversationType = ZIMConversationType;
typedef ZIMKitMessageType = ZIMMessageType;
typedef ZIMKitGroupMemberInfo = ZIMGroupMemberInfo;
typedef ZIMKitUserFullInfo = ZIMUserFullInfo;

/// Conversation information class for ZIMKit
class ZIMKitConversation {
  /// Type of the conversation (peer or group)
  ZIMKitConversationType type = ZIMKitConversationType.peer;

  /// Unique identifier associated with this conversation.
  String id = '';

  /// Display name shown for this conversation.
  String name = '';

  /// Avatar URL shown for this conversation.
  String avatarUrl = '';

  /// Whether new messages should trigger notifications.
  ZIMConversationNotificationStatus notificationStatus =
      ZIMConversationNotificationStatus.notify;

  /// Number of unread messages in this conversation.
  int unreadMessageCount = 0;

  /// Ordering key used to place this conversation in the list.
  int orderKey = 0;

  /// Whether this conversation is disabled in ZIMKit.
  bool disable = false;

  /// Most recent message, or `null` when the conversation has no messages.
  ZIMKitMessage? lastMessage;
}

/// Group information class for ZIMKit
class ZIMKitGroupInfo {
  /// Group notice text
  String notice = "";

  /// Group attributes map
  Map<String, String> attributes = {};

  /// Current group state
  ZIMGroupState state = ZIMGroupState.enter;

  /// Current group event
  ZIMGroupEvent event = ZIMGroupEvent.created;
}

/// Message class for ZIMKit
class ZIMKitMessage {
  /// Type of the message
  ZIMKitMessageType type = ZIMKitMessageType.unknown;

  /// IDs, delivery state, and conversation metadata for this message.
  ZIMKitMessageBaseInfo info = ZIMKitMessageBaseInfo();

  /// Image attachment details when [type] is an image message.
  ZIMKitMessageImageContent? imageContent;

  /// Video attachment details when [type] is a video message.
  ZIMKitMessageVideoContent? videoContent;

  /// Audio attachment details when [type] is an audio message.
  ZIMKitMessageAudioContent? audioContent;

  /// File attachment details when [type] is a file message.
  ZIMKitMessageFileContent? fileContent;

  /// Text payload when [type] is a text message.
  ZIMKitMessageTextContent? textContent;

  /// Legacy system message details when provided by the SDK.
  ZIMKitMessageSystemContent? systemContent;

  /// Custom message details when [type] is a custom message.
  ZIMKitMessageCustomContent? customContent;

  /// Reactions attached to this message.
  ListNotifier<ZIMMessageReaction> reactions = ListNotifier([]);

  /// App-specific data stored locally with this message.
  ValueNotifier<String> localExtendedData = ValueNotifier('');

  Map zimkitExtraInfo = {}; // ZIMKit Internal Use Only.
  ZIMMessage zim = ZIMMessage(); // ZIMKit Internal Use Only.

  @override
  String toString() {
    return 'ZIMKitMessage{'
        'type:$type, '
        'info:$info, '
        'imageContent:$imageContent, '
        'videoContent:$videoContent, '
        'audioContent:$audioContent, '
        'fileContent:$fileContent, '
        'textContent:$textContent, '
        'systemContent:$systemContent, '
        'customContent:$customContent, '
        'reactions:$reactions, '
        'localExtendedData:$localExtendedData, '
        'zimkitExtraInfo:$zimkitExtraInfo, '
        'zim:${zim.toStringX()}, '
        '}';
  }
}

extension ZIMMessageExtensionString on ZIMMessage {
  String toStringX() {
    return 'ZIMMessage{'
        'type:$type, '
        'messageID:$messageID, '
        'localMessageID:$localMessageID, '
        'senderUserID:$senderUserID, '
        'conversationID:$conversationID, '
        'direction:$direction, '
        'sentStatus:$sentStatus, '
        'conversationType:$conversationType, '
        'timestamp:$timestamp, '
        'messageSeq:$messageSeq, '
        'orderKey:$orderKey, '
        'isUserInserted:$isUserInserted, '
        'receiptStatus:$receiptStatus, '
        'extendedData:$extendedData, '
        'localExtendedData:$localExtendedData, '
        'isBroadcastMessage:$isBroadcastMessage, '
        'reactions:$reactions, '
        '}';
  }
}

/// Text payload for a text message.
class ZIMKitMessageTextContent {
  /// Text sent in the message.
  late String text;

  @override
  String toString() {
    return 'ZIMKitMessageTextContent{text:$text}';
  }
}

/// Common identifiers, status, and timestamps for a message.
class ZIMKitMessageBaseInfo {
  /// Server-assigned ID of the message.
  int messageID = 0;

  /// Local ID assigned before the message is sent.
  int localMessageID = 0;

  /// ID of the user who sent the message.
  String senderUserID = '';

  /// ID of the conversation containing this message.
  String conversationID = '';

  /// Whether this message was sent or received by the current user.
  ZIMMessageDirection direction = ZIMMessageDirection.send;

  /// Current sending status of the message.
  ZIMMessageSentStatus sentStatus = ZIMMessageSentStatus.sending;

  /// Type of the conversation containing the message.
  ZIMKitConversationType conversationType = ZIMKitConversationType.peer;

  /// Message timestamp in milliseconds since the Unix epoch.
  int timestamp = 0;

  /// Sequence number of the message within its conversation.
  int conversationSeq = 0;

  /// Ordering key assigned to the message.
  int orderKey = 0;

  /// Whether the message was inserted by the local user.
  bool isUserInserted = false;

  /// Platform error returned when sending the message fails.
  PlatformException? error;

  /// Receipt state of the message.
  ZIMMessageReceiptStatus receiptStatus = ZIMMessageReceiptStatus.none;

  @override
  String toString() {
    return 'ZIMKitMessageBaseInfo{'
        'messageID:$messageID, '
        'localMessageID:$localMessageID, '
        'senderUserID:$senderUserID, '
        'conversationID:$conversationID, '
        'direction:$direction, '
        'sentStatus:$sentStatus, '
        'conversationType:$conversationType, '
        'timestamp:$timestamp, '
        'conversationSeq:$conversationSeq, '
        'orderKey:$orderKey, '
        'isUserInserted:$isUserInserted, '
        'error:$error, '
        'receiptStatus:$receiptStatus, '
        '}';
  }
}

/// Local and remote image attachment details.
class ZIMKitMessageImageContent {
  /// Local path of this image attachment, when available.
  late String fileLocalPath;

  /// Download URL of the original image.
  String fileDownloadUrl = '';

  /// File identifier assigned by the server.
  String fileUID = '';

  /// Name of the image file.
  String fileName = '';

  /// Size of the image file in bytes.
  int fileSize = 0;

  /// Upload progress while sending this image, when available.
  MediaTransferProgress? uploadProgress;

  /// Download progress while receiving this image, when available.
  MediaTransferProgress? downloadProgress;

  /// Download URL of the thumbnail image.
  String thumbnailDownloadUrl = '';

  /// Local path of the thumbnail image.
  String thumbnailLocalPath = '';

  /// Download URL of the large image variant.
  String largeImageDownloadUrl = '';

  /// Local path of the large image variant.
  String largeImageLocalPath = '';

  /// Width of the original image in pixels.
  int originalImageWidth = 0;

  /// Height of the original image in pixels.
  int originalImageHeight = 0;

  /// Width of the large image variant in pixels.
  int largeImageWidth = 0;

  /// Height of the large image variant in pixels.
  int largeImageHeight = 0;

  /// Width of the thumbnail image in pixels.
  int thumbnailWidth = 0;

  /// Height of the thumbnail image in pixels.
  int thumbnailHeight = 0;

  /// Aspect ratio of the original image, or `1.0` when its dimensions are unset.
  double get aspectRatio => (originalImageWidth / originalImageHeight) > 0
      ? (originalImageWidth / originalImageHeight)
      : 1.0;

  @override
  String toString() {
    return 'ZIMKitMessageImageContent{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        'thumbnailDownloadUrl:$thumbnailDownloadUrl, '
        'thumbnailLocalPath:$thumbnailLocalPath, '
        'largeImageDownloadUrl:$largeImageDownloadUrl, '
        'largeImageLocalPath:$largeImageLocalPath, '
        'originalImageWidth:$originalImageWidth, '
        'originalImageHeight:$originalImageHeight, '
        'largeImageWidth:$largeImageWidth, '
        'largeImageHeight:$largeImageHeight, '
        'thumbnailWidth:$thumbnailWidth, '
        'thumbnailHeight:$thumbnailHeight, '
        '}';
  }
}

/// Local and remote video attachment details.
class ZIMKitMessageVideoContent {
  /// Local path of this video attachment, when available.
  late String fileLocalPath;

  /// Download URL of the video file.
  String fileDownloadUrl = '';

  /// File identifier assigned by the server.
  String fileUID = '';

  /// Name of the video file.
  String fileName = '';

  /// Size of the video file in bytes.
  int fileSize = 0;

  /// Upload progress while sending this video, when available.
  MediaTransferProgress? uploadProgress;

  /// Download progress while receiving this video, when available.
  MediaTransferProgress? downloadProgress;

  /// Duration of the video as reported by the ZIM SDK.
  int videoDuration = 0;

  /// Download URL of the video's first-frame image.
  String videoFirstFrameDownloadUrl = '';

  /// Local path of the video's first-frame image.
  String videoFirstFrameLocalPath = '';

  /// Width of the video's first frame in pixels.
  int videoFirstFrameWidth = 0;

  /// Height of the video's first frame in pixels.
  int videoFirstFrameHeight = 0;

  /// Aspect ratio of the first frame, or `1.0` when its dimensions are unset.
  double get aspectRatio => (videoFirstFrameWidth / videoFirstFrameHeight) > 0
      ? (videoFirstFrameWidth / videoFirstFrameHeight)
      : 1.0;

  @override
  String toString() {
    return 'ZIMKitMessageVideoContent{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        'videoDuration:$videoDuration, '
        'videoFirstFrameDownloadUrl:$videoFirstFrameDownloadUrl, '
        'videoFirstFrameLocalPath:$videoFirstFrameLocalPath, '
        'videoFirstFrameWidth:$videoFirstFrameWidth, '
        'videoFirstFrameHeight:$videoFirstFrameHeight, '
        '}';
  }
}

/// Local and remote audio attachment details.
class ZIMKitMessageAudioContent {
  /// Local path of this audio attachment, when available.
  late String fileLocalPath;

  /// Download URL of the audio file.
  String fileDownloadUrl = '';

  /// File identifier assigned by the server.
  String fileUID = '';

  /// Name of the audio file.
  String fileName = '';

  /// Size of the audio file in bytes.
  int fileSize = 0;

  /// Upload progress while sending this audio file, when available.
  MediaTransferProgress? uploadProgress;

  /// Download progress while receiving this audio file, when available.
  MediaTransferProgress? downloadProgress;

  /// Duration of the audio clip as reported by the ZIM SDK.
  int audioDuration = 0;

  @override
  String toString() {
    return 'ZIMKitMessageAudioContent:{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        '}';
  }
}

/// Local and remote file attachment details.
class ZIMKitMessageFileContent {
  /// Local path of this file attachment, when available.
  late String fileLocalPath;

  /// Download URL of the file.
  String fileDownloadUrl = '';

  /// File identifier assigned by the server.
  String fileUID = '';

  /// Name of the file.
  String fileName = '';

  /// Size of the file in bytes.
  int fileSize = 0;

  /// Upload progress while sending this file, when available.
  MediaTransferProgress? uploadProgress;

  /// Download progress while receiving this file, when available.
  MediaTransferProgress? downloadProgress;

  @override
  String toString() {
    return 'ZIMKitMessageFileContent{'
        'fileLocalPath:$fileLocalPath, '
        'fileDownloadUrl:$fileDownloadUrl, '
        'fileUID:$fileUID, '
        'fileName:$fileName, '
        'fileSize:$fileSize, '
        'uploadProgress:$uploadProgress, '
        'downloadProgress:$downloadProgress, '
        '}';
  }
}

/// Content of a system message.
class ZIMKitMessageSystemContent {
  /// Human-readable system message text.
  late String info;

  @override
  String toString() {
    return 'ZIMKitMessageSystemContent{info:$info}';
  }
}

/// Content of a custom message.
class ZIMKitMessageCustomContent {
  /// Serialized custom message payload.
  late String message;

  /// Application-defined type identifier for the custom message.
  late int type;

  /// Text indexed for searching this custom message.
  late String searchedContent;

  @override
  String toString() {
    return 'ZIMKitMessageCustomContent{'
        'message:$message, '
        'type:$type, '
        'searchedContent:$searchedContent, '
        '}';
  }
}

/// Byte counts describing a media upload or download.
class MediaTransferProgress {
  /// Total media size in bytes.
  int totalSize = 0;

  /// Number of bytes already transferred.
  int transferredSize = 0;

  /// Fraction of the transfer completed, from `0.0` to `1.0`.
  double get progress => totalSize == 0 ? 0 : transferredSize / totalSize;

  @override
  String toString() {
    return 'MediaTransferProgress{'
        'totalSize:$totalSize, '
        'transferredSize:$transferredSize, '
        '}';
  }
}

class ZIMKitInvitationProtocolKey {
  static String operationType = 'operation_type';
}

/// file picker typedefs
typedef ZIMKitFileType = FileType;
typedef ZIMKitPlatformFile = PlatformFile;
