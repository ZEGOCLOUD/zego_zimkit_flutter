Future<List<T>> pickFilesFromPicker<T>({
  required bool allowMultiple,
  required Future<List<T>> Function() pickMultiple,
  required Future<T?> Function() pickSingle,
}) async {
  if (allowMultiple) {
    return pickMultiple();
  }

  final file = await pickSingle();
  return file == null ? [] : [file];
}
