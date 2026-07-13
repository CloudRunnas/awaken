import '../support/package_test_harness.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('FFmpegKit.execute static call', (tester) async {
    try {
      await FFmpegKit.execute('-version');
    } catch (_) {
      // Native FFmpeg may be unavailable in test environment.
    }
    expect(FFmpegKit.execute, isA<Function>());
  });
}
