import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

void main() {
  initPackageIntegrationTest();

  testWidgets('html parse', (tester) async {
    const htmlBody =
        '<div class="user_avatar profile_header-avatar">background-image: url(\'https://example.com/img.jpg\')</div>';
    final document = html_parser.parse(htmlBody);
    expect(document.querySelector('div'), isNotNull);
    expect(document.body?.text, contains('background-image'));
  });
}
