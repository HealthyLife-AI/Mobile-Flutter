import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// Shared header for the post-activation onboarding wizard (Health Data →
/// Initial Measurements → Notifications): back arrow, screen title,
/// "الملف الصحي • HealthyLife" eyebrow, step counter and a sliding
/// progress bar. Keeping this in one widget guarantees the three onboarding
/// screens report a consistent step count instead of each hardcoding it.
class OnboardingStepHeader extends StatelessWidget {
  final String title;
  final int step;
  final int totalSteps;

  const OnboardingStepHeader({
    super.key,
    required this.title,
    required this.step,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = step / totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(title, textAlign: TextAlign.right, style: AppTextStyles.sectionHeading)),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'خطوة $step من $totalSteps (${(progress * 100).round()}%)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'HealthyLife • الملف الصحي',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: AppColors.neutralTrack,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
