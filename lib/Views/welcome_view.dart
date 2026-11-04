import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/carbsense_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  // ⚠️ _buildText() now needs context to pass to AppTextStyles
  Widget _buildText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome 👋', style: AppTextStyles.pageHeading(context)),
          SizedBox(height: 5),
          Text(
            'Your smart companion for Carb\ntracking and healthy living.',
            style: AppTextStyles.body(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CarbSenseAppBar(
            showBack: false,
            title: 'CarbSense',
            subtitle: 'Eat Smart. Live Smart',
            mode: AppUserMode.diabetic,
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildText(context), // ← pass context here
                  SizedBox(height: 10),
                  CarbsenseCard(
                    title: 'For Diabetics',
                    subtitle:
                        'See carbs and estimate your meal dose.',
                    icon: FontAwesomeIcons.droplet,
                    iconGradient: AppColors.buttonGradient,
                    backgroundColor: AppColors.diabeticSurface,
                    trailing: Icon(
                      FontAwesomeIcons.circleChevronRight,
                      color: AppColors.diabeticPrimary,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.diabeticMode);
                    },
                  ),
                  SizedBox(height: 10),
                  CarbsenseCard(
                    title: 'For Diet & Nutrition',
                    subtitle: 'Check carbs and track what you eat.',
                    icon: FontAwesomeIcons.leaf,
                    iconGradient: AppColors.dietGradient,
                    backgroundColor: AppColors.dietSurface,
                    trailing: Icon(
                      FontAwesomeIcons.circleChevronRight,
                      color: AppColors.dietPrimary,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.dietMode);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10),
                    child: Text(
                      'Tap a card to get started',
                      style: AppTextStyles.caption(context),
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
