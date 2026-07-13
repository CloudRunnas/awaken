import 'dart:io';

import '../support/package_test_harness.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('Hive.initFlutter with temp directory', (tester) async {
    final tempDir = await Directory.systemTemp.createTemp('phoenix_hive_test');
    try {
      Hive.init(tempDir.path);
      final box = await Hive.openBox('musicDataBox');
      expect(box, isA<Box>());
      await box.close();
    } finally {
      await Hive.close();
      await tempDir.delete(recursive: true);
    }
  });
}
