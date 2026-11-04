import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/models/food_item.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  // exact carbs, no rounding.
  double get _carbsPerServing => widget.item.carbsPerServing;

  double get _totalCarbs => _carbsPerServing * serving;

  // IC Ratio is used exactly as calculated (e.g. 16.67), no rounding.
  double get _rawDose => widget.icRatio <= 0 ? 0 : _totalCarbs / widget.icRatio;
  // int get _doseUnits => _rawDose.round();
  String get _icText => widget.icRatio.toStringAsFixed(1);

  _DoseCase get _doseCase {
    if (widget.icRatio <= 0) return _DoseCase.noInsulin;
    if (_rawDose < 1) return _DoseCase.belowOne;
    return _DoseCase.normal;
  }

  String _fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);

  /// Returns to the start screen and clears the navigation stack.
  void _backToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.welcomeView,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CarbSenseAppBar(
            title: 'Dose Estimate',
            mode: AppUserMode.diabetic,
            showBack: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                              cacheWidth: 800,
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
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xCC1D4ED8), // deep blue, 80%
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
                                  const SizedBox(height: 4),
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
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ───────────── FOOD INFO ─────────────
                          Text(
                            'FOOD INFO',
                            style: AppTextStyles.body(
                              context,
                            ).copyWith(color: Colors.black, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          ),
                          const SizedBox(height: 20),

                          // ───────────── SERVINGS ─────────────
                          Text(
                            'HOW MUCH WILL YOU EAT?',
                            style: AppTextStyles.body(
                              context,
                            ).copyWith(color: Colors.black, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.diabeticBorder,
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
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
                                            '$serving serving${serving > 1 ? 's' : ''} · ${_fmt(_totalCarbs)}g carbs',
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
                                            style: AppTextStyles.body(context),
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
                                  'Total Carbs',
                                  '${_fmt(_totalCarbs)}g',
                                ),
                                const SizedBox(height: 6),
                                _infoRow('Your IC Ratio', _icText),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ───────────── DOSE RESULT ─────────────
                          Text(
                            'INSULIN ESTIMATE',
                            style: AppTextStyles.body(
                              context,
                            ).copyWith(color: Colors.black, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 10),
                          _doseCard(),

                          const SizedBox(height: 14),

                          // ───────────── DISCLAIMER ─────────────
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
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
                                        'This estimate is based on your IC Ratio only. Actual dose may vary with blood sugar, activity, and health status. Your doctor\'s instructions always come first.',
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

                          // ───────────── BUTTONS ─────────────
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
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Choose another food',
                                style: AppTextStyles.button(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _backToHome,
                              child: Text(
                                'Back to home',
                                style: AppTextStyles.statUnit(
                                  context,
                                ).copyWith(color: AppColors.diabeticPrimary),
                              ),
                            ),
                          ),
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

  Widget _doseCard() {
    switch (_doseCase) {
      case _DoseCase.noInsulin:
        return _doseContainer(
          bg: const Color(0xFFF8FAFC),
          border: const Color(0xFFE2E8F0),
          labelColor: const Color(0xFF64748B),
          numText: '—',
          numColor: const Color(0xFF475569),
          unitText: 'no estimate',
          formula: 'TDD was not entered',
          message: 'Go back and enter your TDD to see a dose estimate.',
        );

      case _DoseCase.belowOne:
        return _doseContainer(
          bg: const Color(0xFFFFFBEB),
          border: const Color(0xFFFDE68A),
          labelColor: const Color(0xFFD97706),
          numText: '< 1',
          numColor: const Color(0xFF92400E),
          unitText: 'unit by this estimate',
          formula:
              '${_fmt(_totalCarbs)}g ÷ IC Ratio $_icText = ${_rawDose.toStringAsFixed(2)}',
          message: 'Ask your doctor whether you need insulin for this amount.',
        );

      case _DoseCase.normal:
        return _doseContainer(
          bg: const Color(0xFFEFF6FF),
          border: const Color(0xFFBFDBFE),
          labelColor: const Color(0xFF3B82F6),
          numText: _rawDose.toStringAsFixed(1),
          numColor: const Color(0xFF1D4ED8),
          unitText: 'units of insulin (approx.)',
          formula:
              '${_fmt(_totalCarbs)}g ÷ IC Ratio $_icText = ${_rawDose.toStringAsFixed(2)}',
          message:
              'Round this to what your pen allows, as your doctor advised.',
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.chipDiabetic(context),
                  //      maxLines: 2,
                  //      overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
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
