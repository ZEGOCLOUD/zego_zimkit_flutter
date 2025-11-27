import 'package:zego_zimkit/src/components/messages/input/events.dart';
import 'package:zego_zimkit/src/components/messages/list/events.dart';
import 'package:zego_zimkit/src/components/audio/events.dart';

/// Events class for ZIMKitMessageListPage (extends the existing one)
class ZIMKitMessageListPageEvents {
  const ZIMKitMessageListPageEvents({
    this.audioRecord,
    this.messageInput,
    this.messageList,
  });

  final ZIMKitAudioRecordEvents? audioRecord;
  final ZIMKitMessageInputEvents? messageInput;
  final ZIMKitMessageListEvents? messageList;
}
