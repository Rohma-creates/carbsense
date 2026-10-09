import 'package:carbsense/Views/guest_info_diet.dart';
import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/models/food_item.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carb_level_card.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/eaten_today_section.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DietPostMealScreen extends StatefulWidget {
  final FoodItem item;
  final int? goalIndex; // optional: only used for the goal chip

  const DietPostMealScreen({super.key, required this.item, this.goalIndex});

  @override
  State<DietPostMealScreen> createState() => _DietPostMealScreenState();
}

class _DietPostMealScreenState extends State<DietPostMealScreen> {
  int serving = 1;
  bool _added = false; // false = before adding, true = after tapping Add

  // ── Data helpers ──────────────────────────────────────────────────────────
  double get _carbsPerServing => widget.item.carbsPerServing;

  double get _totalCarbs => _carbsPerServing * serving;

  String _fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);

  GoalProfile? get _goal {
    final i = widget.goalIndex;
    if (i == null || i < 0 || i >= kGoalProfiles.length) return null;
    return kGoalProfiles[i];
  }

  void _addToLog() {
    context.read<DietLogProvider>().addEntry(
      FoodLogEntry(
        name: widget.item.foodItem,
        carbs: _totalCarbs,
        servings: serving,
      ),
    );
    setState(() => _added = true);
  }

  /// Ends the guest session: confirms, clears the log, returns to the start.
  Future<void> _finishSession() async {
    final log = context.read<DietLogProvider>();
    final items = log.todayEntries.length;
    final total = log.totalCarbsToday;

    final end = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('End your session?'),
            content: Text(
              items == 0
                  ? 'You have not logged any food yet.'
                  : 'Today you logged $items item${items == 1 ? '' : 's'} '
                      'with ${_fmt(total)} g of carbs.\n\n'
                      'Ending the session clears this log.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep logging'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('End session'),
              ),
            ],
          ),
    );

    if (end == true && mounted) {
      log.resetSession();
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.welcomeView,
        (route) => false,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CarbSenseAppBar(
            title: 'Meal Summary',
            mode: AppUserMode.diet,
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(),
                  const SizedBox(height: 16),

                  // FOOD INFO + goal chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('FOOD INFO'),
                      if (_goal != null) _goalChip(_goal!),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _infoChip(
                          icon: FontAwesomeIcons.jarWheat,
                          value: '${_fmt(_carbsPerServing)} g',
                          label: 'CARBS / SERVING',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoChip(
                          icon: FontAwesomeIcons.bowlRice,
                          value: widget.item.servingSize,
                          label: 'SERVING SIZE',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Carb level card (Low / Medium / High)
                  CarbLevelCard(gramsPerServing: _carbsPerServing),
                  const SizedBox(height: 12),

                  // Servings stepper  ->  "Added" strip after tapping Add
                  _added ? _buildAddedStrip() : _buildServingsCard(),
                  const SizedBox(height: 14),

                  // Main button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dietPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _added ? () => Navigator.pop(context) : _addToLog,
                      icon: const Icon(
                        FontAwesomeIcons.plus,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: Text(
                        _added ? 'Add another food' : "Add to today's total",
                        style: AppTextStyles.button(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _finishSession,
                      child: Text(
                        "I'm done · end session",
                        style: AppTextStyles.statUnit(
                          context,
                        ).copyWith(color: AppColors.dietPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Eaten today (list from provider) + total + target
                  EatenTodaySection(
                    pendingCarbs: _added ? 0 : _totalCarbs,
                    highlightFirst: _added,
                  ),
                  const SizedBox(height: 16),

                  _buildDisclaimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text,
    style: AppTextStyles.body(
      context,
    ).copyWith(color: Colors.black, letterSpacing: 1.5),
  );

  Widget _buildHero() {
    final url = widget.item.imageUrl.trim();
    return Hero(
      tag: 'food_img_${widget.item.foodItem}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: AppColors.dietBorder),
              if (url.isNotEmpty)
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [const Color(0xCC073B24), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.item.foodItem,
                      style: AppTextStyles.bodyOnDark(
                        context,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.foodDetail,
                      style: AppTextStyles.bodyOnDark(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalChip(GoalProfile goal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: goal.iconBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(goal.icon, size: 12, color: goal.iconColor),
          const SizedBox(width: 5),
          Text(
            '${goal.label} goal',
            style: TextStyle(
              color: goal.iconColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dietBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Servings',
                style: AppTextStyles.statUnit(
                  context,
                ).copyWith(color: Colors.black),
              ),
              const SizedBox(height: 3),
              Text(
                '$serving serving${serving > 1 ? 's' : ''} · ${_fmt(_totalCarbs)} g carbs',
                style: AppTextStyles.caption(
                  context,
                ).copyWith(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
          Row(
            children: [
              _stepBtn('-', () {
                if (serving > 1) setState(() => serving--);
              }),
              SizedBox(
                width: 34,
                child: Text(
                  '$serving',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(context),
                ),
              ),
              _stepBtn('+', () {
                if (serving < 10) setState(() => serving++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddedStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dietSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dietPrimary, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.circleCheck,
            size: 16,
            color: AppColors.dietPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Added $serving serving${serving > 1 ? 's' : ''} · ${_fmt(_totalCarbs)} g',
              style: AppTextStyles.statUnit(
                context,
              ).copyWith(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            FontAwesomeIcons.circleExclamation,
            size: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Estimate based on standard food data. Actual carb content may vary by preparation.',
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: 11, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      decoration: BoxDecoration(
        color: AppColors.dietSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dietBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.dietSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dietBorder, width: 0.5),
            ),
            child: Icon(icon, color: AppColors.dietPrimary, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.chipDiet(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.chipDiet(
                    context,
                  ).copyWith(fontSize: 11, color: AppColors.dietLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.dietSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dietBorder, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body(
            context,
          ).copyWith(color: AppColors.dietPrimary),
        ),
      ),
    );
  }
}
