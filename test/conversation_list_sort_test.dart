import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/services/core/defines.dart';

void main() {
  test('keeps pinned conversations above newer unpinned conversations', () {
    final conversationList = ZIMKitConversationList()
      ..init([
        _conversation('new-unpinned', orderKey: 300),
        _conversation('older-pinned', orderKey: 200, isPinned: true),
        _conversation('newer-pinned', orderKey: 250, isPinned: true),
      ])
      ..sort();

    expect(conversationList.notifier.value.map((item) => item.value.id), [
      'newer-pinned',
      'older-pinned',
      'new-unpinned',
    ]);
  });
}

ZIMConversation _conversation(
  String id, {
  required int orderKey,
  bool isPinned = false,
}) => ZIMConversation()
  ..conversationID = id
  ..type = ZIMConversationType.peer
  ..orderKey = orderKey
  ..isPinned = isPinned;
