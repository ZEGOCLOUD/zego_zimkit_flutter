import 'package:flutter/material.dart';
import 'package:zego_zimkit/src/utils/screen_util/core/size_extension.dart';

/// ZIMKit 消息样式统一配置
///
/// 包含所有消息相关的颜色、字体、尺寸等样式定义
class ZIMKitMessageStyle {
  /// Default height of message items in pixels
  /// Updated to 140 to accommodate two-row input layout
  static double get inputHeight => 140.zH;

  // ==================== Colors ====================

  /// 消息列表背景色
  static const Color messageListBackgroundColor = Color(0xFFF5F6F7);

  /// 发送消息气泡背景色（使用主题色）
  static Color sentMessageBubbleColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  /// 接收消息气泡背景色
  static const Color receivedMessageBubbleColor = Colors.white;

  /// 接收消息气泡阴影颜色
  static final Color receivedMessageBubbleShadowColor =
      Colors.black.withValues(alpha: 0.05);

  /// 发送消息文本颜色
  static const Color sentMessageTextColor = Colors.white;

  /// 接收消息文本颜色（使用主题默认）
  static Color receivedMessageTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  /// 时间戳文本颜色
  static const Color timestampTextColor = Colors.grey;

  /// Reaction 背景色 - 发送消息
  static final Color sentReactionBackgroundColor =
      Colors.white.withValues(alpha: 0.2);

  /// Reaction 背景色 - 接收消息
  static const Color receivedReactionBackgroundColor = Color(0xFFEFF0F2);

  /// Reaction 分隔线颜色 - 发送消息
  static final Color sentReactionDividerColor =
      Colors.white.withValues(alpha: 0.2);

  /// Reaction 分隔线颜色 - 接收消息
  static const Color receivedReactionDividerColor = Color(0xFFCACBCE);

  /// Reaction 文本颜色 - 发送消息
  static final Color sentReactionTextColor =
      Colors.white.withValues(alpha: 0.7);

  /// Reaction 文本颜色 - 接收消息
  static const Color receivedReactionTextColor = Color(0xFF646A73);

  // ==================== Font Sizes ====================

  /// 消息内容文本大小（使用主题默认）
  static double? messageTextSize(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.fontSize;
  }

  /// 时间戳文本大小
  static const double timestampTextSize = 12.0;

  /// Reaction emoji 大小
  static const double reactionEmojiSize = 14.0;

  /// Reaction 用户名文本大小
  static const double reactionUserNameSize = 12.0;

  // ==================== Dimensions ====================

  /// 消息气泡圆角半径
  static const double messageBubbleRadius = 10.0;

  /// 消息气泡水平内边距
  static const double messageBubblePaddingHorizontal = 15.0;

  /// 消息气泡垂直内边距
  static const double messageBubblePaddingVertical = 10.0;

  /// Reaction chip 圆角半径
  static const double reactionChipRadius = 12.0;

  /// Reaction chip 水平内边距
  static const double reactionChipPaddingHorizontal = 8.0;

  /// Reaction chip 垂直内边距
  static const double reactionChipPaddingVertical = 4.0;

  /// Reaction 顶部间距
  static const double reactionTopMargin = 6.0;

  /// Reaction 之间的间距
  static const double reactionSpacing = 6.0;

  /// 消息气泡阴影模糊半径
  static const double messageBubbleShadowBlur = 4.0;

  /// 消息气泡阴影偏移
  static const Offset messageBubbleShadowOffset = Offset(0, 1);

  // ==================== Helper Methods ====================

  /// 获取接收消息气泡阴影
  static List<BoxShadow> getReceivedMessageBubbleShadow() {
    return [
      BoxShadow(
        color: receivedMessageBubbleShadowColor,
        blurRadius: messageBubbleShadowBlur,
        offset: messageBubbleShadowOffset,
      ),
    ];
  }

  /// 获取 Reaction 背景色
  static Color getReactionBackgroundColor(bool isMine) {
    return isMine
        ? sentReactionBackgroundColor
        : receivedReactionBackgroundColor;
  }

  /// 获取 Reaction 分隔线颜色
  static Color getReactionDividerColor(bool isMine) {
    return isMine ? sentReactionDividerColor : receivedReactionDividerColor;
  }

  /// 获取 Reaction 文本颜色
  static Color getReactionTextColor(bool isMine) {
    return isMine ? sentReactionTextColor : receivedReactionTextColor;
  }
}
