import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:zego_zimkit/src/utils/screen_util/core/size_extension.dart';

/// Style configuration class for audio recording components
class ZIMKitRecordStyle {
  /// Size of the locker icon in pixels
  static double get lockerIconSize => 50.zW;
}

/// Custom painter for drawing animated sound wave effects
class SoundWavePainter extends CustomPainter {
  /// Current progress of the sound wave animation (0.0 to 1.0)
  final double progress;

  /// Color of the sound wave
  final Color color;

  /// Whether the animation is currently running
  final bool isAnimating;

  /// Creates a sound wave painter instance
  ///
  /// [progress] Current progress of the sound wave animation (0.0 to 1.0)
  /// [color] Color of the sound wave
  /// [isAnimating] Whether the animation is currently running
  SoundWavePainter({
    required this.progress,
    required this.color,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isAnimating) {
      return;
    }

    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    for (var wave = 0; wave <= progress; wave++) {
      circle(canvas, rect, 5, wave, progress.toInt());
    }
  }

  // animating the opacity according to min radius and waves count.
  void circle(
      Canvas canvas, Rect rect, double minRadius, int wave, int length) {
    Color paintColor;
    double radius;
    if (wave != 0) {
      final opacity = (1 - ((wave - 1) / length)).clamp(0.0, 1.0);
      paintColor = color.withValues(alpha: opacity);

      radius = minRadius * (1 + 0.5 * wave);
      final paint = Paint()
        ..color = paintColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(rect.center, radius, paint);
    }
  }

  //
  // @override
  // bool shouldRepaint(RipplePainter oldDelegate) => true;

  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
