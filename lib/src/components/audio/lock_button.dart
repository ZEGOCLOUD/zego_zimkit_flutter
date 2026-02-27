import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'defines.dart';
import 'status.dart';

/// Widget for locking recording mode
///
/// During voice message recording, this widget allows the user to
/// lock the recording mode to continue recording without holding the button.
class ZIMKitRecordLocker extends StatefulWidget {
  const ZIMKitRecordLocker({
    super.key,
    this.icon,
    required this.processor,
  });

  final Widget? icon;
  final ZIMKitRecordStatus processor;

  @override
  State<ZIMKitRecordLocker> createState() => _ZIMKitRecordLockerState();
}

/// @nodoc
class _ZIMKitRecordLockerState extends State<ZIMKitRecordLocker> {
  Offset startOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.processor.stateNotifier,
      builder: (context, recordState, _) {
        return ValueListenableBuilder(
          valueListenable: widget.processor.lockerStateNotifier,
          builder: (context, lockerState, _) {
            var color = Colors.grey.withValues(alpha: 0.4);
            if (lockerState == ZIMKitRecordLockerState.testing) {
              color = Colors.green.withValues(alpha: 0.4);
            }

            return recordState == ZIMKitRecordState.recording &&
                    lockerState != ZIMKitRecordLockerState.locked
                ? Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2000.zR),
                    ),
                    child: widget.icon ?? const Icon(Icons.lock),
                  )
                : Container();
          },
        );
      },
    );
  }
}
