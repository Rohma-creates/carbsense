import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: isDisabled ? 0.0 : 2.0,
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient:
                isDisabled
                    ? LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade400],
                    )
                    : gradient ?? (AppColors.buttonGradient),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyles.button(
                context,
              ).copyWith(color: isDisabled ? Colors.white70 : null),
            ),
          ),
        ),
      ),
    );
  }
}
