import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

class ZIMKitMessageListMultiModeData {
  bool isMultiMode;
  ZIMKitMessage? initialMessage;

  ZIMKitMessageListMultiModeData({
    required this.isMultiMode,
    this.initialMessage,
  });
}
