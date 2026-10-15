import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/time/date_only.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../bloc/meal_log/meal_log_cubit.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../meal_plan_view.dart';
import '../widgets/date_chip_picker.dart';
import '../widgets/load_error_view.dart';
import '../widgets/meal_card.dart';
import '../widgets/metric_stat_box.dart';
import 'meal_detail_screen.dart';
import '../../core/navigation/app_page_route.dart';
import '../widgets/app_header_bar.dart';

import '../../l10n/l10n.dart';

/// 4.4 Weekly Plan — week picker, macro summary, meal-slot list, all from the
/// plan the nutritionist set (API guide 5.1). Each day shows the daily meals
/// plus that weekday's meals, and the server's totals for that day.
class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  /// Saturday to Friday around today, as the design lays the week out.
  late final List<DateTime> _week = _weekAround(DateTime.now());
  late int _selectedDay = _week
      .indexWhere((d) => isSameLocalDay(d, DateTime.now()))
      .clamp(0, 6)
      .toInt();

  static List<DateTime> _weekAround(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final back = (today.weekday - DateTime.saturday) % 7;
    return [
      for (var i = 0; i < 7; i++)
        DateTime(today.year, today.month, today.day - back + i),
    ];
  }

  static String _weekdayShort(AppLocalizations l10n, DateTime day) =>
      switch (day.weekday) {
        DateTime.saturday => l10n.weekdayShortSaturday,
        DateTime.sunday => l10n.weekdayShortSunday,
        DateTime.monday => l10n.weekdayShortMonday,
        DateTime.tuesday => l10n.weekdayShortTuesday,
        DateTime.wednesday => l10n.weekdayShortWednesday,
        DateTime.thursday => l10n.weekdayShortThursday,
        _ => l10n.weekdayShortFriday,
      };

  @override
  Widget build(BuildContext context) {
    final planState = context.watch<MealPlanCubit>().state;
    final plan = planState.dataOrNull;

    final Widget body;
    if (plan != null) {
      body = _planView(context, plan);
    } else if (planState case AsyncError<MealPlan?>(:final failure)) {
      body = LoadErrorView(
        message: loadFailureMessage(context, failure),
        onRetry: () => context.read<MealPlanCubit>().load(),
      );
    } else if (planState is AsyncSuccess<MealPlan?>) {
      body = const _NoPlan();
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.dailyLogWeeklyPlanTooltip),
      body: SafeArea(child: body),
    );
  }

  Widget _planView(BuildContext context, MealPlan plan) {
    final l10n = context.l10n;
    final material = MaterialLocalizations.of(context);
    final mealLog = context.watch<MealLogCubit>().state;
    final selected = _week[_selectedDay];
    final totals = plan.totalOn(selected);
    final meals = planMealsFor(context, plan, selected,
        isLogged: mealLog.isPlannedLogged);
    final days = [
      for (final d in _week)
        DayItem(
          weekday: _weekdayShort(l10n, d),
          dayNumber: d.day,
          calories: plan.totalOn(d).calories.round(),
          isToday: isSameLocalDay(d, DateTime.now()),
        ),
    ];
    final start = plan.startDate;
    final week = start == null
        ? null
        : selected.difference(DateUtils.dateOnly(start)).inDays ~/ 7 + 1;
    String grams(double g) =>
        l10n.commonGramsValue(context.localizeDigits(g.round()));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.96, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppColors.accentGreenBg,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.calendar_month_rounded,
                      color: AppColors.accentGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.weeklyPlanPreviewScreen,
                          textAlign: TextAlign.start,
                          style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(l10n.weeklyPlanLoggingHint,
                          textAlign: TextAlign.start,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (week != null && week >= 1)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: AppColors.accentGreenBg,
                    borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Row(children: [
                  const Icon(Icons.verified_rounded,
                      color: AppColors.accentGreen, size: 14),
                  const SizedBox(width: 4),
                  Text(l10n.weeklyPlanWeekNumber(context.localizeDigits(week)),
                      style: AppTextStyles.caption),
                ]),
              ),
            const Spacer(),
            Text(context.localizeDigits(material.formatMonthYear(selected)),
                style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 12),
        DateChipPicker(
            days: days,
            selectedIndex: _selectedDay,
            onChanged: (i) => setState(() => _selectedDay = i)),
        const SizedBox(height: 20),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.96, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.accentGreenBg,
                          borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.accentGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(l10n.weeklyPlanDetailed,
                            style: AppTextStyles.caption),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          l10n.weeklyPlanDayOf(context.localizeDigits(
                              material.formatMediumDate(selected))),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(context.localizeDigits(totals.calories.round()),
                        style: AppTextStyles.metricLarge
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(width: 6),
                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(l10n.commonCaloriesUnit,
                            style: AppTextStyles.secondary)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(children: [
                  MetricStatBox(
                      label: l10n.macroHealthyFatsShort,
                      value: grams(totals.fatG)),
                  MetricStatBox(
                      label: l10n.macroCarbohydrates,
                      value: grams(totals.carbsG)),
                  MetricStatBox(
                      label: l10n.macroProteinLabel,
                      value: grams(totals.proteinG)),
                ]),
                const SizedBox(height: 10),
                Text(l10n.weeklyPlanFromNutritionist,
                    textAlign: TextAlign.start, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (meals.isEmpty)
          Text(l10n.planNoMealToday,
              textAlign: TextAlign.center, style: AppTextStyles.caption),
        for (final m in meals)
          MealCard(
            meal: m,
            enableHero: false,
            forceMealTypeColors: true,
            onLog: () => Navigator.of(context)
                .push(AppPageRoute(builder: (_) => MealDetailScreen(meal: m))),
          ),
      ],
    );
  }
}

/// "No active plan yet" (204): an empty state, not an error (5.1).
class _NoPlan extends StatelessWidget {
  const _NoPlan();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.event_note_rounded,
              size: 44, color: AppColors.primary),
          const SizedBox(height: 14),
          Text(context.l10n.planEmptyTitle,
              textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
          const SizedBox(height: 6),
          Text(context.l10n.planEmptyBody,
              textAlign: TextAlign.center, style: AppTextStyles.secondary),
        ]),
      ),
    );
  }
}
