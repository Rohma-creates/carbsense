import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/carbsense_textbox.dart';
import 'package:carbsense/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ── Goal profile data ────────────────────────────────────────────────────────
class GoalProfile {
  final String label;
  final String description; // short text on the card, no carb numbers
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const GoalProfile({
    required this.label,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

const List<GoalProfile> kGoalProfiles = [
  GoalProfile(
    label: 'Lose Weight',
    description: 'Lower-carb choices first',
    icon: FontAwesomeIcons.arrowTrendDown,
    iconBg: Color(0xFFD1FAE5),
    iconColor: Color(0xFF065F46),
  ),
  GoalProfile(
    label: 'Maintain Weight',
    description: 'Balanced choices',
    icon: FontAwesomeIcons.scaleBalanced,
    iconBg: Color(0xFFE0F2FE),
    iconColor: Color(0xFF0369A1),
  ),
  GoalProfile(
    label: 'Build Muscle',
    description: 'Fuel for training',
    icon: FontAwesomeIcons.dumbbell,
    iconBg: Color(0xFFFEF3C7),
    iconColor: Color(0xFF92400E),
  ),
  GoalProfile(
    label: 'Low Carb / Keto',
    description: 'Fewest carbs first',
    icon: FontAwesomeIcons.leaf,
    iconBg: Color(0xFFFCE7F3),
    iconColor: Color(0xFF9D174D),
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────
class GuestInfoDiet extends StatefulWidget {
  const GuestInfoDiet({super.key});

  @override
  State<GuestInfoDiet> createState() => _GuestInfoDietState();
}

class _GuestInfoDietState extends State<GuestInfoDiet> {
  final TextEditingController controllerHeight = TextEditingController();
  final TextEditingController controllerWeight = TextEditingController();
  final TextEditingController controllerAge = TextEditingController();

  int _selectedGoalIndex = 0;

  @override
  void initState() {
    super.initState();
    for (var c in [controllerHeight, controllerWeight, controllerAge]) {
      c.addListener(_onFieldsChanged);
    }
  }

  void _onFieldsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controllerHeight.dispose();
    controllerWeight.dispose();
    controllerAge.dispose();
    super.dispose();
  }

  // ── Validation ───────────────────────────────────────────────────────────
  /* bool get _canProceed {
    final h = double.tryParse(controllerHeight.text);
    final w = double.tryParse(controllerWeight.text);
    final a = double.tryParse(controllerAge.text);
    return h != null && h > 0 && w != null && w > 0 && a != null && a > 0;
  }
*/
  // ── Goal card widget ─────────────────────────────────────────────────────
  Widget _buildGoalCard(BuildContext context, int index) {
    final goal = kGoalProfiles[index];
    final isSelected = _selectedGoalIndex == index;
    final bool isWide =
        index == kGoalProfiles.length - 1 &&
        kGoalProfiles.length.isOdd; // last card spans full width if odd count

    Widget card = GestureDetector(
      onTap: () => setState(() => _selectedGoalIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dietSurface : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.dietPrimary : AppColors.dietBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child:
            isWide
                // wide layout for the last solo card
                ? Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: goal.iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(goal.icon, size: 15, color: goal.iconColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.label,
                            style: AppTextStyles.statNumber(
                              context,
                            ).copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal.description,
                            style: AppTextStyles.statUnit(
                              context,
                            ).copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.dietPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                  ],
                )
                // normal 2-column layout
                : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: goal.iconBg,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              goal.icon,
                              size: 14,
                              color: goal.iconColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal.label,
                            style: AppTextStyles.statNumber(
                              context,
                            ).copyWith(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 2),
                          Text(
                            goal.description,
                            style: AppTextStyles.statUnit(
                              context,
                            ).copyWith(fontSize: 9),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.dietPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
      ),
    );

    return card;
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // Split goals: first 4 in grid, last one full-width
    //  final gridGoals = kGoalProfiles.sublist(0, 4);
    //final lastGoal = kGoalProfiles.last;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          CarbSenseAppBar(
            //    gradient: AppColors.dietGradient,
            title: 'Diet Mode',
            showBack: true,
            subtitle: 'Quick setup — guest session only',
            mode: AppUserMode.diet,
            /*    modeWidget: Container(
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
              child: const Icon(FontAwesomeIcons.leaf, color: Colors.white),
            ),*/
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Your Details',
                        style: AppTextStyles.pageHeading(context),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        'Not saved — Guest session only',
                        style: AppTextStyles.body(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BASIC INFO',
                      style: AppTextStyles.sectionLabel(context),
                    ),
                    const SizedBox(height: 10),
                    CarbsenseTextbox(
                      controller: controllerHeight,
                      label: 'Height (cm)',
                      hint: 'e.g. 170',
                      keyBoardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: Icons.height,

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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    CarbsenseTextbox(
                      controller: controllerAge,
                      label: 'Age',
                      hint: 'e.g. 28',
                      keyBoardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: FontAwesomeIcons.calendarDays,

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
                    const SizedBox(height: 20),
                    Divider(
                      color: AppColors.dietBorder,
                      thickness: 0.5,
                      indent: 30,
                      endIndent: 30,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "WHAT'S YOUR GOAL?",
                      style: AppTextStyles.sectionLabel(context),
                    ),
                    const SizedBox(height: 12),

                    Builder(
                      builder: (context) {
                        final scale = MediaQuery.textScalerOf(
                          context,
                        ).scale(1.0).clamp(1.0, 1.5);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: kGoalProfiles.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12, // was 20
                                mainAxisSpacing: 10,
                                mainAxisExtent:
                                    116 * scale, // ← replaces childAspectRatio
                              ),
                          itemBuilder:
                              (context, i) => _buildGoalCard(context, i),
                        );
                      },
                    ),

                    // 2-column grid for first 4 goals
                    /*        GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 10,

                      childAspectRatio: 1.55,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        kGoalProfiles.length,
                        (i) => _buildGoalCard(context, i),
                      ),
                    ),*/

                    //    const SizedBox(height: 10),

                    // Last goal full-width
                    //    _buildGoalCard(context, kGoalProfiles.length - 1),
                    const SizedBox(height: 10),
                    Text(
                      'Your goal only shapes food suggestions. It does not set a carb budget.',
                      style: AppTextStyles.statUnit(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Continue  →',
                      gradient: AppColors.buttonGradientDiet,
                      onPressed: () {
                        //  _canProceed
                        //   ? () {
                        if (_formKey.currentState!.validate()) {
                          // 2. Hide the soft keyboard automatically for a smoother screen transition
                          FocusScope.of(context).unfocus();
                          Navigator.pushNamed(
                            context,
                            RouteNames.dietGuestCalculation,
                            arguments: {
                              'height': double.parse(controllerHeight.text),
                              'weight': double.parse(controllerWeight.text),
                              'age': double.parse(controllerAge.text),
                              'goalIndex': _selectedGoalIndex,
                            },
                          );
                        }
                      },
                      // : null,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
