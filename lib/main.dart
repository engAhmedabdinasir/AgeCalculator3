import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/zodiac.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
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

  // Strictly require Supabase configuration
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase credentials. Please specify SUPABASE_URL and SUPABASE_ANON_KEY via environment variables or assets/.env.local',
    );
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
      home: const AuthGate(),
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
// Auth Gate
// ─────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.onAuthStateChange,
      builder: (context, snapshot) {
        final session = AuthService.instance.currentSession;
        if (session != null) {
          return const AgeCalculatorHome();
        }
        return const LoginScreen();
      },
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
  final ZodiacSign zodiacSign;

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
    required this.zodiacSign,
  });
}

// ─────────────────────────────────────────────
// Main Page
// ─────────────────────────────────────────────
class AgeCalculatorHome extends StatefulWidget {
  const AgeCalculatorHome({super.key});

  @override
  State<AgeCalculatorHome> createState() => AgeCalculatorHomeState();
}

class AgeCalculatorHomeState extends State<AgeCalculatorHome>
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

  AgeResult calculateAge(DateTime birthDate, [DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();

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

    final todayMidnight = DateTime(now.year, now.month, now.day);
    final birthDateMidnight =
        DateTime(birthDate.year, birthDate.month, birthDate.day);

    DateTime nextBirthday = DateTime(
        todayMidnight.year, birthDateMidnight.month, birthDateMidnight.day);
    if (nextBirthday.isBefore(todayMidnight)) {
      nextBirthday = DateTime(
          todayMidnight.year + 1, birthDateMidnight.month, birthDateMidnight.day);
    }
    final daysUntilNext = nextBirthday.difference(todayMidnight).inDays;
    final nextBirthdayStr =
        '${birthDate.day} ${_months[birthDate.month - 1]} ${nextBirthday.year}';
    final dayOfWeek = _weekdays[birthDate.weekday - 1];
    final zodiac = ZodiacSign.fromDate(birthDate);

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
      zodiacSign: zodiac,
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
        _ageResult = calculateAge(picked);
        _isSaved = false; // reset save state on new date
      });
      _cardAnimController.forward(from: 0);
    }
  }

  /// Save the current calculation to Supabase.
  Future<void> _saveToCloud() async {
    if (_ageResult == null || _selectedDate == null || _isSaving) return;

    // Reject future dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final birthMidnight =
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    if (birthMidnight.isAfter(today)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Birth date cannot be in the future.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

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
    } on SocketException {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('No internet connection. Please check your network.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on PostgrestException catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: ${e.message}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      final errorStr = e.toString().toLowerCase();
      final msg = (errorStr.contains('socket') ||
              errorStr.contains('network') ||
              errorStr.contains('failed host lookup') ||
              errorStr.contains('clientexception'))
          ? 'No internet connection. Please check your network.'
          : 'Error saving: $e';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
            // Bottom padding of 90 ensures content never gets covered by FAB
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 90),
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
                          _buildZodiacCard(),
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
      // Centered Extended History FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        },
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
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
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          tooltip: 'Logout',
          onPressed: () async {
            await AuthService.instance.signOut();
          },
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

  Widget _buildZodiacCard() {
    final result = _ageResult!;
    final zodiac = result.zodiacSign;

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
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFB06AB3)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              zodiac.symbol,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      zodiac.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        zodiac.element,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Zodiac Sign  ·  ${zodiac.dateRange}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayCard() {
    final result = _ageResult!;
    final isToday = result.daysUntilNextBirthday == 0;

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
}
