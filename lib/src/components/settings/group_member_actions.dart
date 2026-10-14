import 'package:zego_zim/zego_zim.dart';

enum ZIMKitGroupMemberAction { remove, setManager, unsetManager, transferOwner }

List<ZIMKitGroupMemberAction> getZIMKitGroupMemberActions({
  required int currentUserRole,
  required int targetRole,
  required bool isCurrentUser,
}) {
  if (isCurrentUser || targetRole == ZIMGroupMemberRole.owner) {
    return const [];
  }

  if (currentUserRole == ZIMGroupMemberRole.owner) {
    return [
      ZIMKitGroupMemberAction.remove,
      targetRole == ZIMGroupMemberRole.admin
          ? ZIMKitGroupMemberAction.unsetManager
          : ZIMKitGroupMemberAction.setManager,
      ZIMKitGroupMemberAction.transferOwner,
    ];
  }

  if (currentUserRole == ZIMGroupMemberRole.admin &&
      targetRole == ZIMGroupMemberRole.member) {
    return const [ZIMKitGroupMemberAction.remove];
  }

  return const [];
}
