import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CarbsenseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient? iconGradient;
  final Color? iconColor;
  final Color backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CarbsenseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconGradient,
    this.iconColor,
    this.borderColor,
    required this.backgroundColor,
    this.width,
    this.height,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ⚠️ BUG FIX: onTap was only wired to the trailing icon, not the
      // whole card. Now tapping anywhere on the card triggers onTap.
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        width: width ?? 300,
        constraints: BoxConstraints(minHeight: height ?? 110),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? AppColors.diabeticBorder,
            width: 0.5,
          ),
        ),
        child: Center(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _buildLeadingIcon(),
            title: Text(title, style: AppTextStyles.cardTitle(context)),
            subtitle: Text(
              subtitle,
              style: AppTextStyles.cardSubtitle(
                context,
              ), // ← was body, now cardSubtitle
            ),
            trailing:
                trailing, // no extra GestureDetector needed — card handles it
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: iconGradient,
        color: iconGradient == null ? (iconColor ?? Colors.blue) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.white, size: 16),
    );
  }
}
