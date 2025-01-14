import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/callkit/defines.dart';

const String messageConversationCacheKey = 'msg_cv_cache';
const String messageConversationCacheID = 'msg_cv_id';
const String messageConversationCacheTypeIndex = 'msg_cv_type_idx';
const String messageConversationSenderID = 'msg_cv_sender_id';

extension ZegoZIMKitOfflineMessageCacheInfoExtesion
    on ZegoZIMKitOfflineMessageCacheInfo {
  String toJson() {
    final dict = {
      messageConversationCacheID: conversationID,
      messageConversationCacheTypeIndex: conversationTypeIndex,
      messageConversationSenderID: senderID,
    };
    return const JsonEncoder().convert(dict);
  }

  static ZegoZIMKitOfflineMessageCacheInfo fromJson(String jsonString) {
    String conversationID = '';
    int conversationTypeIndex = ZIMConversationType.unknown.index;
    String senderID = '';

    Map<String, dynamic>? jsonMap;
    try {
      jsonMap = jsonDecode(jsonString) as Map<String, dynamic>?;
    } catch (e) {
      ZIMKitLogger.logInfo(
          'parse offline cache message, data is not a json:$jsonString');
    } finally {
      if (jsonMap?.containsKey(messageConversationCacheID) ?? false) {
        conversationID = jsonMap![messageConversationCacheID]! as String? ?? '';
      }
      if (jsonMap?.containsKey(messageConversationCacheTypeIndex) ?? false) {
        conversationTypeIndex =
            jsonMap![messageConversationCacheTypeIndex]! as int? ??
                (ZIMConversationType.unknown.index);
      }
      if (jsonMap?.containsKey(messageConversationSenderID) ?? false) {
        senderID = jsonMap![messageConversationSenderID]! as String? ?? '';
      }
    }

    return ZegoZIMKitOfflineMessageCacheInfo(
      conversationID: conversationID,
      conversationTypeIndex: conversationTypeIndex,
      senderID: senderID,
    );
  }
}

/// cached ID of the current message
Future<void> setOfflineMessageConversationInfo(
  ZegoZIMKitOfflineMessageCacheInfo cacheInfo,
) async {
  ZIMKitLogger.logInfo('set offline message:$cacheInfo');

  final prefs = await SharedPreferences.getInstance();
  prefs.setString(messageConversationCacheKey, cacheInfo.toJson());
}

/// Retrieve the cached ID of the current message, which is stored in the handler received from ZPNS.
Future<ZegoZIMKitOfflineMessageCacheInfo> getOfflineMessageConversationInfo({
  bool selfDestructing = true,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString(messageConversationCacheKey) ?? '';

  ZIMKitLogger.logInfo(
    'get offline message conversation info, '
    'data:$data, '
    'selfDestructing:$selfDestructing, ',
  );

  if (selfDestructing) {
    await clearOfflineMessageConversationInfo();
  }

  return ZegoZIMKitOfflineMessageCacheInfoExtesion.fromJson(data);
}

/// cached ID of the current message
Future<void> clearOfflineMessageConversationInfo() async {
  ZIMKitLogger.logInfo('clear offline message id');

  final prefs = await SharedPreferences.getInstance();
  prefs.remove(messageConversationCacheKey);
}
