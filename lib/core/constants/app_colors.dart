import 'package:flutter/material.dart';

class AppColors {
  // Blues — diabetic
  static const Color diabeticDark = Color(0xFF0F3460);
  static const Color diabeticPrimary = Color(0xFF1A56DB);
  static const Color diabeticLight = Color(0xFF4F9CF9);
  static const Color diabeticSurface = Color(0xFFF0F5FF); // light blue bg
  static const Color diabeticBorder = Color(0xFFC7D9FF);

  // Greens — diet
  static const Color dietDark = Color(0xFF062A1F);
  static const Color dietPrimary = Color(0xFF0D9E75);
  static const Color dietLight = Color(0xFF34C99A);
  static const Color dietSurface = Color(0xFFF0FBF7); // light green bg
  static const Color dietBorder = Color(0xFFB3E8D8);

  // Shared
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F7FB);
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3); // very light cool grey
  static const Color divider = Color(0xFFE5E9F0);

  // Gradients
  static const LinearGradient diabeticGradient = LinearGradient(
    colors: [Color(0xFF0F3460), Color(0xFF1A56DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dietGradient = LinearGradient(
    colors: [Color(0xFF062A1F), Color(0xFF0D9E75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF1A56DB), Color(0xFF4F9CF9)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient buttonGradientDiet = LinearGradient(
    colors: [Color(0xFF0D9E75), Color(0xFF34C99A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
