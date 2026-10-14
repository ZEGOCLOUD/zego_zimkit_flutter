import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/components/messages/widgets/message_operation_resolver.dart';
import 'package:zego_zimkit/src/config.defines.dart';

void main() {
  test('message menu follows configured operations and sender constraints', () {
    final config = ZIMKitMessageConfig(
      textMessageConfig: ZIMKitTextMessageConfig(
        operations: const [
          ZIMKitMessageOperationName.copy,
          ZIMKitMessageOperationName.reply,
          ZIMKitMessageOperationName.revoke,
          ZIMKitMessageOperationName.reaction,
        ],
      ),
    );

    expect(
      resolveZIMKitMessageOperations(
        config: config,
        messageType: ZIMMessageType.text,
        isSentByMe: false,
      ),
      [ZIMKitMessageOperation.copy, ZIMKitMessageOperation.reply],
    );
    expect(
      shouldShowZIMKitMessageReactions(config, ZIMMessageType.text),
      isTrue,
    );
  });

  test('speaker is only available for audio messages', () {
    final config = ZIMKitMessageConfig(
      audioMessageConfig: ZIMKitAudioMessageConfig(
        operations: const [
          ZIMKitMessageOperationName.speaker,
          ZIMKitMessageOperationName.reply,
        ],
      ),
      imageMessageConfig: ZIMKitImageMessageConfig(
        operations: const [ZIMKitMessageOperationName.speaker],
      ),
    );

    expect(
      resolveZIMKitMessageOperations(
        config: config,
        messageType: ZIMMessageType.audio,
        isSentByMe: true,
      ),
      [ZIMKitMessageOperation.turnOffSpeaker, ZIMKitMessageOperation.reply],
    );
    expect(
      resolveZIMKitMessageOperations(
        config: config,
        messageType: ZIMMessageType.image,
        isSentByMe: true,
      ),
      isEmpty,
    );
  });

  test('custom and empty reaction lists are respected', () {
    expect(
      resolveZIMKitMessageReactions(
        ZIMKitMessageConfig(messageReactions: const ['🟢', '🔵']),
      ),
      ['🟢', '🔵'],
    );
    expect(
      resolveZIMKitMessageReactions(ZIMKitMessageConfig(messageReactions: [])),
      isEmpty,
    );
  });

  test('combined messages include reply and revoke by default', () {
    final operations = ZIMKitMessageConfig().getOperationsByMessageType(
      ZIMMessageType.combine,
    );

    expect(operations, contains(ZIMKitMessageOperationName.reply));
    expect(operations, contains(ZIMKitMessageOperationName.revoke));
  });
}
