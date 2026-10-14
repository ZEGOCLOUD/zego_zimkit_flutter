import 'package:zego_zimkit/src/components/messages/input/configs.dart';
import 'package:zego_zimkit/src/config.defines.dart';

class ZIMKitResolvedInputButtons {
  const ZIMKitResolvedInputButtons({
    required this.smallButtons,
    required this.expandButtons,
  });

  final List<ZIMKitInputButtonName> smallButtons;
  final List<ZIMKitInputButtonName> expandButtons;
}

ZIMKitResolvedInputButtons resolveZIMKitInputButtons({
  required ZIMKitInputConfig globalConfig,
  required ZIMKitMessageInputConfigs pageConfig,
}) {
  bool isVisible(ZIMKitInputButtonName button) {
    return switch (button) {
      ZIMKitInputButtonName.audio => pageConfig.showRecordButton,
      ZIMKitInputButtonName.emoji => pageConfig.showEmojiButton,
      ZIMKitInputButtonName.picture ||
      ZIMKitInputButtonName.takePhoto => pageConfig.showPickMediaButton,
      ZIMKitInputButtonName.file => pageConfig.showPickFileButton,
      ZIMKitInputButtonName.expand => pageConfig.showMoreButton,
      ZIMKitInputButtonName.voiceCall ||
      ZIMKitInputButtonName.videoCall => true,
    };
  }

  final requestedSmall = globalConfig.smallButtons
      .where(isVisible)
      .toSet()
      .toList();
  final requestedExpand = pageConfig.showMoreButton
      ? globalConfig.expandButtons
            .where(isVisible)
            .where((button) => button != ZIMKitInputButtonName.expand)
            .toSet()
            .toList()
      : <ZIMKitInputButtonName>[];
  final maximum = globalConfig.maxSmallButtonCount < 0
      ? 0
      : globalConfig.maxSmallButtonCount > requestedSmall.length
      ? requestedSmall.length
      : globalConfig.maxSmallButtonCount;
  final hasOverflow = requestedSmall.length > maximum;
  final needsExpansionButton =
      pageConfig.showMoreButton &&
      (requestedExpand.isNotEmpty ||
          hasOverflow ||
          requestedSmall.contains(ZIMKitInputButtonName.expand));

  final inlineCandidates = requestedSmall
      .where((button) => button != ZIMKitInputButtonName.expand)
      .toList();
  final smallButtons = <ZIMKitInputButtonName>[];
  if (needsExpansionButton && maximum > 0) {
    smallButtons.addAll(inlineCandidates.take(maximum - 1));
    final configuredExpandIndex = requestedSmall.indexOf(
      ZIMKitInputButtonName.expand,
    );
    if (configuredExpandIndex < 0) {
      smallButtons.add(ZIMKitInputButtonName.expand);
    } else {
      smallButtons.insert(
        configuredExpandIndex.clamp(0, smallButtons.length),
        ZIMKitInputButtonName.expand,
      );
    }
  } else {
    smallButtons.addAll(inlineCandidates.take(maximum));
  }

  final visibleInlineButtons = smallButtons
      .where((button) => button != ZIMKitInputButtonName.expand)
      .toSet();
  final expandButtons = pageConfig.showMoreButton
      ? <ZIMKitInputButtonName>[
          ...requestedExpand,
          ...inlineCandidates.where(
            (button) =>
                !visibleInlineButtons.contains(button) &&
                !requestedExpand.contains(button),
          ),
        ]
      : <ZIMKitInputButtonName>[];

  return ZIMKitResolvedInputButtons(
    smallButtons: smallButtons,
    expandButtons: expandButtons,
  );
}
