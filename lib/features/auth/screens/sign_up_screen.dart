import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
//import 'package:carbsense/features/auth/screens/login_screen.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/carbsense_textbox.dart';
import 'package:carbsense/widgets/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final AppUserMode mode;
  const SignUpScreen({super.key, required this.mode});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isAccepted = false;
  bool _isHovered = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pwdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _isDiabetic => widget.mode == AppUserMode.diabetic;
  Color get _surfaceColor =>
      _isDiabetic ? AppColors.diabeticSurface : AppColors.dietSurface;

  Color get _borderColor =>
      _isDiabetic ? AppColors.diabeticBorder : AppColors.dietBorder;

  String get _subtitle =>
      _isDiabetic
          ? 'Save your dose history and food log'
          : 'Save your carb budget and meal history';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CarbSenseAppBar(
            title: 'Create Account',
            mode: AppUserMode.diabetic,
            subtitle: _subtitle,
            //   showBack: true,
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _surfaceColor,
                        border: Border.all(color: _borderColor, width: 0.5),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Your guest data will carry over to this account',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Full Name',
                      style: AppTextStyles.cardSubtitle(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 5),
                    CarbsenseTextbox(
                      label: 'Your name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email',
                      style: AppTextStyles.cardSubtitle(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    CarbsenseTextbox(
                      label: 'You@example.com',
                      keyBoardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Password',
                      style: AppTextStyles.cardSubtitle(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 5),

                    CarbsenseTextbox(
                      label: 'Atleast 8 characters',
                      isPassword: true,
                      controller: _pwdController,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isAccepted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isAccepted = newValue ?? false;
                            });
                          },
                        ),

                        Expanded(
                          child: Text(
                            'I agree to the terms of Service and Privacy Policy',
                            style: AppTextStyles.statUnit(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Sign Up',
                        onPressed:
                            _isAccepted
                                ? () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteNames.loginScreen,
                                  );
                                }
                                : null,
                      ),
                    ),

                    const SizedBox(height: 10),

                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, RouteNames.guestInfo);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 50,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient:
                                _isHovered
                                    ? (_isDiabetic
                                        ? AppColors.buttonGradient
                                        : AppColors.buttonGradientDiet)
                                    : LinearGradient(
                                      colors: [Colors.white, Colors.white],
                                    ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Continue as Guest',
                            style: AppTextStyles.button(context).copyWith(
                              color:
                                  _isHovered
                                      ? AppColors.white
                                      : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.statUnit(context),
                        children: [
                          TextSpan(text: 'Already have an account?'),
                          TextSpan(
                            text: 'Login',
                            style: AppTextStyles.statUnit(
                              context,
                            ).copyWith(color: AppColors.diabeticPrimary),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
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
}
