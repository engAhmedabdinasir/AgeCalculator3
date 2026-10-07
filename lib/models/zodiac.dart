/// Model and calculator for Western Zodiac Signs.
class ZodiacSign {
  final String name;
  final String symbol;
  final String element;
  final String dateRange;

  const ZodiacSign({
    required this.name,
    required this.symbol,
    required this.element,
    required this.dateRange,
  });

  /// Calculates the zodiac sign for any given date.
  /// Handles leap years such as 2000-02-29 (Pisces).
  static ZodiacSign fromDate(DateTime date) {
    final m = date.month;
    final d = date.day;

    if ((m == 1 && d <= 19) || (m == 12 && d >= 22)) {
      return const ZodiacSign(
        name: 'Capricorn',
        symbol: '♑',
        element: 'Earth',
        dateRange: 'Dec 22 – Jan 19',
      );
    } else if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) {
      return const ZodiacSign(
        name: 'Aquarius',
        symbol: '♒',
        element: 'Air',
        dateRange: 'Jan 20 – Feb 18',
      );
    } else if ((m == 2 && d >= 19) || (m == 3 && d <= 20)) {
      return const ZodiacSign(
        name: 'Pisces',
        symbol: '♓',
        element: 'Water',
        dateRange: 'Feb 19 – Mar 20',
      );
    } else if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) {
      return const ZodiacSign(
        name: 'Aries',
        symbol: '♈',
        element: 'Fire',
        dateRange: 'Mar 21 – Apr 19',
      );
    } else if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) {
      return const ZodiacSign(
        name: 'Taurus',
        symbol: '♉',
        element: 'Earth',
        dateRange: 'Apr 20 – May 20',
      );
    } else if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) {
      return const ZodiacSign(
        name: 'Gemini',
        symbol: '♊',
        element: 'Air',
        dateRange: 'May 21 – Jun 20',
      );
    } else if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) {
      return const ZodiacSign(
        name: 'Cancer',
        symbol: '♋',
        element: 'Water',
        dateRange: 'Jun 21 – Jul 22',
      );
    } else if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) {
      return const ZodiacSign(
        name: 'Leo',
        symbol: '♌',
        element: 'Fire',
        dateRange: 'Jul 23 – Aug 22',
      );
    } else if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) {
      return const ZodiacSign(
        name: 'Virgo',
        symbol: '♍',
        element: 'Earth',
        dateRange: 'Aug 23 – Sep 22',
      );
    } else if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) {
      return const ZodiacSign(
        name: 'Libra',
        symbol: '♎',
        element: 'Air',
        dateRange: 'Sep 23 – Oct 22',
      );
    } else if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) {
      return const ZodiacSign(
        name: 'Scorpio',
        symbol: '♏',
        element: 'Water',
        dateRange: 'Oct 23 – Nov 21',
      );
    } else {
      return const ZodiacSign(
        name: 'Sagittarius',
        symbol: '♐',
        element: 'Fire',
        dateRange: 'Nov 22 – Dec 21',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZodiacSign &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          symbol == other.symbol &&
          element == other.element &&
          dateRange == other.dateRange;

  @override
  int get hashCode =>
      name.hashCode ^ symbol.hashCode ^ element.hashCode ^ dateRange.hashCode;
}
