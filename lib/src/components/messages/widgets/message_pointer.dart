import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/defines.dart';
import 'package:zego_zimkit/src/services/services.dart';

class ZIMKitTextMessagePointer extends StatelessWidget {
  final ZIMKitMessageType messageType;
  final bool isMine;

  const ZIMKitTextMessagePointer({
    Key? key,
    required this.messageType,
    required this.isMine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: isMine ? 0 : messagePointerWidth / 2,
        top: 0,
        right: isMine ? messagePointerWidth / 2 : 0,
        bottom: 0,
      ),
      width: messagePointerWidth,
      height: messagePointerWidth,
      child: CustomPaint(
        painter: ZIMKitMessageTrianglePainter(
          color: Theme.of(context).primaryColor.withValues(alpha: isMine ? 1 : 0.1),
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

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ZIMKitMessageTrianglePainter oldDelegate) {
    return color != oldDelegate.color || isMine != oldDelegate.isMine;
  }
}
