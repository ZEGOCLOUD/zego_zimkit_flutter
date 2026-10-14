import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/components/messages/input/config_resolver.dart';
import 'package:zego_zimkit/src/components/messages/input/configs.dart';
import 'package:zego_zimkit/src/config.defines.dart';

void main() {
  test('keeps configured inline order and moves overflow into more panel', () {
    final result = resolveZIMKitInputButtons(
      globalConfig: ZIMKitInputConfig(
        smallButtons: [
          ZIMKitInputButtonName.audio,
          ZIMKitInputButtonName.emoji,
          ZIMKitInputButtonName.picture,
          ZIMKitInputButtonName.voiceCall,
        ],
        expandButtons: [ZIMKitInputButtonName.file],
        maxSmallButtonCount: 2,
      ),
      pageConfig: const ZIMKitMessageInputConfigs(),
    );

    expect(result.smallButtons, [
      ZIMKitInputButtonName.audio,
      ZIMKitInputButtonName.expand,
    ]);
    expect(result.expandButtons, [
      ZIMKitInputButtonName.file,
      ZIMKitInputButtonName.emoji,
      ZIMKitInputButtonName.picture,
      ZIMKitInputButtonName.voiceCall,
    ]);
  });

  test('hides the expansion contents when the page hides the more button', () {
    final result = resolveZIMKitInputButtons(
      globalConfig: ZIMKitInputConfig(
        smallButtons: [ZIMKitInputButtonName.audio],
        expandButtons: [ZIMKitInputButtonName.file],
      ),
      pageConfig: const ZIMKitMessageInputConfigs(showMoreButton: false),
    );

    expect(result.smallButtons, [ZIMKitInputButtonName.audio]);
    expect(result.expandButtons, isEmpty);
  });

  test('page-level visibility removes matching global controls', () {
    final result = resolveZIMKitInputButtons(
      globalConfig: ZIMKitInputConfig(
        smallButtons: [
          ZIMKitInputButtonName.audio,
          ZIMKitInputButtonName.emoji,
          ZIMKitInputButtonName.picture,
          ZIMKitInputButtonName.expand,
        ],
        expandButtons: [
          ZIMKitInputButtonName.takePhoto,
          ZIMKitInputButtonName.file,
        ],
      ),
      pageConfig: const ZIMKitMessageInputConfigs(
        showRecordButton: false,
        showEmojiButton: false,
        showPickMediaButton: false,
        showPickFileButton: false,
      ),
    );

    expect(result.smallButtons, [ZIMKitInputButtonName.expand]);
    expect(result.expandButtons, isEmpty);
  });

  test('input config retains custom emojis', () {
    final config = ZIMKitInputConfig(emojis: const ['🌱', '🪴']);

    expect(config.emojis, ['🌱', '🪴']);
  });
}
