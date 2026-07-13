import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_edit/on_audio_edit.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('OnAudioEdit class exists', (tester) async {
    final editor = OnAudioEdit();
    expect(editor, isA<OnAudioEdit>());

    try {
      await editor.getUri();
    } catch (_) {
      // Native URI access may fail in test environment.
    }
  });
}
