import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

class _UnusedZIM implements ZIM {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final core = ZIMKitCore.instance;

  setUp(() {
    core.db = ZIMKitDB();
  });

  // Non-disabled cases intentionally disagree to prove action is authoritative.
  test('adds conversation from added action', () {
    core.onConversationChanged(_UnusedZIM(), [
      ZIMConversationChangeInfo(
        event: ZIMConversationEvent.deleted,
        action: ZIMConversationListChangeAction.added,
        conversation: _conversation(name: 'New conversation'),
      ),
    ]);

    expect(core.db.conversations.notifier.value, hasLength(1));
    expect(
      core.db.conversations.notifier.value.single.value.name,
      'New conversation',
    );
  });

  test('updates conversation from updated action', () {
    core.db.conversations.init([_conversation(name: 'Old name')]);

    core.onConversationChanged(_UnusedZIM(), [
      ZIMConversationChangeInfo(
        event: ZIMConversationEvent.deleted,
        action: ZIMConversationListChangeAction.updated,
        conversation: _conversation(name: 'Updated name'),
      ),
    ]);

    expect(core.db.conversations.notifier.value, hasLength(1));
    expect(
      core.db.conversations.notifier.value.single.value.name,
      'Updated name',
    );
  });

  test('deletes conversation from deleted action', () {
    core.db.conversations.init([_conversation()]);

    core.onConversationChanged(_UnusedZIM(), [
      ZIMConversationChangeInfo(
        event: ZIMConversationEvent.updated,
        action: ZIMConversationListChangeAction.deleted,
        conversation: _conversation(),
      ),
    ]);

    expect(core.db.conversations.notifier.value, isEmpty);
  });

  test('disables conversation from legacy disabled event', () {
    core.db.conversations.init([_conversation()]);

    core.onConversationChanged(_UnusedZIM(), [
      ZIMConversationChangeInfo(
        event: ZIMConversationEvent.disabled,
        action: ZIMConversationListChangeAction.added,
        conversation: _conversation(),
      ),
    ]);

    expect(core.db.conversations.notifier.value, hasLength(1));
    expect(core.db.conversations.notifier.value.single.value.disable, isTrue);
  });
}

ZIMConversation _conversation({String name = 'Conversation'}) {
  return ZIMConversation(
    conversationID: 'conversation-id',
    type: ZIMConversationType.peer,
    conversationName: name,
  );
}
