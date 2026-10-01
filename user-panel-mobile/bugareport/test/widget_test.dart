import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugareport/screens/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders without crashing', (WidgetTester tester) async {
    // Note: Supabase is not initialized in tests.
    // Integration tests should be used for full end-to-end testing.
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen()),
    );
  });
}
