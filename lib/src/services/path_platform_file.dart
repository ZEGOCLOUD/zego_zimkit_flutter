import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';

/// A FilePicker-compatible file backed by a local path.
///
/// FilePicker 13 exposes an abstract [PlatformFile], so SDK-created files
/// need a concrete implementation when sending files selected by other UI.
base class ZIMKitPathPlatformFile extends PlatformFile {
  ZIMKitPathPlatformFile({required this.path, required this.name, this.size});

  @override
  final String path;

  @override
  final String name;

  /// Known file size, when the caller already has it.
  final int? size;

  @override
  Uri get uri => Uri.file(path);

  @override
  XFile get xFile => XFile(path, name: name, length: size);

  @override
  int? lengthSync() => size ?? File(path).lengthSync();

  @override
  Future<int?> length() async => size ?? await File(path).length();

  @override
  Future<Uint8List> readAsBytes() => File(path).readAsBytes();

  @override
  Stream<Uint8List> readAsByteStream() =>
      File(path).openRead().map(Uint8List.fromList);
}
