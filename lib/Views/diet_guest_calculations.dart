import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbs_today_card.dart'; // showSetTargetDialog
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'guest_info_diet.dart';

/// Summary screen shown after the guest enters height / weight / age / goal.
/// It shows BMI only. There is no calculated carb budget: carb needs are
/// personal, so the user may enter their own target (optional).
class DietGuestCalculations extends StatelessWidget {
  final double height; // cm
  final double weight; // kg
  final double age;
  final int goalIndex;

  const DietGuestCalculations({
    super.key,
    required this.height,
    required this.weight,
    required this.age,
    required this.goalIndex,
  });

  GoalProfile get _goal => kGoalProfiles[goalIndex];

  double get _bmi {
    final h = height / 100;
    return weight / (h * h);
  }

  String get _bmiCategory {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25.0) return 'Normal';
    if (_bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  String _fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String sub,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.dietSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dietBorder, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.buttonGhost(context)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.chipDiet(context)),
          const SizedBox(height: 4),
          Text(
            sub,
            style: AppTextStyles.statUnit(context).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.dietPrimary, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption(
                context,
              ).copyWith(color: const Color(0xFF777777), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final log = context.watch<DietLogProvider>();
    final target = log.dailyCarbTarget;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CarbSenseAppBar(
            title: 'Diet Mode',
            subtitle: 'Guest Session - Not Saved',
            showBack: true,
            mode: AppUserMode.diet,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Summary',
                        style: AppTextStyles.pageHeading(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dietSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.dietBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          _goal.label,
                          style: AppTextStyles.statUnit(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'BMI',
                          _bmi.toStringAsFixed(1),
                          _bmiCategory,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Carbs today',
                          '${_fmt(log.totalCarbsToday)} g',
                          'eaten',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'BMI is a general reference only.',
                    style: AppTextStyles.statUnit(context),
                  ),
                  const SizedBox(height: 16),

                  Text('CARB TARGET', style: AppTextStyles.caption(context)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 14),
                    decoration: BoxDecoration(
                      color: AppColors.dietSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.dietBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.bullseye,
                          color: AppColors.dietPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              target == null
                                  ? 'No target set. Add your own anytime to see a progress bar.'
                                  : 'Your own target: ${_fmt(target)} g per day',
                              style: AppTextStyles.statUnit(
                                context,
                              ).copyWith(color: Colors.black87),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => showSetTargetDialog(context),
                          child: Text(target == null ? 'Set' : 'Edit'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 0.5, color: AppColors.dietBorder),

                  const SizedBox(height: 8),
                  Text(
                    'WHAT YOU CAN DO',
                    style: AppTextStyles.caption(context),
                  ),
                  _buildInfoRow(
                    context,
                    FontAwesomeIcons.chartSimple,
                    'See carbs per serving with low, medium or high labels',
                  ),
                  const Divider(thickness: 0.5, color: AppColors.dietBorder),
                  _buildInfoRow(
                    context,
                    FontAwesomeIcons.sliders,
                    'Change serving size and watch carbs update',
                  ),
                  const Divider(thickness: 0.5, color: AppColors.dietBorder),
                  _buildInfoRow(
                    context,
                    FontAwesomeIcons.listCheck,
                    'Keep a running list of what you eat today',
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Find My Food  →',
                      gradient: AppColors.buttonGradientDiet,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.foodCategory,
                          arguments: {
                            'mode': AppUserMode.diet,
                            'goalIndex': goalIndex,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
