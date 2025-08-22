import 'audio_record.dart';
import 'package:flutter/material.dart';

/// Events configuration class for message list page
class ZIMKitMessageListPageEvents {
  /// Creates a message list page events instance
  /// 
  /// [audioRecord] Audio recording events configuration
  /// [onTextFieldTap] Callback when text field is tapped
  ZIMKitMessageListPageEvents({
    this.audioRecord,
    this.onTextFieldTap,
  });

  ZIMKitAudioRecordEvents? audioRecord;

  final VoidCallback? onTextFieldTap;
}
