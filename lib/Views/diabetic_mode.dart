import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/carbsense_card.dart';
import 'package:carbsense/widgets/coming_soon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DiabeticMode extends StatelessWidget {
  const DiabeticMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          CarbSenseAppBar(
            title: 'Diabetic Mode',
            showBack: true,
            subtitle: 'How would you like to continue?',
            mode: AppUserMode.diabetic,
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
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      'CONTINUE AS GUEST',
                      style: AppTextStyles.sectionLabel(context),
                    ),
                    SizedBox(height: 10),
                    CarbsenseCard(
                      title: 'Guest Access',
                      subtitle: 'Use app without saving data',
                      icon: FontAwesomeIcons.user,
                      iconColor: AppColors.textHint,
                      backgroundColor: AppColors.diabeticSurface,
                      trailing: Icon(
                        FontAwesomeIcons.circleChevronRight,
                        color: AppColors.textHint,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.guestInfo);
                      },
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: AppColors.diabeticBorder,
                      thickness: 0.5,
                      indent: 40,
                      endIndent: 40,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'CREATE AN ACCOUNT',
                      style: AppTextStyles.sectionLabel(context),
                    ),
                    SizedBox(height: 10),
                    CarbsenseCard(
                      borderColor: AppColors.diabeticPrimary,
                      title: 'Register',
                      subtitle: 'Save logs, history and insulin measures',
                      icon: FontAwesomeIcons.userPlus,
                      iconGradient: AppColors.buttonGradient,
                      backgroundColor: AppColors.diabeticSurface,
                      trailing: Icon(
                        FontAwesomeIcons.circleChevronRight,
                        color: AppColors.diabeticPrimary,
                      ),
                      onTap: () {
                        showComingSoon(context);
                      },
                    ),
                    SizedBox(height: 20),

                    // ── Why Register card ────────────────────────────────────
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: AppColors.diabeticSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'WHY REGISTER',
                              style: AppTextStyles.chipDiabetic(context),
                            ),
                          ),
                          SizedBox(height: 10),
                          _buildBullet(context, 'Glucose & HbA1c history'),
                          SizedBox(height: 6),
                          _buildBullet(context, 'Carb intake trends over time'),
                          SizedBox(height: 6),
                          _buildBullet(context, 'Sync across devices'),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
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

// ── Small helper so bullet rows aren't repeated 3× ──────────────────
Widget _buildBullet(BuildContext context, String text) {
  return Row(
    children: [
      Icon(FontAwesomeIcons.check, color: AppColors.diabeticPrimary, size: 10),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.caption(
            context,
          ).copyWith(color: Color(0xFF777777)),
        ),
      ),
    ],
  );
}
