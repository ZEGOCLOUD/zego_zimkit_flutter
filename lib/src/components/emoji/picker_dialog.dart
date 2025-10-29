import 'package:flutter/material.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

/// Full emoji picker dialog using emoji_picker_flutter
class ZIMKitEmojiPickerDialog extends StatelessWidget {
  const ZIMKitEmojiPickerDialog({
    super.key,
    required this.onEmojiSelected,
  });

  final Function(String emoji) onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF5F6F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.zR),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(16.zR),
        ),
        child: Column(
          children: [
            // Title bar with close button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.zW, vertical: 12.zH),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.zR),
                  topRight: Radius.circular(16.zR),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '选择表情',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.zSP,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 24.zW,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Emoji picker
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  onEmojiSelected(emoji.emoji);
                  Navigator.of(context).pop();
                },
                config: Config(
                  checkPlatformCompatibility: true,
                  viewOrderConfig: const ViewOrderConfig(
                    top: EmojiPickerItem.categoryBar,
                    middle: EmojiPickerItem.emojiView,
                    bottom: EmojiPickerItem.searchBar,
                  ),
                  emojiViewConfig: EmojiViewConfig(
                    columns: 7,
                    emojiSizeMax: 32.zSP,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFFF5F6F7),
                  ),
                  skinToneConfig: const SkinToneConfig(
                    dialogBackgroundColor: Colors.white,
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    tabBarHeight: 46.zH,
                    backgroundColor: const Color(0xFFF5F6F7),
                    indicatorColor: Colors.blue,
                    iconColorSelected: Colors.blue,
                    backspaceColor: Colors.blue,
                    initCategory: Category.SMILEYS,
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(
                    showBackspaceButton: false,
                    showSearchViewButton: true,
                    backgroundColor: Colors.transparent,
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: const Color(0xFFF5F6F7),
                    buttonIconColor: Colors.black26,
                    hintText: '搜索表情...',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
