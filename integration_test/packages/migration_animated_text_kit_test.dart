import '../support/package_test_harness.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('FlickerAnimatedText in AnimatedTextKit', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 100,
          width: 200,
          child: AnimatedTextKit(
            repeatForever: false,
            animatedTexts: [
              FlickerAnimatedText(
                'AWAKENING',
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'NightMachine',
                  fontSize: 16,
                ),
                speed: const Duration(seconds: 5),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(AnimatedTextKit), findsOneWidget);
  });
}
