import '../support/package_test_harness.dart';
import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('FlutterSlider widget construction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 50,
            child: FlutterSlider(
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black12,
                  border: Border.all(width: 3, color: Colors.white24),
                ),
                activeTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
              axis: Axis.horizontal,
              values: const [0, 100],
              tooltip: FlutterSliderTooltip(disabled: true),
              rangeSlider: true,
              min: 0,
              max: 100,
              onDragging: (index, start, end) {},
            ),
          ),
        ),
      ),
    );
    expect(find.byType(FlutterSlider), findsOneWidget);
  });
}
