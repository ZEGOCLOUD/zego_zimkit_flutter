import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/components/emoji/picker_widget.dart';
import 'package:zego_zimkit/src/components/toolbar/more/panel.dart';
import 'package:zego_zimkit/src/components/toolbar/more/zimkit_camera_picker_state.dart';
import 'package:zego_zimkit/src/components/reply/input_reply_widget.dart';
import 'package:zego_zimkit/src/config.defines.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/services/path_platform_file.dart';
import 'package:zego_zimkit/src/zimkit.dart';

import 'defines.dart';
import 'config_resolver.dart';

/// Message input component with text and voice input modes.
class ZIMKitMessageInput extends StatefulWidget {
  const ZIMKitMessageInput({
    super.key,
    required this.conversationID,
    required this.recordStatus,
    this.recordEvents,
    this.conversationType = ZIMConversationType.peer,
    this.inputConfig,
    this.config,
    this.events,
    this.style,
  });

  final String conversationID;
  final ZIMConversationType conversationType;

  /// Global ZIMKit input configuration.
  final ZIMKitInputConfig? inputConfig;

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
  bool _isVoiceInputMode = false;

  ZIMKitInputConfig get _inputConfig =>
      widget.inputConfig ?? ZIMKitInputConfig();

  ZIMKitResolvedInputButtons get _resolvedButtons => resolveZIMKitInputButtons(
    globalConfig: _inputConfig,
    pageConfig: widget.config ?? const ZIMKitMessageInputConfigs(),
  );

  bool get _hasInlineAudioButton =>
      _resolvedButtons.smallButtons.contains(ZIMKitInputButtonName.audio);

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
            decoration:
                widget.style?.containerDecoration ??
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
                  // Row 1: Text input or hold-to-talk button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.zW,
                      vertical: 8.zH,
                    ),
                    child: _isVoiceInputMode
                        ? _buildVoiceInputButton()
                        : _buildTextInputRow(),
                  ),
                  // Row 2: Toolbar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.zW,
                      vertical: 8.zH,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _buildToolbarButtons(),
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

  InputDecoration get _inputDecoration {
    final configured = widget.style?.inputDecoration;
    final defaultHint =
        _inputConfig.placeholder ??
        ZIMKitCore.instance.innerText.messageEmptyText;
    if (configured != null) {
      return configured.copyWith(hintText: configured.hintText ?? defaultHint);
    }
    return InputDecoration(
      hintText: defaultHint,
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.zW, vertical: 8.zH),
    );
  }

  Widget _buildTextInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            constraints: BoxConstraints(minHeight: 36.zH, maxHeight: 100.zH),
            decoration:
                widget.style?.inputBackgroundDecoration ??
                BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.zR),
                  border: Border.all(color: Colors.grey[300]!, width: 1.zW),
                ),
            child: TextField(
              controller: _editingController,
              focusNode: _focusNode,
              maxLines: widget.config?.maxLines,
              keyboardType:
                  widget.config?.keyboardType ?? TextInputType.multiline,
              textInputAction:
                  widget.config?.textInputAction ?? TextInputAction.newline,
              textCapitalization:
                  widget.config?.textCapitalization ??
                  TextCapitalization.sentences,
              decoration: _inputDecoration,
              onChanged: (text) {
                setState(() {});
              },
            ),
          ),
        ),
        SizedBox(width: 8.zW),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _editingController,
          builder: (context, textValue, child) {
            return _buildSendButton(enabled: textValue.text.trim().isNotEmpty);
          },
        ),
      ],
    );
  }

  Widget _buildVoiceInputButton() {
    final innerText = ZIMKitCore.instance.innerText;
    return SizedBox(
      width: double.infinity,
      height: 36.zH,
      child: ZIMKitRecordButton(
        status: widget.recordStatus,
        conversationID: widget.conversationID,
        conversationType: widget.conversationType,
        onMessageSent: widget.events?.onMessageSent,
        preMessageSending: widget.events?.preMessageSending,
        events: widget.recordEvents,
        padding: EdgeInsets.zero,
        icon: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration:
              widget.style?.inputBackgroundDecoration ??
              BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.zR),
                border: Border.all(color: Colors.grey[300]!, width: 1.zW),
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_none, size: 20.zW, color: Colors.grey[700]),
              SizedBox(width: 8.zW),
              Text(
                innerText.holdToTalkText,
                style: TextStyle(fontSize: 14.zSP, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildToolbarButtons() {
    final buttons = _resolvedButtons.smallButtons
        .map(_buildConfiguredButton)
        .toList();
    final customButtons = _inputConfig.customButtonBuilders;
    final customModeToggle = _hasInlineAudioButton
        ? customButtons?.containsKey(ZIMKitInputButtonName.audio) ?? false
        : customButtons?.containsKey(ZIMKitInputButtonName.expand) ?? false;

    if (_isVoiceInputMode && customModeToggle) {
      buttons.add(_buildTextModeButton());
    }
    return buttons;
  }

  Widget _buildConfiguredButton(ZIMKitInputButtonName button) {
    final customBuilder = _inputConfig.customButtonBuilders?[button];
    if (customBuilder != null) return customBuilder(context);

    if (_isVoiceInputMode &&
        (button == ZIMKitInputButtonName.audio ||
            (button == ZIMKitInputButtonName.expand &&
                !_hasInlineAudioButton))) {
      return _buildTextModeButton();
    }

    return switch (button) {
      ZIMKitInputButtonName.audio => _buildToolbarButton(
        icon: Icons.mic_none,
        onTap: _showVoiceInputMode,
      ),
      ZIMKitInputButtonName.emoji => _buildToolbarButton(
        icon: Icons.sentiment_satisfied_outlined,
        isActive: _currentPanel == ZIMKitInputPanelType.emoji,
        onTap: _toggleEmojiPanel,
      ),
      ZIMKitInputButtonName.picture => _buildToolbarButton(
        icon: Icons.image_outlined,
        onTap: _pickImages,
      ),
      ZIMKitInputButtonName.takePhoto => _buildToolbarButton(
        icon: Icons.camera_alt_outlined,
        onTap: _takePhoto,
      ),
      ZIMKitInputButtonName.voiceCall => _buildToolbarButton(
        icon: Icons.call_outlined,
        onTap: () => _onCallButtonTap(button),
      ),
      ZIMKitInputButtonName.videoCall => _buildToolbarButton(
        icon: Icons.videocam_outlined,
        onTap: () => _onCallButtonTap(button),
      ),
      ZIMKitInputButtonName.file => _buildToolbarButton(
        icon: Icons.attach_file,
        onTap: _pickFiles,
      ),
      ZIMKitInputButtonName.expand => _buildToolbarButton(
        icon: Icons.add_circle_outline,
        isActive: _currentPanel == ZIMKitInputPanelType.more,
        onTap: _toggleMorePanel,
      ),
    };
  }

  Widget _buildTextModeButton() {
    return ValueListenableBuilder<ZIMKitRecordLockerState>(
      valueListenable: widget.recordStatus.lockerStateNotifier,
      builder: (context, lockState, _) {
        return _buildToolbarButton(
          icon: Icons.keyboard,
          enabled: lockState != ZIMKitRecordLockerState.locked,
          onTap: _showTextInputMode,
        );
      },
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    bool isActive = false,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40.zW,
        height: 40.zH,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 28.zW,
          color: enabled
              ? (isActive ? Theme.of(context).primaryColor : Colors.grey[600])
              : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSendButton({required bool enabled}) {
    final sendButtonWidget = widget.style?.sendButtonWidget;
    return IgnorePointer(
      ignoring: !enabled,
      child: GestureDetector(
        onTap: enabled ? _sendTextMessage : null,
        child: Container(
          width: 36.zW,
          height: 36.zH,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? Theme.of(context).primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: sendButtonWidget == null
              ? Icon(
                  Icons.send,
                  color: enabled ? Colors.white : Colors.grey[700],
                  size: 20.zW,
                )
              : Opacity(opacity: enabled ? 1 : 0.6, child: sendButtonWidget),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    switch (_currentPanel) {
      case ZIMKitInputPanelType.emoji:
        return ZIMKitEmojiPickerWidget(
          key: const ValueKey('emoji'),
          emojis: _inputConfig.emojis,
          onEmojiSelected: (emoji) {
            _editingController.text += emoji;
            setState(() {});
          },
        );
      case ZIMKitInputPanelType.more:
        // Extract widgets from actions with location 'more'
        final extraActions =
            widget.config?.actions
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
          configuredButtons: _resolvedButtons.expandButtons
              .map(_buildExpandedButton)
              .toList(),
        );
      default:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  Widget _buildExpandedButton(ZIMKitInputButtonName button) {
    final customBuilder = _inputConfig.customButtonBuilders?[button];
    if (customBuilder != null) return customBuilder(context);

    final innerText = ZIMKitCore.instance.innerText;
    return switch (button) {
      ZIMKitInputButtonName.audio => buildZIMKitInputMoreActionItem(
        context,
        icon: Icons.mic_none,
        label: innerText.voiceInputText,
        onTap: _showVoiceInputMode,
      ),
      ZIMKitInputButtonName.emoji => buildZIMKitInputMoreActionItem(
        context,
        icon: Icons.sentiment_satisfied_outlined,
        label: innerText.emojiInputText,
        onTap: _toggleEmojiPanel,
      ),
      ZIMKitInputButtonName.picture => buildZIMKitInputMoreActionItem(
        context,
        icon: Icons.image,
        label: innerText.photoText,
        onTap: _pickImages,
      ),
      ZIMKitInputButtonName.takePhoto => buildZIMKitInputMoreActionItem(
        context,
        icon: Icons.camera_alt,
        label: innerText.takePhotoText,
        onTap: _takePhoto,
      ),
      ZIMKitInputButtonName.voiceCall => buildZIMKitInputMoreActionItem(
        context,
        icon: Icons.call_outlined,
        label: innerText.voiceCallInputText,
        onTap: () => _onCallButtonTap(button),
      ),
      ZIMKitInputButtonName.videoCall => buildZIMKitInputMoreActionItem(
        context,
        icon: Icons.videocam_outlined,
        label: innerText.videoCallInputText,
        onTap: () => _onCallButtonTap(button),
      ),
      ZIMKitInputButtonName.file => buildZIMKitInputMoreActionItem(
        context,
        icon: Icons.folder,
        label: innerText.fileText,
        onTap: _pickFiles,
      ),
      ZIMKitInputButtonName.expand => const SizedBox.shrink(),
    };
  }

  void _onCallButtonTap(ZIMKitInputButtonName button) {
    setState(() => _currentPanel = ZIMKitInputPanelType.none);
    widget.events?.onCallTap?.call(button);
  }

  void _showVoiceInputMode() {
    _focusNode.unfocus();
    setState(() {
      _isVoiceInputMode = true;
      _currentPanel = ZIMKitInputPanelType.none;
    });
  }

  void _showTextInputMode() {
    setState(() {
      _isVoiceInputMode = false;
      _currentPanel = ZIMKitInputPanelType.none;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
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
          await _sendAsset(asset);
        }
      }

      setState(() {
        _currentPanel = ZIMKitInputPanelType.none;
      });
    } catch (e) {
      debugPrint('Pick images error: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final asset = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(),
        createPickerState: ZIMKitCameraPickerState.new,
      );
      if (asset != null) await _sendAsset(asset);
      if (mounted) setState(() => _currentPanel = ZIMKitInputPanelType.none);
    } catch (error) {
      debugPrint('Take photo error: $error');
    }
  }

  Future<void> _pickFiles() async {
    try {
      final assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 9,
          requestType: RequestType.common,
        ),
      );
      if (assets != null) {
        for (final asset in assets) {
          await _sendAsset(asset, asFile: true);
        }
      }
      if (mounted) setState(() => _currentPanel = ZIMKitInputPanelType.none);
    } catch (error) {
      debugPrint('Pick files error: $error');
    }
  }

  Future<void> _sendAsset(AssetEntity asset, {bool asFile = false}) async {
    final file = await asset.file;
    if (file == null) return;
    final platformFile = ZIMKitPathPlatformFile(
      path: file.path,
      name: file.path.split('/').last,
      size: await file.length(),
    );
    if (asFile) {
      await ZIMKit().sendFileMessage(
        widget.conversationID,
        widget.conversationType,
        [platformFile],
        onMessageSent: _onMessageSent,
        preMessageSending: _onMessagePreSend,
      );
    } else {
      await ZIMKit().sendMediaMessage(
        widget.conversationID,
        widget.conversationType,
        [platformFile],
        onMessageSent: _onMessageSent,
        preMessageSending: _onMessagePreSend,
      );
    }
  }

  Future<void> _handleMoreAction(
    ZIMKitMoreActionsPanelAction action,
    dynamic data,
  ) async {
    try {
      switch (action) {
        case ZIMKitMoreActionsPanelAction.takePhoto:
          if (data is AssetEntity) {
            await _sendAsset(data);
          }
          break;
        case ZIMKitMoreActionsPanelAction.pickImages:
          if (data is List<AssetEntity>) {
            for (final asset in data) {
              await _sendAsset(asset);
            }
          }
          break;
        case ZIMKitMoreActionsPanelAction.pickFiles:
          if (data is List<AssetEntity>) {
            for (final asset in data) {
              await _sendAsset(asset, asFile: true);
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
