import 'package:flutter/foundation.dart';

void updateNotifierWhenMounted<T>({
  required ValueNotifier<T> notifier,
  required T value,
  required bool isMounted,
}) {
  if (!isMounted) return;
  notifier.value = value;
}
