import 'package:flutter_test/flutter_test.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_zimkit/src/events.defines.dart';
import 'package:zego_zimkit/src/services/core/connection_event_mapper.dart';

void main() {
  test('maps signaling connection actions to ZIMKit events', () {
    expect(
      mapZIMKitConnectionAction(ZegoSignalingPluginConnectionAction.unknown),
      isNull,
    );
    expect(
      mapZIMKitConnectionAction(ZegoSignalingPluginConnectionAction.success),
      ZIMConnectionEvent.success,
    );
    expect(
      mapZIMKitConnectionAction(
        ZegoSignalingPluginConnectionAction.activeLogin,
      ),
      ZIMConnectionEvent.activeLogin,
    );
    expect(
      mapZIMKitConnectionAction(
        ZegoSignalingPluginConnectionAction.loginTimeout,
      ),
      ZIMConnectionEvent.networkDisconnected,
    );
    expect(
      mapZIMKitConnectionAction(
        ZegoSignalingPluginConnectionAction.interrupted,
      ),
      ZIMConnectionEvent.networkInterrupted,
    );
    expect(
      mapZIMKitConnectionAction(ZegoSignalingPluginConnectionAction.kickedOut),
      ZIMConnectionEvent.kickedOut,
    );
    expect(
      mapZIMKitConnectionAction(
        ZegoSignalingPluginConnectionAction.tokenExpired,
      ),
      ZIMConnectionEvent.tokenExpired,
    );
    expect(
      mapZIMKitConnectionAction(
        ZegoSignalingPluginConnectionAction.unregistered,
      ),
      ZIMConnectionEvent.networkDisconnected,
    );
  });

  test('maps every signaling connection state', () {
    expect(
      mapZIMKitConnectionState(ZegoSignalingPluginConnectionState.disconnected),
      ZIMConnectionState.disconnected,
    );
    expect(
      mapZIMKitConnectionState(ZegoSignalingPluginConnectionState.connecting),
      ZIMConnectionState.connecting,
    );
    expect(
      mapZIMKitConnectionState(ZegoSignalingPluginConnectionState.connected),
      ZIMConnectionState.connected,
    );
    expect(
      mapZIMKitConnectionState(ZegoSignalingPluginConnectionState.reconnecting),
      ZIMConnectionState.reconnecting,
    );
  });
}
