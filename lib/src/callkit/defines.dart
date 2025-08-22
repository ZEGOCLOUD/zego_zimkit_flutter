import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

import 'package:zego_zimkit/src/services/defines.dart';

class ZegoZIMKitNotificationConfig {
  /// The [resource id] for notification which same as [Zego Console](https://console.zegocloud.com/)
  String? resourceID;

  ///
  bool supportOfflineMessage;

  ///
  ZegoZIMKitAndroidNotificationConfig? androidNotificationConfig;

  ///
  ZegoZIMKitIOSNotificationConfig? iosNotificationConfig;

  /// Creates a notification configuration instance
  ///
  /// [resourceID] Resource ID for notifications
  /// [supportOfflineMessage] Whether to support offline messages, defaults to true
  /// [androidNotificationConfig] Android-specific notification configuration
  /// [iosNotificationConfig] iOS-specific notification configuration
  ZegoZIMKitNotificationConfig({
    this.resourceID,
    this.supportOfflineMessage = true,
    this.androidNotificationConfig,
    this.iosNotificationConfig,
  });

  @override
  String toString() {
    return 'resource id:$resourceID, '
        'supportOfflineMessage:$supportOfflineMessage, '
        'androidNotificationConfig:$androidNotificationConfig, '
        'iosNotificationConfig:$iosNotificationConfig';
  }
}

/// android notification config
class ZegoZIMKitAndroidNotificationConfig {
  /// specify the channel id of notification
  String channelID;

  /// specify the channel name of notification
  String channelName;

  /// specify the icon file name id of notification,
  /// Additionally, you must place your icon file in the following path:
  /// ${project_root}/android/app/src/main/res/drawable/${icon}.png
  String? icon;

  /// specify the sound file name id of notification,
  /// Additionally, you must place your audio file in the following path:
  /// ${project_root}/android/app/src/main/res/raw/${sound}.mp3
  String? sound;

  bool vibrate;

  /// Whether to display a offline pop-up window.
  ///
  /// If used in conjunction with zego_uikit_prebuilt_call,
  /// zego_uikit_prebuilt_call will handle offline notifications,
  /// and in this case, it should be set to false
  bool enable;

  /// Creates an Android notification configuration instance
  ///
  /// [channelID] Notification channel ID, defaults to 'ZIM Message'
  /// [channelName] Notification channel name, defaults to 'Message'
  /// [icon] Icon file name, defaults to empty string
  /// [sound] Sound file name, defaults to empty string
  /// [vibrate] Whether to enable vibration, defaults to false
  /// [enable] Whether to enable notifications, defaults to true
  ZegoZIMKitAndroidNotificationConfig({
    this.channelID = 'ZIM Message',
    this.channelName = 'Message',
    this.icon = '',
    this.sound = '',
    this.vibrate = false,
    this.enable = true,
  });
}

/// iOS notification config
class ZegoZIMKitIOSNotificationConfig {
  /// is iOS sandbox or not
  bool? isSandboxEnvironment;

  ZegoSignalingPluginMultiCertificate certificateIndex;

  /// Creates an iOS notification configuration instance
  ///
  /// [isSandboxEnvironment] Whether running in iOS sandbox environment
  /// [certificateIndex] Certificate index for push notifications, defaults to first certificate
  ZegoZIMKitIOSNotificationConfig({
    this.isSandboxEnvironment,
    this.certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
  });

  @override
  String toString() {
    return 'isSandboxEnvironment:$isSandboxEnvironment, '
        'certificateIndex:$certificateIndex ';
  }
}

class ZegoZIMKitOfflineMessageCacheInfo {
  const ZegoZIMKitOfflineMessageCacheInfo({
    required this.conversationID,
    required this.conversationTypeIndex,
    required this.senderID,
  });

  final String conversationID;
  final int conversationTypeIndex;
  final String senderID;

  bool get valid => conversationID.isNotEmpty && senderID.isNotEmpty;

  ZIMKitConversationType get conversionType =>
      ZIMKitConversationType.values[conversationTypeIndex];

  @override
  String toString() {
    return 'id:$conversationID, '
        'type index:$conversationTypeIndex, '
        'sender id:$senderID';
  }
}
