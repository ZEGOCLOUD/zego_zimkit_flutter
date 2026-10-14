import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zim_audio/zego_zim_audio.dart';

import 'package:zego_zimkit/src/audio/core.dart';
import 'package:zego_zimkit/src/audio/data.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/services.dart';
import 'package:zego_zimkit/src/components/style.dart';

import 'defines.dart';
import 'events.dart';
import 'status.dart';
import 'style.dart';

/// Button widget for recording voice messages
///
/// Displays a microphone button that records audio when pressed and held.
/// Shows recording state with visual feedback and supports slide-to-cancel.
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
  bool _isStartPending = false;
  bool _holdReleasePending = false;
  int? _pendingStartGeneration;

  late AnimationController _animationController;
  late Animation<double> _animation;
  final isAnimatingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 500),
          )
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }
          });

    _animation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();

    onStateChanged();
    widget.status.stateNotifier.addListener(onStateChanged);

    ZIMKitAudioInstance().data.recordCountDownNotifier.addListener(
      onRecordCountDown,
    );
  }

  @override
  void dispose() {
    widget.status.cancelIfRecording();
    super.dispose();

    ZIMKitAudioInstance().data.recordCountDownNotifier.removeListener(
      onRecordCountDown,
    );

    widget.status.stateNotifier.removeListener(onStateChanged);
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [button(), lockerButton()]);
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
    final innerText = ZIMKitCore.instance.innerText;
    return ValueListenableBuilder<ZIMKitRecordState>(
      valueListenable: widget.status.stateNotifier,
      builder: (context, recordState, _) {
        return Semantics(
          container: true,
          button: true,
          label: innerText.startVoiceRecordingLabelText,
          hint: innerText.startVoiceRecordingHintText,
          onTap: recordState == ZIMKitRecordState.idle
              ? () => _startRecording(lockImmediately: true)
              : null,
          child: ExcludeSemantics(
            child: Listener(
              onPointerCancel: (_) {
                if (widget.status.stateNotifier.value ==
                        ZIMKitRecordState.recording &&
                    widget.status.lockerStateNotifier.value !=
                        ZIMKitRecordLockerState.locked) {
                  widget.status.cancelIfRecording();
                }
                startOffset = Offset.zero;
              },
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (widget.status.stateNotifier.value !=
                          ZIMKitRecordState.recording ||
                      widget.status.lockerStateNotifier.value ==
                          ZIMKitRecordLockerState.locked) {
                    return;
                  }

                  final action = resolveRecordGestureAction(
                    horizontalOffset:
                        details.globalPosition.dx - startOffset.dx,
                    verticalOffset: details.globalPosition.dy - startOffset.dy,
                    cancelThreshold: MediaQuery.of(context).size.width * 0.32,
                    lockThreshold: ZIMKitRecordStyle.lockerIconSize * 2,
                    lockHorizontalTolerance:
                        ZIMKitRecordStyle.lockerIconSize * 1.8,
                  );
                  widget.status.updateGestureAction(action);
                },
                onTapDown: (details) {
                  if (widget.status.stateNotifier.value ==
                          ZIMKitRecordState.recording ||
                      _isStartPending) {
                    return;
                  }

                  startOffset = details.globalPosition;
                  _startRecording();
                },
                onTapUp: (_) => _finishHoldGesture(),
                onPanEnd: (_) => _finishHoldGesture(),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isAnimatingNotifier,
                  builder: (context, isAnimating, _) {
                    return CustomPaint(
                      painter: SoundWavePainter(
                        progress: _animation.value,
                        color: Colors.blue,
                        isAnimating: isAnimating,
                      ),
                      child:
                          widget.icon ??
                          Icon(
                            Icons.mic,
                            size: ZIMKitComponentStyle.iconSize,
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.64),
                          ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _startRecording({bool lockImmediately = false}) {
    if (_isStartPending ||
        widget.status.stateNotifier.value == ZIMKitRecordState.recording) {
      return;
    }

    final audio = ZIMKitAudioInstance();
    final filePath = audio.data.generateRecordFilePath();
    final recordStatus = widget.status;
    final recordEvents = widget.events;
    final conversationID = widget.conversationID;
    final conversationType = widget.conversationType;
    final onMessageSent = widget.onMessageSent;
    final preMessageSending = widget.preMessageSending;
    final generation = recordStatus.startRecording(locked: lockImmediately);
    final startFuture = audio.startRecord(
      conversationID,
      conversationType,
      filePath: filePath,
      maxDuration: 60 * 1000,
      onStarted: () {
        if (recordStatus.markRecordingStarted(generation) &&
            _holdReleasePending &&
            !_isStartPending) {
          _holdReleasePending = false;
          _finishHoldGesture();
        }
      },
      onCompleted: (recordData) => _sendRecordedAudio(
        recordData,
        onMessageSent: onMessageSent,
        preMessageSending: preMessageSending,
      ),
      onFailed: (errorCode) => _handleRecordFailure(
        recordStatus,
        recordEvents,
        generation,
        errorCode,
      ),
    );
    _holdReleasePending = false;
    _isStartPending = true;
    _pendingStartGeneration = generation;
    unawaited(_observeRecordingStart(startFuture, generation, filePath));
  }

  Future<void> _observeRecordingStart(
    Future<void> startFuture,
    int generation,
    String filePath,
  ) async {
    try {
      await startFuture;
    } catch (error, stackTrace) {
      ZIMKitAudioInstance().data.removeRecordingByFilePath(filePath);
      if (widget.status.failStartingRecording(generation)) {
        widget.events?.onFailed?.call(_recordingErrorCode(error));
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text(
                ZIMKitCore.instance.innerText.recordingStartFailedText,
              ),
            ),
          );
        }
      }
      unawaited(
        ZIMKitLogger.logError(
          'audio button, startRecord failed: $error\n$stackTrace',
        ),
      );
    } finally {
      if (_pendingStartGeneration == generation) {
        _pendingStartGeneration = null;
        _isStartPending = false;
      }
    }

    if (widget.status.isRecordingGenerationActive(generation) &&
        widget.status.isRecordingReady &&
        _holdReleasePending) {
      _holdReleasePending = false;
      _finishHoldGesture();
    }
  }

  int _recordingErrorCode(Object error) {
    if (error is PlatformException) {
      return int.tryParse(error.code) ?? ZIMAudioErrorCode.unknownFailed;
    }
    return ZIMAudioErrorCode.unknownFailed;
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

  void _finishHoldGesture() {
    if (_isStartPending) {
      _holdReleasePending = true;
      startOffset = Offset.zero;
      return;
    }

    if (widget.status.stateNotifier.value != ZIMKitRecordState.recording) {
      startOffset = Offset.zero;
      return;
    }

    if (!widget.status.isRecordingReady) {
      _holdReleasePending = true;
      startOffset = Offset.zero;
      return;
    }

    final wasLockCandidate =
        widget.status.lockerStateNotifier.value ==
        ZIMKitRecordLockerState.testing;
    final result = widget.status.releaseHoldGesture();
    if (wasLockCandidate && result == ZIMKitRecordFinishResult.locked) {
      unawaited(HapticFeedback.selectionClick());
    }
    startOffset = Offset.zero;
  }

  void onRecordCountDown() {
    final countDown = ZIMKitAudioInstance().data.recordCountDownNotifier.value;
    widget.events?.onCountdownTick?.call(countDown);
  }
}

Future<void> _sendRecordedAudio(
  ZIMKitAudioRecordData recordData, {
  required void Function(ZIMKitMessage)? onMessageSent,
  required FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending,
}) async {
  ZIMKitLogger.logInfo('audio button, onRecordCompleted, $recordData');
  try {
    await ZIMKitCore.instance.sendMediaMessage(
      recordData.conversationID,
      recordData.conversationType,
      recordData.absFilePath,
      ZIMMessageType.audio,
      audioDuration: (recordData.duration / 1000).floor(),
      onMessageSent: onMessageSent,
      preMessageSending: preMessageSending,
    );
    ZIMKitLogger.logInfo('audio button, send audio done');
  } catch (error, stackTrace) {
    await ZIMKitLogger.logError(
      'audio button, send audio error: $error\n$stackTrace',
    );
  }
}

void _handleRecordFailure(
  ZIMKitRecordStatus status,
  ZIMKitAudioRecordEvents? events,
  int generation,
  int errorCode,
) {
  status.failRecording(generation);
  events?.onFailed?.call(errorCode);
}
