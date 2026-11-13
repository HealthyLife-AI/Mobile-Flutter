import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/errors/failure.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../core/time/date_only.dart';
import '../bloc/meal_log/meal_log_cubit.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../meal_plan_view.dart';
import 'meal_detail_screen.dart';
import 'notifications_center_screen.dart';
import 'shopping_list_screen.dart';
import 'weekly_plan_screen.dart';
import '../widgets/meal_logged_snack.dart';
import '../widgets/today_plan.dart';

import '../../l10n/l10n.dart';
import '../widgets/log_meal_sheet.dart';

const Color _mutedIcon = AppColors.textMuted;

bool _reduceMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  final Set<String> _removed = {};

  /// The day shown. Today unless the patient picked another day of the week.
  DateTime _day = DateTime.now();

  /// A one-tap log is on its way.
  bool _logging = false;


  /// The plan and day the server's logs were last read for.
  String? _syncedFor;

  void _openWeeklyPlan() {
    Navigator.of(context)
        .push(AppPageRoute(builder: (_) => const WeeklyPlanScreen()));
  }

  void _openMeal(Meal meal) {
    Navigator.of(context)
        .push(AppPageRoute(builder: (_) => MealDetailScreen(meal: meal)));
  }

  void _onAddMeal() => showLogMealSheet(context);

  void _openShopping() => Navigator.of(context)
      .push(AppPageRoute(builder: (_) => ShoppingListScreen(day: _day)));

  /// Logs the meal as planned, with an undo, as "أكلتها" does on home.
  Future<void> _logMeal(Meal meal) async {
    if (_logging) return;
    setState(() => _logging = true);
    HapticFeedback.mediumImpact();
    await logPlannedAndConfirm(
        messenger: ScaffoldMessenger.of(context),
        cubit: context.read<MealLogCubit>(),
        l10n: context.l10n,
        meal: meal);
    if (mounted) setState(() => _logging = false);
  }

  String _timeOf(DateTime at) =>
      context.localizeDigits(MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay.fromDateTime(at.toLocal())));

  /// Hides the row at once, and deletes the entry for real (here and on the
  /// server, API guide 6.4) when the undo notice closes without an undo. A
  /// delete that fails brings the row back and says why.
  void _delete(_LogItem item) {
    HapticFeedback.lightImpact();
    setState(() => _removed.add(item.id));
    final cubit = context.read<MealLogCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    messenger.hideCurrentSnackBar();
    final notice = messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.dailyLogMealDeleted),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 100),
        duration: const Duration(seconds: 4),
        // With an action it would stay until dismissed, and the delete would
        // wait with it.
        persist: false,
        action: SnackBarAction(
          label: l10n.commonUndo,
          onPressed: () {
            if (mounted) setState(() => _removed.remove(item.id));
          },
        ),
      ),
    );
    notice.closed.then((reason) async {
      if (reason == SnackBarClosedReason.action) return;
      final failure = (await cubit.delete(item.id)).failureOrNull;
      if (failure == null) return;
      if (mounted) setState(() => _removed.remove(item.id));
      messenger.showSnackBar(SnackBar(
        content: Text(switch (failure) {
          ApiFailure(code: 'log_locked') => l10n.entryEditLocked,
          NetworkFailure() => l10n.dailyLogDeleteOffline,
          _ => l10n.dailyLogDeleteFailed,
        }),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 100),
        backgroundColor: AppColors.danger,
      ));
    });
  }

  /// Today's items: the plan's meals logged today (in the plan's order), then
  /// planned meals logged today that are no longer in the plan, then today's
  /// off-plan foods. Calories are what was logged, swaps included. Logs from
  /// earlier days are kept but not shown here.
  List<_LogItem> _collectItems(
      List<MealLogEntry> logged, List<Meal> todayMeals) {
    final now = DateTime.now();
    final entries =
        logged.where((e) => isSameLocalDay(e.loggedAt, now)).toList();
    final byPlanMeal = {
      for (final e in entries)
        if (e.plannedMeal != null) e.plannedMeal!.id: e,
    };

    final planned = [
      for (final m in todayMeals)
        if (byPlanMeal[m.id] case final entry?)
          _LogItem(
              id: entry.id,
              name: m.name,
              calories: entry.calories,
              time: m.timeRange,
              meal: m,
              deletable: entry.canDeleteAt(now)),
    ];

    final added = entries
        .where((e) =>
            e.plannedMeal != null &&
            !todayMeals.any((m) => m.id == e.plannedMeal!.id))
        .map((e) => _LogItem(
            id: e.id,
            name: e.plannedMeal!.name,
            calories: e.calories,
            time: e.plannedMeal!.timeRange,
            meal: e.plannedMeal!,
            deletable: e.canDeleteAt(now)));

    // Planned foods read from the server that match none of today's plan
    // meals (logged on another device under an older plan, say).
    final loose = [
      for (final e in entries)
        if (e.plannedMeal == null && !e.isOffPlan)
          _LogItem(
            id: e.id,
            name: e.name,
            calories: e.calories,
            grams: e.grams,
            deletable: e.canDeleteAt(now),
            editable: e.canEditGramsAt(now),
          ),
    ];

    final off = <_LogItem>[
      for (final e in entries.where((e) => e.isOffPlan).toList().reversed)
        _LogItem(
          id: e.id,
          name: e.name,
          calories: e.calories,
          grams: e.grams,
          offPlan: true,
          deletable: e.canDeleteAt(now),
          editable: e.canEditGramsAt(now),
        ),
    ];

    return [...planned, ...added, ...loose, ...off];
  }

  /// Reads today's logs from the server once the plan is known, so a planned
  /// log joins its meal (6.2). Read again on each new day and plan.
  void _syncWhenReady(AsyncState<MealPlan?> planState, List<Meal> todayMeals) {
    if (planState is! AsyncSuccess<MealPlan?> &&
        planState is! AsyncError<MealPlan?>) {
      return;
    }
    final key = '${planState.dataOrNull?.id}|${dateOnly(DateTime.now())}';
    if (key == _syncedFor) return;
    _syncedFor = key;
    final cubit = context.read<MealLogCubit>();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => cubit.syncToday(todayMeals));
  }

  /// Asks for the new grams of a one-food entry and saves them (6.3).
  Future<void> _editGrams(_LogItem item) async {
    final l10n = context.l10n;
    final cubit = context.read<MealLogCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final grams = await _GramsSheet.show(context,
        name: item.name, grams: item.grams ?? 100);
    if (grams == null || grams == item.grams) return;
    final failure = (await cubit.updateGrams(item.id, grams)).failureOrNull;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(switch (failure) {
          null => l10n.dailyLogGramsChanged,
          ApiFailure(code: 'log_locked') => l10n.entryEditLocked,
          NetworkFailure() => l10n.dailyLogEditOffline,
          NotFoundFailure() => l10n.dailyLogEditGone,
          _ => l10n.dailyLogEditFailed,
        }),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 100),
        backgroundColor: failure == null ? null : AppColors.danger,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MealLogCubit, MealLogState>(
          builder: (context, mealLog) {
            // Today's meals and calorie target, from the nutritionist's plan.
            final planState = context.watch<MealPlanCubit>().state;
            final MealPlan? plan = planState.dataOrNull;
            final now = DateTime.now();
            final todayMeals = plan == null
                ? const <Meal>[]
                : planMealsFor(context, plan, now,
                    isLogged: mealLog.isPlannedLogged);
            _syncWhenReady(planState, todayMeals);
            final items = _collectItems(mealLog.entries, todayMeals);

            final active =
                items.where((i) => !_removed.contains(i.id)).toList();
            final eaten = active.fold<int>(0, (t, i) => t + i.calories);
            final isToday = isSameLocalDay(_day, now);
            final dayMeals = plan == null
                ? const <Meal>[]
                : isToday
                    ? todayMeals
                    : planMealsFor(context, plan, _day);
            // Today's planned meals that are logged, by meal.
            final loggedByMeal = {
              for (final i in active)
                if (i.meal != null) i.meal!.id: i,
            };
            final entryById = {for (final e in mealLog.entries) e.id: e};
            // Everything else logged today: off-plan foods, and planned
            // meals that are no longer in today's plan.
            final others = [
              for (final i in items)
                if (i.meal == null ||
                    !todayMeals.any((m) => m.id == i.meal!.id))
                  i,
            ];
            final loggedDays = {
              for (final e in mealLog.entries)
                DateTime(e.loggedAt.toLocal().year, e.loggedAt.toLocal().month,
                    e.loggedAt.toLocal().day),
            };
            final next = isToday
                ? dayMeals
                    .where((m) => !loggedByMeal.containsKey(m.id))
                    .firstOrNull
                : null;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<MealLogCubit>().syncToday(todayMeals),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _FadeSlide(
                      delayMs: 0,
                      dy: -16,
                      child: _Header(
                          onCalendar: _openWeeklyPlan,
                          onShopping: _openShopping)),
                  const SizedBox(height: 14),
                  _FadeSlide(
                    delayMs: 60,
                    child: WeekStrip(
                      days: weekAround(now),
                      selected: _day,
                      loggedDays: loggedDays,
                      onSelect: (d) {
                        HapticFeedback.selectionClick();
                        setState(() => _day = d);
                      },
                    ),
                  ),
                  if (!isToday) ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: Text(context.l10n.todayPlanViewOnly,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _day = now),
                        child: Text(context.l10n.todayPlanBackToToday),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 14),
                  if (plan != null)
                    _FadeSlide(
                      delayMs: 120,
                      child: DayTotalsCard(
                        totals: plan.totalOn(_day),
                        eatenKcal: isToday ? eaten : null,
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (dayMeals.isEmpty && others.isEmpty)
                    const _EmptyState(key: ValueKey('empty')),
                  for (var i = 0; i < dayMeals.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FadeSlide(
                        key: ValueKey('${_day.day}-${dayMeals[i].id}'),
                        delayMs: 180 + math.min(i, 5) * 80,
                        child: Builder(builder: (context) {
                          final meal = dayMeals[i];
                          final log = isToday ? loggedByMeal[meal.id] : null;
                          final entry = log == null ? null : entryById[log.id];
                          return PlanMealCard(
                            meal: meal,
                            onOpen: () => _openMeal(meal),
                            highlighted: identical(meal, next),
                            loggedTime:
                                entry == null ? null : _timeOf(entry.loggedAt),
                            onLog: isToday && log == null
                                ? () => _logMeal(meal)
                                : null,
                            logging: _logging,
                            onDeleteLog: log != null && log.deletable
                                ? () => _delete(log)
                                : null,
                          );
                        }),
                      ),
                    ),
                  if (isToday && others.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(context.l10n.logMealTabOffPlan,
                        style: AppTextStyles.sectionHeading),
                    const SizedBox(height: 10),
                    for (final item in others)
                      KeyedSubtree(
                        key: ValueKey(item.id),
                        child: _CollapsibleCard(
                          removed: _removed.contains(item.id),
                          child: _TimelineCard(
                            item: item,
                            isLatest: false,
                            onTap: item.meal != null
                                ? () => _openMeal(item.meal!)
                                : item.editable
                                    ? () => _editGrams(item)
                                    : null,
                            onDelete:
                                item.deletable ? () => _delete(item) : null,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  _FadeSlide(
                      delayMs: 600, child: _AddMealButton(onTap: _onAddMeal)),
                  const SizedBox(height: 12),
                  _FadeSlide(
                      delayMs: 660,
                      child: _WeeklyPlanButton(onTap: _openWeeklyPlan)),
                  const SizedBox(height: 16),
                  const _FadeSlide(delayMs: 720, child: _ReminderCard()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ───────────────────────────── Data ─────────────────────────────

class _LogItem {
  /// The [MealLogEntry.id] the row shows.
  final String id;
  final String name;
  final int calories;
  final int? grams;
  final String? time;
  final bool offPlan;
  final Meal? meal;

  /// False once the server's edit window has passed (6.1).
  final bool deletable;

  /// One food the server has saved: its grams can be changed (6.3).
  final bool editable;

  const _LogItem({
    required this.id,
    required this.name,
    required this.calories,
    this.grams,
    this.time,
    this.offPlan = false,
    this.meal,
    this.deletable = true,
    this.editable = false,
  });
}

/// Asks for a food's new grams, 1 to 5000 (6.3). Pops with the grams, or
/// with nothing when the patient leaves.
class _GramsSheet extends StatefulWidget {
  const _GramsSheet({required this.name, required this.grams});

  final String name;
  final int grams;

  static Future<int?> show(BuildContext context,
          {required String name, required int grams}) =>
      showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => _GramsSheet(name: name, grams: grams),
      );

  @override
  State<_GramsSheet> createState() => _GramsSheetState();
}

class _GramsSheetState extends State<_GramsSheet> {
  late final TextEditingController _grams =
      TextEditingController(text: '${widget.grams}');
  bool _invalid = false;

  @override
  void dispose() {
    _grams.dispose();
    super.dispose();
  }

  void _save() {
    final grams = int.tryParse(_grams.text.trim());
    if (grams == null || grams < 1 || grams > 5000) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(grams);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.dailyLogEditGramsTitle, style: AppTextStyles.cardTitle),
          const SizedBox(height: 4),
          Text(widget.name, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          TextField(
            controller: _grams,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: l10n.dailyLogEditGramsLabel,
              errorText: _invalid ? l10n.dailyLogEditGramsRange : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _save,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Header ─────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onCalendar;
  final VoidCallback onShopping;
  const _Header({required this.onCalendar, required this.onShopping});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(child: Text(l10n.todayPlanTitle, style: AppTextStyles.h1)),
        OutlinedButton.icon(
          onPressed: onShopping,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 44),
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button)),
          ),
          icon: const Icon(Icons.shopping_cart_outlined, size: 20),
          label: Text(l10n.shoppingListTitle,
              style: AppTextStyles.pillLabel
                  .copyWith(color: AppColors.textPrimary)),
        ),
        _HeaderIcon(
            icon: Icons.calendar_month_outlined,
            onTap: onCalendar,
            tooltip: l10n.dailyLogWeeklyPlanTooltip),
        _HeaderIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () => Navigator.of(context).push(AppPageRoute(
                builder: (_) => const NotificationsCenterScreen())),
            tooltip: l10n.commonNotifications),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _HeaderIcon(
      {required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: _PressableScale(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Summary card ─────────────────────────────

// ───────────────────────────── Section header ─────────────────────────────

// ───────────────────────────── Timeline card ─────────────────────────────

class _TimelineCard extends StatelessWidget {
  final _LogItem item;
  final bool isLatest;
  final VoidCallback? onTap;

  /// Null hides the delete button: the server's edit window has passed (6.1).
  final VoidCallback? onDelete;
  const _TimelineCard(
      {required this.item,
      required this.isLatest,
      required this.onDelete,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = item.offPlan ? AppColors.accentOrange : AppColors.primary;
    final accentBg =
        item.offPlan ? AppColors.accentOrangeBg : AppColors.primaryTint;
    final tagText = item.offPlan
        ? context.l10n.dailyLogOffPlanFree
        : context.l10n.dailyLogFromPlan;
    final tagIcon = item.offPlan
        ? Icons.add_circle_outline_rounded
        : Icons.check_circle_outline_rounded;

    return _PressableScale(
      onTap: onTap,
      pressedScale: .98,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsetsDirectional.fromSTEB(8, 14, 14, 14),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingIcon(
                  pulse: isLatest,
                  color: accent,
                  background: accentBg,
                  icon: item.offPlan
                      ? Icons.restaurant_rounded
                      : Icons.rice_bowl_rounded,
                ),
                if (item.time != null) ...[
                  const SizedBox(height: 6),
                  Text(context.localizeDigits(item.time!),
                      style: const TextStyle(fontSize: 10, color: _mutedIcon)),
                ],
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tagIcon, size: 13, color: accent),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          tagText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 14, color: accent),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              context.l10n.commonKcalValue(
                                  context.localizeDigits(item.calories)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                      if (item.grams != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.scale_rounded,
                                size: 14, color: _mutedIcon),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                context.l10n.commonGramsValue(
                                    context.localizeDigits(item.grams!)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              Semantics(
                button: true,
                label: context.l10n.dailyLogDeleteMeal,
                child: Tooltip(
                  message: context.l10n.dailyLogDeleteMeal,
                  child: _PressableScale(
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 22, color: _mutedIcon),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// أيقونة الوجبة، وآخر وجبة مسجّلة تنبض بحلقة هادئة.
class _PulsingIcon extends StatefulWidget {
  final bool pulse;
  final Color color;
  final Color background;
  final IconData icon;
  const _PulsingIcon(
      {required this.pulse,
      required this.color,
      required this.background,
      required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));

  void _sync() {
    final run = widget.pulse && !_reduceMotion(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _PulsingIcon old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.pulse)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final t = Curves.easeOut.transform(_c.value);
                  return Opacity(
                    opacity: (1 - t) * .5,
                    child: Container(
                      width: 44 + 8 * t,
                      height: 44 + 8 * t,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: widget.color, width: 2)),
                    ),
                  );
                },
              ),
            ),
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(color: widget.background, shape: BoxShape.circle),
            child: Icon(widget.icon, color: widget.color, size: 22),
          ),
        ],
      ),
    );
  }
}

/// عند الحذف: البطاقة تتلاشى وتنكمش بسلاسة (وترجع لو ضغطتي "تراجع").
class _CollapsibleCard extends StatelessWidget {
  final bool removed;
  final Widget child;
  const _CollapsibleCard({required this.removed, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 380),
      sizeCurve: Curves.easeInOutCubic,
      crossFadeState:
          removed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: child,
      secondChild: const SizedBox(width: double.infinity),
    );
  }
}

// ───────────────────────────── Reminder / empty / button ─────────────────────────────

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.dailyLogDietitianReminder,
                    style: AppTextStyles.cardTitle),
                const SizedBox(height: 6),
                Text(
                  context.l10n.dailyLogFlexibilityNote,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.self_improvement_rounded,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, t, child) => Transform.scale(scale: t, child: child),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.primaryTint, shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_menu_rounded,
                    color: AppColors.primary, size: 30),
              ),
            ),
            const SizedBox(height: 12),
            Text(context.l10n.dailyLogNoMealsYet,
                style: AppTextStyles.secondary),
          ],
        ),
      ),
    );
  }
}

class _AddMealButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMealButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.navLogMealTooltip,
      child: _PressableScale(
        onTap: onTap,
        pressedScale: .96,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: .28),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(context.l10n.navLogMealTooltip,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The second action under "log a new meal": the week's plan, the same screen
/// the calendar icon in the header opens.
class _WeeklyPlanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _WeeklyPlanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.dailyLogWeeklyPlanTooltip;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: _PressableScale(
        onTap: onTap,
        pressedScale: .96,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.primary, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.primaryInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Shared helpers ─────────────────────────────

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ],
    );

/// ظهور تدريجي مع انزلاق، بتأخير يختلف لكل عنصر (stagger).
class _FadeSlide extends StatelessWidget {
  final int delayMs;
  final double dy;
  final Widget child;
  const _FadeSlide(
      {super.key, required this.delayMs, required this.child, this.dy = 26});

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return child;
    final total = delayMs + 650;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0).toDouble(),
        child:
            Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
      ),
    );
  }
}

/// ضغطة بتصغّر العنصر قليلاً ثم ترجعه (إحساس لمسي).
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  const _PressableScale(
      {required this.child, this.onTap, this.pressedScale = .88});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
