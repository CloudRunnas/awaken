import '../support/package_test_harness.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('Flushbar widget construction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Flushbar(
                  messageText: const Text(
                    'Enter a Playlist Name! ¯\\_(ツ)_/¯',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: const Duration(seconds: 2),
                ).show(context);
              },
              child: const Text('Show'),
            );
          },
        ),
      ),
    );
    expect(find.text('Show'), findsOneWidget);
  });
}
