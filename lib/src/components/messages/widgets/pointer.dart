import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/defines/style.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

/// Widget for displaying message bubble pointer/tail
///
/// Renders the triangular pointer on message bubbles to indicate
/// whether the message was sent or received.
class ZIMKitTextMessagePointer extends StatelessWidget {
  final ZIMKitMessageType messageType;
  final bool isMine;

  const ZIMKitTextMessagePointer({
    super.key,
    required this.messageType,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: isMine ? 0 : (messagePointerWidth / 2).zW,
        top: 0,
        right: isMine ? (messagePointerWidth / 2).zW : 0,
        bottom: 0,
      ),
      width: messagePointerWidth,
      height: messagePointerWidth,
      child: CustomPaint(
        painter: ZIMKitMessageTrianglePainter(
          color: isMine ? Theme.of(context).primaryColor : Colors.white,
          isMine: isMine,
        ),
      ),
    );
  }
}

/// Custom painter for drawing message triangle pointers
class ZIMKitMessageTrianglePainter extends CustomPainter {
  /// Color of the triangle
  final Color color;

  /// Whether the message is from the current user
  final bool isMine;

  /// Creates a message triangle painter instance
  ///
  /// [color] Color of the triangle
  /// [isMine] Whether the message is from the current user
  ZIMKitMessageTrianglePainter({required this.color, required this.isMine});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path();
    if (isMine) {
      path
        ..moveTo(size.width, size.height / 2)
        ..lineTo(0, 0)
        ..lineTo(0, size.height);
    } else {
      path
        ..moveTo(0, size.height / 2)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height);
    }
    path.close();

    // Add subtle shadow for white triangles (remote messages)
    if (!isMine && color == Colors.white) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawPath(path, shadowPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ZIMKitMessageTrianglePainter oldDelegate) {
    return color != oldDelegate.color || isMine != oldDelegate.isMine;
  }
}
