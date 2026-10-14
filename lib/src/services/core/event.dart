import 'dart:async';

import 'package:zego_plugin_adapter/zego_plugin_adapter.dart' as adapter;
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart'
    as signaling;
import 'package:zego_zim/zego_zim.dart'
    show
        ZIMGroupAttributesUpdateInfo,
        ZIMGroupEvent,
        ZIMGroupFullInfo,
        ZIMGroupMemberEvent,
        ZIMGroupMemberInfo,
        ZIMGroupMemberState,
        ZIMGroupOperatedInfo,
        ZIMGroupState;

import 'package:zego_zimkit/src/services/logger_service.dart';
import 'package:zego_zimkit/src/services/core/connection_event_mapper.dart';
import 'package:zego_zimkit/zego_zimkit.dart';
import 'package:zego_zimkit/src/events.defines.dart' as kit_events;

part 'event_domain.dart';

mixin ZIMKitCoreEvent {
  StreamSubscription<adapter.ZegoSignalingPluginConnectionStateChangedEvent>?
  _connectionStateSubscription;
  StreamSubscription<adapter.ZegoSignalingPluginTokenWillExpireEvent>?
  _tokenWillExpireSubscription;

  void initEventHandler() {
    ZIMKitLogger.logInfo('register event handle.');
    final target = ZIMKitCore.instance;
    signaling.ZegoUIKitSignalingPlugin().eventCenter.passThroughEvent
      /*Conversation*/
      ..onConversationChanged = target.onConversationChanged
      ..onConversationTotalUnreadMessageCountUpdated =
          target.onConversationTotalUnreadMessageCountUpdated
      /*Message*/
      ..onReceivePeerMessage = target.onReceivePeerMessage
      ..onReceiveRoomMessage = target.onReceiveRoomMessage
      ..onReceiveGroupMessage = target.onReceiveGroupMessage
      ..onMessageRevokeReceived = target.onMessageRevokeReceived
      ..onMessageReactionsChanged = target.onMessageReactionsChanged
      /*Group*/
      ..onGroupStateChanged = target.onGroupStateChanged
      ..onGroupNameUpdated = target.onGroupNameUpdated
      ..onGroupAvatarUrlUpdated = target.onGroupAvatarUrlUpdated
      ..onGroupNoticeUpdated = target.onGroupNoticeUpdated
      ..onGroupAttributesUpdated = target.onGroupAttributesUpdated
      ..onGroupMemberStateChanged = target.onGroupMemberStateChanged
      ..onGroupMemberInfoUpdated = target.onGroupMemberInfoUpdated
      // zpns notification
      ..onZPNsRegistered = target.onZPNsRegistered
      ..onZPNsNotificationArrived = target.onZPNsNotificationArrived
      ..onZPNsNotificationClicked = target.onZPNsNotificationClicked;

    _connectionStateSubscription = signaling.ZegoUIKitSignalingPlugin()
        .getConnectionStateChangedEventStream()
        .listen((event) {
          final connectionEvent = mapZIMKitConnectionAction(event.action);
          if (connectionEvent == null) return;

          final connectionState = mapZIMKitConnectionState(event.state);
          final extendedData = Map<String, dynamic>.fromEntries(
            event.extendedData.entries.map(
              (entry) => MapEntry('${entry.key}', entry.value),
            ),
          );
          dispatchZIMKitConnectionStateChanged(
            state: connectionState,
            event: connectionEvent,
            extendedData: extendedData,
          );
          if (connectionEvent == ZIMConnectionEvent.tokenExpired) {
            dispatchZIMKitTokenExpired();
          }
        });

    _tokenWillExpireSubscription = signaling.ZegoUIKitSignalingPlugin()
        .getTokenWillExpireEventStream()
        .listen((event) => dispatchZIMKitTokenWillExpire(event.second));
  }

  Future<void> uninitEventHandler() async {
    ZIMKitLogger.logInfo('unregister event handle.');
    await _connectionStateSubscription?.cancel();
    await _tokenWillExpireSubscription?.cancel();
    _connectionStateSubscription = null;
    _tokenWillExpireSubscription = null;

    signaling.ZegoUIKitSignalingPlugin().eventCenter.passThroughEvent
      /*Conversation*/
      ..onConversationChanged = null
      ..onConversationTotalUnreadMessageCountUpdated = null
      /*Message*/
      ..onReceivePeerMessage = null
      ..onReceiveRoomMessage = null
      ..onReceiveGroupMessage = null
      ..onMessageRevokeReceived = null
      ..onMessageReactionsChanged = null
      /*Group*/
      ..onGroupStateChanged = null
      ..onGroupNameUpdated = null
      ..onGroupAvatarUrlUpdated = null
      ..onGroupNoticeUpdated = null
      ..onGroupAttributesUpdated = null
      ..onGroupMemberStateChanged = null
      ..onGroupMemberInfoUpdated = null;
  }
}

void dispatchZIMKitConnectionStateChanged({
  required kit_events.ZIMConnectionState state,
  required kit_events.ZIMConnectionEvent event,
  Map<String, dynamic>? extendedData,
}) {
  final callback =
      ZIMKitCore.instance.events?.connection.onConnectionStateChanged;
  callback?.call(
    ZIMKitConnectionStateEvent(
      state: state,
      event: event,
      extendedData: extendedData,
    ),
  );
}

void dispatchZIMKitTokenWillExpire(int remainSeconds) {
  final callback = ZIMKitCore.instance.events?.connection.onTokenWillExpire;
  callback?.call(ZIMKitTokenExpiredEvent(remainSeconds: remainSeconds));
}

void dispatchZIMKitTokenExpired() {
  final callback = ZIMKitCore.instance.events?.connection.onTokenExpired;
  callback?.call();
}

void dispatchZIMKitMediaTransferProgress({
  required ZIMKitMessage message,
  required int currentSize,
  required int totalSize,
  required bool isUploading,
}) {
  final callback = ZIMKitCore.instance.events?.message.onMediaTransferProgress;
  callback?.call(
    ZIMKitMediaTransferProgressEvent(
      message: message,
      currentSize: currentSize,
      totalSize: totalSize,
      isUploading: isUploading,
    ),
  );
}

void dispatchZIMKitImageDownloadProgress({
  required ZIMKitMessage message,
  required int currentSize,
  required int? totalSize,
}) {
  dispatchZIMKitMediaTransferProgress(
    message: message,
    currentSize: currentSize,
    totalSize: totalSize ?? 0,
    isUploading: false,
  );
}
