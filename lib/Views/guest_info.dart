import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/carbsense_textbox.dart';
import 'package:carbsense/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GuestInfoScreen extends StatefulWidget {
  const GuestInfoScreen({super.key});

  @override
  State<GuestInfoScreen> createState() => _GuestInfoScreenState();
}

class _GuestInfoScreenState extends State<GuestInfoScreen> {
  final TextEditingController controllerHeight = TextEditingController();
  final TextEditingController controllerWeight = TextEditingController();
  final TextEditingController controllerTDD = TextEditingController();
  double? tdd;
  // ── MUST HAVE: attaches listeners so cards update as user types ──────
  @override
  void initState() {
    super.initState();
    for (var c in [controllerHeight, controllerWeight, controllerTDD]) {
      c.addListener(_onFieldsChanged);
    }
  }

  void _onFieldsChanged() {
    if (mounted) setState(() {});
  }

  // ── MUST HAVE: prevents memory leaks ────────────────────────────────
  @override
  void dispose() {
    controllerHeight.dispose();
    controllerWeight.dispose();
    controllerTDD.dispose();
    super.dispose();
  }

  // ── Computed getters ─────────────────────────────────────────────────

  String get icRatio {
    tdd = double.tryParse(controllerTDD.text);
    if (tdd == null || tdd == 0) return '—';
    return (500 / tdd!).toStringAsFixed(2);
  }

  String get bmi {
    final heightCm = double.tryParse(controllerHeight.text);
    final weightKg = double.tryParse(controllerWeight.text);
    if (heightCm == null || weightKg == null || heightCm == 0) return '—';
    final h = heightCm / 100;
    return (weightKg / (h * h)).toStringAsFixed(1);
  }

  /* String get isf {
    // Access the text directly to ensure tdd is updated
    final tddVal = double.tryParse(controllerTDD.text);
    if (tddVal == null || tddVal == 0) return '—';

    return (1800 / tddVal).toStringAsFixed(2);
  }*/

  // ── Stat card widget ─────────────────────────────────────────────────

  /* Widget _buildCard(BuildContext context, String title, String value) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.diabeticSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.diabeticBorder, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.buttonGhost(context)),
          SizedBox(height: 6),
          Text(value, style: AppTextStyles.chipDiabetic(context)),
        ],
      ),
    );
  }*/

  Widget _buildCard(BuildContext context, String title, String value) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 80,
      ), // was width:100, height:80
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.diabeticSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.diabeticBorder, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.buttonGhost(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTextStyles.chipDiabetic(context)),
          ),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          CarbSenseAppBar(
            title: 'Quick Setup',
            showBack: true,
            subtitle: 'Enter your details to calculate your dose',
            /*   modeWidget: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: Icon(FontAwesomeIcons.droplet, color: Colors.white),
            ),*/
            mode: AppUserMode.diabetic,
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Details',
                        style: AppTextStyles.pageHeading(context),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Not saved — Guest session only',
                        style: AppTextStyles.body(context),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'BASIC INFO',
                        style: AppTextStyles.sectionLabel(context),
                      ),
                      SizedBox(height: 10),
                      CarbsenseTextbox(
                        controller: controllerHeight,
                        label: 'Height (cm,optional)',
                        hint: 'e.g. 170',
                        keyBoardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: Icons.height,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final parsedNum = double.tryParse(value);
                          if (parsedNum == null) {
                            return 'Please enter a valid numeric value';
                          }
                          if (parsedNum <= 0) {
                            return 'Enter a value greater than 0';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      CarbsenseTextbox(
                        controller: controllerWeight,
                        label: 'Weight (kg)',
                        hint: 'e.g. 70',
                        keyBoardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: FontAwesomeIcons.scaleBalanced,

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field cannot be left empty';
                          }

                          final parsedNum = double.tryParse(value);
                          if (parsedNum == null) {
                            return 'Please enter a valid numeric value';
                          }
                          if (parsedNum <= 0) {
                            return 'Enter a value greater than 0';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'INSULIN INFO',
                        style: AppTextStyles.sectionLabel(context),
                      ),
                      SizedBox(height: 20),
                      CarbsenseTextbox(
                        controller: controllerTDD,
                        label: 'Total Daily Dose (TDD)',
                        hint: 'e.g. 42',
                        keyBoardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: FontAwesomeIcons.syringe,
                        validator: (value) {
                          // 1. If it's completely empty, pass without error (it's skipped)
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final parsed = double.tryParse(value);

                          // 2. If they typed text that isn't a number
                          if (parsed == null) {
                            return 'Please enter a valid number';
                          }

                          // 3. If they specifically typed 0 or a negative number
                          if (parsed <= 0) {
                            return 'TDD must be greater than 0';
                          }

                          if (parsed < 5 || parsed > 200) {
                            return 'TDD is usually 5–200 units. Please check it.';
                          }

                          return null; // All checks passed!
                        },
                      ),
                      SizedBox(height: 20),
                      Divider(
                        color: AppColors.diabeticBorder,
                        thickness: 0.5,
                        indent: 40,
                        endIndent: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'CALCULATED FOR YOU',
                        style: AppTextStyles.sectionLabel(context),
                      ),
                      SizedBox(height: 20),
                      Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildCard(context, 'IC Ratio', icRatio),
                          ),
                          SizedBox(width: 10),
                          Expanded(child: _buildCard(context, 'BMI', bmi)),
                          SizedBox(width: 10),
                          //   Expanded(child: _buildCard(context, 'ISF', isf)),
                        ],
                      ),
                      SizedBox(height: 50),
                      CustomButton(
                        text: 'Find my Food  →',
                        gradient: AppColors.buttonGradient,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final tddValue = double.tryParse(
                              controllerTDD.text,
                            );
                            final weightValue =
                                double.tryParse(controllerWeight.text) ?? 0;
                            if (tddValue != null && weightValue > 0) {
                              final perKg = tddValue / weightValue;
                              if (perKg < 0.2 || perKg > 1.5) {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text(
                                          'Please check your TDD',
                                        ),
                                        content: Text(
                                          'A TDD of ${controllerTDD.text} units looks unusual for a weight of ${controllerWeight.text} kg. Is it correct?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, false),
                                            child: const Text('Check again'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, true),
                                            child: const Text("It's correct"),
                                          ),
                                        ],
                                      ),
                                );
                                if (ok != true || !context.mounted) return;
                              }
                            }
                            FocusScope.of(context).unfocus();
                            Navigator.pushNamed(
                              context,
                              RouteNames.foodCategory,
                              arguments: {
                                'mode': AppUserMode.diabetic,
                                'icRatio': double.tryParse(icRatio) ?? 0.0,
                              },
                            );
                          }
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
