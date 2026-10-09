import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/widgets/carbsense_logo.dart';
import 'package:flutter/material.dart';

class CarbSenseAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  //  final Gradient? gradient;
  //final Widget? modeWidget;
  final AppUserMode? mode;

  const CarbSenseAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    required this.mode,
    //   this.gradient,
    // this.modeWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Gradient dynamicGradient =
        mode == AppUserMode.diabetic
            ? AppColors.diabeticGradient
            : AppColors.dietGradient;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main gradient container ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 60),
          decoration: BoxDecoration(
            gradient: dynamicGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Back button OR logo ────────────────────────────────
              if (showBack) ...[
                InkWell(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                /*    if (modeWidget != null) ...[
                  const SizedBox(width: 10),
                  modeWidget!,
                ],*/
              ] else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: const CarbSenseLogo(size: 44),
                ),

              const SizedBox(width: 14),

              // ── Title + optional subtitle ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.appNameAppBar(context),
                      maxLines: 1, // ← ADD
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.tagline(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Decorative circles ───────────────────────────────────────
        Positioned(
          top: -30,
          right: -30,
          child: IgnorePointer(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: -20,
          child: IgnorePointer(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
