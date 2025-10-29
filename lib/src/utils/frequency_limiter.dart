import 'dart:async';

/// A utility class that limits the frequency of method calls
///
/// This class prevents a method from being called too frequently by enforcing
/// a minimum time interval between calls.
class FrequencyLimiter<T> {
  /// Whether a method is currently being called
  bool isCalling = false;

  /// The minimum duration between method calls
  final Duration duration;

  /// Creates a frequency limiter instance
  ///
  /// [duration] The minimum time interval between method calls
  FrequencyLimiter(this.duration);

  T run(T fallback, T Function() method) {
    if (isCalling) return fallback;
    isCalling = true;
    Timer(duration, () {
      isCalling = false;
    });
    return method.call();
  }
}
