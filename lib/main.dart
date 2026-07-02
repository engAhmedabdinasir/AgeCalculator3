import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    try {
      await dotenv.load(fileName: 'assets/.env.local');
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('Could not load assets/.env.local: $e');
      }
    }
  }

  // Fallback to the default credentials if still empty
  if (supabaseUrl.isEmpty) {
    supabaseUrl = 'https://gzzruzkwkryyvscyombs.supabase.co';
  }
  if (supabaseAnonKey.isEmpty) {
    supabaseAnonKey = 'sb_publishable_2lks3IuC_r3r4EnEZa5EXA_MAKVpm67';
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  runApp(const AgeCalculatorApp());
}

class AgeCalculatorApp extends StatelessWidget {
  const AgeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Age Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF1E1B2E),
        ),
      ),
      home: const AgeCalculatorHome(),
    );

    // On web/desktop, wrap in a phone frame for a mobile feel
    if (kIsWeb) {
      return MaterialApp(
        title: 'Age Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
          useMaterial3: true,
        ),
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0A1A),
          body: Center(
            child: _MobilePhoneFrame(child: app),
          ),
        ),
      );
    }

    return app;
  }
}

// ─────────────────────────────────────────────
// Web Split Layout: Dark left + White right
// ─────────────────────────────────────────────
class _WebSplitLayout extends StatelessWidget {
  const _WebSplitLayout();

  @override
  Widget build(BuildContext context) {
    // The inner Flutter app with the actual calculator
    final innerApp = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF1E1B2E),
        ),
      ),
      home: const AgeCalculatorHome(),
    );

    return Scaffold(
      body: Row(
        children: [
          // ── LEFT PANEL: Dark with phone frame ──
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A0818),
                    Color(0xFF0F0C29),
                    Color(0xFF1A1730),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative blurred glow circles
                  Positioned(
                    top: -80,
                    left: -80,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    right: -60,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFB06AB3).withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  // Centered phone frame
                  Center(
                    child: _MobilePhoneFrame(child: innerApp),
                  ),
                ],
              ),
            ),
          ),

          // ── RIGHT PANEL: White info section ──
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Powered by Supabase',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Heading
                    const Text(
                      'Age\nCalculator',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F0C29),
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Discover your exact age down to the minute. Save your results to the cloud and track your history.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Divider
                    Container(
                      height: 1,
                      color: const Color(0xFFE5E7EB),
                    ),
                    const SizedBox(height: 36),

                    // Feature list
                    const Text(
                      'FEATURES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureRow(
                      Icons.cake_rounded,
                      'Exact Age',
                      'Years, months, days — all calculated precisely',
                      const Color(0xFF6C63FF),
                    ),
                    _buildFeatureRow(
                      Icons.timer_rounded,
                      'Detailed Stats',
                      'Total days, hours & minutes since birth',
                      const Color(0xFFFF8A65),
                    ),
                    _buildFeatureRow(
                      Icons.cloud_upload_rounded,
                      'Cloud Save',
                      'Persist calculations to Supabase instantly',
                      const Color(0xFF4FC3F7),
                    ),
                    _buildFeatureRow(
                      Icons.history_rounded,
                      'History',
                      'Browse all past saved calculations',
                      const Color(0xFF81C784),
                    ),
                    const SizedBox(height: 36),

                    // Divider
                    Container(height: 1, color: const Color(0xFFE5E7EB)),
                    const SizedBox(height: 32),

                    // Stats row
                    const Text(
                      'BY THE NUMBERS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildStatBadge('8,760', 'Hours / Year'),
                        const SizedBox(width: 16),
                        _buildStatBadge('525,600', 'Minutes / Year'),
                        const SizedBox(width: 16),
                        _buildStatBadge('365', 'Days / Year'),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Supabase tech note
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFE5E7EB), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFFB06AB3)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.storage_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Supabase Database',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Real-time PostgreSQL · Row Level Security · Anonymous Access',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
      IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mobile Phone Frame (web only)
// ─────────────────────────────────────────────
class _MobilePhoneFrame extends StatelessWidget {
  final Widget child;
  const _MobilePhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    const phoneWidth = 390.0;
    const phoneHeight = 844.0;
    const borderRadius = 44.0;

    return Container(
      width: phoneWidth + 20,
      height: phoneHeight + 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C2C3E), Color(0xFF1A1A2E)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 60,
            spreadRadius: 10,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              SizedBox(width: phoneWidth, height: phoneHeight, child: child),
              // Dynamic Island notch
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 120,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A3A5C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Home bar
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 130,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────
class AgeResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int totalHours;
  final int totalMinutes;
  final int daysUntilNextBirthday;
  final String nextBirthdayDate;
  final String dayOfWeekBorn;

  AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalHours,
    required this.totalMinutes,
    required this.daysUntilNextBirthday,
    required this.nextBirthdayDate,
    required this.dayOfWeekBorn,
  });
}

// ─────────────────────────────────────────────
// Main Page
// ─────────────────────────────────────────────
class AgeCalculatorHome extends StatefulWidget {
  const AgeCalculatorHome({super.key});

  @override
  State<AgeCalculatorHome> createState() => _AgeCalculatorHomeState();
}

class _AgeCalculatorHomeState extends State<AgeCalculatorHome>
    with TickerProviderStateMixin {
  DateTime? _selectedDate;
  AgeResult? _ageResult;

  // Save state
  bool _isSaving = false;
  bool _isSaved = false;

  late AnimationController _cardAnimController;
  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    );
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  AgeResult _calculateAge(DateTime birthDate) {
    final now = DateTime.now();

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final totalDays = now.difference(birthDate).inDays;
    final totalHours = now.difference(birthDate).inHours;
    final totalMinutes = now.difference(birthDate).inMinutes;

    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
    final daysUntilNext = nextBirthday.difference(now).inDays + 1;
    final nextBirthdayStr =
        '${birthDate.day} ${_months[birthDate.month - 1]} ${nextBirthday.year}';
    final dayOfWeek = _weekdays[birthDate.weekday - 1];

    return AgeResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      daysUntilNextBirthday: daysUntilNext,
      nextBirthdayDate: nextBirthdayStr,
      dayOfWeekBorn: dayOfWeek,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'SELECT YOUR BIRTH DATE',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1B2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _ageResult = _calculateAge(picked);
        _isSaved = false; // reset save state on new date
      });
      _cardAnimController.forward(from: 0);
    }
  }

  /// Save the current calculation to Supabase.
  Future<void> _saveToCloud() async {
    if (_ageResult == null || _selectedDate == null || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await SupabaseService.instance.saveCalculation(
        birthDate: _selectedDate!,
        years: _ageResult!.years,
        months: _ageResult!.months,
        days: _ageResult!.days,
        totalDays: _ageResult!.totalDays,
        totalHours: _ageResult!.totalHours,
        totalMinutes: _ageResult!.totalMinutes,
        dayOfWeekBorn: _ageResult!.dayOfWeekBorn,
      );
      setState(() {
        _isSaved = true;
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cloud_done_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Saved to Supabase cloud!'),
              ],
            ),
            backgroundColor: const Color(0xFF6C63FF),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  /// Show history bottom sheet fetched from Supabase.
  Future<void> _showHistory() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _HistoryBottomSheet(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF1E1B3A),
              Color(0xFF24243E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildDatePickerCard(),
                const SizedBox(height: 24),
                if (_ageResult != null) ...[
                  FadeTransition(
                    opacity: _cardFadeAnim,
                    child: SlideTransition(
                      position: _cardSlideAnim,
                      child: Column(
                        children: [
                          _buildMainAgeCard(),
                          const SizedBox(height: 16),
                          _buildStatsGrid(),
                          const SizedBox(height: 16),
                          _buildBirthdayCard(),
                          const SizedBox(height: 20),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ] else
                  _buildPlaceholder(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      // History FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showHistory,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.history_rounded),
        label: const Text('History',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.cake_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Age Calculator',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Powered by Supabase ⚡',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DATE OF BIRTH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _pickDate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: _selectedDate != null
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedDate != null
                      ? Colors.transparent
                      : const Color(0xFF6C63FF).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: _selectedDate != null
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : 'Tap to select your birth date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _selectedDate != null
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.7), size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAgeCard() {
    final result = _ageResult!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            'YOU ARE',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          ScaleTransition(
            scale: _pulseAnim,
            child: Text(
              '${result.years}',
              style: const TextStyle(
                fontSize: 88,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const Text(
            'YEARS OLD',
            style: TextStyle(
              fontSize: 18,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAgeUnit('${result.months}', 'MONTHS'),
              _buildVerticalDivider(),
              _buildAgeUnit('${result.days}', 'DAYS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeUnit(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
        height: 50, width: 1, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildStatsGrid() {
    final result = _ageResult!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.today_rounded,
          label: 'Total Days',
          value: _formatNumber(result.totalDays),
          color: const Color(0xFF4FC3F7),
        ),
        _buildStatCard(
          icon: Icons.schedule_rounded,
          label: 'Total Hours',
          value: _formatNumber(result.totalHours),
          color: const Color(0xFFFFB74D),
        ),
        _buildStatCard(
          icon: Icons.timer_rounded,
          label: 'Total Minutes',
          value: _formatNumber(result.totalMinutes),
          color: const Color(0xFF81C784),
        ),
        _buildStatCard(
          icon: Icons.wb_sunny_rounded,
          label: 'Day You Were Born',
          value: result.dayOfWeekBorn,
          color: const Color(0xFFFF8A65),
          smallText: true,
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool smallText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Text(value,
              style: TextStyle(
                  fontSize: smallText ? 16 : 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBirthdayCard() {
    final result = _ageResult!;
    final isToday = result.daysUntilNextBirthday <= 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isToday
              ? [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)]
              : [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isToday ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFF6C63FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(isToday ? '🎂' : '🎉',
                style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Happy Birthday! 🎊' : 'Next Birthday',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isToday ? Colors.black87 : Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  isToday ? 'Wishing you a wonderful day!' : result.nextBirthdayDate,
                  style: TextStyle(
                      fontSize: 13,
                      color: isToday
                          ? Colors.black54
                          : Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          if (!isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('${result.daysUntilNextBirthday}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const Text('days',
                      style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Save to Supabase button with animated state.
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaved ? null : _saveToCloud,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _isSaved
              ? const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF27AE60)])
              : LinearGradient(
                  colors: _isSaving
                      ? [
                          const Color(0xFF6C63FF).withValues(alpha: 0.5),
                          const Color(0xFFB06AB3).withValues(alpha: 0.5),
                        ]
                      : [const Color(0xFF6C63FF), const Color(0xFFB06AB3)],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (_isSaved ? const Color(0xFF2ECC71) : const Color(0xFF6C63FF))
                  .withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSaving)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            else
              Icon(
                _isSaved ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
                color: Colors.white,
                size: 20,
              ),
            const SizedBox(width: 10),
            Text(
              _isSaving
                  ? 'Saving…'
                  : _isSaved
                      ? 'Saved to Supabase ✓'
                      : 'Save to Supabase',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withValues(alpha: 0.15),
                    const Color(0xFFB06AB3).withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.cake_outlined,
                  size: 56,
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            Text('Select your date of birth',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6))),
            const SizedBox(height: 8),
            Text('Tap the field above to get started',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.3))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// History Bottom Sheet
// ─────────────────────────────────────────────
class _HistoryBottomSheet extends StatefulWidget {
  const _HistoryBottomSheet();

  @override
  State<_HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<_HistoryBottomSheet> {
  List<Map<String, dynamic>>? _history;
  String? _error;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await SupabaseService.instance.getHistory();
      setState(() => _history = data);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  String _formatBirthDate(String isoDate) {
    final d = DateTime.tryParse(isoDate);
    if (d == null) return isoDate;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String _formatTimestamp(String isoTs) {
    final d = DateTime.tryParse(isoTs)?.toLocal();
    if (d == null) return isoTs;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1730),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Cloud History',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const Spacer(),
                Text('Supabase ⚡',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.07),
              margin: const EdgeInsets.symmetric(horizontal: 20)),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: _error != null
                ? _buildError()
                : _history == null
                    ? _buildLoading()
                    : _history!.isEmpty
                        ? _buildEmpty()
                        : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: Colors.red.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text('Failed to load history',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _history = null;
                  _error = null;
                });
                _loadHistory();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_outlined,
              size: 52, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 14),
          Text('No saved calculations yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 6),
          Text('Calculate an age and tap "Save to Supabase"',
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _history!.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _history![index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                width: 1),
          ),
          child: Row(
            children: [
              // Age badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${item['years']}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1)),
                    Text('yrs',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatBirthDate('${item['birth_date']}'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['months']}m ${item['days']}d  ·  ${_formatNumber(item['total_days'] as int)} days',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.45)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp('${item['calculated_at']}'),
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
              ),
              // Weekday chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item['day_of_week_born']}'.substring(0, 3),
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB06AB3),
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}
