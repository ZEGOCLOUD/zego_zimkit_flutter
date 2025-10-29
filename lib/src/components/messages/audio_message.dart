import 'package:flutter/material.dart';

import 'package:zego_zim_audio/zego_zim_audio.dart';

import 'package:zego_zimkit/src/audio/core.dart';
import 'package:zego_zimkit/src/audio/data.dart';
import 'package:zego_zimkit/src/components/audio/defines.dart';
import 'package:zego_zimkit/src/components/style.dart';
import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/components/messages/widgets/reactions.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/zimkit.dart';

class ZIMKitAudioMessage extends StatefulWidget {
  const ZIMKitAudioMessage({
    super.key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.onReplyMessageTap,
  });

  final ZIMKitMessage message;

  final void Function(
    BuildContext context,
    ZIMKitMessage message,
    Function defaultAction,
  )? onPressed;
  final void Function(
    BuildContext context,
    LongPressStartDetails details,
    ZIMKitMessage message,
    Function defaultAction,
  )? onLongPress;
  final void Function(String repliedMessageID)? onReplyMessageTap;

  @override
  State<ZIMKitAudioMessage> createState() => _ZIMKitAudioMessageState();
}

/// @nodoc
class _ZIMKitAudioMessageState extends State<ZIMKitAudioMessage> {
  final localPlayStatusNotifier =
      ValueNotifier<ZIMKitAudioPlayStatus>(ZIMKitAudioPlayStatus(
    id: 0,
    isPlaying: false,
  ));

  bool get isPlayingCurrent =>
      ZIMKitAudioInstance().data.playStatusNotifier.value.isPlaying &&
      ZIMKitAudioInstance().data.playStatusNotifier.value.id ==
          widget.message.info.messageID;

  SliderThemeData get sliderThemeData => SliderThemeData(
        trackHeight: 2.0.zH,
        thumbColor: Colors.white,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 3.0.zR,
        ),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.5),
      );

  @override
  void initState() {
    super.initState();

    ZIMKitAudioInstance()
        .data
        .playStatusNotifier
        .addListener(onPlayStatusUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    ZIMKitAudioInstance()
        .data
        .playStatusNotifier
        .removeListener(onPlayStatusUpdated);

    if (ZIMKitAudioInstance().data.playStatusNotifier.value.id ==
        widget.message.info.messageID) {
      ZIMKitAudioInstance().stopPlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () async {
          final defaultAction =
              isPlayingCurrent ? defaultStopPressed : defaultPlayPressed;
          widget.onPressed != null
              ? widget.onPressed?.call(context, widget.message, defaultAction)
              : defaultAction();
        },
        onLongPressStart: (details) => widget.onLongPress != null
            ? widget.onLongPress
                ?.call(context, details, widget.message, defaultLongPress)
            : defaultLongPress,
        child: LayoutBuilder(builder: (context, constraints) {
          const minDisplayWidth = 100;
          final audioDuration = widget.message.audioContent?.audioDuration ?? 0;
          var durationWidth = audioDuration * 5;
          if (durationWidth > constraints.maxWidth - minDisplayWidth) {
            durationWidth = constraints.maxWidth.toInt() - minDisplayWidth - 1;
          }
          return Container(
            width: (minDisplayWidth + durationWidth).toDouble(),
            padding: EdgeInsets.symmetric(horizontal: 12.zW, vertical: 8.zH),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.zR),
              color: widget.message.isMine
                  ? ZIMKitMessageStyle.sentMessageBubbleColor(context)
                  : ZIMKitMessageStyle.receivedMessageBubbleColor,
              boxShadow: widget.message.isMine
                  ? null
                  : ZIMKitMessageStyle.getReceivedMessageBubbleShadow(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio controls
                Row(
                  children: [
                    ...state(),
                    process(),
                    duration(),
                  ],
                ),
                // Reactions inside bubble (like Android)
                ZIMKitMessageReactionsWidget(
                  message: widget.message,
                  isMine: widget.message.isMine,
                  onReactionTap: (reactionType) async {
                    await _handleReactionTap(reactionType);
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _handleReactionTap(String reactionType) async {
    final currentUserID = ZIMKit().currentUser()?.baseInfo.userID;
    if (currentUserID == null) return;

    final reactions = widget.message.reactions.value;

    // Check if current user already reacted with this type
    final existingReaction = reactions.firstWhere(
      (r) => r.reactionType == reactionType,
      orElse: () => throw StateError('Reaction not found'),
    );

    try {
      final hasReacted = existingReaction.userList.any(
        (user) => user.userID == currentUserID,
      );

      if (hasReacted) {
        // Remove reaction
        await ZIMKit().deleteMessageReaction(widget.message, reactionType);
      } else {
        // Add reaction
        await ZIMKit().addMessageReaction(widget.message, reactionType);
      }
    } catch (e) {
      // Reaction not found, do nothing
    }
  }

  List<Widget> state() {
    final playPauseWidget = ValueListenableBuilder<ZIMKitAudioPlayStatus>(
      valueListenable: localPlayStatusNotifier,
      builder: (context, playingStatus, _) {
        if (playingStatus.id != widget.message.info.messageID) {
          return Icon(
            Icons.play_arrow,
            color: widget.message.isMine
                ? ZIMKitMessageStyle.sentMessageTextColor
                : ZIMKitMessageStyle.sentMessageBubbleColor(context),
          );
        }

        return Icon(
          playingStatus.isPlaying ? Icons.pause : Icons.play_arrow,
          color: widget.message.isMine
              ? Colors.white
              : Theme.of(context).primaryColor,
        );
      },
    );

    if (widget.message.audioContent!.fileLocalPath.isEmpty) {
      return [
        SizedBox(
          width: (ZIMKitComponentStyle.iconSize / 2).zW,
          height: (ZIMKitComponentStyle.iconSize / 2).zH,
          child: const CircularProgressIndicator(),
        ),
        SizedBox(
          width: 5.zW,
        ),
      ];
    }

    return [playPauseWidget];
  }

  Widget duration() {
    return Text(
      formatAudioRecordDuration(
        widget.message.audioContent!.audioDuration * 1000,
      ),
      style: TextStyle(
        fontSize: 12,
        color: widget.message.isMine ? Colors.white : null,
      ),
    );
  }

  Widget process() {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 2,
            color: Colors.transparent,
            child: ValueListenableBuilder<ZIMKitAudioPlayStatus>(
              valueListenable: localPlayStatusNotifier,
              builder: (context, playingStatus, _) {
                if (playingStatus.id != widget.message.info.messageID) {
                  return SliderTheme(
                    data: sliderThemeData,
                    child: Slider(
                      value: 0,
                      min: 0.0,
                      max: 1,
                      onChanged: (_) {},
                    ),
                  );
                }

                return ValueListenableBuilder<int>(
                  valueListenable:
                      ZIMKitAudioInstance().data.playProcessNotifier,
                  builder: (context, playProcess, _) {
                    return SliderTheme(
                      data: sliderThemeData,
                      child: Slider(
                        value: (playProcess / 1000).toDouble().floorToDouble(),
                        min: 0.0,
                        max: widget.message.audioContent!.audioDuration
                            .toDouble(),
                        onChanged: (_) {},
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> defaultPlayPressed() async {
    await ZIMKitAudioInstance().startPlay(
      widget.message.info.messageID,
      widget.message.audioContent?.fileLocalPath ?? '',
      routeType: ZIMAudioRouteType.speaker,
    );
  }

  Future<void> defaultStopPressed() async {
    await ZIMKitAudioInstance().stopPlay();
  }

  Future<void> defaultLongPress() async {}

  void onPlayStatusUpdated() {
    localPlayStatusNotifier.value =
        ZIMKitAudioInstance().data.playStatusNotifier.value;
  }
}
