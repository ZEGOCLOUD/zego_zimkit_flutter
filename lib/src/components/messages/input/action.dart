import 'package:flutter/cupertino.dart';

import 'defines.dart';

class ZIMKitMessageInputAction {
  final Widget child;
  final ZIMKitMessageInputActionLocation location;

  const ZIMKitMessageInputAction(
    this.child, [
    this.location = ZIMKitMessageInputActionLocation.rightInside,
  ]);

  const ZIMKitMessageInputAction.left(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.left,
        );

  const ZIMKitMessageInputAction.right(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.right,
        );

  const ZIMKitMessageInputAction.leftInside(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.leftInside,
        );

  const ZIMKitMessageInputAction.rightInside(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.rightInside,
        );

  const ZIMKitMessageInputAction.more(Widget child)
      : this(
          child,
          ZIMKitMessageInputActionLocation.more,
        );
}
