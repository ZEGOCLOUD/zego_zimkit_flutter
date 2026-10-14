Future<void> handleZIMKitGroupMemberQueryFailure({
  required Object error,
  required Future<int> Function() tryRelogin,
  required Future<void> Function() retryQuery,
  required void Function() clearFetched,
  required void Function(Object error) onError,
}) async {
  var retryCode = -1;
  Object reportedError = error;
  try {
    retryCode = await tryRelogin();
  } catch (reloginError) {
    reportedError = reloginError;
  }

  if (retryCode == 0) {
    try {
      await retryQuery();
      return;
    } catch (retryError) {
      reportedError = retryError;
    }
  }

  clearFetched();
  onError(reportedError);
}
