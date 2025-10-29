import 'dart:math';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/utils/screen_util/core/screen_util.dart';

/// @nodoc
extension ZIMSizeExtension on num {
  ///[ZIMScreenUtil.setWidth]
  double get zW => ZIMScreenUtil().setWidth(this);

  ///[ZIMScreenUtil.setHeight]
  double get zH => ZIMScreenUtil().setHeight(this);

  ///[ZIMScreenUtil.radius]
  double get zR => ZIMScreenUtil().radius(this);

  ///[ZIMScreenUtil.diagonal]
  double get zDG => ZIMScreenUtil().diagonal(this);

  ///[ZIMScreenUtil.diameter]
  double get zDM => ZIMScreenUtil().diameter(this);

  ///[ZIMScreenUtil.setSp]
  double get zSP => ZIMScreenUtil().setSp(this);

  ///smart size :  it check your value - if it is bigger than your value it will set your value
  ///for example, you have set 16.sm() , if for your screen 16.sp() is bigger than 16 , then it will set 16 not 16.sp()
  ///I think that it is good for save size balance on big sizes of screen
  double get zSPMin => min(toDouble(), zSP);

  @Deprecated('use spMin instead')
  double get zSM => min(toDouble(), zSP);

  double get zSPMax => max(toDouble(), zSP);

  ///屏幕宽度的倍数
  ///Multiple of screen width
  double get zSW => ZIMScreenUtil().screenWidth * this;

  ///屏幕高度的倍数
  ///Multiple of screen height
  double get zSH => ZIMScreenUtil().screenHeight * this;

  ///[ZIMScreenUtil.setHeight]
  SizedBox get zVerticalSpace => ZIMScreenUtil().setVerticalSpacing(this);

  ///[ZIMScreenUtil.setVerticalSpacingFromWidth]
  SizedBox get zVerticalSpaceFromWidth =>
      ZIMScreenUtil().setVerticalSpacingFromWidth(this);

  ///[ZIMScreenUtil.setWidth]
  SizedBox get zHorizontalSpace => ZIMScreenUtil().setHorizontalSpacing(this);

  ///[ZIMScreenUtil.radius]
  SizedBox get zHorizontalSpaceRadius =>
      ZIMScreenUtil().setHorizontalSpacingRadius(this);

  ///[ZIMScreenUtil.radius]
  SizedBox get zVerticalSpacingRadius =>
      ZIMScreenUtil().setVerticalSpacingRadius(this);

  ///[ZIMScreenUtil.diameter]
  SizedBox get zHorizontalSpaceDiameter =>
      ZIMScreenUtil().setHorizontalSpacingDiameter(this);

  ///[ZIMScreenUtil.diameter]
  SizedBox get zVerticalSpacingDiameter =>
      ZIMScreenUtil().setVerticalSpacingDiameter(this);

  ///[ZIMScreenUtil.diagonal]
  SizedBox get zHorizontalSpaceDiagonal =>
      ZIMScreenUtil().setHorizontalSpacingDiagonal(this);

  ///[ZIMScreenUtil.diagonal]
  SizedBox get zVerticalSpacingDiagonal =>
      ZIMScreenUtil().setVerticalSpacingDiagonal(this);
}

/// @nodoc
extension ZIMEdgeInsetsExtension on EdgeInsets {
  /// Creates adapt insets using r [ZIMSizeExtension].
  EdgeInsets get zR => copyWith(
        top: top.zR,
        bottom: bottom.zR,
        right: right.zR,
        left: left.zR,
      );

  EdgeInsets get dm => copyWith(
        top: top.zDM,
        bottom: bottom.zDM,
        right: right.zDM,
        left: left.zDM,
      );

  EdgeInsets get dg => copyWith(
        top: top.zDG,
        bottom: bottom.zDG,
        right: right.zDG,
        left: left.zDG,
      );

  EdgeInsets get w => copyWith(
        top: top.zW,
        bottom: bottom.zW,
        right: right.zW,
        left: left.zW,
      );

  EdgeInsets get h => copyWith(
        top: top.zH,
        bottom: bottom.zH,
        right: right.zH,
        left: left.zH,
      );
}

/// @nodoc
extension ZIMBorderRaduisExtension on BorderRadius {
  /// Creates adapt BorderRadius using r [ZIMSizeExtension].
  BorderRadius get r => copyWith(
        bottomLeft: bottomLeft.zR,
        bottomRight: bottomRight.zR,
        topLeft: topLeft.zR,
        topRight: topRight.zR,
      );

  BorderRadius get w => copyWith(
        bottomLeft: bottomLeft.zW,
        bottomRight: bottomRight.zW,
        topLeft: topLeft.zW,
        topRight: topRight.zW,
      );

  BorderRadius get h => copyWith(
        bottomLeft: bottomLeft.zH,
        bottomRight: bottomRight.zH,
        topLeft: topLeft.zH,
        topRight: topRight.zH,
      );
}

/// @nodoc
extension ZIMRaduisExtension on Radius {
  /// Creates adapt Radius using r [ZIMSizeExtension].
  Radius get zR => Radius.elliptical(x.zR, y.zR);

  Radius get zDM => Radius.elliptical(
        x.zDM,
        y.zDM,
      );

  Radius get zDG => Radius.elliptical(
        x.zDG,
        y.zDG,
      );

  Radius get zW => Radius.elliptical(x.zW, y.zW);

  Radius get zH => Radius.elliptical(x.zH, y.zH);
}

/// @nodoc
extension ZIMBoxConstraintsExtension on BoxConstraints {
  /// Creates adapt BoxConstraints using r [ZIMSizeExtension].
  BoxConstraints get zR => copyWith(
        maxHeight: maxHeight.zR,
        maxWidth: maxWidth.zR,
        minHeight: minHeight.zR,
        minWidth: minWidth.zR,
      );

  /// Creates adapt BoxConstraints using h-w [ZIMSizeExtension].
  BoxConstraints get zHW => copyWith(
        maxHeight: maxHeight.zH,
        maxWidth: maxWidth.zW,
        minHeight: minHeight.zH,
        minWidth: minWidth.zW,
      );

  BoxConstraints get zW => copyWith(
        maxHeight: maxHeight.zW,
        maxWidth: maxWidth.zW,
        minHeight: minHeight.zW,
        minWidth: minWidth.zW,
      );

  BoxConstraints get zH => copyWith(
        maxHeight: maxHeight.zH,
        maxWidth: maxWidth.zH,
        minHeight: minHeight.zH,
        minWidth: minWidth.zH,
      );
}
