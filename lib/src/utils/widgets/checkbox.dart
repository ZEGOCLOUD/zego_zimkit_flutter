import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/utils/screen_util/core/size_extension.dart';

class RoundBlueCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RoundBlueCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          shape: const CircleBorder(),
          side: BorderSide(
            color: Colors.grey,
            width: 2.zR,
          ),
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue;
            }
            return null;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
