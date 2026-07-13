import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('SleekCircularSlider widget construction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SleekCircularSlider(
            appearance: CircularSliderAppearance(
              infoProperties: InfoProperties(
                bottomLabelStyle: const TextStyle(color: Colors.white),
                bottomLabelText: 'SENSITIVITY',
                mainLabelStyle: const TextStyle(color: Colors.white),
              ),
              size: 100,
              customColors: CustomSliderColors(
                progressBarColor: Colors.orange,
                trackColor: Colors.black26,
              ),
              customWidths: CustomSliderWidths(progressBarWidth: 4),
            ),
            min: 0,
            max: 100,
            initialValue: 50,
            onChange: (double value) {},
          ),
        ),
      ),
    );
    expect(find.byType(SleekCircularSlider), findsOneWidget);
  });
}
