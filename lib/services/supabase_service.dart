import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton service for all Supabase database operations.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Save or update a calculation in the `calculations` table using upsert.
  /// Rejects future birth dates and onConflict matches ('user_id,birth_date').
  Future<void> saveCalculation({
    required DateTime birthDate,
    required int years,
    required int months,
    required int days,
    required int totalDays,
    required int totalHours,
    required int totalMinutes,
    required String dayOfWeekBorn,
    String? label,
  }) async {
    // 1. Reject future dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final birthMidnight = DateTime(birthDate.year, birthDate.month, birthDate.day);
    if (birthMidnight.isAfter(today)) {
      throw ArgumentError('Birth date cannot be in the future.');
    }

    final userId = _client.auth.currentUser?.id;
    final payload = <String, dynamic>{
      'birth_date': birthDate.toIso8601String().substring(0, 10),
      'years': years,
      'months': months,
      'days': days,
      'total_days': totalDays,
      'total_hours': totalHours,
      'total_minutes': totalMinutes,
      'day_of_week_born': dayOfWeekBorn,
    };

    if (userId != null) {
      payload['user_id'] = userId;
    }
    if (label != null && label.trim().isNotEmpty) {
      payload['label'] = label.trim();
    }

    await _client.from('calculations').upsert(
          payload,
          onConflict: 'user_id,birth_date',
        );
  }

  /// Fetch the authenticated user's saved calculations, newest first.
  Future<List<Map<String, dynamic>>> getHistory() async {
    final userId = _client.auth.currentUser?.id;
    var query = _client.from('calculations').select();
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    final response = await query.order('calculated_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Delete a calculation by ID from the `calculations` table.
  Future<void> deleteCalculation(String id) async {
    await _client.from('calculations').delete().eq('id', id);
  }
}
