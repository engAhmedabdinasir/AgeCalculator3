import 'package:flutter/material.dart';

/// Official Brand Colors for Age Calculator
class BrandColors {
  // Brand palette taken directly from the official logo
  static const Color primaryBlue = Color(0xFF1E6FD9);
  static const Color accentOrange = Color(0xFFF7941D);
  static const Color secondaryTeal = Color(0xFF22B573);
  static const Color darkNavy = Color(0xFF14142B);

  // Surface and card colors preserving the dark glassmorphism aesthetic
  static const Color cardDark = Color(0xFF1F1F3D);
  static const Color surfaceDark = Color(0xFF191932);

  // Gradient accents: blue -> teal gradient (#1E6FD9 -> #22B573)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryBlue, secondaryTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradientHorizontal = LinearGradient(
    colors: [primaryBlue, secondaryTeal],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Soft glow shadow in brand blue
  static BoxShadow glowShadow = BoxShadow(
    color: primaryBlue.withValues(alpha: 0.35),
    blurRadius: 20,
    spreadRadius: 2,
    offset: const Offset(0, 6),
  );
}
