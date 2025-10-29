import 'package:flutter/material.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

/// More actions panel providing additional message input options
/// Includes take photo, pick images, pick files, and call functions
class ZIMKitMoreActionsPanelWidget extends StatelessWidget {
  const ZIMKitMoreActionsPanelWidget({
    super.key,
    required this.conversationID,
    required this.conversationType,
    required this.onActionSelected,
    this.onCallTap,
    this.extraActions = const [],
  });

  final String conversationID;
  final ZIMConversationType conversationType;
  final Function(String action, dynamic data)? onActionSelected;
  final VoidCallback? onCallTap;
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
          _buildActionItem(
            context,
            icon: Icons.camera_alt,
            label: ZIMKitCore.instance.innerText.takePhotoText,
            onTap: () => _handleTakePhoto(context),
          ),
          _buildActionItem(
            context,
            icon: Icons.image,
            label: ZIMKitCore.instance.innerText.photoText,
            onTap: () => _handlePickImages(context),
          ),
          _buildActionItem(
            context,
            icon: Icons.folder,
            label: ZIMKitCore.instance.innerText.fileText,
            onTap: () => _handlePickFiles(context),
          ),
          _buildActionItem(
            context,
            icon: Icons.call,
            label: ZIMKitCore.instance.innerText.callText,
            onTap: () {
              if (onCallTap != null) {
                onCallTap!();
              } else {
                onActionSelected?.call('call', null);
              }
            },
          ),
          // Wrap extra actions with size constraints to match internal buttons
          ...extraActions.map((widget) => _wrapExtraAction(widget)),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55.zW,
            height: 55.zH,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.zR),
              border: Border.all(color: Colors.grey[300]!, width: 1.zW),
            ),
            child: Icon(
              icon,
              size: 28.zW,
              color: iconColor ?? Colors.grey[700],
            ),
          ),
          SizedBox(height: 6.zH),
          Text(
            label,
            style: TextStyle(fontSize: 11.zSP, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Wraps extra action widgets with size constraints to match internal buttons
  /// This ensures consistent button sizes regardless of the external widget size
  Widget _wrapExtraAction(Widget widget) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 55.zW, height: 55.zH, child: widget),
        SizedBox(height: 6.zH),
        // Empty space for label alignment consistency
        SizedBox(height: 11.zSP * 1.2),
      ],
    );
  }

  Future<void> _handleTakePhoto(BuildContext context) async {
    try {
      final AssetEntity? entity = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(),
      );

      if (entity != null) {
        onActionSelected?.call('takePhoto', entity);
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
        onActionSelected?.call('pickImages', result);
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
        onActionSelected?.call('pickFiles', result);
      }
    } catch (e) {
      debugPrint('Pick files error: $e');
    }
  }
}
