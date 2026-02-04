import 'package:flutter/material.dart';

class AppColors {
  // Medical / Brand Colors
  static const Color medicalBlue = Color(0xFF4A90E2); // Primary
  static const Color medicalTeal = Color(0xFF50E3C2); // Secondary
  static const Color softGreen = Color(0xFF91E2A6); // Success
  static const Color warningAmber = Color(0xFFF5A623); // Warning
  static const Color errorRed = Color(0xFFE74C3C); // Error

  // Neutrals - Light Mode
  static const Color lightBackground = Color(
    0xFFFAFAFA,
  ); // Off-white background
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  // Neutrals - Dark Mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF2A2A3E);

  // Text - Light Mode
  static const Color textPrimary = Color(0xFF333333); // Dark Grey
  static const Color textSecondary = Color(0xFF888888); // Muted Grey

  // Text - Dark Mode
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // Action Card Colors
  static const List<Color> flexionGradient = [
    Color(0xFF4A90E2),
    Color(0xFF357ABD),
  ];
  static const List<Color> abductionGradient = [
    Color(0xFF50E3C2),
    Color(0xFF3DBEA6),
  ];
  static const List<Color> rotationGradient = [
    Color(0xFFF5A623),
    Color(0xFFD4891A),
  ];
  static const List<Color> horizontalGradient = [
    Color(0xFFE74C3C),
    Color(0xFFC0392B),
  ];
  static const List<Color> pronationGradient = [
    Color(0xFF9B59B6),
    Color(0xFF7D3C98),
  ];
  static const List<Color> deviationGradient = [
    Color(0xFF1ABC9C),
    Color(0xFF16A085),
  ];

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    colors: [medicalBlue, medicalTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [medicalBlue, Color(0xFF357ABD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
