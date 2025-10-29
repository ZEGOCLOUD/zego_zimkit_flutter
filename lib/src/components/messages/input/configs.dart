import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'action.dart';

/// Configuration class for ZIMKitMessageInput
class ZIMKitMessageInputConfigs {
  const ZIMKitMessageInputConfigs({
    this.showPickFileButton = true,
    this.showPickMediaButton = true,
    this.showMoreButton = true,
    this.showRecordButton = true,
    this.showEmojiButton = true,
    this.actions = const [],
    this.editingController,
    this.inputFocusNode,
    this.listScrollController,
    this.closePanelNotifier,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.textInputAction,
    this.textCapitalization,
    this.repliedMessage,
  });

  /// Show pick file button
  final bool showPickFileButton;

  /// Show pick media button
  final bool showPickMediaButton;

  /// Show more button
  final bool showMoreButton;

  /// Show record button
  final bool showRecordButton;

  /// Show emoji button
  final bool showEmojiButton;

  /// Custom actions
  final List<ZIMKitMessageInputAction> actions;

  /// Text editing controller
  final TextEditingController? editingController;

  /// Input focus node
  final FocusNode? inputFocusNode;

  /// List scroll controller
  final ScrollController? listScrollController;

  /// Close panel notifier
  final ValueNotifier<int>? closePanelNotifier;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Max lines
  final int? maxLines;

  /// Min lines
  final int? minLines;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Text capitalization
  final TextCapitalization? textCapitalization;

  /// Replied message for reply feature
  final ZIMKitMessage? repliedMessage;

  /// Create a copy of this config object with some fields replaced
  ZIMKitMessageInputConfigs copyWith({
    bool? showPickFileButton,
    bool? showPickMediaButton,
    bool? showMoreButton,
    bool? showRecordButton,
    bool? showEmojiButton,
    List<ZIMKitMessageInputAction>? actions,
    TextEditingController? editingController,
    FocusNode? inputFocusNode,
    ScrollController? listScrollController,
    ValueNotifier<int>? closePanelNotifier,
    TextInputType? keyboardType,
    int? maxLines,
    int? minLines,
    TextInputAction? textInputAction,
    TextCapitalization? textCapitalization,
    ZIMKitMessage? repliedMessage,
  }) {
    return ZIMKitMessageInputConfigs(
      showPickFileButton: showPickFileButton ?? this.showPickFileButton,
      showPickMediaButton: showPickMediaButton ?? this.showPickMediaButton,
      showMoreButton: showMoreButton ?? this.showMoreButton,
      showRecordButton: showRecordButton ?? this.showRecordButton,
      showEmojiButton: showEmojiButton ?? this.showEmojiButton,
      actions: actions ?? this.actions,
      editingController: editingController ?? this.editingController,
      inputFocusNode: inputFocusNode ?? this.inputFocusNode,
      listScrollController: listScrollController ?? this.listScrollController,
      closePanelNotifier: closePanelNotifier ?? this.closePanelNotifier,
      keyboardType: keyboardType ?? this.keyboardType,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      textInputAction: textInputAction ?? this.textInputAction,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      repliedMessage: repliedMessage ?? this.repliedMessage,
    );
  }
}
