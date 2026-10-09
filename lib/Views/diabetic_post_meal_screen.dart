import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/models/food_item.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/diabetic_log_section.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DiabeticPostMealScreen extends StatefulWidget {
  final FoodItem item;
  final double icRatio;
  const DiabeticPostMealScreen({
    super.key,
    required this.item,
    required this.icRatio,
  });

  @override
  State<DiabeticPostMealScreen> createState() => _DiabeticPostMealScreenState();
}

class _DiabeticPostMealScreenState extends State<DiabeticPostMealScreen> {
  int serving = 1;
  bool _added = false; // false = before adding, true = after tapping Add

  // "12.5 gm" -> 13 (rounded to whole grams). The old code turned it into 125.
  int get _carbsPerServing => widget.item.carbsPerServing.round();

  int get _roundedIcRatio =>
      ((widget.icRatio / 10).round() * 10).clamp(10, 999);

  int get _totalCarbs => _carbsPerServing * serving;

  double get _rawDose =>
      _roundedIcRatio == 0 ? 0 : _totalCarbs / _roundedIcRatio;
  int get _doseUnits => _rawDose.round();

  _DoseCase get _doseCase {
    if (widget.icRatio == 0) return _DoseCase.noInsulin;
    if (_rawDose < 1) return _DoseCase.belowOne;
    return _DoseCase.normal;
  }

  int get _moreServings =>
      _carbsPerServing == 0
          ? 0
          : ((_roundedIcRatio - _totalCarbs) / _carbsPerServing).floor().clamp(
            0,
            99,
          );

  void _addToLog() {
    context.read<DietLogProvider>().addEntry(
      FoodLogEntry(
        name: widget.item.foodItem,
        carbs: _totalCarbs.toDouble(),
        servings: serving,
        // only the dose shown on the card is logged; "below 1 unit" and
        // "no insulin" cases are logged as 0
        insulinUnits: _doseCase == _DoseCase.normal ? _doseUnits.toDouble() : 0,
      ),
    );
    setState(() => _added = true);
  }

  String _fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);

  /// Ends the guest session: confirms, clears the log, returns to the start.
  Future<void> _finishSession() async {
    final log = context.read<DietLogProvider>();
    final items = log.todayEntries.length;
    final carbs = log.totalCarbsToday;
    final units = log.totalInsulinToday;

    final end = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('End your session?'),
            content: Text(
              items == 0
                  ? 'You have not logged any food yet.'
                  : 'Today you logged $items item${items == 1 ? '' : 's'}: '
                      '${_fmt(carbs)} g carbs and about ${_fmt(units)} units '
                      'of estimated insulin.\n\nEnding the session clears this log.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CarbSenseAppBar(
            title: 'Meal Summary',
            mode: AppUserMode.diabetic,
            showBack: true,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Hero(
                      tag: 'food_img_${widget.item.foodItem}',
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Container(color: AppColors.diabeticBorder),
                            Image.network(
                              widget.item.imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const SizedBox.shrink(),
                            ),

                            Positioned(
                              left: 0,
                              right: 0,
                              top: 150,
                              height: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(
                                        0xCC1D4ED8,
                                      ), // deep blue, 80% opacity
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 170,
                              left: 14,
                              right: 14,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.item.foodItem,
                                    style: AppTextStyles.bodyOnDark(
                                      context,
                                    ).copyWith(fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),

                                  Text(
                                    widget.item.foodDetail,
                                    style: AppTextStyles.bodyOnDark(
                                      context,
                                    ).copyWith(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      // padding: const EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //////////////////////////////////SECTION FOOD_INFO///////////////
                          Text(
                            'FOOD INFO',
                            style: AppTextStyles.body(
                              context,
                            ).copyWith(color: Colors.black, letterSpacing: 1.5),
                          ),

                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _infoChip(
                                  icon: FontAwesomeIcons.jarWheat,
                                  value:
                                      '${_fmt(widget.item.carbsPerServing)} g',
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
                          const SizedBox(height: 20),

                          Text(
                            'HOW MUCH DID YOU EAT?',
                            style: AppTextStyles.body(
                              context,
                            ).copyWith(color: Colors.black, letterSpacing: 1.5),
                          ),

                          SizedBox(height: 10),

                          if (_added)
                            _buildAddedStrip()
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.diabeticBorder,
                                  width: 0.5,
                                ),
                              ),
                              padding: EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Number of Servings',
                                              style: AppTextStyles.statUnit(
                                                context,
                                              ).copyWith(color: Colors.black),
                                            ),
                                            const SizedBox(height: 3),

                                            Text(
                                              '$serving serving${serving > 1 ? 's' : ''} · ${_totalCarbs}g carbs',
                                              style: AppTextStyles.caption(
                                                context,
                                              ).copyWith(
                                                fontSize: 10,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      /////stepper
                                      Row(
                                        children: [
                                          _stepBtn('-', () {
                                            if (serving > 1) {
                                              setState(() => serving--);
                                            }
                                          }),

                                          SizedBox(
                                            width: 34,
                                            child: Text(
                                              '$serving',
                                              textAlign: TextAlign.center,
                                              style: AppTextStyles.body(
                                                context,
                                              ),
                                            ),
                                          ),

                                          _stepBtn('+', () {
                                            if (serving < 10) {
                                              setState(() => serving++);
                                            }
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 20),
                                  _infoRow(
                                    'Total Carbs Eaten',
                                    '${_totalCarbs}g',
                                  ),
                                  const SizedBox(height: 6),
                                  _infoRow('Your IC Ratio', '$_roundedIcRatio'),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),
                          ////////////////////////////DOSE RESULT///////
                          Text(
                            'INSULIN ESTIMATE',
                            style: AppTextStyles.body(
                              context,
                            ).copyWith(color: Colors.black, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 10),
                          _doseCard(),

                          const SizedBox(height: 14),

                          ////////////////////////////////////////DISCLAIMER/////////////////
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.amber.shade200,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Always confirm with your doctor',
                                        style: AppTextStyles.statUnit(
                                          context,
                                        ).copyWith(color: Colors.black),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'This estimate is based on your IC Ratio only. Actual dose may vary with blood sugar, activity, and health status.',
                                        style: AppTextStyles.caption(
                                          context,
                                        ).copyWith(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.diabeticPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  _added
                                      ? () => Navigator.pop(context)
                                      : _addToLog,
                              child: Text(
                                _added
                                    ? 'Add another food'
                                    : "Add to today's log",
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
                                ).copyWith(color: AppColors.diabeticPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          DiabeticLogSection(highlightFirst: _added),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        color: AppColors.diabeticSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.diabeticPrimary, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.circleCheck,
            size: 16,
            color: AppColors.diabeticPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Added $serving serving${serving > 1 ? 's' : ''} · ${_totalCarbs}g carbs',
              style: AppTextStyles.statUnit(
                context,
              ).copyWith(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doseCard() {
    switch (_doseCase) {
      case _DoseCase.noInsulin:
        return _doseContainer(
          bg: const Color(0xFFF0FDF4),
          border: const Color(0xFF86EFAC),
          labelColor: const Color(0xFF16A34A),
          numText: '0',
          numColor: const Color(0xFF15803D),
          unitText: 'units needed',
          formula: 'TDD is 0 or was not entered',
          message: 'No insulin dose is calculated. Confirm with your doctor.',
        );

      case _DoseCase.belowOne:
        return _doseContainer(
          bg: const Color(0xFFFFFBEB),
          border: const Color(0xFFFDE68A),
          labelColor: const Color(0xFFD97706),
          numText: '< 1',
          numColor: const Color(0xFF92400E),
          unitText: 'unit needed',
          formula:
              '${_totalCarbs}g ÷ IC Ratio $_roundedIcRatio = ${_rawDose.toStringAsFixed(2)} → below 1 unit',
          message:
              'You can safely eat $_moreServings more serving${_moreServings != 1 ? 's' : ''} of this food before needing insulin.',
        );

      case _DoseCase.normal:
        return _doseContainer(
          bg: const Color(0xFFEFF6FF),
          border: const Color(0xFFBFDBFE),
          labelColor: const Color(0xFF3B82F6),
          numText: '$_doseUnits',
          numColor: const Color(0xFF1D4ED8),
          unitText: 'unit${_doseUnits != 1 ? 's' : ''} of insulin',
          formula:
              '${_totalCarbs}g ÷ IC Ratio $_roundedIcRatio = ${_rawDose.toStringAsFixed(2)} → $_doseUnits unit${_doseUnits != 1 ? 's' : ''}',
          message: '',
        );
    }
  }

  Widget _doseContainer({
    required Color bg,
    required Color border,
    required Color labelColor,
    required String numText,
    required Color numColor,
    required String unitText,
    required String formula,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'ESTIMATED DOSE',
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: labelColor, letterSpacing: 1.5),
          ),

          const SizedBox(height: 8),

          Text(
            numText,
            style: AppTextStyles.statNumber(context).copyWith(color: numColor),
          ),

          Text(
            unitText,
            style: AppTextStyles.caption(context).copyWith(color: labelColor),
          ),

          const SizedBox(height: 6),

          Text(
            formula,
            style: AppTextStyles.caption(
              context,
            ).copyWith(fontSize: 10, color: labelColor.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),

          if (message.isNotEmpty) ...[
            const SizedBox(height: 6),

            Text(
              message,
              style: AppTextStyles.statUnit(context).copyWith(color: numColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      //  height: 80,
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: AppColors.diabeticSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.diabeticBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.diabeticSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.diabeticBorder, width: 0.5),
            ),
            child: Icon(icon, color: AppColors.diabeticPrimary, size: 16),
          ),

          SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.chipDiabetic(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),

                Text(
                  label,
                  style: AppTextStyles.chipDiabetic(
                    context,
                  ).copyWith(fontSize: 10, color: AppColors.diabeticLight),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          color: AppColors.diabeticSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.diabeticBorder, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body(
            context,
          ).copyWith(color: AppColors.diabeticPrimary),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.statUnit(context).copyWith(color: Colors.black),
        ),

        Text(
          value,
          style: AppTextStyles.statUnit(
            context,
          ).copyWith(color: AppColors.diabeticPrimary),
        ),
      ],
    );
  }
}

enum _DoseCase { noInsulin, belowOne, normal }
