// lib/widgets/carb_level_card.dart
import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/utils/carb_level.dart';
import 'package:flutter/material.dart';

/// "Carb level per serving" card: pill (Low / Medium / High) + 3-segment bar.
class CarbLevelCard extends StatelessWidget {
  final double gramsPerServing;
  const CarbLevelCard({super.key, required this.gramsPerServing});

  static const _inactive = Color(0xFFE5E9F0);
  static const _lowColor = Color(0xFF1D9E75);
  static const _mediumColor = Color(0xFFEF9F27);
  static const _highColor = Color(0xFFD85A30);

  Widget _segment(bool active, Color activeColor) {
    return Expanded(
      child: Container(
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active ? activeColor : _inactive,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text, bool active) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.statUnit(context).copyWith(
          fontSize: 11,
          color: active ? Colors.black : Colors.black54,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = carbLevel(gramsPerServing);
    final isLow = level == CarbLevel.low;
    final isMedium = level == CarbLevel.medium;
    final isHigh = level == CarbLevel.high;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dietBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Carb level per serving',
                style: AppTextStyles.statUnit(
                  context,
                ).copyWith(color: Colors.black),
              ),
              CarbLevelPill(gramsPerServing: gramsPerServing),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _segment(isLow, _lowColor),
              _segment(isMedium, _mediumColor),
              _segment(isHigh, _highColor),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _label(context, 'Low', isLow),
              _label(context, 'Medium', isMedium),
              _label(context, 'High', isHigh),
            ],
          ),
        ],
      ),
    );
  }
}
