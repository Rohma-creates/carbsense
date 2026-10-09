// lib/widgets/eaten_today_section.dart
import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:carbsense/utils/carb_level.dart';
import 'package:carbsense/widgets/carbs_today_card.dart'; // showSetTargetDialog
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String _fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);
String _time(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "Eaten today" list + total + optional target progress. Reads DietLogProvider.
///
/// [pendingCarbs]  carbs of the selected food if NOT yet added (shows
///                 "+ X g if you add this meal"). Pass 0 once added.
/// [highlightFirst] highlight the newest entry (use right after adding).
class EatenTodaySection extends StatelessWidget {
  final double pendingCarbs;
  final bool highlightFirst;
  const EatenTodaySection({
    super.key,
    this.pendingCarbs = 0,
    this.highlightFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final log = context.watch<DietLogProvider>();
    final entries = log.todayEntries; // newest first
    final total = log.totalCarbsToday;
    final target = log.dailyCarbTarget;

    final small = AppTextStyles.statUnit(
      context,
    ).copyWith(fontSize: 11, color: Colors.black54);
    final normal = AppTextStyles.statUnit(
      context,
    ).copyWith(color: Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EATEN TODAY',
              style: AppTextStyles.body(
                context,
              ).copyWith(color: Colors.black, letterSpacing: 1.5),
            ),
            Text(
              '${entries.length} item${entries.length == 1 ? '' : 's'}',
              style: small,
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('Nothing eaten yet', style: small),
          ),

        for (int i = 0; i < entries.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(
              left: 12,
              top: 8,
              bottom: 8,
              right: 4,
            ),
            decoration: BoxDecoration(
              color:
                  (highlightFirst && i == 0)
                      ? AppColors.dietSurface
                      : AppColors.white,
              border: Border.all(
                color:
                    (highlightFirst && i == 0)
                        ? AppColors.dietPrimary
                        : AppColors.dietBorder,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entries[i].name,
                        style: normal.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${entries[i].servings} serving${entries[i].servings == 1 ? '' : 's'} · ${_time(entries[i].time)}',
                        style: small,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_fmt(entries[i].carbs)} g',
                      style: normal.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    CarbLevelPill(
                      gramsPerServing:
                          entries[i].servings == 0
                              ? 0
                              : entries[i].carbs / entries[i].servings,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => log.removeEntry(entries[i]),
                ),
              ],
            ),
          ),

        const SizedBox(height: 4),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total today',
                    style: normal.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    target == null
                        ? '${_fmt(total)} g'
                        : '${_fmt(total)} g of ${_fmt(target)} g',
                    style: AppTextStyles.chipDiet(
                      context,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
              if (pendingCarbs > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+ ${_fmt(pendingCarbs)} g if you add this meal',
                    style: small,
                  ),
                ),
              if (target != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (total / target).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: AppColors.white,
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
                Text(
                  total > target
                      ? '${_fmt(total - target)} g over your target'
                      : '${_fmt(target - total)} g remaining',
                  style: small.copyWith(color: AppColors.dietPrimary),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dietBorder, width: 0.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.track_changes,
                size: 16,
                color: AppColors.dietPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  target == null
                      ? 'No daily target set'
                      : 'Your own target: ${_fmt(target)} g',
                  style: normal,
                ),
              ),
              TextButton(
                onPressed: () => showSetTargetDialog(context),
                child: Text(target == null ? 'Set my target' : 'Edit'),
              ),
            ],
          ),
        ),

        if (entries.isNotEmpty)
          Center(
            child: TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Clear today\'s log?'),
                        content: const Text(
                          'All items you added today will be removed.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                );
                if (ok == true) log.clearLog();
              },
              child: Text('Clear log', style: small),
            ),
          ),
      ],
    );
  }
}
