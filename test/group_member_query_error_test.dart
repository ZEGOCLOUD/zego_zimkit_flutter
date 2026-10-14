import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/services/core/group_member_query_error.dart';

void main() {
  test(
    'reports a failed query after the relogin check declines retry',
    () async {
      final queryError = StateError('group member query failed');
      Object? reportedError;
      var isFetched = true;

      await handleZIMKitGroupMemberQueryFailure(
        error: queryError,
        tryRelogin: () async => -1,
        retryQuery: () async {},
        clearFetched: () => isFetched = false,
        onError: (error) => reportedError = error,
      );

      expect(reportedError, same(queryError));
      expect(isFetched, isFalse);
    },
  );

  test('retries the query after successful relogin', () async {
    var retryCount = 0;
    var errorCount = 0;

    await handleZIMKitGroupMemberQueryFailure(
      error: StateError('not logged in'),
      tryRelogin: () async => 0,
      retryQuery: () async => retryCount++,
      clearFetched: () {},
      onError: (_) => errorCount++,
    );

    expect(retryCount, 1);
    expect(errorCount, 0);
  });

  test('reports an error thrown while checking whether to relogin', () async {
    final reloginError = StateError('relogin failed');
    Object? reportedError;
    var isFetched = true;

    await handleZIMKitGroupMemberQueryFailure(
      error: StateError('query failed'),
      tryRelogin: () async => throw reloginError,
      retryQuery: () async {},
      clearFetched: () => isFetched = false,
      onError: (error) => reportedError = error,
    );

    expect(reportedError, same(reloginError));
    expect(isFetched, isFalse);
  });
}
