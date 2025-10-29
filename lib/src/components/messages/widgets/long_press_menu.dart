import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/emoji/picker_dialog.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

/// Message operation types
enum ZIMKitMessageOperation {
  copy,
  reply,
  forward,
  select,
  delete,
  revoke,
  turnOffSpeaker,
}

/// Callback for multi-select mode
typedef OnMultiSelectModeChanged = void Function(
    bool enabled, String? initialMessageID);
typedef GetSelectedMessages = List<ZIMKitMessage> Function();

/// Message options menu shown when long-pressing a message
/// Provides actions like copy, reply, forward, delete, revoke, etc.
class ZIMKitMessageOptionsMenuWidget extends StatelessWidget {
  const ZIMKitMessageOptionsMenuWidget({
    super.key,
    required this.message,
    required this.position,
    required this.onActionSelected,
    required this.isSentByMe,
  });

  final ZIMKitMessage message;
  final Offset position;
  final Function(ZIMKitMessageOperation action) onActionSelected;
  final bool isSentByMe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        // Menu
        Positioned(
          left: _calculateMenuLeft(context),
          top: _calculateMenuTop(context),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 40.zW,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(8.zR),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji reaction bar
                  _buildEmojiReactionBar(context),
                  // Action buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiReactionBar(BuildContext context) {
    // Commonly used emojis (aligned with iOS ZIMKit)
    final emojis = ['❤️', '👍', '👎', '😄', '😢', '😮', '😡'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.zW, vertical: 8.zH),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...emojis.map((emoji) => _buildEmojiButton(emoji, context)),
            // More button to show full emoji picker
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close current menu
                showDialog(
                  context: context,
                  builder: (context) => ZIMKitEmojiPickerDialog(
                    onEmojiSelected: (emoji) async {
                      try {
                        // Check if already reacted
                        final currentUserID =
                            ZIMKitCore.instance.currentUser?.baseInfo.userID ??
                                '';
                        final hasReacted = message.reactions.value
                            .where((r) => r.reactionType == emoji)
                            .any((r) => r.userList
                                .any((u) => u.userID == currentUserID));

                        if (hasReacted) {
                          await ZIMKitCore.instance
                              .deleteMessageReaction(message, emoji);
                          debugPrint('[ZIMKit] Deleted reaction: $emoji');
                        } else {
                          await ZIMKitCore.instance
                              .addMessageReaction(message, emoji);
                          debugPrint('[ZIMKit] Added reaction: $emoji');
                        }
                      } catch (e) {
                        debugPrint('[ZIMKit] Emoji reaction error: $e');
                      }
                    },
                  ),
                );
              },
              child: Container(
                width: 32.zW,
                height: 32.zH,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(16.zR),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20.zW,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji, BuildContext context) {
    // Check if current user already reacted with this emoji
    final currentUserID =
        ZIMKitCore.instance.currentUser?.baseInfo.userID ?? '';
    final hasReacted = message.reactions.value
        .where((r) => r.reactionType == emoji)
        .any((r) => r.userList.any((u) => u.userID == currentUserID));

    return _AnimatedEmojiButton(
      emoji: emoji,
      hasReacted: hasReacted,
      onTap: () async {
        try {
          Navigator.of(context).pop(); // Close menu first

          if (hasReacted) {
            // Delete reaction if already reacted
            await ZIMKitCore.instance.deleteMessageReaction(message, emoji);
            debugPrint('[ZIMKit] Deleted reaction: $emoji');
          } else {
            // Add reaction if not yet reacted
            await ZIMKitCore.instance.addMessageReaction(message, emoji);
            debugPrint('[ZIMKit] Added reaction: $emoji');
          }
        } catch (e) {
          debugPrint('[ZIMKit] Emoji reaction error: $e');
        }
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final actions = _getAvailableActions();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.zH),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions
              .map((action) => _buildActionButton(action, context))
              .toList(),
        ),
      ),
    );
  }

  List<ZIMKitMessageOperation> _getAvailableActions() {
    final actions = <ZIMKitMessageOperation>[];

    // Copy available for text messages
    if (message.type == ZIMMessageType.text) {
      actions.add(ZIMKitMessageOperation.copy);
    }

    // Common actions
    actions.add(ZIMKitMessageOperation.reply);
    actions.add(ZIMKitMessageOperation.forward);
    actions.add(ZIMKitMessageOperation.select);
    actions.add(ZIMKitMessageOperation.delete);

    // Revoke only for own messages
    if (isSentByMe) {
      actions.add(ZIMKitMessageOperation.revoke);
    }

    // Speaker toggle for audio messages
    if (message.type == ZIMMessageType.audio) {
      actions.add(ZIMKitMessageOperation.turnOffSpeaker);
    }

    return actions;
  }

  Widget _buildActionButton(
      ZIMKitMessageOperation action, BuildContext context) {
    IconData icon;
    String label;

    switch (action) {
      case ZIMKitMessageOperation.copy:
        icon = Icons.content_copy;
        label = 'Copy';
        break;
      case ZIMKitMessageOperation.reply:
        icon = Icons.reply;
        label = 'Reply';
        break;
      case ZIMKitMessageOperation.forward:
        icon = Icons.forward;
        label = 'Forward';
        break;
      case ZIMKitMessageOperation.select:
        icon = Icons.check_circle_outline;
        label = 'Select';
        break;
      case ZIMKitMessageOperation.delete:
        icon = Icons.delete_outline;
        label = 'Delete';
        break;
      case ZIMKitMessageOperation.revoke:
        icon = Icons.undo;
        label = 'Revoke';
        break;
      case ZIMKitMessageOperation.turnOffSpeaker:
        icon = Icons.headphones;
        label = 'Turn Off\nSpeaker';
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onActionSelected(action);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.zW, vertical: 8.zH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24.zW),
            SizedBox(height: 4.zH),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.zSP,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMenuLeft(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = 380.0.zW; // Estimated menu width

    if (position.dx + menuWidth > screenWidth) {
      return screenWidth - menuWidth - 10;
    }
    return position.dx.clamp(10.0, screenWidth - menuWidth - 10);
  }

  double _calculateMenuTop(BuildContext context) {
    return (position.dy - 120)
        .clamp(60.0, MediaQuery.of(context).size.height - 200);
  }
}

/// Animated emoji button with scale animation on tap
class _AnimatedEmojiButton extends StatefulWidget {
  const _AnimatedEmojiButton({
    required this.emoji,
    required this.hasReacted,
    required this.onTap,
  });

  final String emoji;
  final bool hasReacted;
  final VoidCallback onTap;

  @override
  State<_AnimatedEmojiButton> createState() => _AnimatedEmojiButtonState();
}

class _AnimatedEmojiButtonState extends State<_AnimatedEmojiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.zW),
          padding: EdgeInsets.symmetric(horizontal: 8.zW, vertical: 4.zH),
          decoration: BoxDecoration(
            color: widget.hasReacted
                ? Colors.blue.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.zR),
            border: Border.all(
              color: widget.hasReacted ? Colors.blue : Colors.grey[700]!,
              width: 1.zW,
            ),
          ),
          child: Text(
            widget.emoji,
            style: TextStyle(fontSize: 24.zSP),
          ),
        ),
      ),
    );
  }
}

/// Show message options menu
Future<void> showZIMKitMessageOptionsMenu(
  BuildContext context,
  ZIMKitMessage message,
  Offset position,
  bool isSentByMe,
  Function(ZIMKitMessageOperation action) onActionSelected,
) async {
  await showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => ZIMKitMessageOptionsMenuWidget(
      message: message,
      position: position,
      onActionSelected: onActionSelected,
      isSentByMe: isSentByMe,
    ),
  );
}
