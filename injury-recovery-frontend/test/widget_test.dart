// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:VOMAS/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VOMASApp());

    // Allow time for widgets to render
    await tester.pumpAndSettle();

    // Check if the app loads without crashing (basic smoke test)
    // The HomeScreen shows "VOMAS" as the title
    expect(find.text('VOMAS'), findsOneWidget);
  });
}
