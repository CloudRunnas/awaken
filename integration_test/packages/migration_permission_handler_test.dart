import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('Permission.audio and Permission.storage', (tester) async {
    expect(Permission.audio, isA<Permission>());
    expect(Permission.storage, isA<Permission>());

    try {
      await Permission.audio.request();
      await Permission.storage.request();
    } catch (_) {
      // Permission dialogs may not be available in test environment.
    }
  });
}
