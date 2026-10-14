import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/components/settings/notifier_update.dart';

void main() {
  test('does not update a notifier after its owner is disposed', () {
    final notifier = ValueNotifier(false)..dispose();

    expect(
      () => updateNotifierWhenMounted(
        notifier: notifier,
        value: true,
        isMounted: false,
      ),
      returnsNormally,
    );
  });

  test('updates a notifier while its owner is mounted', () {
    final notifier = ValueNotifier(false);

    updateNotifierWhenMounted(notifier: notifier, value: true, isMounted: true);

    expect(notifier.value, isTrue);
    notifier.dispose();
  });
}
