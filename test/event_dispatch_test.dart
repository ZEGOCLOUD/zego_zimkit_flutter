import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/events.dart';
import 'package:zego_zimkit/src/events.defines.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/services/core/event.dart';

void main() {
  tearDown(() {
    ZIMKitCore.instance.events = null;
  });

  test('dispatches upload and download progress to the public event', () {
    final events = <ZIMKitMediaTransferProgressEvent>[];
    ZIMKitCore.instance.events = ZIMKitEvents(
      message: ZIMKitMessageEvents(onMediaTransferProgress: events.add),
    );

    dispatchZIMKitMediaTransferProgress(
      message: ZIMKitMessage(),
      currentSize: 25,
      totalSize: 100,
      isUploading: true,
    );
    dispatchZIMKitMediaTransferProgress(
      message: ZIMKitMessage(),
      currentSize: 70,
      totalSize: 100,
      isUploading: false,
    );

    expect(events.map((event) => event.progress), [0.25, 0.7]);
    expect(events.map((event) => event.isUploading), [true, false]);

    final zeroTotal = ZIMKitMediaTransferProgressEvent(
      message: ZIMKitMessage(),
      currentSize: 0,
      totalSize: 0,
      isUploading: true,
    );
    expect(zeroTotal.progress, 0);
  });

  test('dispatches image cache download progress to the public event', () {
    ZIMKitMediaTransferProgressEvent? received;
    ZIMKitCore.instance.events = ZIMKitEvents(
      message: ZIMKitMessageEvents(
        onMediaTransferProgress: (event) => received = event,
      ),
    );

    dispatchZIMKitImageDownloadProgress(
      message: ZIMKitMessage(),
      currentSize: 40,
      totalSize: null,
    );

    expect(received?.isUploading, isFalse);
    expect(received?.currentSize, 40);
    expect(received?.totalSize, 0);
  });

  test('dispatches connection state and event data', () {
    ZIMKitConnectionStateEvent? received;
    ZIMKitCore.instance.events = ZIMKitEvents(
      connection: ZIMKitConnectionEvents(
        onConnectionStateChanged: (event) => received = event,
      ),
    );

    dispatchZIMKitConnectionStateChanged(
      state: ZIMConnectionState.connected,
      event: ZIMConnectionEvent.success,
      extendedData: {'reason': 'connected'},
    );

    expect(received?.state, ZIMConnectionState.connected);
    expect(received?.event, ZIMConnectionEvent.success);
    expect(received?.extendedData, {'reason': 'connected'});
  });

  test('dispatches token expiration countdown and expired callbacks', () {
    int? remainingSeconds;
    var expiredCount = 0;
    ZIMKitCore.instance.events = ZIMKitEvents(
      connection: ZIMKitConnectionEvents(
        onTokenWillExpire: (event) => remainingSeconds = event.remainSeconds,
        onTokenExpired: () => expiredCount++,
      ),
    );

    dispatchZIMKitTokenWillExpire(30);
    dispatchZIMKitTokenExpired();

    expect(remainingSeconds, 30);
    expect(expiredCount, 1);
  });
}
