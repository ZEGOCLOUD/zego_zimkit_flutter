part of '../zimkit.dart';

/// Service mixin for default dialog functionality
///
/// Provides default UI dialogs for common operations like:
/// - Creating new peer chats
/// - Creating new group chats
/// - Joining existing groups
///
/// Use with [ZIMKit] to access dialog functionality.
mixin ZIMKitDefaultDialogService {
  void showDefaultNewPeerChatDialog(BuildContext context) {
    final userIDController = TextEditingController();
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          final innerText = ZIMKitCore.instance.innerText;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(innerText.newChatTitle),
              content: TextField(
                controller: userIDController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: innerText.userIdLabel,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(innerText.cancelButtonText),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(innerText.okButtonText),
                ),
              ],
            );
          });
        },
      ).then((ok) {
        if (ok != true) return;
        if (userIDController.text.isNotEmpty) {
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ZIMKitMessageListPage(
                conversationID: userIDController.text,
              );
            }));
          } else {
            ZIMKitLogger.logInfo(
              'showDefaultNewChatDialog, context is not mounted',
              tag: 'zimkit',
              subTag: 'dialogs_utils',
            );
          }
        }
      });
    });
  }

  void showDefaultNewGroupChatDialog(BuildContext context) {
    final groupIDController = TextEditingController();
    final groupNameController = TextEditingController();
    final groupUsersController = TextEditingController();
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          final innerText = ZIMKitCore.instance.innerText;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(innerText.newGroupTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: groupNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: innerText.groupNameLabel,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: groupIDController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: innerText.groupIdOptionalLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 3,
                    controller: groupUsersController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: innerText.inviteUserIdsLabel,
                      hintText: innerText.inviteUserIdsHint,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(innerText.cancelButtonText),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(innerText.okButtonText),
                ),
              ],
            );
          });
        },
      ).then((bool? ok) {
        if (ok != true) return;
        if (groupNameController.text.isNotEmpty &&
            groupUsersController.text.isNotEmpty) {
          ZIMKit()
              .createGroup(
            groupNameController.text,
            groupUsersController.text.split(','),
            id: groupIDController.text,
          )
              .then((String? conversationID) {
            if (conversationID != null) {
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ZIMKitMessageListPage(
                    conversationID: conversationID,
                    conversationType: ZIMConversationType.group,
                  );
                }));
              } else {
                ZIMKitLogger.logInfo(
                  'showDefaultNewGroupChatDialog, context is not mounted',
                  tag: 'zimkit',
                  subTag: 'dialogs_utils',
                );
              }
            }
          });
        }
      });
    });
  }

  void showDefaultJoinGroupDialog(BuildContext context) {
    final groupIDController = TextEditingController();
    Timer.run(() {
      showDialog<bool>(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          final innerText = ZIMKitCore.instance.innerText;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(innerText.joinGroupTitle),
              content: TextField(
                controller: groupIDController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: innerText.groupIdLabel,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(innerText.cancelButtonText),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(innerText.okButtonText),
                ),
              ],
            );
          });
        },
      ).then((bool? ok) {
        if (ok != true) return;
        if (groupIDController.text.isNotEmpty) {
          ZIMKit().joinGroup(groupIDController.text).then((int errorCode) {
            if (errorCode == 0) {
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ZIMKitMessageListPage(
                    conversationID: groupIDController.text,
                    conversationType: ZIMConversationType.group,
                  );
                }));
              } else {
                ZIMKitLogger.logInfo(
                  'showDefaultJoinGroupDialog, context is not mounted',
                  tag: 'zimkit',
                  subTag: 'dialogs_utils',
                );
              }
            }
          });
        }
      });
    });
  }
}
