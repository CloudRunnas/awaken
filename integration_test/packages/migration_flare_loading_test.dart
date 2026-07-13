import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix/src/beginning/widgets/dialogues/awakening.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('Awakening loader widget renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Awakening()),
      ),
    );
    expect(find.text('AWAKENING'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
