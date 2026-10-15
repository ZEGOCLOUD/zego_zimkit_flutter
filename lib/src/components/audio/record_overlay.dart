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
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: _actionPanelHeight(context),
                              child: _actionPanel(
                                isLocked: isLocked,
                                isCancelPreview: isCancelPreview,
                                isRecordingReady: isRecordingReady,
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

  double _actionPanelHeight(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final height = math.min(viewport.width * 0.55, viewport.height * 0.34);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final isCompact = viewport.height < 680;
    final controlsHeight = isCompact
        ? 46.0 + 2 + 16 + 2 + 28
        : 52.0 + 4 + 17 + 4 + 32;
    final minHeight = math.max(
      156.0,
      (safeBottom + 8 + controlsHeight + 22 + 8) / 0.85,
    );
    return height.clamp(minHeight, math.max(240.0, minHeight)).toDouble();
  }

  Widget _actionPanel({
    required bool isLocked,
    required bool isCancelPreview,
    required bool isRecordingReady,
    required bool isLockCandidate,
  }) {
    final panelColor = isLocked
        ? const Color(0xFF2863D8)
        : isCancelPreview
        ? const Color(0xFF35363A)
        : const Color(0xFFE9EDF2);
    final timerColor = isLocked || isCancelPreview
        ? Colors.white
        : const Color(0xFF353B45);
    final isCompact = MediaQuery.sizeOf(context).height < 680;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 8;
    final panelHeight = _actionPanelHeight(context);

    return AnimatedBuilder(
      animation: _waveController,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            color: panelColor,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: panelHeight * 0.15,
            child: ValueListenableBuilder<int>(
              valueListenable:
                  ZIMKitAudioInstance().data.recordDurationNotifier,
              builder: (context, duration, _) {
                return Text(
                  formatAudioRecordDuration(duration),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: timerColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomPadding,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: isLocked
                  ? _lockedActions(
                      isRecordingReady: isRecordingReady,
                      isCompact: isCompact,
                    )
                  : _holdingActions(
                      isCancelPreview: isCancelPreview,
                      isLockCandidate: isLockCandidate,
                      isCompact: isCompact,
                    ),
            ),
          ),
        ],
      ),
      builder: (context, child) {
        return ClipPath(
          clipBehavior: Clip.antiAlias,
          clipper: _RecordActionPanelClipper(
            progress: _reduceMotion ? 0.42 : _waveController.value,
          ),
          child: child,
        );
      },
    );
  }

  Widget _holdingActions({
    required bool isCancelPreview,
    required bool isLockCandidate,
    required bool isCompact,
  }) {
    final innerText = ZIMKitCore.instance.innerText;
    final foregroundColor = isCancelPreview
        ? Colors.white
        : const Color(0xFF353B45);
    final lockLabelColor = isCancelPreview || isLockCandidate
        ? Colors.white
        : const Color(0xFF353B45);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: isCompact ? 46 : 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isCancelPreview
                ? Colors.white.withValues(alpha: 0.14)
                : isLockCandidate
                ? const Color(0xFF2863D8)
                : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isCancelPreview
                  ? Colors.white38
                  : isLockCandidate
                  ? const Color(0xFF2863D8)
                  : const Color(0xFFD7DCE3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCancelPreview
                    ? Icons.delete_outline
                    : isLockCandidate
                    ? Icons.lock
                    : Icons.lock_outline,
                color: lockLabelColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isCancelPreview
                    ? innerText.releaseToCancelText
                    : isLockCandidate
                    ? innerText.releaseToLockText
                    : innerText.slideUpToLockText,
                style: TextStyle(
                  color: lockLabelColor,
                  fontSize: isCompact ? 14 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isCancelPreview) ...[
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            innerText.slideLeftToCancelText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: foregroundColor.withValues(alpha: 0.82),
              fontSize: isCompact ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 4),
        ],
        Icon(
          Icons.mic_none,
          color: foregroundColor.withValues(alpha: 0.72),
          size: isCompact ? 28 : 32,
        ),
      ],
    );
  }

  Widget _lockedActions({
    required bool isRecordingReady,
    required bool isCompact,
  }) {
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
                  minimumSize: Size.fromHeight(isCompact ? 48 : 56),
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: ZIMKitAudioInstance().data.recordDurationNotifier,
            builder: (context, _, _) {
              return FilledButton.icon(
                key: const ValueKey('record-send-button'),
                onPressed: widget.status.canSendRecording
                    ? widget.onSend
                    : null,
                icon: const Icon(Icons.send),
                label: Text(innerText.sendRecordingText),
                style: FilledButton.styleFrom(
                  foregroundColor: const Color(0xFF2863D8),
                  backgroundColor: Colors.white,
                  minimumSize: Size.fromHeight(isCompact ? 48 : 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecordActionPanelClipper extends CustomClipper<Path> {
  const _RecordActionPanelClipper({required this.progress});

  final double progress;

  @override
  Path getClip(Size size) {
    const sampleCount = 160;
    final edgeY = size.height * 0.3;
    final phase = progress * math.pi * 2;
    final pulse = (math.sin(phase) + 1) / 2;
    final amplitude = size.height * (0.025 + pulse * 0.035);
    final path = Path()..moveTo(0, edgeY);

    for (var index = 1; index <= sampleCount; index++) {
      final position = index / sampleCount;
      final envelope = math.sin(math.pi * position);
      final baseY = edgeY - envelope * (edgeY - amplitude);
      final ripple =
          amplitude * envelope * math.sin(position * math.pi * 12 + phase);
      final y = (baseY + ripple).clamp(0.0, size.height).toDouble();
      path.lineTo(size.width * position, y);
    }

    return path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_RecordActionPanelClipper oldClipper) =>
      oldClipper.progress != progress;
}
