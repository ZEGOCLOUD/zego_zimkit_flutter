import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/services/file_picker_result_adapter.dart';

void main() {
  group('pickFilesFromPicker', () {
    test(
      'returns all files for multiple selection without calling single',
      () async {
        var multipleCalls = 0;
        var singleCalls = 0;

        final result = await pickFilesFromPicker<String>(
          allowMultiple: true,
          pickMultiple: () async {
            multipleCalls++;
            return ['first', 'second'];
          },
          pickSingle: () async {
            singleCalls++;
            return 'single';
          },
        );

        expect(result, ['first', 'second']);
        expect(multipleCalls, 1);
        expect(singleCalls, 0);
      },
    );

    test(
      'wraps a single selection and returns empty on cancellation',
      () async {
        final selected = await pickFilesFromPicker<String>(
          allowMultiple: false,
          pickMultiple: () async => ['unexpected'],
          pickSingle: () async => 'only',
        );
        final cancelled = await pickFilesFromPicker<String>(
          allowMultiple: false,
          pickMultiple: () async => ['unexpected'],
          pickSingle: () async => null,
        );

        expect(selected, ['only']);
        expect(cancelled, isEmpty);
      },
    );
  });
}
