import 'package:zego_zimkit/src/defines.dart';

class ZIMKitMessageListMultiModeData {
  bool isMultiMode;
  ZIMKitMessage? initialMessage;

  ZIMKitMessageListMultiModeData({
    required this.isMultiMode,
    this.initialMessage,
  });
}
