import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/components/style.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';

/// Button widget for expanding additional actions in the toolbar
///
/// Displays a button that shows additional action options when pressed.
/// Used in the message input toolbar for features like location, file, etc.
class ZIMKitMoreButton extends StatelessWidget {
  ZIMKitMoreButton({
    super.key,
    required this.buttons,
    this.icon,
    EdgeInsetsGeometry? padding,
  }) : padding = padding ?? EdgeInsets.all(32.0.zR);

  final Widget? icon;
  final List<Widget> buttons;
  final EdgeInsetsGeometry padding;

  double get rowHeight => 40.zH;

  double get rowPadding => 10.zH;

  double get columnPadding => 10.zW;

  int get rowCount => 4;

  int get maxRowCount => 2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        int rows = (buttons.length + 3) ~/ 4;
        rows = rows > 2 ? 2 : rows;

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: rowPadding * (maxRowCount - 1) +
                      rowHeight * maxRowCount +
                      padding.vertical * maxRowCount,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: padding,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowCount,
                          childAspectRatio: 1.0,
                          // column spacing
                          mainAxisSpacing: rowPadding,
                          // row spacing
                          crossAxisSpacing: columnPadding,
                        ),
                        itemCount: buttons.length,
                        itemBuilder: (context, index) {
                          return buttons[index];
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: icon ??
          Icon(
            Icons.add,
            size: ZIMKitComponentStyle.iconSize,
            color: Theme.of(context)
                .textTheme
                .bodyLarge!
                .color!
                .withValues(alpha: 0.64),
          ),
    );
  }
}
