part of '../zimkit.dart';

/// Service mixin for helper and utility functions
///
/// Provides methods for app lifecycle management, message forwarding,
/// and platform-specific functionality.
/// Use with [ZIMKit] to access helper functionality.
mixin ZIMKitHelperService {
  void registerAppLifecycleStateChangedListener(
    ZegoPluginAdapterMessageHandler listener,
  ) {
    ZegoPluginAdapter().service().registerMessageHandler(listener);
  }

  void unregisterAppLifecycleStateChangedListener(
    ZegoPluginAdapterMessageHandler listener,
  ) {
    ZegoPluginAdapter().service().unregisterMessageHandler(listener);
  }

  Future<bool> isAppLocked() async {
    return await ZegoZIMKitPluginPlatform.instance.isLockScreen();
  }

  // Forward messages management
  void setForwardMessages(
    List<ZIMKitMessage> messages,
    ZIMKitForwardType forwardType,
  ) {
    ZIMKitCore.instance.forwardMessages = messages;
    ZIMKitCore.instance.forwardType = forwardType;
  }

  List<ZIMKitMessage> getForwardMessages() {
    return ZIMKitCore.instance.forwardMessages;
  }

  ZIMKitForwardType? getForwardType() {
    return ZIMKitCore.instance.forwardType;
  }

  void clearForwardMessages() {
    ZIMKitCore.instance.forwardMessages = [];
    ZIMKitCore.instance.forwardType = null;
  }
}
