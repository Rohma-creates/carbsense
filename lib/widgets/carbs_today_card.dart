// lib/widgets/carbs_today_card.dart
import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String _fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);

Future<void> showSetTargetDialog(BuildContext context) async {
  final log = context.read<DietLogProvider>();
  final controller = TextEditingController(
    text: log.dailyCarbTarget == null ? '' : _fmt(log.dailyCarbTarget!),
  );
  await showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Your daily carb target'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'e.g. 150',
              suffixText: 'g',
              helperText: 'Use the number from your dietitian or your own plan',
            ),
          ),
          actions: [
            if (log.hasTarget)
              TextButton(
                onPressed: () {
                  log.clearTarget();
                  Navigator.pop(ctx);
                },
                child: const Text('Remove'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(controller.text.trim());
                if (v == null || v <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a number greater than 0'),
                    ),
                  );
                  return;
                }
                log.setTarget(v);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
  );
}

/// Shows "already eaten + this meal = total today".
/// If the user set a target, also shows a progress bar.
class CarbsTodayCard extends StatelessWidget {
  final double thisMealCarbs;
  const CarbsTodayCard({super.key, required this.thisMealCarbs});

  Widget _row(
    BuildContext context,
    String left,
    String right, {
    bool bold = false,
  }) {
    final style = AppTextStyles.statUnit(context).copyWith(
      color: Colors.black,
      fontSize: 12,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(left, style: style), Text(right, style: style)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final log = context.watch<DietLogProvider>();
    final eaten = log.totalCarbsToday;
    final total = eaten + thisMealCarbs;
    final target = log.dailyCarbTarget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.dietSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dietBorder, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(context, 'Already eaten', '${_fmt(eaten)} g'),
              _row(context, 'This meal', '+ ${_fmt(thisMealCarbs)} g'),
              const Divider(height: 16),
              _row(context, 'Total today', '${_fmt(total)} g', bold: true),
              if (target != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (total / target).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      total > target
                          ? const Color(0xFFDC2626)
                          : total / target > 0.85
                          ? const Color(0xFFF59E0B)
                          : AppColors.dietPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 g', style: AppTextStyles.caption(context)),
                    Text(
                      total > target
                          ? '${_fmt(total - target)} g over your target'
                          : '${_fmt(target - total)} g remaining',
                      style: AppTextStyles.caption(
                        context,
                      ).copyWith(color: AppColors.dietPrimary),
                    ),
                    Text(
                      '${_fmt(target)} g',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.dietBorder, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.track_changes, size: 16, color: AppColors.dietPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  target == null
                      ? 'No daily target set'
                      : 'Your own target: ${_fmt(target)} g',
                  style: AppTextStyles.caption(context),
                ),
              ),
              TextButton(
                onPressed: () => showSetTargetDialog(context),
                child: Text(target == null ? 'Set my target' : 'Edit'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
