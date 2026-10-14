import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/config.defines.dart';

enum ZIMKitMessageOperation {
  copy,
  reply,
  forward,
  select,
  delete,
  revoke,
  turnOffSpeaker,
}

List<ZIMKitMessageOperation> resolveZIMKitMessageOperations({
  required ZIMKitMessageConfig config,
  required ZIMMessageType messageType,
  required bool isSentByMe,
}) {
  final operations = config.getOperationsByMessageType(messageType);
  final resolved = <ZIMKitMessageOperation>[];

  for (final operation in operations) {
    final ZIMKitMessageOperation? action = switch (operation) {
      ZIMKitMessageOperationName.copy =>
        messageType == ZIMMessageType.text ? ZIMKitMessageOperation.copy : null,
      ZIMKitMessageOperationName.reply => ZIMKitMessageOperation.reply,
      ZIMKitMessageOperationName.forward => ZIMKitMessageOperation.forward,
      ZIMKitMessageOperationName.multipleChoice =>
        ZIMKitMessageOperation.select,
      ZIMKitMessageOperationName.delete => ZIMKitMessageOperation.delete,
      ZIMKitMessageOperationName.revoke =>
        isSentByMe ? ZIMKitMessageOperation.revoke : null,
      ZIMKitMessageOperationName.speaker =>
        messageType == ZIMMessageType.audio
            ? ZIMKitMessageOperation.turnOffSpeaker
            : null,
      ZIMKitMessageOperationName.reaction => null,
    };

    if (action != null && !resolved.contains(action)) {
      resolved.add(action);
    }
  }

  return resolved;
}

bool shouldShowZIMKitMessageReactions(
  ZIMKitMessageConfig config,
  ZIMMessageType messageType,
) {
  return config
          .getOperationsByMessageType(messageType)
          .contains(ZIMKitMessageOperationName.reaction) &&
      (config.messageReactions?.isNotEmpty ?? true);
}

List<String> resolveZIMKitMessageReactions(ZIMKitMessageConfig config) {
  return config.messageReactions ??
      const ['❤️', '👍', '👎', '😄', '😢', '😮', '😡'];
}
