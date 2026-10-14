import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/audio/core.dart';
import 'package:zego_zimkit/src/components/audio/defines.dart';
import 'package:zego_zimkit/src/components/audio/status.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

/// Full-screen recording feedback and the actions shown after locking.
class ZIMKitRecordOverlay extends StatefulWidget {
  const ZIMKitRecordOverlay({
    super.key,
    required this.status,
    required this.onSend,
    required this.onDiscard,
  });

  final ZIMKitRecordStatus status;
  final VoidCallback onSend;
  final VoidCallback onDiscard;

  @override
  State<ZIMKitRecordOverlay> createState() => _ZIMKitRecordOverlayState();
}

class _ZIMKitRecordOverlayState extends State<ZIMKitRecordOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _waveController.stop();
    } else if (!_waveController.isAnimating) {
      _waveController.repeat();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BlockSemantics(
        child: ValueListenableBuilder<ZIMKitRecordLockerState>(
          valueListenable: widget.status.lockerStateNotifier,
          builder: (context, lockerState, _) {
            final isLocked = lockerState == ZIMKitRecordLockerState.locked;
            return ValueListenableBuilder<bool>(
              valueListenable: widget.status.cancelPreviewNotifier,
              builder: (context, isCancelPreview, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: widget.status.recorderReadyNotifier,
                  builder: (context, isRecordingReady, _) {
                    return AbsorbPointer(
                      absorbing: !isLocked,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.72),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Align(
                              alignment: const Alignment(0, -0.16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 520,
                                  ),
                                  child: _recordingCard(
                                    isLocked: isLocked,
                                    isCancelPreview: isCancelPreview,
                                    isRecordingReady: isRecordingReady,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 18,
                              child: isLocked
                                  ? _lockedActions(
                                      isRecordingReady: isRecordingReady,
                                    )
                                  : _holdingActions(
                                      isCancelPreview: isCancelPreview,
                                      isLockCandidate:
                                          lockerState ==
                                          ZIMKitRecordLockerState.testing,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _recordingCard({
    required bool isLocked,
    required bool isCancelPreview,
    required bool isRecordingReady,
  }) {
    final innerText = ZIMKitCore.instance.innerText;
    final isCanceling = isCancelPreview && !isLocked;
    final backgroundColor = isCanceling
        ? const Color(0xFFF44747)
        : const Color(0xFFD9E6FF);
    final foregroundColor = isCanceling
        ? Colors.white
        : const Color(0xFF26364F);
    final waveColor = isCanceling ? Colors.white : const Color(0xFF2863D8);

    return Container(
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (isLocked) ...[
                Icon(Icons.lock, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
                Text(
                  isRecordingReady
                      ? innerText.recordingLockedText
                      : innerText.recordingStartingText,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else if (isCanceling) ...[
                const Icon(Icons.delete_outline, size: 18),
                const SizedBox(width: 8),
                Text(
                  innerText.releaseToCancelText,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Icon(Icons.mic, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
                Text(
                  innerText.holdToTalkText,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              ValueListenableBuilder<int>(
                valueListenable:
                    ZIMKitAudioInstance().data.recordDurationNotifier,
                builder: (context, duration, _) {
                  return Text(
                    formatAudioRecordDuration(duration),
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 15,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, _) {
              return SizedBox(
                height: 44,
                width: double.infinity,
                child: CustomPaint(
                  painter: _RecordWaveformPainter(
                    progress: _reduceMotion ? 0.42 : _waveController.value,
                    color: waveColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _holdingActions({
    required bool isCancelPreview,
    required bool isLockCandidate,
  }) {
    final innerText = ZIMKitCore.instance.innerText;
    final foregroundColor = isCancelPreview ? Colors.white : Colors.white70;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: isLockCandidate ? 66 : 58,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isLockCandidate
                ? const Color(0xFF2863D8)
                : Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.46),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLockCandidate ? Icons.lock : Icons.lock_outline,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                isLockCandidate
                    ? innerText.releaseToLockText
                    : innerText.slideUpToLockText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isCancelPreview
              ? innerText.releaseToCancelText
              : '${innerText.releaseToSendText}  ·  ← ${innerText.slideLeftToCancelText}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.17),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white38),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.mic, color: Colors.white, size: 30),
        ),
      ],
    );
  }

  Widget _lockedActions({required bool isRecordingReady}) {
    final innerText = ZIMKitCore.instance.innerText;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: innerText.discardRecordingLabelText,
            child: Tooltip(
              message: innerText.discardRecordingLabelText,
              child: OutlinedButton.icon(
                key: const ValueKey('record-discard-button'),
                onPressed: isRecordingReady ? widget.onDiscard : null,
                icon: const Icon(Icons.delete_outline),
                label: Text(innerText.discardRecordingText),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            key: const ValueKey('record-send-button'),
            onPressed: isRecordingReady ? widget.onSend : null,
            icon: const Icon(Icons.send),
            label: Text(innerText.sendRecordingText),
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF2863D8),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordWaveformPainter extends CustomPainter {
  const _RecordWaveformPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 13;
    const barWidth = 4.0;
    const gap = 6.0;
    const maxHeight = 34.0;
    const minHeight = 8.0;
    final totalWidth = barCount * barWidth + (barCount - 1) * gap;
    final startX = (size.width - totalWidth) / 2;
    final centerY = size.height / 2;
    final paint = Paint()..color = color;

    for (var index = 0; index < barCount; index++) {
      final phase = progress * math.pi * 2 + index * 0.72;
      final strength = (math.sin(phase) + 1) / 2;
      final height = minHeight + (maxHeight - minHeight) * strength;
      final rect = Rect.fromCenter(
        center: Offset(
          startX + index * (barWidth + gap) + barWidth / 2,
          centerY,
        ),
        width: barWidth,
        height: height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RecordWaveformPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
