import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/services/path_platform_file.dart';

void main() {
  test('path-backed file exposes its URI, length, and content', () async {
    final directory = await Directory.systemTemp.createTemp('zimkit-file-');
    addTearDown(() => directory.delete(recursive: true));

    final file = File('${directory.path}/note.txt');
    final expectedBytes = Uint8List.fromList([90, 101, 103, 111]);
    await file.writeAsBytes(expectedBytes);

    final platformFile = ZIMKitPathPlatformFile(
      path: file.path,
      name: 'note.txt',
      size: expectedBytes.length,
    );

    expect(platformFile.path, file.path);
    expect(platformFile.uri, Uri.file(file.path));
    expect(platformFile.lengthSync(), expectedBytes.length);
    expect(await platformFile.length(), expectedBytes.length);
    expect(await platformFile.readAsBytes(), expectedBytes);
    expect(
      await platformFile.readAsByteStream().expand((chunk) => chunk).toList(),
      expectedBytes,
    );
    expect(platformFile.xFile.path, file.path);
  });
}
