import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

/// Input Box Button Type
///
/// Used to configure the buttons displayed at the bottom of the input box and in the expansion panel
enum ZIMKitInputButtonName {
  /// Voice button
  audio,

  /// Emoji button
  emoji,

  /// Picture button
  picture,

  /// Take photo button
  takePhoto,

  /// Voice call button
  voiceCall,

  /// Video call button
  videoCall,

  /// File button
  file,

  /// More button (expand the expansion panel)
  expand,
}

/// Message Operation Type
///
/// Used to configure the operation menu items displayed when long-pressing a message
enum ZIMKitMessageOperationName {
  /// Copy message (text messages only)
  copy,

  /// Reply to message
  reply,

  /// Forward message
  forward,

  /// Revoke message
  revoke,

  /// Delete message
  delete,

  /// Multiple selection mode
  multipleChoice,

  /// Emoji reaction
  reaction,

  /// Speaker mode (audio messages)
  speaker,
}

/// Message Forward Type
enum ZIMKitForwardType {
  /// Forward single message
  single,

  /// Forward multiple messages one by one
  oneByOne,

  /// Merge multiple messages and forward
  merge,
}

/// Input Box Configuration
///
/// Used to configure input box buttons, emojis, etc.
class ZIMKitInputConfig {
  ZIMKitInputConfig({
    List<ZIMKitInputButtonName>? smallButtons,
    List<ZIMKitInputButtonName>? expandButtons,
    List<String>? emojis,
    this.maxSmallButtonCount = 4,
    this.placeholder,
    this.customButtonBuilders,
  })  : smallButtons = smallButtons ??
            const [
              ZIMKitInputButtonName.audio,
              ZIMKitInputButtonName.emoji,
              ZIMKitInputButtonName.picture,
              ZIMKitInputButtonName.expand,
            ],
        expandButtons = expandButtons ??
            const [
              ZIMKitInputButtonName.takePhoto,
              ZIMKitInputButtonName.file,
            ];

  /// List of small buttons displayed at the bottom
  final List<ZIMKitInputButtonName> smallButtons;

  /// List of buttons displayed in the expansion panel
  final List<ZIMKitInputButtonName> expandButtons;

  /// Maximum number of buttons at the bottom
  final int maxSmallButtonCount;

  /// Input box placeholder
  final String? placeholder;

  /// Custom button builders
  final Map<ZIMKitInputButtonName, Widget Function(BuildContext)>?
      customButtonBuilders;

  @override
  String toString() {
    return 'ZIMKitInputConfig{'
        'smallButtons:$smallButtons, '
        'expandButtons:$expandButtons, '
        'maxSmallButtonCount:$maxSmallButtonCount, '
        'placeholder:$placeholder, '
        'customButtonBuilders:$customButtonBuilders, '
        '}';
  }
}

/// Text Message Configuration
class ZIMKitTextMessageConfig {
  ZIMKitTextMessageConfig({
    List<ZIMKitMessageOperationName>? operations,
  }) : operations = operations ??
            const [
              ZIMKitMessageOperationName.copy,
              ZIMKitMessageOperationName.reply,
              ZIMKitMessageOperationName.forward,
              ZIMKitMessageOperationName.multipleChoice,
              ZIMKitMessageOperationName.delete,
              ZIMKitMessageOperationName.revoke,
              ZIMKitMessageOperationName.reaction,
            ];

  /// Supported operations list
  final List<ZIMKitMessageOperationName> operations;

  @override
  String toString() {
    return 'ZIMKitTextMessageConfig{operations:$operations}';
  }
}

/// Image Message Configuration
class ZIMKitImageMessageConfig {
  ZIMKitImageMessageConfig({
    List<ZIMKitMessageOperationName>? operations,
  }) : operations = operations ??
            const [
              ZIMKitMessageOperationName.reply,
              ZIMKitMessageOperationName.forward,
              ZIMKitMessageOperationName.multipleChoice,
              ZIMKitMessageOperationName.delete,
              ZIMKitMessageOperationName.revoke,
              ZIMKitMessageOperationName.reaction,
            ];

  /// Supported operations list
  final List<ZIMKitMessageOperationName> operations;

  @override
  String toString() {
    return 'ZIMKitImageMessageConfig{operations:$operations}';
  }
}

/// Audio Message Configuration
class ZIMKitAudioMessageConfig {
  ZIMKitAudioMessageConfig({
    List<ZIMKitMessageOperationName>? operations,
  }) : operations = operations ??
            const [
              ZIMKitMessageOperationName.speaker,
              ZIMKitMessageOperationName.reply,
              ZIMKitMessageOperationName.forward,
              ZIMKitMessageOperationName.multipleChoice,
              ZIMKitMessageOperationName.delete,
              ZIMKitMessageOperationName.revoke,
              ZIMKitMessageOperationName.reaction,
            ];

  /// Supported operations list
  final List<ZIMKitMessageOperationName> operations;

  @override
  String toString() {
    return 'ZIMKitAudioMessageConfig{operations:$operations}';
  }
}

/// Video Message Configuration
class ZIMKitVideoMessageConfig {
  ZIMKitVideoMessageConfig({
    List<ZIMKitMessageOperationName>? operations,
  }) : operations = operations ??
            const [
              ZIMKitMessageOperationName.reply,
              ZIMKitMessageOperationName.forward,
              ZIMKitMessageOperationName.multipleChoice,
              ZIMKitMessageOperationName.delete,
              ZIMKitMessageOperationName.revoke,
              ZIMKitMessageOperationName.reaction,
            ];

  /// Supported operations list
  final List<ZIMKitMessageOperationName> operations;

  @override
  String toString() {
    return 'ZIMKitVideoMessageConfig{operations:$operations}';
  }
}

/// File Message Configuration
class ZIMKitFileMessageConfig {
  ZIMKitFileMessageConfig({
    List<ZIMKitMessageOperationName>? operations,
  }) : operations = operations ??
            const [
              ZIMKitMessageOperationName.reply,
              ZIMKitMessageOperationName.forward,
              ZIMKitMessageOperationName.multipleChoice,
              ZIMKitMessageOperationName.delete,
              ZIMKitMessageOperationName.revoke,
              ZIMKitMessageOperationName.reaction,
            ];

  /// Supported operations list
  final List<ZIMKitMessageOperationName> operations;

  @override
  String toString() {
    return 'ZIMKitFileMessageConfig{operations:$operations}';
  }
}

/// Combine Message Configuration
class ZIMKitCombineMessageConfig {
  ZIMKitCombineMessageConfig({
    List<ZIMKitMessageOperationName>? operations,
  }) : operations = operations ??
            const [
              ZIMKitMessageOperationName.forward,
              ZIMKitMessageOperationName.multipleChoice,
              ZIMKitMessageOperationName.delete,
              ZIMKitMessageOperationName.reaction,
            ];

  /// Supported operations list
  final List<ZIMKitMessageOperationName> operations;

  @override
  String toString() {
    return 'ZIMKitCombineMessageConfig{operations:$operations}';
  }
}

/// Message Configuration
///
/// Used to configure operation items and message reactions for various message types
class ZIMKitMessageConfig {
  ZIMKitMessageConfig({
    ZIMKitTextMessageConfig? textMessageConfig,
    ZIMKitImageMessageConfig? imageMessageConfig,
    ZIMKitAudioMessageConfig? audioMessageConfig,
    ZIMKitVideoMessageConfig? videoMessageConfig,
    ZIMKitFileMessageConfig? fileMessageConfig,
    ZIMKitCombineMessageConfig? combineMessageConfig,
    List<String>? messageReactions,
  })  : textMessageConfig = textMessageConfig ?? ZIMKitTextMessageConfig(),
        imageMessageConfig = imageMessageConfig ?? ZIMKitImageMessageConfig(),
        audioMessageConfig = audioMessageConfig ?? ZIMKitAudioMessageConfig(),
        videoMessageConfig = videoMessageConfig ?? ZIMKitVideoMessageConfig(),
        fileMessageConfig = fileMessageConfig ?? ZIMKitFileMessageConfig(),
        combineMessageConfig =
            combineMessageConfig ?? ZIMKitCombineMessageConfig();

  /// Text message configuration
  final ZIMKitTextMessageConfig textMessageConfig;

  /// Image message configuration
  final ZIMKitImageMessageConfig imageMessageConfig;

  /// Audio message configuration
  final ZIMKitAudioMessageConfig audioMessageConfig;

  /// Video message configuration
  final ZIMKitVideoMessageConfig videoMessageConfig;

  /// File message configuration
  final ZIMKitFileMessageConfig fileMessageConfig;

  /// Combine message configuration
  final ZIMKitCombineMessageConfig combineMessageConfig;

  /// Get operations list by message type
  List<ZIMKitMessageOperationName> getOperationsByMessageType(
      ZIMMessageType type) {
    switch (type) {
      case ZIMMessageType.text:
        return textMessageConfig.operations;
      case ZIMMessageType.image:
        return imageMessageConfig.operations;
      case ZIMMessageType.audio:
        return audioMessageConfig.operations;
      case ZIMMessageType.video:
        return videoMessageConfig.operations;
      case ZIMMessageType.file:
        return fileMessageConfig.operations;
      case ZIMMessageType.combine:
        return combineMessageConfig.operations;
      default:
        return [];
    }
  }

  @override
  String toString() {
    return 'ZIMKitMessageConfig{'
        'textMessageConfig:$textMessageConfig, '
        'imageMessageConfig:$imageMessageConfig, '
        'audioMessageConfig:$audioMessageConfig, '
        'videoMessageConfig:$videoMessageConfig, '
        'fileMessageConfig:$fileMessageConfig, '
        'combineMessageConfig:$combineMessageConfig, '
        '}';
  }
}

/// Conversation Configuration
class ZIMKitConversationConfig {
  ZIMKitConversationConfig({
    this.showPinned = true,
    this.showNotificationStatus = true,
  });

  /// Whether to show the pinned indicator
  final bool showPinned;

  /// Whether to show the do-not-disturb indicator
  final bool showNotificationStatus;

  @override
  String toString() {
    return 'ZIMKitConversationConfig{'
        'showPinned:$showPinned, '
        'showNotificationStatus:$showNotificationStatus, '
        '}';
  }
}
