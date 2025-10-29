import 'package:flutter/material.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

/// Emoji picker widget with 1500+ emojis organized in categories
/// Supports search, skin tones, and recent emojis
class ZIMKitEmojiPickerWidget extends StatelessWidget {
  const ZIMKitEmojiPickerWidget({
    super.key,
    required this.onEmojiSelected,
    this.textEditingController,
  });

  final Function(String emoji) onEmojiSelected;
  final TextEditingController? textEditingController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: EmojiPicker(
        textEditingController: textEditingController,
        onEmojiSelected: (category, emoji) {
          onEmojiSelected(emoji.emoji);
        },
        config: Config(
          height: 250,
          checkPlatformCompatibility: true,
          viewOrderConfig: const ViewOrderConfig(
            top: EmojiPickerItem.categoryBar,
            middle: EmojiPickerItem.emojiView,
            bottom: EmojiPickerItem.searchBar,
          ),
          emojiViewConfig: const EmojiViewConfig(
            columns: 7,
            emojiSizeMax: 32,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            backgroundColor: Color(0xFFF5F6F7),
          ),
          skinToneConfig: const SkinToneConfig(
            dialogBackgroundColor: Colors.white,
          ),
          categoryViewConfig: const CategoryViewConfig(
            tabBarHeight: 46,
            backgroundColor: Color(0xFFF5F6F7),
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
          searchViewConfig: const SearchViewConfig(
            backgroundColor: Color(0xFFF5F6F7),
            buttonIconColor: Colors.black26,
          ),
        ),
      ),
    );
  }
}
