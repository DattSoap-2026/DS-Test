import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeType { success, warning, error, info, neutral }

class CustomBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final bool isSmall;

  const CustomBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor;
    Color textColor;
    switch (type) {
      case BadgeType.success:
        bgColor = isDark ? AppColors.darkSuccessBg : AppColors.successBg;
        textColor = AppColors.success;
        break;
      case BadgeType.warning:
        bgColor = isDark ? AppColors.darkWarningBg : AppColors.warningBg;
        textColor = AppColors.warning;
        break;
      case BadgeType.error:
        bgColor =
            isDark ? AppColors.darkErrorBg : AppColors.errorBg;
        textColor = AppColors.lightError;
        break;
      case BadgeType.info:
        bgColor = isDark ? AppColors.darkInfoBg : AppColors.infoBg;
        textColor = AppColors.info;
        break;
      case BadgeType.neutral:
        bgColor = isDark
            ? AppColors.darkCard
            : AppColors.lightBackground;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isSmall ? 6 : 10),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
