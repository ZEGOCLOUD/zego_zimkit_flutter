import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

import 'package:zego_zimkit/src/events.defines.dart' as kit_events;

kit_events.ZIMConnectionEvent? mapZIMKitConnectionAction(
  ZegoSignalingPluginConnectionAction action,
) {
  return switch (action) {
    ZegoSignalingPluginConnectionAction.unknown => null,
    ZegoSignalingPluginConnectionAction.success =>
      kit_events.ZIMConnectionEvent.success,
    ZegoSignalingPluginConnectionAction.activeLogin =>
      kit_events.ZIMConnectionEvent.activeLogin,
    ZegoSignalingPluginConnectionAction.loginTimeout =>
      kit_events.ZIMConnectionEvent.networkDisconnected,
    ZegoSignalingPluginConnectionAction.interrupted =>
      kit_events.ZIMConnectionEvent.networkInterrupted,
    ZegoSignalingPluginConnectionAction.kickedOut =>
      kit_events.ZIMConnectionEvent.kickedOut,
    ZegoSignalingPluginConnectionAction.tokenExpired =>
      kit_events.ZIMConnectionEvent.tokenExpired,
    ZegoSignalingPluginConnectionAction.unregistered =>
      kit_events.ZIMConnectionEvent.networkDisconnected,
  };
}

kit_events.ZIMConnectionState mapZIMKitConnectionState(
  ZegoSignalingPluginConnectionState state,
) {
  return switch (state) {
    ZegoSignalingPluginConnectionState.disconnected =>
      kit_events.ZIMConnectionState.disconnected,
    ZegoSignalingPluginConnectionState.connecting =>
      kit_events.ZIMConnectionState.connecting,
    ZegoSignalingPluginConnectionState.connected =>
      kit_events.ZIMConnectionState.connected,
    ZegoSignalingPluginConnectionState.reconnecting =>
      kit_events.ZIMConnectionState.reconnecting,
  };
}
