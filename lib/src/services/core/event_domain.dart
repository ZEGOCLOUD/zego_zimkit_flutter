part of 'event.dart';

/// Event class for group state changes
class ZIMKitEventGroupStateChanged {
  /// Creates a group state changed event instance
  ///
  /// [state] The new group state
  /// [event] The group event that occurred
  /// [operatedInfo] Information about the operation
  /// [groupInfo] Complete group information
  ZIMKitEventGroupStateChanged({
    required this.state,
    required this.event,
    required this.operatedInfo,
    required this.groupInfo,
  });
  final ZIMGroupState state;
  final ZIMGroupEvent event;
  final ZIMGroupOperatedInfo operatedInfo;
  final ZIMGroupFullInfo groupInfo;
}

/// Event class for group name updates
class ZIMKitEventGroupNameUpdated {
  /// Creates a group name updated event instance
  ///
  /// [groupName] The new group name
  /// [operatedInfo] Information about the operation
  /// [groupID] The group ID
  ZIMKitEventGroupNameUpdated({
    required this.groupName,
    required this.operatedInfo,
    required this.groupID,
  });
  final String groupName;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

/// Event class for group avatar URL updates
class ZIMKitEventGroupAvatarUrlUpdated {
  /// Creates a group avatar URL updated event instance
  ///
  /// [groupAvatarUrl] The new group avatar URL
  /// [operatedInfo] Information about the operation
  /// [groupID] The group ID
  ZIMKitEventGroupAvatarUrlUpdated({
    required this.groupAvatarUrl,
    required this.operatedInfo,
    required this.groupID,
  });
  final String groupAvatarUrl;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

/// Event class for group notice updates
class ZIMKitEventGroupNoticeUpdated {
  /// Creates a group notice updated event instance
  ///
  /// [groupNotice] The new group notice
  /// [operatedInfo] Information about the operation
  /// [groupID] The group ID
  ZIMKitEventGroupNoticeUpdated({
    required this.groupNotice,
    required this.operatedInfo,
    required this.groupID,
  });
  final String groupNotice;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

/// Event class for group attributes updates
class ZIMKitEventGroupAttributesUpdated {
  /// Creates a group attributes updated event instance
  ///
  /// [updateInfo] List of updated group attributes information
  /// [operatedInfo] Information about the operation
  /// [groupID] The group ID
  ZIMKitEventGroupAttributesUpdated({
    required this.updateInfo,
    required this.operatedInfo,
    required this.groupID,
  });
  final List<ZIMGroupAttributesUpdateInfo> updateInfo;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

/// Event class for group member state changes
class ZIMKitEventGroupMemberStateChanged {
  /// Creates a group member state changed event instance
  ///
  /// [state] The new member state
  /// [event] The member event that occurred
  /// [userList] List of affected users
  /// [operatedInfo] Information about the operation
  /// [groupID] The group ID
  ZIMKitEventGroupMemberStateChanged({
    required this.state,
    required this.event,
    required this.userList,
    required this.operatedInfo,
    required this.groupID,
  });
  final ZIMGroupMemberState state;
  final ZIMGroupMemberEvent event;
  final List<ZIMGroupMemberInfo> userList;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}

/// Event class for group member information updates
class ZIMKitEventGroupMemberInfoUpdated {
  /// Creates a group member info updated event instance
  ///
  /// [userInfo] List of updated user information
  /// [operatedInfo] Information about the operation
  /// [groupID] The group ID
  ZIMKitEventGroupMemberInfoUpdated({
    required this.userInfo,
    required this.operatedInfo,
    required this.groupID,
  });
  final List<ZIMGroupMemberInfo> userInfo;
  final ZIMGroupOperatedInfo operatedInfo;
  final String groupID;
}
