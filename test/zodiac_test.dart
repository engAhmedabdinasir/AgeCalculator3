import 'package:flutter_test/flutter_test.dart';
import 'package:agecalculator/models/zodiac.dart';

void main() {
  group('ZodiacSign calculation tests', () {
    test('Calculates Pisces for leap year 2000-02-29', () {
      final date = DateTime(2000, 2, 29);
      final sign = ZodiacSign.fromDate(date);

      expect(sign.name, 'Pisces');
      expect(sign.symbol, '♓');
      expect(sign.element, 'Water');
    });

    test('Calculates Pisces for regular year 2001-02-28', () {
      final date = DateTime(2001, 2, 28);
      final sign = ZodiacSign.fromDate(date);

      expect(sign.name, 'Pisces');
      expect(sign.symbol, '♓');
    });

    test('Calculates all 12 signs correctly at representative dates', () {
      expect(ZodiacSign.fromDate(DateTime(1995, 1, 10)).name, 'Capricorn');
      expect(ZodiacSign.fromDate(DateTime(1995, 2, 10)).name, 'Aquarius');
      expect(ZodiacSign.fromDate(DateTime(1995, 3, 10)).name, 'Pisces');
      expect(ZodiacSign.fromDate(DateTime(1995, 4, 10)).name, 'Aries');
      expect(ZodiacSign.fromDate(DateTime(1995, 5, 10)).name, 'Taurus');
      expect(ZodiacSign.fromDate(DateTime(1995, 6, 10)).name, 'Gemini');
      expect(ZodiacSign.fromDate(DateTime(1995, 7, 10)).name, 'Cancer');
      expect(ZodiacSign.fromDate(DateTime(1995, 8, 10)).name, 'Leo');
      expect(ZodiacSign.fromDate(DateTime(1995, 9, 10)).name, 'Virgo');
      expect(ZodiacSign.fromDate(DateTime(1995, 10, 10)).name, 'Libra');
      expect(ZodiacSign.fromDate(DateTime(1995, 11, 10)).name, 'Scorpio');
      expect(ZodiacSign.fromDate(DateTime(1995, 12, 10)).name, 'Sagittarius');
      expect(ZodiacSign.fromDate(DateTime(1995, 12, 25)).name, 'Capricorn');
    });

    test('Boundary dates for signs', () {
      // Aries vs Taurus
      expect(ZodiacSign.fromDate(DateTime(2024, 4, 19)).name, 'Aries');
      expect(ZodiacSign.fromDate(DateTime(2024, 4, 20)).name, 'Taurus');

      // Capricorn year turnover
      expect(ZodiacSign.fromDate(DateTime(2024, 12, 31)).name, 'Capricorn');
      expect(ZodiacSign.fromDate(DateTime(2025, 1, 1)).name, 'Capricorn');
      expect(ZodiacSign.fromDate(DateTime(2025, 1, 19)).name, 'Capricorn');
      expect(ZodiacSign.fromDate(DateTime(2025, 1, 20)).name, 'Aquarius');
    });
  });
}
