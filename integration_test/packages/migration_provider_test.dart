import '../support/package_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _TestNotifier extends ChangeNotifier {
  void tick() => notifyListeners();
}

void main() {
  initPackageIntegrationTest();

  testWidgets('ChangeNotifierProvider', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<_TestNotifier>(
          create: (_) => _TestNotifier(),
          child: Builder(
            builder: (context) {
              final notifier = Provider.of<_TestNotifier>(context);
              expect(notifier, isA<_TestNotifier>());
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  });
}
