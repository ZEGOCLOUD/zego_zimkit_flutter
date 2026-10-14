import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/services/extensions/zim_extension.dart';

void main() {
  test('toKIT preserves the SDK message sequence', () {
    final zimMessage = ZIMTextMessage(message: 'hello')..messageSeq = 42;

    final kitMessage = zimMessage.toKIT();

    expect(kitMessage.info.conversationSeq, 42);
    expect(kitMessage.textContent?.text, 'hello');
  });
}
