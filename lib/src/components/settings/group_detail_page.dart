import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/settings/conversation_settings.dart';
import 'package:zego_zimkit/src/components/settings/group_member_actions.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/extensions/flutter_extension.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util_config.dart';
import 'package:zego_zimkit/src/zimkit.dart';

/// Lets the host application select user IDs to invite into a group.
typedef ZIMKitGroupMemberPicker =
    Future<List<String>?> Function(
      BuildContext context,
      List<ZIMKitGroupMemberInfo> currentMembers,
    );

/// Group information, member management, and conversation settings page.
class ZIMKitGroupDetailPage extends StatefulWidget {
  const ZIMKitGroupDetailPage({
    super.key,
    required this.groupID,
    this.onInviteMembers,
  });

  final String groupID;
  final ZIMKitGroupMemberPicker? onInviteMembers;

  @override
  State<ZIMKitGroupDetailPage> createState() => _ZIMKitGroupDetailPageState();
}

class _ZIMKitGroupDetailPageState extends State<ZIMKitGroupDetailPage> {
  late final ValueListenable<ZIMKitGroupInfo> _groupInfo;
  late final ValueListenable<int> _memberCount;
  late final ValueListenable<ZIMKitConversation> _conversation;
  late final ListNotifier<ZIMGroupMemberInfo> _members;
  Object? _memberLoadError;

  @override
  void initState() {
    super.initState();
    _groupInfo = ZIMKit().queryGroupInfo(widget.groupID);
    _memberCount = ZIMKit().queryGroupMemberCount(widget.groupID);
    _members = ZIMKit().queryGroupMemberList(
      widget.groupID,
      onError: _onMemberLoadError,
    );
    _conversation = ZIMKit().getConversation(
      widget.groupID,
      ZIMConversationType.group,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZIMScreenUtilInit(
      designSize: ZIMKitScreenUtilConfig.designSize,
      builder: (context, child) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(ZIMKitCore.instance.innerText.groupDetailTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5.zW,
        ),
        body: ListView(
          children: [
            SizedBox(height: 16.zH),
            _buildGroupInfo(),
            SizedBox(height: 16.zH),
            _buildMembers(),
            SizedBox(height: 16.zH),
            ZIMKitConversationSettings(
              conversationID: widget.groupID,
              conversationType: ZIMConversationType.group,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfo() {
    return ValueListenableBuilder<ZIMKitConversation>(
      valueListenable: _conversation,
      builder: (context, conversation, child) => Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.zW, vertical: 20.zH),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32.zR,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: conversation.avatarUrl.isNotEmpty
                      ? NetworkImage(conversation.avatarUrl)
                      : null,
                  child: conversation.avatarUrl.isEmpty
                      ? const Icon(Icons.group, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 14.zW),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name.isEmpty
                            ? widget.groupID
                            : conversation.name,
                        style: TextStyle(fontSize: 18.zSP),
                      ),
                      SizedBox(height: 4.zH),
                      ValueListenableBuilder<int>(
                        valueListenable: _memberCount,
                        builder: (context, count, child) => Text(
                          '${ZIMKitCore.instance.innerText.groupIdLabel}: ${widget.groupID} · ${ZIMKitCore.instance.innerText.groupMembersText}: ${count < 0 ? '—' : count}',
                          style: TextStyle(
                            fontSize: 12.zSP,
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
          ValueListenableBuilder<ZIMKitGroupInfo>(
            valueListenable: _groupInfo,
            builder: (context, info, child) => info.notice.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 1.zH),
                    padding: EdgeInsets.all(16.zW),
                    child: Text(
                      '${ZIMKitCore.instance.innerText.groupNoticeText}: ${info.notice}',
                      style: TextStyle(fontSize: 14.zSP),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembers() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.zW, vertical: 12.zH),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ZIMKitCore.instance.innerText.groupMembersText,
                    style: TextStyle(
                      fontSize: 16.zSP,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _inviteMembers,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(ZIMKitCore.instance.innerText.groupAddMemberText),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<List<ZIMGroupMemberInfo>>(
            valueListenable: _members,
            builder: (context, members, child) {
              if (_memberLoadError != null && members.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(20.zH),
                  child: Column(
                    children: [
                      Text(
                        ZIMKitCore.instance.innerText.operationFailedFormat
                            .replaceFirst('%s', '$_memberLoadError'),
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      TextButton(
                        onPressed: _retryMemberLoad,
                        child: Text(
                          ZIMKitCore.instance.innerText.groupRetryText,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (members.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(20.zH),
                  child: Text(
                    ZIMKitCore.instance.innerText.groupNoMembersText,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }
              return Column(
                children: [
                  if (_memberLoadError != null)
                    TextButton(
                      onPressed: _retryMemberLoad,
                      child: Text(ZIMKitCore.instance.innerText.groupRetryText),
                    ),
                  ...members.map(_buildMemberRow),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _onMemberLoadError(Object error) {
    if (!mounted) return;
    setState(() => _memberLoadError = error);
  }

  void _retryMemberLoad() {
    setState(() => _memberLoadError = null);
    ZIMKit().queryGroupMemberList(widget.groupID, onError: _onMemberLoadError);
  }

  Widget _buildMemberRow(ZIMGroupMemberInfo member) {
    final displayName = member.memberNickname.isNotEmpty
        ? member.memberNickname
        : (member.userName.isNotEmpty ? member.userName : member.userID);
    final currentUserID =
        ZIMKitCore.instance.currentUser?.baseInfo.userID ?? '';
    final actions = getZIMKitGroupMemberActions(
      currentUserRole: _currentUserRole,
      targetRole: member.memberRole,
      isCurrentUser: member.userID == currentUserID,
    );
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: member.userAvatarUrl.isNotEmpty
            ? NetworkImage(member.userAvatarUrl)
            : null,
        child: member.userAvatarUrl.isEmpty
            ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(displayName),
      subtitle: Text(_roleName(member.memberRole)),
      trailing: actions.isEmpty
          ? null
          : PopupMenuButton<ZIMKitGroupMemberAction>(
              onSelected: (action) => _runMemberAction(member, action),
              itemBuilder: (context) => actions
                  .map(
                    (action) => PopupMenuItem(
                      value: action,
                      child: Text(_actionName(action)),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  int get _currentUserRole {
    final currentUserID =
        ZIMKitCore.instance.currentUser?.baseInfo.userID ?? '';
    for (final member in _members.value) {
      if (member.userID == currentUserID) return member.memberRole;
    }
    return 0;
  }

  String _roleName(int role) {
    final innerText = ZIMKitCore.instance.innerText;
    if (role == ZIMGroupMemberRole.owner) return innerText.groupOwnerRoleText;
    if (role == ZIMGroupMemberRole.admin) return innerText.groupAdminRoleText;
    return innerText.groupMemberRoleText;
  }

  String _actionName(ZIMKitGroupMemberAction action) {
    final innerText = ZIMKitCore.instance.innerText;
    return switch (action) {
      ZIMKitGroupMemberAction.remove => innerText.groupRemoveMemberText,
      ZIMKitGroupMemberAction.setManager => innerText.groupMakeAdminText,
      ZIMKitGroupMemberAction.unsetManager => innerText.groupRemoveAdminText,
      ZIMKitGroupMemberAction.transferOwner =>
        innerText.groupTransferOwnershipText,
    };
  }

  Future<void> _inviteMembers() async {
    final picker = widget.onInviteMembers;
    if (picker == null) {
      _showMessage(ZIMKitCore.instance.innerText.groupPickerUnavailableText);
      return;
    }
    try {
      final selected = await picker(context, List.unmodifiable(_members.value));
      if (selected == null || selected.isEmpty) return;
      final currentIDs = _members.value.map((member) => member.userID).toSet();
      final userIDs = selected
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty && !currentIDs.contains(id))
          .toSet()
          .toList();
      if (userIDs.isEmpty) return;
      final errorCode = await ZIMKit().addUersToGroup(widget.groupID, userIDs);
      if (errorCode != 0) {
        _showOperationError(errorCode);
      }
    } catch (error) {
      _showOperationError(error);
    }
  }

  Future<void> _runMemberAction(
    ZIMGroupMemberInfo member,
    ZIMKitGroupMemberAction action,
  ) async {
    if (action == ZIMKitGroupMemberAction.remove ||
        action == ZIMKitGroupMemberAction.transferOwner) {
      final confirmed = await _confirmAction(member, action);
      if (!confirmed) return;
    }
    try {
      final errorCode = switch (action) {
        ZIMKitGroupMemberAction.remove => await ZIMKit().removeUesrsFromGroup(
          widget.groupID,
          [member.userID],
        ),
        ZIMKitGroupMemberAction.setManager => await ZIMKit().setGroupMemberRole(
          conversationID: widget.groupID,
          userID: member.userID,
          role: ZIMGroupMemberRole.admin,
        ),
        ZIMKitGroupMemberAction.unsetManager =>
          await ZIMKit().setGroupMemberRole(
            conversationID: widget.groupID,
            userID: member.userID,
            role: ZIMGroupMemberRole.member,
          ),
        ZIMKitGroupMemberAction.transferOwner =>
          await ZIMKit().transferGroupOwner(widget.groupID, member.userID),
      };
      if (errorCode != 0) _showOperationError(errorCode);
    } catch (error) {
      _showOperationError(error);
    }
  }

  Future<bool> _confirmAction(
    ZIMGroupMemberInfo member,
    ZIMKitGroupMemberAction action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_actionName(action)),
        content: Text('${_actionName(action)}: ${member.userID}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ZIMKitCore.instance.innerText.cancelButtonText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(ZIMKitCore.instance.innerText.confirmButtonText),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showOperationError(Object error) {
    _showMessage(
      ZIMKitCore.instance.innerText.operationFailedFormat.replaceFirst(
        '%s',
        '$error',
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
