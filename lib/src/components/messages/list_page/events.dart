import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/components/messages/input/events.dart';
import 'package:zego_zimkit/src/components/messages/list/events.dart';
import 'package:zego_zimkit/src/components/audio/events.dart';

/// Events class for ZIMKitMessageListPage (extends the existing one)
class ZIMKitMessageListPageEvent {
  const ZIMKitMessageListPageEvent({
    this.audioRecordEvents,
    this.messageInputEvents,
    this.messageListEvents,
  });

  final ZIMKitMessageInputEvents? messageInputEvents;
  final ZIMKitAudioRecordEvents? audioRecordEvents;
  final ZIMKitMessageListEvents? messageListEvents;
}
