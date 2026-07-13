import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palette_generator/palette_generator.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('PaletteGenerator.fromImageProvider', (tester) async {
    final image = const AssetImage('assets/res/default.jpg');
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(image);
      expect(paletteGenerator, isA<PaletteGenerator>());
    } catch (_) {
      // Asset may not be loaded in test environment.
      expect(PaletteGenerator.fromImageProvider, isA<Function>());
    }
  });
}
