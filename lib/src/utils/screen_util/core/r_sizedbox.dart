import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:zego_zimkit/src/utils/screen_util/core/size_extension.dart';

/// @nodoc
class ZIMRSizedBox extends SizedBox {
  const ZIMRSizedBox({
    super.key,
    super.height,
    super.width,
    super.child,
  })  : _square = false;

  const ZIMRSizedBox.zVertical(
    double? height, {
    super.key,
    super.child,
  })  : _square = false,
        super(height: height);

  const ZIMRSizedBox.zHorizontal(
    double? width, {
    super.key,
    super.child,
  })  : _square = false,
        super(width: width);

  const ZIMRSizedBox.zSquare({
    super.key,
    double? height,
    super.dimension,
    super.child,
  })  : _square = true,
        super.square();

  ZIMRSizedBox.fromSize({
    super.key,
    super.size,
    super.child,
  })  : _square = false,
        super.fromSize();

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
      additionalConstraints: _additionalConstraints,
    );
  }

  final bool _square;

  BoxConstraints get _additionalConstraints {
    final boxConstraints =
        BoxConstraints.tightFor(width: width, height: height);
    return _square ? boxConstraints.zR : boxConstraints.zHW;
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderConstrainedBox renderObject) {
    renderObject.additionalConstraints = _additionalConstraints;
  }
}
