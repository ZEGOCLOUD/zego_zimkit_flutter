import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/components/settings/notifier_update.dart';
import 'package:zego_zimkit/src/zimkit.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

/// Shared pin and notification settings for peer and group conversations.
class ZIMKitConversationSettings extends StatefulWidget {
  const ZIMKitConversationSettings({
    super.key,
    required this.conversationID,
    required this.conversationType,
  });

  final String conversationID;
  final ZIMConversationType conversationType;

  @override
  State<ZIMKitConversationSettings> createState() =>
      _ZIMKitConversationSettingsState();
}

class _ZIMKitConversationSettingsState
    extends State<ZIMKitConversationSettings> {
  late final ValueNotifier<bool> _isPinned;
  late final ValueNotifier<bool> _isNotDisturb;

  @override
  void initState() {
    super.initState();
    final conversation = ZIMKit().getConversation(
      widget.conversationID,
      widget.conversationType,
    );
    _isPinned = ValueNotifier(conversation.value.isPinned);
    _isNotDisturb = ValueNotifier(
      conversation.value.notificationStatus ==
          ZIMConversationNotificationStatus.doNotDisturb,
    );
  }

  @override
  void dispose() {
    _isPinned.dispose();
    _isNotDisturb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildSwitch(
            title: ZIMKitCore.instance.innerText.chatPinnedTitle,
            notifier: _isPinned,
            update: _updatePinned,
          ),
          Divider(height: 1.zH, color: Colors.grey[200]),
          _buildSwitch(
            title: ZIMKitCore.instance.innerText.chatNotDisturbTitle,
            notifier: _isNotDisturb,
            update: _updateNotDisturb,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required ValueNotifier<bool> notifier,
    required Future<void> Function(bool value) update,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, child) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.zW),
        height: 56.zH,
        child: Row(
          children: [
            Text(title, style: TextStyle(fontSize: 16.zSP)),
            const Spacer(),
            Switch(
              value: value,
              onChanged: update,
              activeThumbColor: const Color(0xFF3478F6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePinned(bool value) async {
    try {
      await ZIMKit().updateConversationPinnedState(
        widget.conversationID,
        widget.conversationType,
        value,
      );
      updateNotifierWhenMounted(
        notifier: _isPinned,
        value: value,
        isMounted: mounted,
      );
      if (mounted) {
        _showTip(
          value
              ? ZIMKitCore.instance.innerText.pinnedToast
              : ZIMKitCore.instance.innerText.unpinnedToast,
        );
      }
    } catch (error) {
      _showFailure(error);
    }
  }

  Future<void> _updateNotDisturb(bool value) async {
    try {
      await ZIMKit().setConversationNotificationStatus(
        widget.conversationID,
        widget.conversationType,
        value
            ? ZIMConversationNotificationStatus.doNotDisturb
            : ZIMConversationNotificationStatus.notify,
      );
      updateNotifierWhenMounted(
        notifier: _isNotDisturb,
        value: value,
        isMounted: mounted,
      );
      if (mounted) {
        _showTip(
          value
              ? ZIMKitCore.instance.innerText.notDisturbEnabledToast
              : ZIMKitCore.instance.innerText.notDisturbDisabledToast,
        );
      }
    } catch (error) {
      _showFailure(error);
    }
  }

  void _showTip(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _showFailure(Object error) {
    if (!mounted) return;
    _showTip(
      ZIMKitCore.instance.innerText.operationFailedFormat.replaceFirst(
        '%s',
        '$error',
      ),
    );
  }
}
