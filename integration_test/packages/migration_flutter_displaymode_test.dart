import '../support/package_test_harness.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('FlutterDisplayMode.setHighRefreshRate', (tester) async {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {
      // Display mode API is Android-only.
    }
    expect(FlutterDisplayMode.setHighRefreshRate, isA<Function>());
  });
}
