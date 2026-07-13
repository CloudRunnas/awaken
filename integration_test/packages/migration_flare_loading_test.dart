import '../support/package_test_harness.dart';
import 'package:flare_loading/flare_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  initPackageIntegrationTest();

  testWidgets('FlareLoading widget construction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FlareLoading(
          height: 100,
          width: 100,
          startAnimation: 'searching',
          name: 'assets/res/disc.flr',
          alignment: Alignment.center,
          fit: BoxFit.cover,
          onError: (_, __) {},
          onSuccess: (_) {},
        ),
      ),
    );
    expect(find.byType(FlareLoading), findsOneWidget);
  });
}
