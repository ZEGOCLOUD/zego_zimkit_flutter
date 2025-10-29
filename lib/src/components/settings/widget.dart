import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util_config.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Single chat detail and settings page
/// Provides conversation settings including pinning and notification preferences
class ZIMKitSingleChatDetailPage extends StatefulWidget {
  const ZIMKitSingleChatDetailPage({
    super.key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
  });

  final String conversationID;
  final ZIMConversationType conversationType;

  @override
  State<ZIMKitSingleChatDetailPage> createState() =>
      _ZIMKitSingleChatDetailPageState();
}

class _ZIMKitSingleChatDetailPageState
    extends State<ZIMKitSingleChatDetailPage> {
  final ValueNotifier<String> _userName = ValueNotifier('');
  final ValueNotifier<String> _avatarUrl = ValueNotifier('');
  final ValueNotifier<bool> _isPinned = ValueNotifier(false);
  final ValueNotifier<bool> _isNotDisturb = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadConversationInfo();
  }

  @override
  void dispose() {
    _userName.dispose();
    _avatarUrl.dispose();
    _isPinned.dispose();
    _isNotDisturb.dispose();
    super.dispose();
  }

  Future<void> _loadConversationInfo() async {
    try {
      // Get conversation info
      final conversation = ZIMKit().getConversation(
        widget.conversationID,
        widget.conversationType,
      );

      _isPinned.value = conversation.value.isPinned;
      _isNotDisturb.value = conversation.value.notificationStatus ==
          ZIMConversationNotificationStatus.doNotDisturb;
      _userName.value = conversation.value.name;
      _avatarUrl.value = conversation.value.avatarUrl;

      // For single chat, get user detail info
      if (widget.conversationType == ZIMConversationType.peer) {
        final userInfo = await ZIMKit().queryUser(widget.conversationID);
        _userName.value = userInfo.baseInfo.userName;
        _avatarUrl.value = userInfo.baseInfo.userAvatarUrl;
      }
    } catch (e) {
      debugPrint('Load conversation info error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZIMScreenUtilInit(
      designSize: ZIMKitScreenUtilConfig.designSize,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text(
              ZIMKitCore.instance.innerText.chatSettingsTitle,
              style: TextStyle(fontSize: 20.zSP),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5.zW,
          ),
          body: Column(
            children: [
              SizedBox(height: 20.zH),
              // User info section
              _buildUserInfo(),
              SizedBox(height: 20.zH),
              // Settings section
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildChatPinSetting(),
                    Divider(height: 1.zH, color: Colors.grey[200]),
                    _buildChatNotDisturbSetting(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatNotDisturbSetting() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isNotDisturb,
      builder: (context, isNotDisturb, child) {
        return _buildSwitchItem(
          title: ZIMKitCore.instance.innerText.chatNotDisturbTitle,
          value: isNotDisturb,
          onChanged: (value) async {
            try {
              await ZIMKit().setConversationNotificationStatus(
                widget.conversationID,
                widget.conversationType,
                value
                    ? ZIMConversationNotificationStatus.doNotDisturb
                    : ZIMConversationNotificationStatus.notify,
              );
              _isNotDisturb.value = value;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? ZIMKitCore.instance.innerText.notDisturbEnabledToast
                          : ZIMKitCore
                              .instance.innerText.notDisturbDisabledToast,
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Update notification status error: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ZIMKitCore.instance.innerText.operationFailedFormat
                          .replaceFirst('%s', '$e'),
                    ),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildChatPinSetting() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPinned,
      builder: (context, isPinned, child) {
        return _buildSwitchItem(
          title: ZIMKitCore.instance.innerText.chatPinnedTitle,
          value: isPinned,
          onChanged: (value) async {
            try {
              await ZIMKit().updateConversationPinnedState(
                widget.conversationID,
                widget.conversationType,
                value,
              );
              _isPinned.value = value;
              if (mounted) {
                showTips(
                  value
                      ? ZIMKitCore.instance.innerText.pinnedToast
                      : ZIMKitCore.instance.innerText.unpinnedToast,
                );
              }
            } catch (e) {
              debugPrint('Update pinned state error: $e');
              if (mounted) {
                showTips(
                  ZIMKitCore.instance.innerText.operationFailedFormat
                      .replaceFirst('%s', '$e'),
                );
              }
            }
          },
        );
      },
    );
  }

  void showTips(String tips) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tips), duration: const Duration(seconds: 1)),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 30.zH),
      child: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: _userName,
          builder: (context, userName, child) {
            return ValueListenableBuilder<String>(
              valueListenable: _avatarUrl,
              builder: (context, avatarUrl, child) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 45.zR,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl.isEmpty
                          ? Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 36.zSP,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(height: 15.zH),
                    Text(
                      userName.isEmpty ? 'Unknown' : userName,
                      style: TextStyle(
                        fontSize: 20.zSP,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.zW),
      height: 56.zH,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.zSP, color: Colors.black87),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3478F6),
          ),
        ],
      ),
    );
  }
}
