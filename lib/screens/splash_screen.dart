import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Animated Splash Screen with Teal theme, orange and pink accents.
/// Displays logo card with glow, animated progress bar, pulsing dots,
/// and navigates to '/home' or '/login' based on Supabase session state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _cardTextController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  late final AnimationController _dotsController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (1400ms): Fade in + Scale from 0.85 to 1.0
    _cardTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _cardTextController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _cardTextController,
        curve: Curves.easeOutBack,
      ),
    );

    // 2. Progress bar animation (2400ms): Fills from 0% to 100%
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // 3. Pulsing dots animation (1200ms loop)
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _cardTextController.forward();
    _progressController.forward();

    // 4. Timer to check auth session and navigate after 2500ms
    _navigationTimer = Timer(const Duration(milliseconds: 2500), _checkAuthAndNavigate);
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _cardTextController.dispose();
    _progressController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Widget _buildDot(Color color, double phaseOffset) {
    final t = (_dotsController.value - phaseOffset) % 1.0;
    final wave = (math.cos(t * 2 * math.pi) + 1.0) / 2.0;
    final opacity = (0.4 + 0.6 * wave).clamp(0.4, 1.0);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF062B2B),
              Color(0xFF0A3A3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Fade & Scale transition for Logo Card and Title/Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Center white rounded card with dual glow & teal border
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFF1D9E75),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D9E75).withValues(alpha: 0.35),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFFED93B1).withValues(alpha: 0.20),
                              blurRadius: 60,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 130,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Age Calculator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Track your journey',
                        style: TextStyle(
                          color: Color(0xFFF59A23),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Thin rounded gradient progress bar
              Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4A44),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                          heightFactor: 1.0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF1D9E75),
                                  Color(0xFFF59A23),
                                  Color(0xFFED93B1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Three pulsing dots
              AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(const Color(0xFF1D9E75), 0.0),
                      const SizedBox(width: 8),
                      _buildDot(const Color(0xFFF59A23), 0.33),
                      const SizedBox(width: 8),
                      _buildDot(const Color(0xFFED93B1), 0.66),
                    ],
                  );
                },
              ),
              const Spacer(),
              // Version at the very bottom
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Color(0xFFED93B1),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
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
