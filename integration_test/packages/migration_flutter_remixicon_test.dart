import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remixicon/flutter_remixicon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('flutter_remixicon import and MIcon data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: const [
            Icon(MIcon.riSearchLine),
            Icon(MIcon.riLock2Line),
          ],
        ),
      ),
    );
    expect(MIcon.riSearchLine, isA<IconData>());
    expect(find.byIcon(MIcon.riSearchLine), findsOneWidget);
  });
}
