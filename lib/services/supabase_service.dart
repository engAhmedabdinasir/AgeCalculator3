import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton service for all Supabase database operations.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Save a calculation result to the `calculations` table.
  Future<void> saveCalculation({
    required DateTime birthDate,
    required int years,
    required int months,
    required int days,
    required int totalDays,
    required int totalHours,
    required int totalMinutes,
    required String dayOfWeekBorn,
  }) async {
    await _client.from('calculations').insert({
      'birth_date': birthDate.toIso8601String().substring(0, 10),
      'years': years,
      'months': months,
      'days': days,
      'total_days': totalDays,
      'total_hours': totalHours,
      'total_minutes': totalMinutes,
      'day_of_week_born': dayOfWeekBorn,
    });
  }

  /// Fetch the last 20 saved calculations, newest first.
  Future<List<Map<String, dynamic>>> getHistory() async {
    final response = await _client
        .from('calculations')
        .select()
        .order('calculated_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }
}
