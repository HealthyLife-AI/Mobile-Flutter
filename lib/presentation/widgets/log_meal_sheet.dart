import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/meal_log/meal_log_cubit.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../meal_plan_view.dart';
import '../screens/food_search_screen.dart';
import '../screens/meal_detail_screen.dart';
import 'meal_logged_snack.dart';
import 'segmented_sliding_tabs.dart';

/// "Log a meal": a bottom sheet over the screen the patient is on, in place
/// of a full intermediate screen. Two tabs: a meal from the plan (one tap, or
/// its details) and a food that is not in the plan (the food search).
Future<void> showLogMealSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const LogMealSheet(),
    );

class LogMealSheet extends StatefulWidget {
  const LogMealSheet({super.key});

  @override
  State<LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends State<LogMealSheet> {
  int _tab = 0;

  /// Closes the sheet, then runs [then] with the pieces that outlive it.
  void _closeThen(void Function(NavigatorState navigator) then) {
    final navigator = Navigator.of(context);
    navigator.pop();
    then(navigator);
  }

  void _eat(Meal meal) {
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<MealLogCubit>();
    final l10n = context.l10n;
    _closeThen((_) => logPlannedAndConfirm(
        messenger: messenger, cubit: cubit, l10n: l10n, meal: meal));
  }

  void _openDetails(Meal meal) => _closeThen((navigator) => navigator
      .push(AppPageRoute(builder: (_) => MealDetailScreen(meal: meal))));

  void _openSearch() => _closeThen((navigator) =>
      navigator.push(AppPageRoute(builder: (_) => const FoodSearchScreen())));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(l10n.logMealTitle, style: AppTextStyles.h1)),
              IconButton(
                tooltip: l10n.commonClose,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: AppColors.background),
              ),
            ]),
            const SizedBox(height: 8),
            SegmentedSlidingTabs(
              tabs: [l10n.logMealTabPlan, l10n.logMealTabOffPlan],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 16),
            if (_tab == 0)
              _PlanTab(onEat: _eat, onDetails: _openDetails)
            else
              _OffPlanTab(onSearch: _openSearch),
          ],
        ),
      ),
    );
  }
}

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.onEat, required this.onDetails});

  final ValueChanged<Meal> onEat;
  final ValueChanged<Meal> onDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = context.watch<MealPlanCubit>().state.dataOrNull;
    final log = context.watch<MealLogCubit>().state;
    final meals = plan == null
        ? const <Meal>[]
        : planMealsFor(context, plan, DateTime.now(),
            isLogged: log.isPlannedLogged);

    if (meals.isEmpty) {
      return _Note(
        icon: Icons.event_busy_outlined,
        text: plan == null ? l10n.planEmptyTitle : l10n.planNoMealToday,
      );
    }
    final allLogged = meals.every((m) => m.status == MealStatus.logged);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (allLogged) ...[
          _Note(icon: Icons.check_circle_outline, text: l10n.logMealAllLogged),
          const SizedBox(height: 12),
        ],
        for (final meal in meals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MealRow(
                meal: meal,
                onEat: () => onEat(meal),
                onDetails: () => onDetails(meal)),
          ),
      ],
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow(
      {required this.meal, required this.onEat, required this.onDetails});

  final Meal meal;
  final VoidCallback onEat;
  final VoidCallback onDetails;

  static IconData _icon(PlanMealType? type) => switch (type) {
        PlanMealType.breakfast => Icons.free_breakfast_outlined,
        PlanMealType.lunch => Icons.restaurant_rounded,
        PlanMealType.dinner => Icons.dinner_dining_rounded,
        PlanMealType.snack => Icons.eco_rounded,
        _ => Icons.restaurant_menu_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final logged = meal.status == MealStatus.logged;
    final summary = meal.items.map((i) => i.name).take(3).join(' · ');
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onDetails,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: logged ? AppColors.successBg : AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(_icon(meal.source?.type),
                    color: logged ? AppColors.success : AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.name, style: AppTextStyles.cardTitle),
                    Text(
                      summary.isEmpty
                          ? l10n.commonCaloriesValue(meal.calories)
                          : '${l10n.commonCaloriesValue(meal.calories)} · $summary',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (logged)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(l10n.homeLogged,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700)),
                ])
              else
                FilledButton(
                  onPressed: onEat,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(88, 48),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.mealAte,
                      style: AppTextStyles.ctaText.copyWith(fontSize: 15)),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _OffPlanTab extends StatelessWidget {
  const _OffPlanTab({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Note(icon: Icons.search_rounded, text: l10n.logMealOffPlanHint),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onSearch,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.search_rounded),
          label: Text(l10n.logMealSearchFood, style: AppTextStyles.ctaText),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.secondary)),
      ]),
    );
  }
}
