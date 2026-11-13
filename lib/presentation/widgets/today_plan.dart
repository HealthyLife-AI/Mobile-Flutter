import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../l10n/l10n.dart';

/// Saturday to Friday around [now], as the plan's week is laid out.
List<DateTime> weekAround(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final back = (today.weekday - DateTime.saturday) % 7;
  return [
    for (var i = 0; i < 7; i++)
      DateTime(today.year, today.month, today.day - back + i),
  ];
}

String weekdayShort(AppLocalizations l10n, DateTime day) =>
    switch (day.weekday) {
      DateTime.saturday => l10n.weekdayShortSaturday,
      DateTime.sunday => l10n.weekdayShortSunday,
      DateTime.monday => l10n.weekdayShortMonday,
      DateTime.tuesday => l10n.weekdayShortTuesday,
      DateTime.wednesday => l10n.weekdayShortWednesday,
      DateTime.thursday => l10n.weekdayShortThursday,
      _ => l10n.weekdayShortFriday,
    };

IconData _mealIcon(PlanMealType? type) => switch (type) {
      PlanMealType.breakfast => Icons.free_breakfast_outlined,
      PlanMealType.lunch => Icons.restaurant_rounded,
      PlanMealType.dinner => Icons.dinner_dining_rounded,
      PlanMealType.snack => Icons.eco_rounded,
      _ => Icons.restaurant_menu_rounded,
    };

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// The week's days in a row. The selected day is filled; a dot marks the days
/// with at least one logged meal.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.days,
    required this.selected,
    required this.loggedDays,
    required this.onSelect,
  });

  final List<DateTime> days;
  final DateTime selected;

  /// Days (at midnight) that have a log.
  final Set<DateTime> loggedDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DayChip(
                label: weekdayShort(l10n, day),
                number: context.localizeDigits(day.day),
                selected: _sameDay(day, selected),
                logged: loggedDays.any((d) => _sameDay(d, day)),
                onTap: () => onSelect(day),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.number,
    required this.selected,
    required this.logged,
    required this.onTap,
  });

  final String label;
  final String number;
  final bool selected;
  final bool logged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label $number',
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label,
                      maxLines: 1,
                      style: AppTextStyles.tiny.copyWith(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.9)
                              : AppColors.textSecondary)),
                ),
                Text(number,
                    style: AppTextStyles.cardTitle.copyWith(color: fg)),
                const SizedBox(height: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: logged
                        ? (selected ? Colors.white : AppColors.accentGreen)
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The day's calories from the plan, how much of it is logged (today), and the
/// protein, carbs and fat.
class DayTotalsCard extends StatelessWidget {
  const DayTotalsCard({super.key, required this.totals, this.eatenKcal});

  final Macros totals;

  /// Calories logged today, or null on another day (no bar then).
  final int? eatenKcal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goal = totals.calories.round();
    final progress =
        (eatenKcal == null || goal == 0) ? null : (eatenKcal! / goal);
    String g(double v) =>
        l10n.commonGramsShortValue(context.localizeDigits(v.round()));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(context.localizeDigits(goal),
                  style: AppTextStyles.metricLarge
                      .copyWith(color: AppColors.primaryInk)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l10n.todayPlanKcalToday,
                    style: AppTextStyles.secondary
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                color: AppColors.primary,
                backgroundColor: AppColors.primaryTint,
                semanticsLabel: l10n.todayPlanKcalOfGoal(
                    context.localizeDigits(eatenKcal!),
                    context.localizeDigits(goal)),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _Macro(value: g(totals.proteinG), label: l10n.macroProteinLabel),
              _Macro(value: g(totals.carbsG), label: l10n.macroCarbohydrates),
              _Macro(value: g(totals.fatG), label: l10n.macroFatLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.cardTitle),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// One planned meal of the day, with its foods and grams. A food that has
/// alternatives in the plan says so. Today, a meal not logged yet has one log
/// button; a logged one says when, and can be deleted.
class PlanMealCard extends StatelessWidget {
  const PlanMealCard({
    super.key,
    required this.meal,
    required this.onOpen,
    this.highlighted = false,
    this.loggedTime,
    this.onLog,
    this.logging = false,
    this.onDeleteLog,
  });

  final Meal meal;
  final VoidCallback onOpen;

  /// The next meal to log: a teal frame.
  final bool highlighted;

  /// When it was logged ("8:10 ص"), or null when it is not logged.
  final String? loggedTime;

  /// Logs the meal as planned. Null hides the button (logged, or another day).
  final VoidCallback? onLog;

  /// A log is on its way: the button waits.
  final bool logging;

  /// Deletes the log. Null when there is none or its edit window has passed.
  final VoidCallback? onDeleteLog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sources = meal.source?.items ?? const <PlanItem>[];
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
            color: highlighted ? AppColors.primary : AppColors.border,
            width: highlighted ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    ),
                    child: Icon(_mealIcon(meal.source?.type),
                        color: AppColors.primaryInk, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(meal.name, style: AppTextStyles.cardTitle)),
                  if (loggedTime != null) ...[
                    _LoggedChip(text: l10n.todayPlanLoggedAt(loggedTime!)),
                    if (onDeleteLog != null)
                      IconButton(
                        tooltip: l10n.todayPlanDeleteLog,
                        onPressed: onDeleteLog,
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.textMuted),
                      ),
                  ] else
                    Text(
                        l10n.commonKcalValue(
                            context.localizeDigits(meal.calories)),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < meal.items.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.turquoise),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(meal.items[i].name,
                            style: AppTextStyles.body),
                      ),
                      if (i < sources.length &&
                          sources[i].alternatives.isNotEmpty) ...[
                        _AltChip(text: l10n.todayPlanAltAvailable),
                        const SizedBox(width: 8),
                      ],
                      Text(
                          l10n.commonGramsShortValue(
                              context.localizeDigits(meal.items[i].grams)),
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              if (onLog != null) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: logging ? null : onLog,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: highlighted
                        ? AppColors.primary
                        : AppColors.primaryTint,
                    foregroundColor:
                        highlighted ? Colors.white : AppColors.primaryInk,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.button)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(l10n.todayPlanLogMeal,
                      style: AppTextStyles.ctaText.copyWith(
                          fontSize: 15,
                          color: highlighted
                              ? Colors.white
                              : AppColors.primaryInk)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoggedChip extends StatelessWidget {
  const _LoggedChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 14, color: AppColors.success),
            const SizedBox(width: 4),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pillLabel
                      .copyWith(color: AppColors.success)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AltChip extends StatelessWidget {
  const _AltChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_horiz_rounded,
              size: 14, color: AppColors.primaryInk),
          const SizedBox(width: 3),
          Text(text, style: AppTextStyles.tiny.copyWith(
              color: AppColors.primaryInk, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
