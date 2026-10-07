// Widget tests for the Age Calculator app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agecalculator/main.dart';
import 'package:agecalculator/screens/login_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: child,
    );
  }

  testWidgets('AgeCalculatorHome loads and shows Age Calculator title & logout', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const AgeCalculatorHome()));
    await tester.pump();

    // Verify the header text and icons are visible
    expect(find.text('Age Calculator'), findsOneWidget);
    expect(find.text('Powered by Supabase ⚡'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });

  testWidgets('Date picker prompt is visible before selection', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const AgeCalculatorHome()));
    await tester.pump();

    expect(find.text('Tap to select your birth date'), findsOneWidget);
    expect(find.text('DATE OF BIRTH'), findsOneWidget);
  });

  testWidgets('Placeholder is shown before date is selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const AgeCalculatorHome()));
    await tester.pump();

    expect(find.text('Select your date of birth'), findsOneWidget);
    expect(find.text('Tap the field above to get started'), findsOneWidget);
  });

  testWidgets('Calendar icon and History button are present', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const AgeCalculatorHome()));
    await tester.pump();

    expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('LoginScreen shows form fields and toggle', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const LoginScreen()));
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
  });

  test('calculateAge calculates birthday boundaries and zodiac correctly', () {
    final state = AgeCalculatorHomeState();
    final birthDate = DateTime(2000, 7, 4);

    // Case 1: Today is the birthday
    final nowOnBirthday = DateTime(2026, 7, 4, 15, 30);
    final resultOnBirthday = state.calculateAge(birthDate, nowOnBirthday);
    expect(resultOnBirthday.daysUntilNextBirthday, 0);
    expect(resultOnBirthday.years, 26);
    expect(resultOnBirthday.months, 0);
    expect(resultOnBirthday.days, 0);
    expect(resultOnBirthday.zodiacSign.name, 'Cancer');

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

    // Case 4: Leap year birth date 2000-02-29
    final leapDate = DateTime(2000, 2, 29);
    final leapResult = state.calculateAge(leapDate, DateTime(2024, 2, 29));
    expect(leapResult.years, 24);
    expect(leapResult.zodiacSign.name, 'Pisces');
    expect(leapResult.zodiacSign.symbol, '♓');
  });
}
