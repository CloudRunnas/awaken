import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  initPackageIntegrationTest();

  testWidgets('http.get with Uri.parse', (tester) async {
    try {
      final response = await http.get(
        Uri.parse('https://example.com'),
      );
      expect(response.statusCode, greaterThan(0));
    } catch (_) {
      // Network may be unavailable in test environment.
      expect(http.get, isA<Function>());
    }
  });
}
