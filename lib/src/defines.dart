import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:zego_zimkit/src/extensions/extensions.dart';

typedef ZIMKitMessageNotifier = ValueNotifier<ZIMKitMessage>;
typedef ZIMKitMessageListNotifier = ListNotifier<ZIMKitMessageNotifier>;
typedef ZIMKitConversationNotifier = ValueNotifier<ZIMKitConversation>;
typedef ZIMKitConversationListNotifier
    = ListNotifier<ZIMKitConversationNotifier>;

typedef ZIMKitConversationType = ZIMConversationType;
typedef ZIMKitMessageType = ZIMMessageType;
typedef ZIMKitGroupMemberInfo = ZIMGroupMemberInfo;
typedef ZIMKitUserFullInfo = ZIMUserFullInfo;

/// Conversation information class for ZIMKit
class ZIMKitConversation {
  /// Type of the conversation (peer or group)
  ZIMKitConversationType type = ZIMKitConversationType.peer;

  // conversation
  String id = '';
  String name = '';
  String avatarUrl = '';

  ZIMConversationNotificationStatus notificationStatus =
      ZIMConversationNotificationStatus.notify;
  int unreadMessageCount = 0;
  int orderKey = 0;
  bool disable = false;
  bool isPinned = false;
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

  ZIMKitMessageBaseInfo info = ZIMKitMessageBaseInfo();

  ZIMKitMessageImageContent? imageContent;
  ZIMKitMessageVideoContent? videoContent;
  ZIMKitMessageAudioContent? audioContent;
  ZIMKitMessageFileContent? fileContent;
  ZIMKitMessageTextContent? textContent;
  ZIMKitMessageSystemContent? systemContent;
  ZIMKitMessageCustomContent? customContent;
  ZIMKitMessageCombineContent? combineContent;
  ZIMKitMessageRevokeContent? revokeContent;
  ZIMKitMessageTipsContent? tipsContent;

  /// 回复消息信息
  ZIMKitReplyMessageInfo? replyInfo;

  ListNotifier<ZIMMessageReaction> reactions = ListNotifier([]);

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
        'combineContent:$combineContent, '
        'revokeContent:$revokeContent, '
        'tipsContent:$tipsContent, '
        'replyInfo:$replyInfo, '
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
        'conversationSeq:$messageSeq, '
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

class ZIMKitMessageTextContent {
  late String text;

  @override
  String toString() {
    return 'ZIMKitMessageTextContent{text:$text}';
  }
}

class ZIMKitMessageBaseInfo {
  int messageID = 0;
  int localMessageID = 0;
  String senderUserID = '';
  String senderUserName = ''; // Added for display purposes
  String conversationID = '';
  ZIMMessageDirection direction = ZIMMessageDirection.send;
  ZIMMessageSentStatus sentStatus = ZIMMessageSentStatus.sending;
  ZIMKitConversationType conversationType = ZIMKitConversationType.peer;
  int timestamp = 0;
  int conversationSeq = 0;
  int orderKey = 0;
  bool isUserInserted = false;
  PlatformException? error;
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

class ZIMKitMessageImageContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
  MediaTransferProgress? downloadProgress;

  // image
  String thumbnailDownloadUrl = '';
  String thumbnailLocalPath = '';
  String largeImageDownloadUrl = '';
  String largeImageLocalPath = '';
  int originalImageWidth = 0;
  int originalImageHeight = 0;
  int largeImageWidth = 0;
  int largeImageHeight = 0;
  int thumbnailWidth = 0;
  int thumbnailHeight = 0;

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

class ZIMKitMessageVideoContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
  MediaTransferProgress? downloadProgress;

  // video
  int videoDuration = 0;
  String videoFirstFrameDownloadUrl = '';
  String videoFirstFrameLocalPath = '';
  int videoFirstFrameWidth = 0;
  int videoFirstFrameHeight = 0;

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

class ZIMKitMessageAudioContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
  MediaTransferProgress? downloadProgress;

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

class ZIMKitMessageFileContent {
  late String fileLocalPath;
  String fileDownloadUrl = '';
  String fileUID = '';
  String fileName = '';
  int fileSize = 0;
  MediaTransferProgress? uploadProgress;
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

class ZIMKitMessageSystemContent {
  late String info;

  @override
  String toString() {
    return 'ZIMKitMessageSystemContent{info:$info}';
  }
}

class ZIMKitMessageCustomContent {
  late String message;
  late int type;
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

class MediaTransferProgress {
  int totalSize = 0;
  int transferredSize = 0;
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

/// Reply Message Information Class
///
/// Contains basic information of the replied message
class ZIMKitReplyMessageInfo {
  /// Original message ID
  int messageID;

  /// Original message sender ID
  String senderUserID;

  /// Original message sender name
  String senderUserName;

  /// Original message type
  ZIMKitMessageType messageType;

  /// Original message content summary (for display)
  String contentSummary;

  /// Original message object (if available)
  ZIMKitMessage? originalMessage;

  ZIMKitReplyMessageInfo({
    required this.messageID,
    required this.senderUserID,
    required this.senderUserName,
    required this.messageType,
    required this.contentSummary,
    this.originalMessage,
  });

  @override
  String toString() {
    return 'ZIMKitReplyMessageInfo{'
        'messageID:$messageID, '
        'senderUserID:$senderUserID, '
        'senderUserName:$senderUserName, '
        'messageType:$messageType, '
        'contentSummary:$contentSummary, '
        'originalMessage:${originalMessage != null ? 'exists' : 'null'}, '
        '}';
  }
}

/// Combined Message Content Class
///
/// Used for combining and forwarding multiple messages
class ZIMKitMessageCombineContent {
  /// Combined message title
  String title;

  /// Combined message summary (message list preview)
  List<String> summary;

  /// Combined message ID (for querying details)
  String combineID;

  /// Combined message list (populated after querying details)
  List<ZIMKitMessage>? messageList;

  ZIMKitMessageCombineContent({
    required this.title,
    required this.summary,
    required this.combineID,
    this.messageList,
  });

  @override
  String toString() {
    return 'ZIMKitMessageCombineContent{'
        'title:$title, '
        'summary:$summary, '
        'combineID:$combineID, '
        'messageList count:${messageList?.length ?? 0}, '
        '}';
  }
}

/// Revoked Message Content Class
///
/// Contains relevant information about message revocation
class ZIMKitMessageRevokeContent {
  /// Revoker ID
  String operatorID;

  /// Revoker name
  String operatorName;

  /// Revocation timestamp
  int revokeTimestamp;

  /// Original message type
  ZIMKitMessageType originalType;

  /// Whether re-editing is allowed (revoked within 2 minutes)
  bool canReEdit;

  ZIMKitMessageRevokeContent({
    required this.operatorID,
    required this.operatorName,
    required this.revokeTimestamp,
    required this.originalType,
    this.canReEdit = false,
  });

  @override
  String toString() {
    return 'ZIMKitMessageRevokeContent{'
        'operatorID:$operatorID, '
        'operatorName:$operatorName, '
        'revokeTimestamp:$revokeTimestamp, '
        'originalType:$originalType, '
        'canReEdit:$canReEdit, '
        '}';
  }
}

/// Tips Message Content Class
///
/// Used to display system prompts, such as group announcements, joining/leaving groups, etc.
class ZIMKitMessageTipsContent {
  /// Tips type
  ZIMKitTipsType type;

  /// Tips text content
  String content;

  /// Extended information
  Map<String, dynamic>? extendedData;

  ZIMKitMessageTipsContent({
    required this.type,
    required this.content,
    this.extendedData,
  });

  @override
  String toString() {
    return 'ZIMKitMessageTipsContent{'
        'type:$type, '
        'content:$content, '
        'extendedData:$extendedData, '
        '}';
  }
}

/// Tips message type enumeration
enum ZIMKitTipsType {
  /// Group announcement
  groupNotice,

  /// User joined the group
  memberJoined,

  /// User left the group
  memberLeft,

  /// User was kicked out of the group
  memberKicked,

  /// Group information changed
  groupInfoChanged,

  /// Other tips
  other,
}

/// User Information Class
class ZIMKitUser {
  /// User ID
  String id;

  /// User name
  String name;

  /// User avatar URL
  String avatarUrl;

  ZIMKitUser({
    required this.id,
    this.name = '',
    this.avatarUrl = '',
  });

  @override
  String toString() {
    return 'ZIMKitUser{id:$id, name:$name, avatarUrl:$avatarUrl}';
  }
}

/// file picker typedefs
typedef ZIMKitFileType = FileType;
typedef ZIMKitPlatformFile = PlatformFile;
