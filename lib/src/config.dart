import 'package:zego_zimkit/src/callkit/defines.dart';
import 'package:zego_zimkit/src/config.defines.dart';
import 'package:zego_zimkit/src/inner_text.dart';

/// ZIMKit Configuration Class
///
/// Used to configure various functions of ZIMKit, including input box, messages, conversations, etc.
///
/// Example:
/// ```dart
/// final config = ZIMKitConfig(
///   inputConfig: ZIMKitInputConfig(
///     smallButtons: [
///       ZIMKitInputButtonName.audio,
///       ZIMKitInputButtonName.emoji,
///       ZIMKitInputButtonName.picture,
///       ZIMKitInputButtonName.expand,
///     ],
///   ),
///   messageConfig: ZIMKitMessageConfig(
///     textMessageConfig: ZIMKitTextMessageConfig(
///       operations: [
///         ZIMKitMessageOperationName.copy,
///         ZIMKitMessageOperationName.reply,
///         ZIMKitMessageOperationName.forward,
///       ],
///     ),
///   ),
/// );
/// ```
class ZIMKitConfig {
  ZIMKitConfig({
    ZIMKitInputConfig? inputConfig,
    ZIMKitMessageConfig? messageConfig,
    ZIMKitConversationConfig? conversationConfig,
    ZIMKitInnerText? innerText,
    this.notificationConfig,
    this.advancedConfig,
  })  : inputConfig = inputConfig ?? ZIMKitInputConfig(),
        messageConfig = messageConfig ?? ZIMKitMessageConfig(),
        conversationConfig = conversationConfig ?? ZIMKitConversationConfig(),
        innerText = innerText ?? ZIMKitInnerText();

  /// Input box configuration
  final ZIMKitInputConfig inputConfig;

  /// Message configuration
  final ZIMKitMessageConfig messageConfig;

  /// Conversation configuration
  final ZIMKitConversationConfig conversationConfig;

  /// Internal text configuration
  ///
  /// Used to configure internationalization of all UI texts
  final ZIMKitInnerText innerText;

  /// Push notification configuration
  ///
  /// Used to configure offline push notifications
  final ZegoZIMKitNotificationConfig? notificationConfig;

  /// Advanced configuration
  ///
  /// Used to pass advanced configuration options to the underlying SDK
  final Map<String, dynamic>? advancedConfig;

  /// Default configuration
  ///
  /// Provides a configuration containing all default values
  factory ZIMKitConfig.defaultConfig() {
    return ZIMKitConfig();
  }

  @override
  String toString() {
    return 'ZIMKitConfig{'
        'inputConfig:$inputConfig, '
        'messageConfig:$messageConfig, '
        'conversationConfig:$conversationConfig, '
        'innerText:$innerText, '
        'notificationConfig:$notificationConfig, '
        'advancedConfig:$advancedConfig, '
        '}';
  }
}
