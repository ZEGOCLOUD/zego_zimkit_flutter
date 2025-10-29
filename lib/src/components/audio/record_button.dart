import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/audio/core.dart';
import 'package:zego_zimkit/src/audio/data.dart';
import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/services.dart';
import 'package:zego_zimkit/src/components/style.dart';

import 'defines.dart';
import 'events.dart';
import 'status.dart';
import 'style.dart';

class ZIMKitRecordButton extends StatefulWidget {
  ZIMKitRecordButton({
    super.key,
    required this.status,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.icon,
    EdgeInsets? padding,
    this.onMessageSent,
    this.events,
    this.preMessageSending,
  }) : padding = padding ?? EdgeInsets.all(32.0.zR);

  final Widget? icon;
  final EdgeInsetsGeometry padding;
  final ZIMKitRecordStatus status;

  /// The conversationID of the conversation to send message.
  final String conversationID;

  /// The conversationType of the conversation to send message.
  final ZIMConversationType conversationType;

  /// events
  final ZIMKitAudioRecordEvents? events;

  /// Called when a message is sent.
  final void Function(ZIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending;

  @override
  State<ZIMKitRecordButton> createState() => _ZIMKitRecordButtonState();
}

/// @nodoc
class _ZIMKitRecordButtonState extends State<ZIMKitRecordButton>
    with SingleTickerProviderStateMixin {
  Offset startOffset = Offset.zero;
  double slideMaxOffsetX = 0;

  List<StreamSubscription<dynamic>?> subscriptions = [];

  late AnimationController _animationController;
  late Animation<double> _animation;
  final isAnimatingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      slideMaxOffsetX = MediaQuery.of(context).size.width / 5 * 2;
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )
      ..addListener(
        () {
          setState(() {});
        },
      )
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            _animationController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _animationController.forward();
          }
        },
      );

    _animation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat();

    widget.status.stateNotifier.value = ZIMKitRecordState.idle;
    onStateChanged();
    widget.status.stateNotifier.addListener(onStateChanged);

    ZIMKitAudioInstance()
        .data
        .recordCountDownNotifier
        .addListener(onRecordCountDown);

    subscriptions
      ..add(ZIMKitAudioInstance()
          .data
          .recordCompleteStreamCtrl
          ?.stream
          .asBroadcastStream()
          .listen(onRecordCompleted))
      ..add(ZIMKitAudioInstance()
          .data
          .recordFailedStreamCtrl
          ?.stream
          .asBroadcastStream()
          .listen(onRecordError));
  }

  @override
  void dispose() {
    super.dispose();

    ZIMKitAudioInstance()
        .data
        .recordCountDownNotifier
        .removeListener(onRecordCountDown);

    widget.status.stateNotifier.removeListener(onStateChanged);
    _animationController.dispose();

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        button(),
        lockerButton(),
      ],
    );
  }

  Widget lockerButton() {
    return ValueListenableBuilder(
      valueListenable: widget.status.stateNotifier,
      builder: (context, recordState, _) {
        return ValueListenableBuilder(
          valueListenable: widget.status.lockerStateNotifier,
          builder: (context, lockState, _) {
            return recordState == ZIMKitRecordState.recording &&
                    ZIMKitRecordLockerState.locked == lockState
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      child: Icon(
                        Icons.lock,
                        color: Colors.green,
                        size: ZIMKitComponentStyle.iconSize / 2,
                      ),
                    ),
                  )
                : Container();
          },
        );
      },
    );
  }

  Widget button() {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        startOffset = details.globalPosition;

        widget.status.lockerStateNotifier.value = ZIMKitRecordLockerState.idle;
      },
      onHorizontalDragUpdate: (details) {
        if (widget.status.stateNotifier.value != ZIMKitRecordState.recording) {
          return;
        }

        Offset currentOffset = details.globalPosition;
        double horizontalDistance = currentOffset.dx - startOffset.dx;
        double verticalDistance = currentOffset.dy - startOffset.dy;

        if (horizontalDistance < -slideMaxOffsetX &&
            verticalDistance > -ZIMKitMessageStyle.inputHeight / 2) {
          widget.status.stateNotifier.value = ZIMKitRecordState.cancel;
          widget.status.stateNotifier.value = ZIMKitRecordState.idle;
        }

        final isInLocker = (verticalDistance < 0 &&
            verticalDistance > -ZIMKitRecordStyle.lockerIconSize);
        if (isInLocker) {
          widget.status.lockerStateNotifier.value =
              ZIMKitRecordLockerState.testing;
        } else {
          widget.status.lockerStateNotifier.value =
              ZIMKitRecordLockerState.idle;
        }
      },
      onHorizontalDragEnd: (details) {
        startOffset = Offset.zero;

        if (widget.status.stateNotifier.value != ZIMKitRecordState.recording) {
          return;
        }

        if (widget.status.lockerStateNotifier.value ==
            ZIMKitRecordLockerState.testing) {
          widget.status.lockerStateNotifier.value =
              ZIMKitRecordLockerState.locked;
        } else {
          widget.status.stateNotifier.value = ZIMKitRecordState.complete;
          widget.status.stateNotifier.value = ZIMKitRecordState.idle;

          widget.status.lockerStateNotifier.value =
              ZIMKitRecordLockerState.idle;
        }
      },
      onTapDown: (details) {
        ZIMKitAudioInstance().startRecord(
          widget.conversationID,
          widget.conversationType,
          maxDuration: 60 * 1000,
        );

        widget.status.stateNotifier.value = ZIMKitRecordState.recording;
      },
      onTapUp: (details) {
        widget.status.stateNotifier.value = ZIMKitRecordState.complete;
        widget.status.stateNotifier.value = ZIMKitRecordState.idle;

        widget.status.lockerStateNotifier.value = ZIMKitRecordLockerState.idle;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isAnimatingNotifier,
        builder: (context, isAnimating, _) {
          return CustomPaint(
            painter: SoundWavePainter(
              progress: _animation.value,
              color: Colors.blue,
              isAnimating: isAnimating,
            ),
            child: widget.icon ??
                Icon(
                  Icons.mic,
                  size: ZIMKitComponentStyle.iconSize,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withValues(alpha: 0.64),
                ),
          );
        },
      ),
    );
  }

  void onStateChanged() {
    final currentState = widget.status.stateNotifier.value;

    switch (currentState) {
      case ZIMKitRecordState.idle:
      case ZIMKitRecordState.cancel:
      case ZIMKitRecordState.complete:
        isAnimatingNotifier.value = false;
        _animationController.stop();
        break;
      case ZIMKitRecordState.recording:
        isAnimatingNotifier.value = true;
        _animationController.forward(from: 0.0);
        break;
    }
  }

  void onRecordCountDown() {
    final countDown = ZIMKitAudioInstance().data.recordCountDownNotifier.value;
    widget.events?.onCountdownTick?.call(countDown);
  }

  void onRecordCompleted(ZIMKitAudioRecordData recordData) {
    ZIMKitLogger.logInfo('audio button, onRecordCompleted, $recordData');

    widget.status.stateNotifier.value = ZIMKitRecordState.complete;
    widget.status.stateNotifier.value = ZIMKitRecordState.idle;

    widget.status.lockerStateNotifier.value = ZIMKitRecordLockerState.idle;

    ZIMKitCore.instance
        .sendMediaMessage(
      recordData.conversationID,
      recordData.conversationType,
      recordData.absFilePath,
      ZIMMessageType.audio,
      audioDuration: (recordData.duration / 1000).floor(),
      onMessageSent: widget.onMessageSent,
      preMessageSending: widget.preMessageSending,
    )
        .then((_) {
      ZIMKitLogger.logInfo('audio button, send audio done');
    }).catchError((e) {
      ZIMKitLogger.logInfo('audio button, send audio error, $e');
    });
  }

  void onRecordError(int errorCode) {
    widget.events?.onFailed?.call(errorCode);
  }
}
