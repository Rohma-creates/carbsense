// lib/widgets/diabetic_log_section.dart
import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String _fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);
String _time(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "Eaten today" list for diabetic mode: carbs and estimated insulin per entry,
/// plus daily totals. Reads DietLogProvider.
class DiabeticLogSection extends StatelessWidget {
  final bool highlightFirst; // highlight the newest entry right after adding
  const DiabeticLogSection({super.key, this.highlightFirst = false});

  @override
  Widget build(BuildContext context) {
    final log = context.watch<DietLogProvider>();
    final entries = log.todayEntries; // newest first

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
            child: Text('Nothing logged yet', style: small),
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
                      ? AppColors.diabeticSurface
                      : AppColors.white,
              border: Border.all(
                color:
                    (highlightFirst && i == 0)
                        ? AppColors.diabeticPrimary
                        : AppColors.diabeticBorder,
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
                    Text(
                      entries[i].insulinUnits > 0
                          ? '${_fmt(entries[i].insulinUnits)} unit${entries[i].insulinUnits == 1 ? '' : 's'}'
                          : '0 units',
                      style: small.copyWith(color: AppColors.diabeticPrimary),
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
            color: AppColors.diabeticSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.diabeticBorder, width: 0.5),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total carbs today',
                    style: normal.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_fmt(log.totalCarbsToday)} g',
                    style: AppTextStyles.chipDiabetic(
                      context,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated insulin today',
                    style: normal.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_fmt(log.totalInsulinToday)} units',
                    style: AppTextStyles.chipDiabetic(
                      context,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Estimates only. Always confirm doses with your doctor.',
          style: small,
        ),

        if (entries.isNotEmpty)
          Center(
            child: TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text("Clear today's log?"),
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
