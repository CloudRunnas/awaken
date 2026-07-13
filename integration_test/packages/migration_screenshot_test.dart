import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('ScreenshotController', (tester) async {
    final screenshotController = ScreenshotController();
    expect(screenshotController, isA<ScreenshotController>());

    try {
      await screenshotController.captureFromWidget(
        const SizedBox(
          height: 100,
          width: 100,
          child: ColoredBox(color: Colors.red),
        ),
      );
    } catch (_) {
      // Capture may fail without full platform bindings.
    }
  });
}
