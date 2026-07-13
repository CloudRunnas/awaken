import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('MdiIcons icon data exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Icon(MdiIcons.github),
            Icon(MdiIcons.gmail),
            Icon(MdiIcons.skipPrevious),
            Icon(MdiIcons.heart),
          ],
        ),
      ),
    );
    expect(MdiIcons.github, isA<IconData>());
    expect(find.byIcon(MdiIcons.github), findsOneWidget);
  });
}
