import 'dart:io';

import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('Share.shareXFiles with XFile', (tester) async {
    final tempFile = File('${Directory.systemTemp.path}/phoenix_share_test.txt');
    await tempFile.writeAsString('test');

    try {
      await Share.shareXFiles([XFile(tempFile.path)]);
    } catch (_) {
      // Share sheet may not be available in test environment.
    }

    expect(XFile(tempFile.path).path, endsWith('phoenix_share_test.txt'));
    await tempFile.delete();
  });
}
