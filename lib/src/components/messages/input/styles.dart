import 'package:flutter/material.dart';

/// Style/UI builders class for ZIMKitMessageInput
class ZIMKitMessageInputStyles {
  const ZIMKitMessageInputStyles({
    this.theme,
    this.inputDecoration,
    this.inputBackgroundDecoration,
    this.containerPadding,
    this.containerDecoration,
    this.sendButtonWidget,
    this.pickMediaButtonWidget,
    this.pickFileButtonWidget,
  });

  /// Theme data
  final ThemeData? theme;

  /// Input decoration
  final InputDecoration? inputDecoration;

  /// Input background decoration
  final BoxDecoration? inputBackgroundDecoration;

  /// Container padding
  final EdgeInsetsGeometry? containerPadding;

  /// Container decoration
  final Decoration? containerDecoration;

  /// Custom send button widget
  final Widget? sendButtonWidget;

  /// Custom pick media button widget
  final Widget? pickMediaButtonWidget;

  /// Custom pick file button widget
  final Widget? pickFileButtonWidget;

  /// Create a copy of this style object with some fields replaced
  ZIMKitMessageInputStyles copyWith({
    ThemeData? theme,
    InputDecoration? inputDecoration,
    BoxDecoration? inputBackgroundDecoration,
    EdgeInsetsGeometry? containerPadding,
    Decoration? containerDecoration,
    Widget? sendButtonWidget,
    Widget? pickMediaButtonWidget,
    Widget? pickFileButtonWidget,
  }) {
    return ZIMKitMessageInputStyles(
      theme: theme ?? this.theme,
      inputDecoration: inputDecoration ?? this.inputDecoration,
      inputBackgroundDecoration:
          inputBackgroundDecoration ?? this.inputBackgroundDecoration,
      containerPadding: containerPadding ?? this.containerPadding,
      containerDecoration: containerDecoration ?? this.containerDecoration,
      sendButtonWidget: sendButtonWidget ?? this.sendButtonWidget,
      pickMediaButtonWidget:
          pickMediaButtonWidget ?? this.pickMediaButtonWidget,
      pickFileButtonWidget: pickFileButtonWidget ?? this.pickFileButtonWidget,
    );
  }
}
