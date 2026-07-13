import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html_unescape/html_unescape.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('HtmlUnescape convert', (tester) async {
    const raw = 'Tom &amp; Jerry &lt;3';
    final lyricsDat = HtmlUnescape().convert(raw);
    expect(lyricsDat, 'Tom & Jerry <3');
  });
}
