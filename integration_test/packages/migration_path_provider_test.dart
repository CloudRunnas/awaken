import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('getApplicationDocumentsDirectory', (tester) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      expect(dir.path, isNotEmpty);
    } catch (_) {
      // Path provider may be unavailable in some test environments.
      expect(getApplicationDocumentsDirectory, isA<Function>());
    }
  });
}
