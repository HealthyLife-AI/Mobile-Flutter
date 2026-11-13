import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';

/// Home, at the top: the day at a glance on the brand's deep background.
///
/// A ring with the meals logged out of the day's meals, the calories logged
/// out of the plan's target, and one sentence: the nutritionist's line for
/// today when there is one (from `GET /me/today`), else what the next meal is.
/// The day's activities from the same answer sit under it. This replaces the
/// separate "today's adherence" and "يومك اليوم" cards, whose meal list
/// repeated the meals shown right below.
class HomeDayCard extends StatelessWidget {
  const HomeDayCard({
    super.key,
    required this.logged,
    required this.total,
    required this.eatenKcal,
    required this.targetKcal,
    required this.nextMeal,
  });

  final int logged;
  final int total;
  final int eatenKcal;
  final int targetKcal;

  /// The first meal not logged yet, or null when the day is done.
  final Meal? nextMeal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = context.watch<TodayCubit>().state.dataOrNull;
    final sentence = today?.motivation ??
        (nextMeal == null
            ? l10n.logMealAllLogged
            : l10n.homeNextMealIs(nextMeal!.name));
    final activities = today?.activities ?? const [];
    final progress = total == 0 ? 0.0 : logged / total;

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.liveCardGradient,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.homeAdherenceToday,
                          style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.8))),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeKcalOfTarget(
                            context.localizeDigits(eatenKcal),
                            context.localizeDigits(targetKcal)),
                        style: AppTextStyles.sectionHeading
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(sentence,
                          style: AppTextStyles.secondary.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                _Ring(
                  progress: progress,
                  label:
                      '${context.localizeDigits(logged)}/${context.localizeDigits(total)}',
                  caption: l10n.homeRingMeals,
                ),
              ],
            ),
            for (final activity in activities) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.directions_walk_rounded,
                      size: 18, color: AppColors.turquoise),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      [
                        activity.title,
                        if (activity.durationMinutes case final m?)
                          l10n.durationMinutes(m, context.localizeDigits(m)),
                        if (activity.timesPerDay case final t?)
                          l10n.timesPerDay(t, context.localizeDigits(t)),
                      ].join(' • '),
                      style: AppTextStyles.secondary
                          .copyWith(color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring(
      {required this.progress, required this.label, required this.caption});

  final double progress;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => CustomPaint(
          painter: _RingPainter(v),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: AppTextStyles.sectionHeading
                      .copyWith(color: Colors.white, height: 1.1)),
              Text(caption,
                  style: AppTextStyles.tiny
                      .copyWith(color: Colors.white.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    canvas.drawArc(
        arc,
        0,
        2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = Colors.white.withValues(alpha: 0.15));
    if (value <= 0) return;
    canvas.drawArc(
        arc,
        -math.pi / 2,
        2 * math.pi * value,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = AppColors.turquoise);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

IconData mealTypeIcon(PlanMealType? type) => switch (type) {
      PlanMealType.breakfast => Icons.free_breakfast_outlined,
      PlanMealType.lunch => Icons.restaurant_rounded,
      PlanMealType.dinner => Icons.dinner_dining_rounded,
      PlanMealType.snack => Icons.eco_rounded,
      _ => Icons.restaurant_menu_rounded,
    };

/// One of today's meals on home. The next meal is highlighted with its two
/// actions; the others are one compact row.
class HomeMealTile extends StatelessWidget {
  const HomeMealTile({
    super.key,
    required this.meal,
    required this.isNext,
    required this.onOpen,
    this.actions,
  });

  final Meal meal;
  final bool isNext;

  /// Opens the meal's details (amounts, alternatives, the full log path).
  final VoidCallback onOpen;

  /// "التفاصيل والبدائل" and "أكلتها", under the next meal.
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final logged = meal.status == MealStatus.logged;
    final summary = [
      if (isNext) l10n.commonKcalValue(context.localizeDigits(meal.calories)),
      ...meal.items.map((i) => i.name),
    ].join(' · ');

    final head = Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(AppRadius.cardSmall),
          ),
          child: Icon(mealTypeIcon(meal.source?.type),
              color: AppColors.primaryInk, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(meal.name, style: AppTextStyles.cardTitle),
                  if (isNext) _Chip(text: l10n.homeNextMealChip),
                ],
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (logged)
          _Chip(text: l10n.homeLogged, icon: Icons.check_circle_rounded)
        else if (!isNext)
          OutlinedButton(
            onPressed: onOpen,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(64, 44),
              foregroundColor: AppColors.primaryInk,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button)),
            ),
            child: Text(l10n.reminderActionLog, style: AppTextStyles.pillLabel),
          ),
      ],
    );

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
            color: isNext ? AppColors.primary : AppColors.border,
            width: isNext ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              head,
              if (actions != null) ...[const SizedBox(height: 12), actions!],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primaryInk),
            const SizedBox(width: 4),
          ],
          Text(text, style: AppTextStyles.pillLabel),
        ],
      ),
    );
  }
}

/// "Ate something off plan? Log it" — opens the log sheet.
class HomeOffPlanCard extends StatelessWidget {
  const HomeOffPlanCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                ),
                child: const Icon(Icons.search_rounded,
                    color: AppColors.primaryInk, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(l10n.homeOffPlanQuestion,
                      style: AppTextStyles.cardTitle)),
              const SizedBox(width: 8),
              Text(l10n.homeOffPlanAction,
                  style: AppTextStyles.pillLabel
                      .copyWith(color: AppColors.primaryInk)),
              const Icon(Icons.chevron_left_rounded,
                  color: AppColors.primaryInk),
            ],
          ),
        ),
      ),
    );
  }
}
