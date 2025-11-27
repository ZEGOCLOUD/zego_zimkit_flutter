import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/components/emoji/picker_widget.dart';
import 'package:zego_zimkit/src/components/toolbar/more/panel.dart';
import 'package:zego_zimkit/src/components/reply/input_reply_widget.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/zimkit.dart';

import 'defines.dart';

/// Message input component with two-row layout
/// First row: Text input field with send button
/// Second row: Action toolbar with +, emoji, photo, and microphone buttons
class ZIMKitMessageInput extends StatefulWidget {
  const ZIMKitMessageInput({
    super.key,
    required this.conversationID,
    required this.recordStatus,
    this.recordEvents,
    this.conversationType = ZIMConversationType.peer,
    this.config,
    this.events,
    this.style,
  });

  final String conversationID;
  final ZIMConversationType conversationType;

  /// record abouts
  final ZIMKitAudioRecordEvents? recordEvents;
  final ZIMKitRecordStatus recordStatus;

  /// Configuration for message input
  final ZIMKitMessageInputConfigs? config;

  /// Events for message input
  final ZIMKitMessageInputEvents? events;

  /// Style for message input
  final ZIMKitMessageInputStyles? style;

  @override
  State<ZIMKitMessageInput> createState() => _ZIMKitMessageInputState();
}

class _ZIMKitMessageInputState extends State<ZIMKitMessageInput> {
  final TextEditingController _defaultEditingController =
      TextEditingController();
  final FocusNode _defaultFocusNode = FocusNode();

  TextEditingController get _editingController =>
      widget.config?.editingController ?? _defaultEditingController;
  FocusNode get _focusNode =>
      widget.config?.inputFocusNode ?? _defaultFocusNode;

  ZIMKitInputPanelType _currentPanel = ZIMKitInputPanelType.none;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.config?.closePanelNotifier?.addListener(_onClosePanelRequested);
  }

  void _onClosePanelRequested() {
    closePanels();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.config?.closePanelNotifier?.removeListener(_onClosePanelRequested);
    if (widget.config?.inputFocusNode == null) {
      _defaultFocusNode.dispose();
    }
    if (widget.config?.editingController == null) {
      _defaultEditingController.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _currentPanel = ZIMKitInputPanelType.keyboard;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.style?.theme ?? Theme.of(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply state UI
          if (widget.config?.repliedMessage != null)
            ZIMKitInputReplyWidget(
              repliedMessage: widget.config!.repliedMessage!,
              onCancel: () {
                widget.events?.onReplyCancelled?.call();
              },
            ),
          // Input area
          Container(
            decoration: widget.style?.containerDecoration ??
                BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 0.5.zW),
                  ),
                ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Input field
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.zW,
                      vertical: 8.zH,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: 36.zH,
                              maxHeight: 100.zH,
                            ),
                            decoration:
                                widget.style?.inputBackgroundDecoration ??
                                    BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6.zR),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1.zW,
                                      ),
                                    ),
                            child: TextField(
                              controller: _editingController,
                              focusNode: _focusNode,
                              maxLines: widget.config?.maxLines,
                              keyboardType: widget.config?.keyboardType ??
                                  TextInputType.multiline,
                              textInputAction: widget.config?.textInputAction ??
                                  TextInputAction.newline,
                              textCapitalization:
                                  widget.config?.textCapitalization ??
                                      TextCapitalization.sentences,
                              decoration: widget.style?.inputDecoration ??
                                  InputDecoration(
                                    hintText: ZIMKitCore
                                        .instance.innerText.messageEmptyText,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.zW,
                                      vertical: 8.zH,
                                    ),
                                  ),
                              onChanged: (text) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8.zW),
                        // Send button or placeholder
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _editingController,
                          builder: (context, textValue, child) {
                            if (textValue.text.trim().isNotEmpty) {
                              return _buildSendButton();
                            } else {
                              return SizedBox(width: 36.zW, height: 36.zH);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Row 2: Toolbar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.zW,
                      vertical: 8.zH,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // + button
                        if (widget.config?.showMoreButton ?? true)
                          _buildToolbarButton(
                            icon: Icons.add_circle_outline,
                            isActive:
                                _currentPanel == ZIMKitInputPanelType.more,
                            onTap: _toggleMorePanel,
                          ),
                        // Emoji button
                        if (widget.config?.showEmojiButton ?? true)
                          _buildToolbarButton(
                            icon: Icons.sentiment_satisfied_outlined,
                            isActive:
                                _currentPanel == ZIMKitInputPanelType.emoji,
                            onTap: _toggleEmojiPanel,
                          ),
                        // Photo button
                        if (widget.config?.showPickMediaButton ?? true)
                          _buildToolbarButton(
                            icon: Icons.image_outlined,
                            onTap: _pickImages,
                          ),
                        // Microphone button (Record audio)
                        if (widget.config?.showRecordButton ?? true)
                          SizedBox(
                            width: 40.zW,
                            height: 40.zH,
                            child: ZIMKitRecordButton(
                              status: widget.recordStatus,
                              conversationID: widget.conversationID,
                              conversationType: widget.conversationType,
                              onMessageSent: widget.events?.onMessageSent,
                              preMessageSending:
                                  widget.events?.preMessageSending,
                              events: widget.recordEvents,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.mic_none,
                                size: 28.zW,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom panel (emoji or more)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.zW,
        height: 40.zH,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 28.zW,
          color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _sendTextMessage,
      child: Container(
        width: 36.zW,
        height: 36.zH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: widget.style?.sendButtonWidget ??
            Icon(Icons.send, color: Colors.white, size: 20.zW),
      ),
    );
  }

  Widget _buildBottomPanel() {
    switch (_currentPanel) {
      case ZIMKitInputPanelType.emoji:
        return ZIMKitEmojiPickerWidget(
          key: const ValueKey('emoji'),
          onEmojiSelected: (emoji) {
            _editingController.text += emoji;
            setState(() {});
          },
        );
      case ZIMKitInputPanelType.more:
        // Extract widgets from actions with location 'more'
        final extraActions = widget.config?.actions
                .where(
                  (action) =>
                      action.location == ZIMKitMessageInputActionLocation.more,
                )
                .map((action) => action.child)
                .toList() ??
            [];
        return ZIMKitMoreActionsPanelWidget(
          key: const ValueKey('more'),
          conversationID: widget.conversationID,
          conversationType: widget.conversationType,
          onActionSelected: _handleMoreAction,
          extraActions: extraActions,
        );
      default:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  void _toggleEmojiPanel() {
    _focusNode.unfocus();
    setState(() {
      _currentPanel = _currentPanel == ZIMKitInputPanelType.emoji
          ? ZIMKitInputPanelType.none
          : ZIMKitInputPanelType.emoji;
    });
  }

  void _toggleMorePanel() {
    _focusNode.unfocus();
    setState(() {
      _currentPanel = _currentPanel == ZIMKitInputPanelType.more
          ? ZIMKitInputPanelType.none
          : ZIMKitInputPanelType.more;
    });
  }

  // Public method to close panels
  void closePanels() {
    if (_currentPanel != ZIMKitInputPanelType.none) {
      setState(() {
        _currentPanel = ZIMKitInputPanelType.none;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 9,
          requestType: RequestType.image,
        ),
      );

      if (result != null && result.isNotEmpty) {
        for (final asset in result) {
          final file = await asset.file;
          if (file != null) {
            final platformFile = ZIMKitPlatformFile(
              path: file.path,
              name: file.path.split('/').last,
              size: await file.length(),
            );
            await ZIMKit().sendMediaMessage(
              widget.conversationID,
              widget.conversationType,
              [platformFile],
              onMessageSent: _onMessageSent,
              preMessageSending: _onMessagePreSend,
            );
          }
        }
      }

      setState(() {
        _currentPanel = ZIMKitInputPanelType.none;
      });
    } catch (e) {
      debugPrint('Pick images error: $e');
    }
  }

  Future<void> _handleMoreAction(
      ZIMKitMoreActionsPanelAction action, dynamic data) async {
    try {
      switch (action) {
        case ZIMKitMoreActionsPanelAction.takePhoto:
          if (data is AssetEntity) {
            final file = await data.file;
            if (file != null) {
              final platformFile = ZIMKitPlatformFile(
                path: file.path,
                name: file.path.split('/').last,
                size: await file.length(),
              );
              await ZIMKit().sendMediaMessage(
                widget.conversationID,
                widget.conversationType,
                [platformFile],
                onMessageSent: _onMessageSent,
                preMessageSending: _onMessagePreSend,
              );
            }
          }
          break;
        case ZIMKitMoreActionsPanelAction.pickImages:
          if (data is List<AssetEntity>) {
            for (final asset in data) {
              final file = await asset.file;
              if (file != null) {
                final platformFile = ZIMKitPlatformFile(
                  path: file.path,
                  name: file.path.split('/').last,
                  size: await file.length(),
                );
                await ZIMKit().sendMediaMessage(
                  widget.conversationID,
                  widget.conversationType,
                  [platformFile],
                  onMessageSent: _onMessageSent,
                  preMessageSending: _onMessagePreSend,
                );
              }
            }
          }
          break;
        case ZIMKitMoreActionsPanelAction.pickFiles:
          if (data is List<AssetEntity>) {
            for (final asset in data) {
              final file = await asset.file;
              if (file != null) {
                await ZIMKit().sendFileMessage(
                  widget.conversationID,
                  widget.conversationType,
                  [
                    ZIMKitPlatformFile(
                      path: file.path,
                      name: file.path.split('/').last,
                      size: await file.length(),
                    ),
                  ],
                  onMessageSent: _onMessageSent,
                  preMessageSending: _onMessagePreSend,
                );
              }
            }
          }
          break;
      }

      setState(() {
        _currentPanel = ZIMKitInputPanelType.none;
      });
    } catch (e) {
      debugPrint('Handle more action error: $e');
    }
  }

  Future<void> _sendTextMessage() async {
    final text = _editingController.text.trim();
    if (text.isEmpty) return;

    _editingController.clear();

    await ZIMKit().sendTextMessage(
      widget.conversationID,
      widget.conversationType,
      text,
      repliedMessage: widget.config?.repliedMessage,
      onMessageSent: _onMessageSent,
      preMessageSending: _onMessagePreSend,
    );

    // Clear reply state after sending
    widget.events?.onReplyCancelled?.call();
  }

  void _onMessageSent(ZIMKitMessage message) {
    widget.events?.onMessageSent?.call(message);
  }

  Future<ZIMKitMessage> _onMessagePreSend(ZIMKitMessage message) async {
    await widget.events?.preMessageSending?.call(message);
    return message;
  }
}
