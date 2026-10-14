import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/components/settings/group_member_actions.dart';

void main() {
  test('owner can manage and transfer a non-owner member', () {
    expect(
      getZIMKitGroupMemberActions(
        currentUserRole: ZIMGroupMemberRole.owner,
        targetRole: ZIMGroupMemberRole.member,
        isCurrentUser: false,
      ),
      [
        ZIMKitGroupMemberAction.remove,
        ZIMKitGroupMemberAction.setManager,
        ZIMKitGroupMemberAction.transferOwner,
      ],
    );
  });

  test('manager can remove regular members but cannot change roles', () {
    expect(
      getZIMKitGroupMemberActions(
        currentUserRole: ZIMGroupMemberRole.admin,
        targetRole: ZIMGroupMemberRole.member,
        isCurrentUser: false,
      ),
      [ZIMKitGroupMemberAction.remove],
    );
    expect(
      getZIMKitGroupMemberActions(
        currentUserRole: ZIMGroupMemberRole.admin,
        targetRole: ZIMGroupMemberRole.admin,
        isCurrentUser: false,
      ),
      isEmpty,
    );
  });

  test('members cannot manage themselves or the group owner', () {
    expect(
      getZIMKitGroupMemberActions(
        currentUserRole: ZIMGroupMemberRole.owner,
        targetRole: ZIMGroupMemberRole.owner,
        isCurrentUser: false,
      ),
      isEmpty,
    );
    expect(
      getZIMKitGroupMemberActions(
        currentUserRole: ZIMGroupMemberRole.owner,
        targetRole: ZIMGroupMemberRole.member,
        isCurrentUser: true,
      ),
      isEmpty,
    );
  });
}
