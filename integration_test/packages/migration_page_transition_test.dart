import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('PageTransition widget construction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.size,
                    alignment: Alignment.center,
                    child: const Scaffold(body: Text('Target')),
                  ),
                );
              },
              child: const Text('Navigate'),
            );
          },
        ),
      ),
    );
    expect(find.text('Navigate'), findsOneWidget);
  });
}
