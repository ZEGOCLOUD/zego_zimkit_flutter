import 'dart:convert';

import 'package:zego_zpns/zego_zpns.dart';

import 'package:zego_zimkit/src/services/logger_service.dart';

class ZIMKitIOSIMMessageData {
  final String title;
  final String body;
  final String conversationID;
  final int conversationTypeIndex;
  final String senderID;
  final String senderName;

  ZIMKitIOSIMMessageData({
    required this.title,
    required this.body,
    required this.conversationID,
    required this.conversationTypeIndex,
    required this.senderID,
    required this.senderName,
  });

  @override
  String toString() {
    return 'ZIMKitIOSIMMessageData{'
        'title:$title, '
        'body:$body, '
        'conversationID:$conversationID, '
        'conversationTypeIndex:$conversationTypeIndex, '
        'senderID:$senderID, '
        'senderName:$senderName'
        '}';
  }
}

class ZIMKitIOSIMMessageDataParser {
  /// 解析iOS IM消息数据
  ///
  /// iOS的extras结构：
  /// extras:{
  ///   aps: {
  ///     alert: {title: user_870125, body: 喝酒据斤斤计较}
  ///   },
  ///   payload: {
  ///     "operation_type":"text_msg",
  ///     "id":"116802",
  ///     "sender":{
  ///         "id":"870125","name":"user_870125"
  ///     },
  ///     "type":1
  ///   },
  ///   zego: {version: 1, zpns_request_id: 4855622119122677075}
  /// }
  ///
  Future<ZIMKitIOSIMMessageData> parse(
    ZPNsMessage message,
  ) async {
    final aps = message.extras['aps'] as Map<Object?, Object?>? ?? {};
    final alert = aps['alert'] as Map<Object?, Object?>? ?? {};
    final body = alert['body']?.toString() ?? '';
    final title = alert['title']?.toString() ?? '';

    final payload = message.extras['payload']?.toString() ?? '';
    final payloadMap = _parsePayloadMap(payload);
    final conversationID = payloadMap['id'] as String? ?? '';
    final conversationTypeIndex = payloadMap['type'] as int? ?? -1;

    final senderInfo = payloadMap['sender'] as Map<String, dynamic>? ?? {};
    final senderID = senderInfo['id'] as String? ?? '';
    final senderName = senderInfo['name'] as String? ?? '';

    return ZIMKitIOSIMMessageData(
      title: title,
      body: body,
      conversationID: conversationID,
      conversationTypeIndex: conversationTypeIndex,
      senderID: senderID,
      senderName: senderName,
    );
  }

  Map<String, dynamic> _parsePayloadMap(String payload) {
    Map<String, dynamic> payloadMap = {};
    try {
      payloadMap = jsonDecode(payload) as Map<String, dynamic>? ?? {};
    } catch (e) {
      ZIMKitLogger.logInfo(
        'payload， json decode data exception:$e',
      );
    }
    ZIMKitLogger.logInfo(
      'payloadMap:$payloadMap',
    );

    return payloadMap;
  }
}
