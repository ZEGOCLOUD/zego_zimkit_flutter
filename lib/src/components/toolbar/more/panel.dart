import 'package:flutter/material.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

import 'defines.dart';

/// More actions panel providing additional message input options
/// Includes take photo, pick images, pick files, and call functions
class ZIMKitMoreActionsPanelWidget extends StatelessWidget {
  const ZIMKitMoreActionsPanelWidget({
    super.key,
    required this.conversationID,
    required this.conversationType,
    required this.onActionSelected,
    this.extraActions = const [],
  });

  final String conversationID;
  final ZIMConversationType conversationType;
  final Function(ZIMKitMoreActionsPanelAction action, dynamic data)?
      onActionSelected;

  /// please use [buildZIMKitInputMoreActionItem] to build a same style widget
  final List<Widget> extraActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.zH,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 0.5.zW),
        ),
      ),
      child: GridView.count(
        crossAxisCount: 4,
        padding: EdgeInsets.all(20.zR),
        mainAxisSpacing: 20.zH,
        crossAxisSpacing: 20.zW,
        childAspectRatio: 0.75, // Adjust aspect ratio to fit icon + label
        children: [
          buildZIMKitInputMoreActionItem(
            context,
            icon: Icons.camera_alt,
            label: ZIMKitCore.instance.innerText.takePhotoText,
            onTap: () => _handleTakePhoto(context),
          ),
          buildZIMKitInputMoreActionItem(
            context,
            icon: Icons.image,
            label: ZIMKitCore.instance.innerText.photoText,
            onTap: () => _handlePickImages(context),
          ),
          buildZIMKitInputMoreActionItem(
            context,
            icon: Icons.folder,
            label: ZIMKitCore.instance.innerText.fileText,
            onTap: () => _handlePickFiles(context),
          ),
          ...extraActions.map(
            (widget) => SizedBox(
              width: 55.zW,
              height: 55.zH,
              child: widget,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTakePhoto(BuildContext context) async {
    try {
      final AssetEntity? entity = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(),
      );

      if (entity != null) {
        onActionSelected?.call(ZIMKitMoreActionsPanelAction.takePhoto, entity);
      }
    } catch (e) {
      debugPrint('Take photo error: $e');
    }
  }

  Future<void> _handlePickImages(BuildContext context) async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 9,
          requestType: RequestType.image,
        ),
      );

      if (result != null && result.isNotEmpty) {
        onActionSelected?.call(ZIMKitMoreActionsPanelAction.pickImages, result);
      }
    } catch (e) {
      debugPrint('Pick images error: $e');
    }
  }

  Future<void> _handlePickFiles(BuildContext context) async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 9,
          requestType: RequestType.common,
        ),
      );

      if (result != null && result.isNotEmpty) {
        onActionSelected?.call(ZIMKitMoreActionsPanelAction.pickFiles, result);
      }
    } catch (e) {
      debugPrint('Pick files error: $e');
    }
  }
}
