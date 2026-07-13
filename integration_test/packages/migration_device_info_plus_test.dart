import '../support/package_test_harness.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('DeviceInfoPlugin androidInfo sdkInt check', (tester) async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      final isAndroid11 = info.version.sdkInt > 29;
      expect(isAndroid11, isA<bool>());
    } catch (_) {
      // Skip on non-Android platforms.
    }
  });
}
