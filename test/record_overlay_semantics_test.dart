import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zimkit/src/components/audio/record_overlay.dart';
import 'package:zego_zimkit/src/components/audio/status.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

void main() {
  testWidgets('locked recording overlay blocks background semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final recordStatus = ZIMKitRecordStatus()..startRecording(locked: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            Semantics(
              button: true,
              label: 'Background action',
              child: SizedBox(width: 48, height: 48),
            ),
            ZIMKitRecordOverlay(
              status: recordStatus,
              onSend: () {},
              onDiscard: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.semantics.byLabel('Background action'), findsNothing);
    expect(
      find.semantics.byLabel(
        ZIMKitCore.instance.innerText.discardRecordingLabelText,
      ),
      findsOneWidget,
    );
    expect(
      find.semantics.byLabel(ZIMKitCore.instance.innerText.sendRecordingText),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('locked actions wait for native recorder readiness', (
    tester,
  ) async {
    final recordStatus = ZIMKitRecordStatus();
    final generation = recordStatus.startRecording(locked: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            ZIMKitRecordOverlay(
              status: recordStatus,
              onSend: () {},
              onDiscard: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.text('Starting recording…'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('record-discard-button')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('record-send-button')),
          )
          .onPressed,
      isNull,
    );

    recordStatus.markRecordingStarted(generation);
    await tester.pump();

    expect(find.text('Recording locked'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('record-discard-button')),
          )
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('record-send-button')),
          )
          .onPressed,
      isNotNull,
    );
  });
}
