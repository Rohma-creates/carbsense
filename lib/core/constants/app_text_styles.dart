import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Breakpoints (logical pixels)
/// - Compact  : width < 400   → small phones (SE, older Androids)
/// - Normal   : 400 – 599     → standard phones  ← design baseline
/// - Medium   : 600 – 839     → large phones / small tablets
/// - Expanded : ≥ 840         → tablets / foldables / desktops
enum _Breakpoint { compact, normal, medium, expanded }

class AppTextStyles {
  // ─── Internal scale helper ───────────────────────────────────────────
  static double _scale(BuildContext context, double base) {
    final width = MediaQuery.sizeOf(context).width;

    final bp =
        width < 400
            ? _Breakpoint.compact
            : width < 600
            ? _Breakpoint.normal
            : width < 840
            ? _Breakpoint.medium
            : _Breakpoint.expanded;

    final factor = switch (bp) {
      _Breakpoint.compact => 0.92,
      _Breakpoint.normal => 1.00,
      _Breakpoint.medium => 1.12,
      _Breakpoint.expanded => 1.25,
    };

    return (base * factor).clamp(11.0, base * 1.5);
  }

  // ════════════════════════════════════════════════════════════════════
  // APP NAME / BRAND
  // ════════════════════════════════════════════════════════════════════

  /// "CarbSense" on Splash — dark, large
  static TextStyle appNameLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 30),
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// "CarbSense" in AppBar gradient strip — white
  static TextStyle appNameAppBar(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 22),
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  // ════════════════════════════════════════════════════════════════════
  // TAGLINE
  // ════════════════════════════════════════════════════════════════════

  /// In AppBar strip — faded white
  static TextStyle tagline(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 12),
    fontWeight: FontWeight.w400,
    color: AppColors.white.withValues(alpha: 0.55),
    letterSpacing: 1.2,
  );

  /// On Splash — hint grey
  static TextStyle taglineMuted(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 12),
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 2.0,
  );

  // ════════════════════════════════════════════════════════════════════
  // SCREEN TITLE  (inside AppBar gradient strip)
  // ════════════════════════════════════════════════════════════════════

  /// "Your Profile", "Settings", "Dashboard"
  static TextStyle screenTitle(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 18),
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: -0.2,
  );

  /// Subtitle under screen title
  static TextStyle screenSubtitle(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 12),
    fontWeight: FontWeight.w400,
    color: AppColors.white.withValues(alpha: 0.55),
    letterSpacing: 0.1,
    height: 1.5,
  );

  // ════════════════════════════════════════════════════════════════════
  // PAGE HEADING  (on white body area)
  // ════════════════════════════════════════════════════════════════════

  /// "Welcome 👋", "Your Details"
  static TextStyle pageHeading(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 20),
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // ════════════════════════════════════════════════════════════════════
  // BODY
  // ════════════════════════════════════════════════════════════════════

  /// General body copy on white background
  static TextStyle body(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 16),
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  /// Body on a dark/gradient background
  static TextStyle bodyOnDark(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 14),
    fontWeight: FontWeight.w400,
    color: AppColors.white.withValues(alpha: 0.80),
    height: 1.6,
  );

  // ════════════════════════════════════════════════════════════════════
  // CARD TITLE
  // ════════════════════════════════════════════════════════════════════

  /// Compact feature cards — "For Diabetics", "Guest Access"
  static TextStyle cardTitle(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 17),
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  /// Profile-selection cards (larger)
  static TextStyle cardTitleLarge(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 17),
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // ════════════════════════════════════════════════════════════════════
  // CARD SUBTITLE
  // ════════════════════════════════════════════════════════════════════

  /// "Use app without saving data", "Save logs, history..."
  static TextStyle cardSubtitle(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 15),
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ════════════════════════════════════════════════════════════════════
  // SECTION LABEL / OVERLINE
  // ════════════════════════════════════════════════════════════════════

  /// All-caps small overline — "CONTINUE AS GUEST", "BASIC INFO"
  static TextStyle sectionLabel(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 14),
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.4,
  );

  // ════════════════════════════════════════════════════════════════════
  // BUTTONS
  // ════════════════════════════════════════════════════════════════════

  /// Primary filled button — "Create Account", "Find my Food"
  static TextStyle button(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 15),
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
  );

  /// Ghost / text button — "Continue as Guest", "Skip"
  static TextStyle buttonGhost(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 15),
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  // ════════════════════════════════════════════════════════════════════
  // CHIPS / BADGES
  // ════════════════════════════════════════════════════════════════════

  /// White text on solid colour — selected/active chip
  static TextStyle chipFilled(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 12),
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
  );

  /// Diabetic-mode tinted — "WHY REGISTER", "HbA1c"
  static TextStyle chipDiabetic(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 14),
    fontWeight: FontWeight.w600,
    color: AppColors.diabeticPrimary,
    letterSpacing: 0.2,
  );

  /// Diet-mode tinted — "WHY REGISTER", "Calories"
  static TextStyle chipDiet(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 12),
    fontWeight: FontWeight.w600,
    color: AppColors.dietPrimary,
    letterSpacing: 0.2,
  );

  // ════════════════════════════════════════════════════════════════════
  // STAT / NUMBER  (dashboard metrics)
  // ════════════════════════════════════════════════════════════════════

  /// Big metric numbers — "120", "2,400 kcal"
  static TextStyle statNumber(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 32),
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );

  /// Unit label next to a stat — "mg/dL", "kcal"
  static TextStyle statUnit(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 13),
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  // ════════════════════════════════════════════════════════════════════
  // CAPTION / HINT
  // ════════════════════════════════════════════════════════════════════

  /// Text field hints/labels, timestamps, fine-print
  static TextStyle caption(BuildContext context) => GoogleFonts.poppins(
    fontSize: _scale(context, 15),
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 0.1,
  );
}
