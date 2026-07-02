// Widget tests for the Age Calculator app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agecalculator/main.dart';

void main() {
  testWidgets('App loads and shows Age Calculator title', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pumpAndSettle();

    // Verify the header text is visible
    expect(find.text('Age Calculator'), findsOneWidget);
    expect(find.text('Discover your exact age'), findsOneWidget);
  });

  testWidgets('Date picker prompt is visible before selection', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Tap to select your birth date'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
  });

  testWidgets('Placeholder is shown before date is selected', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Select your date of birth'), findsOneWidget);
    expect(find.text('Tap the field above to get started'), findsOneWidget);
  });

  testWidgets('Calendar icon is present', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
  });
}
