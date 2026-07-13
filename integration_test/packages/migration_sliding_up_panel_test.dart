import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('SlidingUpPanel widget construction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SlidingUpPanel(
            parallaxEnabled: true,
            isDraggable: true,
            backdropColor: Colors.black,
            minHeight: 60,
            maxHeight: 400,
            backdropEnabled: true,
            backdropTapClosesPanel: true,
            renderPanelSheet: true,
            color: Colors.transparent,
            collapsed: const Text('Collapsed'),
            panel: const Center(child: Text('Panel')),
          ),
        ),
      ),
    );
    expect(find.byType(SlidingUpPanel), findsOneWidget);
  });
}
