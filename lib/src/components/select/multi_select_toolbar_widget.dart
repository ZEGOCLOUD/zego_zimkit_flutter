import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/forward/select_page.dart';
import 'package:zego_zimkit/src/components/select/message_list_multi_select_processor.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

/// Toolbar for multi-select mode operations
/// Provides actions like delete and forward for selected messages
class ZIMKitMultiSelectToolbarWidget extends StatefulWidget {
  const ZIMKitMultiSelectToolbarWidget({super.key});

  @override
  State<ZIMKitMultiSelectToolbarWidget> createState() =>
      _ZIMKitMultiSelectToolbarWidgetState();
}

class _ZIMKitMultiSelectToolbarWidgetState
    extends State<ZIMKitMultiSelectToolbarWidget> {
  Set<ZIMKitMessage> get selectedMessages =>
      ZIMKitMessageListMultiSelectProcessor().selectedMessages;
  int get selectedCount =>
      ZIMKitMessageListMultiSelectProcessor().selectedMessages.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.zH,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 2.zR,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Merge forward button
            _buildActionButton(
              icon: Icons.forward,
              label: ZIMKitCore.instance.innerText.forwardCombinedText,
              enabled: selectedCount > 0,
              onTap: selectedCount > 0 ? _forwardSelectedMerge : null,
            ),
            // One by one forward button
            _buildActionButton(
              icon: Icons.redo,
              label: ZIMKitCore.instance.innerText.forwardSeparatelyText,
              enabled: selectedCount > 0,
              onTap: selectedCount > 0 ? _forwardSelectedOneByOne : null,
            ),
            // Delete button
            _buildActionButton(
              icon: Icons.delete_outline,
              label: ZIMKitCore.instance.innerText.deleteMenuText,
              enabled: selectedCount > 0,
              onTap: selectedCount > 0 ? _deleteSelectedMessages : null,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool enabled,
    VoidCallback? onTap,
    Color? color,
  }) {
    final buttonColor =
        enabled ? (color ?? Colors.grey[700]) : Colors.grey[400];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.zW, vertical: 8.zH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28.zW,
              color: buttonColor,
            ),
            SizedBox(height: 4.zH),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.zSP,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSelectedMessages() async {
    debugPrint(
      '[Demo] _deleteSelectedMessages: ${selectedMessages.length} messages selected',
    );
    if (selectedMessages.isEmpty) return;

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(ZIMKitCore.instance.innerText.deleteMessagesTitle),
        content: Text(ZIMKitCore.instance.innerText.deleteMessagesContentFormat
            .replaceAll('%d', '${selectedMessages.length}')),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ZIMKitCore.instance.innerText.cancelButtonText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(ZIMKitCore.instance.innerText.confirmButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      debugPrint('[Demo] Deleting ${selectedMessages.length} messages');
      await ZIMKit().deleteMessage(selectedMessages.toList());
      debugPrint('[Demo] Messages deleted successfully');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
            content: Text(ZIMKitCore.instance.innerText.deletedToast)));
      }
      ZIMKitMessageListMultiSelectProcessor().cancelMultiSelect();
    } else {
      debugPrint('[Demo] Delete cancelled');
    }
  }

  Future<void> _forwardSelectedOneByOne() async {
    if (selectedMessages.isEmpty) return;

    // Use SDK's forward page
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ZIMKitForwardSelectPage(
          messages: selectedMessages.toList(),
          forwardType: ZIMKitForwardType.oneByOne,
        ),
      ),
    );

    if (result == true) {
      ZIMKitMessageListMultiSelectProcessor().cancelMultiSelect();
    }
  }

  Future<void> _forwardSelectedMerge() async {
    if (selectedMessages.isEmpty) return;

    // Use SDK's forward page
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ZIMKitForwardSelectPage(
          messages: selectedMessages.toList(),
          forwardType: ZIMKitForwardType.merge,
        ),
      ),
    );

    if (result == true) {
      ZIMKitMessageListMultiSelectProcessor().cancelMultiSelect();
    }
  }
}
