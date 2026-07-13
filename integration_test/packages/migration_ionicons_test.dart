import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons_plus/ionicons_plus.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('Ionicons icon data exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: const [
            Icon(Ionicons.settings_outline),
            Icon(Ionicons.shuffle_outline),
            Icon(Ionicons.logo_paypal),
          ],
        ),
      ),
    );
    expect(Ionicons.settings_outline, isA<IconData>());
    expect(find.byIcon(Ionicons.settings_outline), findsOneWidget);
  });
}
