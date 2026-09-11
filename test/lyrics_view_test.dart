import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:phoenix/src/beginning/widgets/lyrics/lyrics_panel.dart';

void main() {
  testWidgets('LyricsPanel accepts textColor and backgroundColor parameters',
      (WidgetTester tester) async {
    // Build the LyricsPanel with white text and dark background.
    await tester.pumpWidget(
      MaterialApp(
        home: LyricsPanel(
          textColor: Colors.white,
          backgroundColor: Colors.black87,
        ),
      ),
    );

    // Wait for any animations to settle.
    await tester.pumpAndSettle();

    // Verify that the widget renders without throwing.
    expect(find.byType(LyricsPanel), findsOneWidget);

    // Additional checks could be added here if we could control the lyrics data.
    // For now, we ensure the widget is constructable with the given parameters.
  });
}