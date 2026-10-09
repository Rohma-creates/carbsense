// lib/utils/carb_level.dart
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

enum CarbLevel { low, medium, high }

/// General guide only (same cutoffs for every user). Change the numbers here
/// and every screen (pill, level card, log) updates automatically.
CarbLevel carbLevel(double gramsPerServing) {
  if (gramsPerServing < 10) return CarbLevel.low;
  if (gramsPerServing <= 30) return CarbLevel.medium;
  return CarbLevel.high;
}

class CarbLevelPill extends StatelessWidget {
  final double gramsPerServing;
  const CarbLevelPill({super.key, required this.gramsPerServing});

  @override
  Widget build(BuildContext context) {
    final level = carbLevel(gramsPerServing);
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (level) {
      case CarbLevel.low:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        label = 'Low';
        break;
      case CarbLevel.medium:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Medium';
        break;
      case CarbLevel.high:
        bg = const Color(0xFFFAECE7);
        fg = const Color(0xFF712B13);
        label = 'High';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.chipDiet(
          context,
        ).copyWith(fontSize: 11, color: fg),
      ),
    );
  }
}
