import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// FullWidthActionBar — section 2.5 design EXCEPTION: reserved for
/// completing an entire flow (e.g. "Go straight to my daily plan" on the
/// success screen), not for an in-card action. No side margin, and
/// noticeably LESS rounded than the usual pill CTA.
class FullWidthActionBar extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const FullWidthActionBar({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.actionBar),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.actionBar),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.ctaText),
                if (icon != null) ...[const SizedBox(width: 8), Icon(icon, color: Colors.white, size: 20)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
