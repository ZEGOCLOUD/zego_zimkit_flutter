import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util_config.dart';
import 'package:zego_zimkit/src/zimkit.dart';

import 'conversation_settings.dart';

/// Single chat detail and settings page.
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

  @override
  void initState() {
    super.initState();
    _loadConversationInfo();
  }

  @override
  void dispose() {
    _userName.dispose();
    _avatarUrl.dispose();
    super.dispose();
  }

  Future<void> _loadConversationInfo() async {
    try {
      final conversation = ZIMKit().getConversation(
        widget.conversationID,
        widget.conversationType,
      );
      _userName.value = conversation.value.name;
      _avatarUrl.value = conversation.value.avatarUrl;
      if (widget.conversationType == ZIMConversationType.peer) {
        final userInfo = await ZIMKit().queryUser(widget.conversationID);
        _userName.value = userInfo.baseInfo.userName;
        _avatarUrl.value = userInfo.baseInfo.userAvatarUrl;
      }
    } catch (error) {
      debugPrint('Load conversation info error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZIMScreenUtilInit(
      designSize: ZIMKitScreenUtilConfig.designSize,
      builder: (context, child) => Scaffold(
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
            _buildUserInfo(),
            SizedBox(height: 20.zH),
            ZIMKitConversationSettings(
              conversationID: widget.conversationID,
              conversationType: widget.conversationType,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 30.zH),
      child: Center(
        child: ValueListenableBuilder<String>(
          valueListenable: _userName,
          builder: (context, userName, child) => ValueListenableBuilder<String>(
            valueListenable: _avatarUrl,
            builder: (context, avatarUrl, child) => Column(
              children: [
                CircleAvatar(
                  radius: 45.zR,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
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
            ),
          ),
        ),
      ),
    );
  }
}
