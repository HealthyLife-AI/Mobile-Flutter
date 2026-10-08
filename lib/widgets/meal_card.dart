import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../models/meal_models.dart';
import 'gradient_cta_button.dart';

IconData mealSlotIcon(String slot) {
  switch (slot) {
    case 'sun':
      return Icons.wb_twilight_rounded;
    case 'sun_orange':
      return Icons.wb_sunny_rounded;
    case 'leaf':
      return Icons.eco_rounded;
    case 'moon':
      return Icons.nightlight_round;
    default:
      return Icons.restaurant_rounded;
  }
}

// Meal-type icon colors (2.2, v2) — breakfast and lunch share the same
// "daytime" family and are distinguished by icon SHAPE (sunrise vs. full
// sun above), not color. Snack is green, dinner is indigo.
Color mealSlotBg(String slot) {
  switch (slot) {
    case 'sun':
      return AppColors.mealBreakfastBg;
    case 'sun_orange':
      return AppColors.mealLunchBg;
    case 'leaf':
      return AppColors.mealSnackBg;
    case 'moon':
      return AppColors.mealDinnerBg;
    default:
      return AppColors.chipInactiveBg;
  }
}

Color mealSlotIconColor(String slot) {
  switch (slot) {
    case 'sun':
      return AppColors.mealBreakfastIcon;
    case 'sun_orange':
      return AppColors.mealLunchIcon;
    case 'leaf':
      return AppColors.mealSnackIcon;
    case 'moon':
      return AppColors.mealDinnerIcon;
    default:
      return AppColors.textSecondary;
  }
}

/// MealCard — the recurring meal-slot card used on Home + Weekly Plan.
/// Renders the three states described in the spec: logged / current / upcoming.
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onLog;
  final VoidCallback? onSwapAlternatives;
  // Only one screen mounted at a time should fly this Hero — the app shell
  // keeps tabs alive via IndexedStack, so Home and Weekly Plan would both
  // render a MealCard for the same meal.id simultaneously. Only Home (the
  // primary entry point into MealDetailScreen) enables the Hero flight;
  // Weekly Plan renders the same icon without wrapping it, avoiding a
  // "multiple heroes share the same tag" crash.
  final bool enableHero;
  // Weekly Plan (5.2) always shows colored meal-type icons, even for a
  // scheduled/future meal — it's a planning overview, not a daily
  // interactive one. Home (5.1) keeps the gray "empty box" for upcoming
  // meals instead. Defaults to Home's behavior.
  final bool forceMealTypeColors;

  const MealCard({
    super.key,
    required this.meal,
    this.onLog,
    this.onSwapAlternatives,
    this.enableHero = true,
    this.forceMealTypeColors = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = meal.status == MealStatus.current;
    final bool isUpcoming = meal.status == MealStatus.upcoming;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: isCurrent ? null : Border.all(color: AppColors.borderLight),
        boxShadow: isCurrent
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isCurrent)
            Container(
              height: 6,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _CaloriesChip(calories: meal.calories),
                    const Spacer(),
                    if (meal.status == MealStatus.logged)
                      const Flexible(
                        child: _StatusPill(
                          text: 'تم تسجيل الوجبة',
                          color: AppColors.accentGreen,
                          bg: AppColors.accentGreenBg,
                          icon: Icons.check_circle_rounded,
                        ),
                      )
                    else if (isCurrent)
                      const Flexible(
                        child: _StatusPill(
                          text: 'الوجبة القادمة / الحالية',
                          color: AppColors.primary,
                          bg: AppColors.accentGreenBg,
                          icon: null,
                          dotOnly: true,
                        ),
                      )
                    else
                      const Flexible(
                        child: _StatusPill(
                          text: 'مجدولة لاحقاً',
                          color: AppColors.textSecondary,
                          bg: AppColors.chipInactiveBg,
                        ),
                      ),
                    const SizedBox(width: 10),
                    _buildMealIcon(isUpcoming),
                  ],
                ),
                const SizedBox(height: 12),
                Text(meal.name, textAlign: TextAlign.right, style: AppTextStyles.sectionHeading),
                const SizedBox(height: 4),
                Text(meal.timeRange, textAlign: TextAlign.right, style: AppTextStyles.secondary),
                const SizedBox(height: 16),
                ...meal.items.map((it) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.chipInactiveBg,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text('${it.grams} غ', style: AppTextStyles.caption),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 4,
                            child: Text(it.name, textAlign: TextAlign.right, style: AppTextStyles.body),
                          ),
                          const SizedBox(width: 8),
                          if (meal.status != MealStatus.logged)
                            Icon(
                              it.checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: it.checked ? AppColors.primary : AppColors.textSecondary,
                              size: 20,
                            )
                          else
                            const Icon(Icons.check_rounded, color: AppColors.accentGreen, size: 18),
                        ],
                      ),
                    )),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onSwapAlternatives,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meal.alternativesText,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 14),
                  GradientCtaButton(
                    label: 'سجّل هذه الوجبة الآن',
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: onLog,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealIcon(bool isUpcoming) {
    final bool showGrayBox = isUpcoming && !forceMealTypeColors;
    final icon = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: showGrayBox ? AppColors.chipInactiveBg : mealSlotBg(meal.iconEmojiSlot),
        shape: BoxShape.circle,
      ),
      child: Icon(mealSlotIcon(meal.iconEmojiSlot), color: showGrayBox ? AppColors.textSecondary : mealSlotIconColor(meal.iconEmojiSlot), size: 22),
    );
    if (!enableHero) return icon;
    return Hero(tag: 'meal-icon-${meal.id}', child: icon);
  }
}

class _CaloriesChip extends StatelessWidget {
  final int calories;
  const _CaloriesChip({required this.calories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primarySoftBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text('$calories سعرة', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  final IconData? icon;
  final bool dotOnly;
  const _StatusPill({required this.text, required this.color, required this.bg, this.icon, this.dotOnly = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotOnly) Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 6), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          if (icon != null) Icon(icon, size: 14, color: color),
          if (icon != null) const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
