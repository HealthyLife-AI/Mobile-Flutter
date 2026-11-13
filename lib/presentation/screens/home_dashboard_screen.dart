import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/navigation/app_page_route.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../bloc/meal_log/meal_log_cubit.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../meal_plan_view.dart';
import '../widgets/load_error_view.dart';
import '../widgets/meal_logged_snack.dart';
import '../widgets/scroll_edge_fade.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/offline_banner.dart';
import '../widgets/connection_status_sheet.dart';
import 'meal_detail_screen.dart';
import 'notifications_center_screen.dart';
import 'password_settings_screen.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/notifications/notifications_cubit.dart';
import '../widgets/password_reminder_card.dart';
import '../bloc/patient_features_cubits.dart';
import '../widgets/measurement_schedule_card.dart';
import '../widgets/quick_contact_card.dart';
import '../widgets/today_card.dart';
import '../widgets/home_day.dart';
import '../widgets/log_meal_sheet.dart';
import 'weekly_plan_screen.dart';

import '../../l10n/l10n.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Design tokens (local to this screen)
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static Color get teal => AppColors.primary;
  static const ink = AppColors.textPrimary;
  static const muted = AppColors.textMuted;
  static const green = AppColors.success;
  static const line = AppColors.chipInactiveBg;
  static const amber = AppColors.warning;
}

TextStyle _ts(double size,
        {FontWeight w = FontWeight.w600, Color? c, double? h}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c ?? _C.ink, height: h);

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  HomeConnectionState _conn = HomeConnectionState.online;
  int _pendingCount = 0;

  /// Demo affordance: tap the pulsing status dot next to the greeting to
  /// preview the offline → syncing → online cycle.
  void _toggleConnection() {
    if (_conn == HomeConnectionState.online) {
      setState(() {
        _conn = HomeConnectionState.offline;
        _pendingCount = 1;
      });
      return;
    }
    if (_conn == HomeConnectionState.offline) {
      setState(() => _conn = HomeConnectionState.syncing);
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        final synced = _pendingCount;
        setState(() {
          _conn = HomeConnectionState.online;
          _pendingCount = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                  synced > 0
                      ? context.l10n.homeSyncedItems(synced)
                      : context.l10n.homeOnlineNow,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        );
      });
    }
  }

  /// Pull-to-refresh: everything the home screen shows, read again.
  Future<void> _refreshAll() => Future.wait([
        context.read<MealPlanCubit>().load(),
        context.read<NotificationsCubit>().load(),
        context.read<TodayCubit>().load(),
        context.read<MeasurementScheduleCubit>().load(),
        context.read<QuickRequestsCubit>().load(),
        context.read<PostsUnreadCubit>().load(),
      ]);

  bool _eating = false;

  /// "I ate it": the meal is logged as planned, with one tap. The log is kept
  /// on the device at once (the server copy goes through the offline queue),
  /// and the patient can undo it for a few seconds; it stays editable after.
  Future<void> _eat(Meal meal) async {
    if (_eating) return;
    setState(() => _eating = true);
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<MealLogCubit>();
    final l10n = context.l10n;
    await logPlannedAndConfirm(
        messenger: messenger, cubit: cubit, l10n: l10n, meal: meal);
    if (mounted) setState(() => _eating = false);
  }

  void _openMeal(Meal meal) {
    Navigator.of(context)
        .push(AppPageRoute(builder: (_) => MealDetailScreen(meal: meal)));
  }

  @override
  Widget build(BuildContext context) {
    final planState = context.watch<MealPlanCubit>().state;
    final plan = planState.dataOrNull;
    // First load: the skeleton, as before. A refresh keeps the plan shown.
    if (plan == null &&
        (planState is AsyncInitial<MealPlan?> ||
            planState is AsyncLoading<MealPlan?>)) {
      return const Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: HomeSkeleton()));
    }
    final mealLog = context.watch<MealLogCubit>().state;
    final now = DateTime.now();
    final meals = plan == null
        ? const <Meal>[]
        : planMealsFor(context, plan, now, isLogged: mealLog.isPlannedLogged);
    final logged = meals.where((m) => m.status == MealStatus.logged).length;
    final next = meals.where((m) => m.status != MealStatus.logged).firstOrNull;
    final target = plan?.totalOn(now).calories.round() ?? 0;

    final offlineUi = _conn != HomeConnectionState.online;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            // The greeting starts below the fade band, so at rest it is never
            // faded into the top of the screen; content scrolling away still
            // fades out.
            child: ScrollEdgeFade(
              fadeHeight: 16,
              child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refreshAll,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    children: [
                      _Reveal(
                        child: _Header(
                          offline: offlineUi,
                          // The bell opens the inbox, not the settings that decide
                          // which notifications are sent (the two are different
                          // screens on purpose).
                          onBell: () => Navigator.of(context).push(AppPageRoute(
                              builder: (_) =>
                                  const NotificationsCenterScreen())),
                          onStatus: _toggleConnection,
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: offlineUi
                            ? Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: OfflineBanner(
                                  state: _conn,
                                  pendingCount: _pendingCount,
                                  onTap: () =>
                                      ConnectionStatusSheet.show(context),
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                      // Gentle reminder while the password is the temporary one
                      // from the nutritionist (API guide 3.4). Never blocks the app.
                      if (context.select<AuthCubit, bool>((cubit) =>
                          cubit.state.user?.passwordIsTemporary ?? false)) ...[
                        const SizedBox(height: 16),
                        PasswordReminderCard(
                          onTap: () => Navigator.of(context).push(AppPageRoute(
                              builder: (_) => const PasswordSettingsScreen())),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (plan == null) ...[
                        // No plan to show: the load failed, or there is no active
                        // plan yet (204), which is an empty state, not an error.
                        if (planState
                            case AsyncError<MealPlan?>(:final failure))
                          LoadErrorView(
                            failure: failure,
                            onRetry: () => context.read<MealPlanCubit>().load(),
                          )
                        else
                          const _Reveal(delayMs: 80, child: _NoPlanCard()),
                      ] else ...[
                        // The day at a glance: meals and calories logged, and
                        // the nutritionist's line for today or the next meal.
                        _Reveal(
                          delayMs: 80,
                          from: const Offset(0, 0.12),
                          child: HomeDayCard(
                            logged: logged,
                            total: meals.length,
                            eatenKcal: mealLog.totalCalories,
                            targetKcal: target,
                            nextMeal: next,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _Reveal(
                          delayMs: 160,
                          child: Row(children: [
                            Expanded(
                                child: Text(context.l10n.homeTodayMeals,
                                    style: AppTextStyles.sectionHeading)),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                  AppPageRoute(
                                      builder: (_) =>
                                          const WeeklyPlanScreen())),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryInk,
                                  minimumSize: const Size(48, 44)),
                              child: Text(context.l10n.homeWeeklyPlanLink,
                                  style: AppTextStyles.pillLabel),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 8),
                        if (meals.isEmpty)
                          Text(context.l10n.planNoMealToday,
                              textAlign: TextAlign.center,
                              style: _ts(12.5, c: _C.muted)),
                        for (int i = 0; i < meals.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _Reveal(
                              delayMs: 220 + i * 90,
                              from: const Offset(0, 0.1),
                              child: HomeMealTile(
                                meal: meals[i],
                                isNext: identical(meals[i], next),
                                onOpen: () => _openMeal(meals[i]),
                                actions: identical(meals[i], next)
                                    ? _MealActions(
                                        onEat: () => _eat(meals[i]),
                                        onDetails: () => _openMeal(meals[i]),
                                        eating: _eating,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        const SizedBox(height: 2),
                        _Reveal(
                          delayMs: 300 + meals.length * 90,
                          child: HomeOffPlanCard(
                              onTap: () => showLogMealSheet(context)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Below the meals: the questionnaire and the other
                      // reminders of the day, then the weigh-in reminder.
                      const _Reveal(delayMs: 600, child: TodayReminders()),
                      const _Reveal(
                          delayMs: 640, child: MeasurementDueReminder()),
                      const SizedBox(height: 4),
                      const _Reveal(delayMs: 700, child: QuickContactCard()),
                      const SizedBox(height: 16),
                      const _Reveal(delayMs: 760, child: _TipCard()),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Generic reveal (fade + slide, with delay)
// ─────────────────────────────────────────────────────────────────────────────
class _Reveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final Offset from;
  const _Reveal({
    required this.child,
    this.delayMs = 0,
    this.from = const Offset(0, 0.08),
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  late final Animation<Offset> _s =
      Tween<Offset>(begin: widget.from, end: Offset.zero).animate(_a);
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _a, child: SlideTransition(position: _s, child: widget.child));
}

// ─────────────────────────────────────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool offline;
  final VoidCallback onBell, onStatus;
  const _Header(
      {required this.offline, required this.onBell, required this.onStatus});

  @override
  Widget build(BuildContext context) {
    final patientName = context.watch<AuthCubit>().state.user?.name ?? '';
    // Unread notifications plus unread posts from the nutritionist (spec,
    // phase 3). No badge when there is nothing unread.
    final unread = context.watch<NotificationsCubit>().state.unreadCount +
        (context.watch<PostsUnreadCubit>().state.dataOrNull ?? 0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Tooltip(
                  message: offline
                      ? context.l10n.homeTapToSync
                      : context.l10n.homeOnlineTapPreview,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onStatus,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 6),
                      child: _StatusDot(offline: offline),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                      context.l10n.homeGreeting(
                          patientName.isEmpty ? 'no' : 'yes', patientName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ts(21, w: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: _C.muted),
                const SizedBox(width: 6),
                // A full date can be long ("Wednesday, October 15, 2026").
                Flexible(
                  child: Text(
                      context.localizeDigits(MaterialLocalizations.of(context)
                          .formatFullDate(DateTime.now())),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ts(12, c: _C.muted)),
                ),
              ]),
            ],
          ),
        ),
        _BellButton(onTap: onBell, unread: unread),
      ],
    );
  }
}

class _StatusDot extends StatefulWidget {
  final bool offline;
  const _StatusDot({required this.offline});
  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.offline ? _C.amber : _C.green;
    return SizedBox(
      width: 22,
      height: 22,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_c.value);
          return Stack(alignment: Alignment.center, children: [
            Container(
              width: 9 + 13 * t,
              height: 9 + 13 * t,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.35 * (1 - t))),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 9,
              height: 9,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ]);
        },
      ),
    );
  }
}

class _BellButton extends StatefulWidget {
  final VoidCallback onTap;

  /// Shown as a count badge while above zero.
  final int unread;
  const _BellButton({required this.onTap, required this.unread});
  @override
  State<_BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<_BellButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4000))
    ..repeat();
  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.notificationsTitle,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _C.teal, width: 1.4),
            ),
            child: Stack(alignment: Alignment.center, children: [
              AnimatedBuilder(
                animation: _c,
                builder: (context, child) {
                  final t = _c.value;
                  // a quick "ring" every few seconds
                  final angle = t < 0.14
                      ? math.sin(t / 0.14 * math.pi * 4) * 0.28 * (1 - t / 0.14)
                      : 0.0;
                  return Transform.rotate(
                      angle: angle,
                      alignment: Alignment.topCenter,
                      child: child);
                },
                child: Icon(Icons.notifications_none_rounded,
                    color: _C.teal, size: 23),
              ),
              if (widget.unread > 0)
                PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 17, minHeight: 17),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        widget.unread > 9
                            ? context.localizeDigits('9+')
                            : context.localizeDigits(widget.unread),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            height: 1.1,
                            fontWeight: FontWeight.w700),
                      ),
                    )),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  No active plan yet (204): an empty state, not an error (5.1)
// ─────────────────────────────────────────────────────────────────────────────
class _NoPlanCard extends StatelessWidget {
  const _NoPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.line),
      ),
      child: Row(children: [
        const _IconTile(icon: Icons.event_note_rounded),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.l10n.planEmptyTitle,
                style: _ts(15, w: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(context.l10n.planEmptyBody,
                style: _ts(12, w: FontWeight.w500, c: _C.muted, h: 1.4)),
          ]),
        ),
      ]),
    );
  }
}

/// The two actions of the current meal: eat it as planned (one tap, with an
/// undo), or open its details to change an amount or pick an alternative.
class _MealActions extends StatelessWidget {
  const _MealActions(
      {required this.onEat, required this.onDetails, required this.eating});

  final VoidCallback onEat;
  final VoidCallback onDetails;

  /// A log is on its way: the button waits, so a second tap does nothing.
  final bool eating;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return Row(children: [
      Expanded(
        child: OutlinedButton(
          onPressed: onDetails,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(l10n.mealDetailsAndSwaps,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: AppTextStyles.pillLabel),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: FilledButton.icon(
          onPressed: eating ? null : onEat,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: const Icon(Icons.check_rounded, size: 20),
          label: Text(l10n.mealAte,
              style: AppTextStyles.ctaText.copyWith(fontSize: 15)),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tip card
// ─────────────────────────────────────────────────────────────────────────────
class _TipCard extends StatefulWidget {
  const _TipCard();
  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final g = (math.sin(_c.value * 2 * math.pi) + 1) / 2;
            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: _C.teal.withValues(alpha: 0.10 + 0.25 * g),
                      blurRadius: 6 + 12 * g),
                ],
              ),
              child: child,
            );
          },
          child:
              Icon(Icons.lightbulb_outline_rounded, size: 20, color: _C.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            context.l10n.homeHydrationTip,
            style: _ts(11.5, c: AppColors.textMuted, h: 1.7),
          ),
        ),
      ]),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  const _IconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 21, color: _C.teal),
    );
  }
}
