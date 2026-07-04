// Widget tests for the Age Calculator app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agecalculator/main.dart';

void main() {
  testWidgets('App loads and shows Age Calculator title', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pump();

    // Verify the header text is visible
    expect(find.text('Age Calculator'), findsOneWidget);
    expect(find.text('Powered by Supabase ⚡'), findsOneWidget);
  });

  testWidgets('Date picker prompt is visible before selection', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pump();

    expect(find.text('Tap to select your birth date'), findsOneWidget);
    expect(find.text('DATE OF BIRTH'), findsOneWidget);
  });

  testWidgets('Placeholder is shown before date is selected', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pump();

    expect(find.text('Select your date of birth'), findsOneWidget);
    expect(find.text('Tap the field above to get started'), findsOneWidget);
  });

  testWidgets('Calendar icon is present', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeCalculatorApp());
    await tester.pump();

    expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
  });

  test('calculateAge calculates birthday boundaries correctly', () {
    final state = AgeCalculatorHomeState();
    final birthDate = DateTime(2000, 7, 4);

    // Case 1: Today is the birthday
    final nowOnBirthday = DateTime(2026, 7, 4, 15, 30);
    final resultOnBirthday = state.calculateAge(birthDate, nowOnBirthday);
    expect(resultOnBirthday.daysUntilNextBirthday, 0);
    expect(resultOnBirthday.years, 26);
    expect(resultOnBirthday.months, 0);
    expect(resultOnBirthday.days, 0);

    // Case 2: Birthday is tomorrow
    final nowDayBefore = DateTime(2026, 7, 3, 10, 0);
    final resultDayBefore = state.calculateAge(birthDate, nowDayBefore);
    expect(resultDayBefore.daysUntilNextBirthday, 1);
    expect(resultDayBefore.years, 25);
    expect(resultDayBefore.months, 11);
    expect(resultDayBefore.days, 29);

    // Case 3: Birthday was yesterday
    final nowDayAfter = DateTime(2026, 7, 5, 9, 0);
    final resultDayAfter = state.calculateAge(birthDate, nowDayAfter);
    expect(resultDayAfter.daysUntilNextBirthday, 364);
    expect(resultDayAfter.years, 26);
    expect(resultDayAfter.months, 0);
    expect(resultDayAfter.days, 1);
  });
}


