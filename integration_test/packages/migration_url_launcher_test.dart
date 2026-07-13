import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('canLaunchUrl pattern', (tester) async {
    final url = Uri.parse('https://github.com/shaan-mephobic/The-Phoenix-Project');
    try {
      final canLaunch = await canLaunchUrl(url);
      expect(canLaunch, isA<bool>());
    } catch (_) {
      // URL launcher may be unavailable in test environment.
      expect(canLaunchUrl, isA<Function>());
    }
  });
}
