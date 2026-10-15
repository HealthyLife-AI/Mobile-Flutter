import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/app_dependencies.dart';
import '../core/theme/app_colors.dart';
import '../domain/measurement_schedule.dart';
import 'bloc/meal_plan/meal_plan_cubit.dart';
import 'bloc/measurements/measurements_cubit.dart';
import 'bloc/notifications/notifications_cubit.dart';
import 'widgets/animated_bottom_nav_pill.dart';
import 'widgets/load_error_view.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/daily_log_screen.dart';
import 'screens/first_measurement_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/log_meal_intro_screen.dart';
import '../core/navigation/app_page_route.dart';

import '../l10n/l10n.dart';

/// Bottom-nav shell. extendBody: true so the floating pill never sits
/// flush against the screen edge (section 2.3).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0; // Home tab selected by default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The device's timezone can change while the app is in the background. The
  /// guide asks for it whenever it changes (10.5), so the settings are checked
  /// on each return to the foreground. The shell is shown only to a signed-in
  /// patient, so nothing is sent otherwise.
  ///
  /// The plan is read again too, in case the nutritionist changed it while the
  /// app was away (5.1). The plan on screen stays while it reloads. The
  /// notifications and measurements are re-read for the same reason: a push
  /// that arrived or a measurement synced elsewhere must show up, and the
  /// Progress tab's gate depends on the measurements.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(context.read<AppDependencies>().preferences.syncIfZoneChanged());
    unawaited(context.read<MealPlanCubit>().load());
    unawaited(context.read<NotificationsCubit>().load());
    unawaited(context.read<MeasurementsCubit>().load());
  }

  /// The weigh-in day the patient chose to skip with "view my progress". The
  /// prompt comes back for the next due day, once a newer reading moves it.
  DateTime? _skippedDueDay;

  /// What the Progress tab shows. It is read from real data, not a flag kept
  /// in memory: a fresh install, a restart or a measurement taken elsewhere
  /// all decide the same way.
  ///
  /// The measurement prompt shows while there is no reading yet, and again
  /// once the weekly reading is due (API guide 10.6). In between, the patient
  /// sees their progress.
  _ProgressView _progressView(MeasurementsState state) {
    final snapshot = state.snapshot;
    // A refresh keeps the last answer on screen instead of a spinner.
    if (snapshot == null) {
      return state.status == MeasurementsStatus.error
          ? _ProgressView.error
          : _ProgressView.loading;
    }
    if (snapshot.isEmpty) return _ProgressView.prompt;
    if (state.measurementDue &&
        nextMeasurementDay(snapshot) != _skippedDueDay) {
      return _ProgressView.prompt;
    }
    return _ProgressView.progress;
  }

  Widget _progressTab(BuildContext context) {
    return BlocBuilder<MeasurementsCubit, MeasurementsState>(
      builder: (context, state) {
        switch (_progressView(state)) {
          case _ProgressView.prompt:
            final snapshot = state.snapshot!;
            return FirstMeasurementScreen(
              snapshot: snapshot,
              showBack: false,
              showExitAction: false,
              replaceEntryRoute: false,
              // Saving reloads the cubit, which switches this tab to the
              // progress dashboard.
              onMeasurementSaved: () =>
                  context.read<MeasurementsCubit>().load(),
              onViewProgress: () =>
                  setState(() => _skippedDueDay = nextMeasurementDay(snapshot)),
            );
          case _ProgressView.progress:
            return const ProgressScreen();
          case _ProgressView.loading:
            return const _ProgressTabLoading();
          case _ProgressView.error:
            // Nothing to show and no way to decide: say so and offer a retry.
            // The patient is never dropped into the dashboard on a guess.
            return LoadErrorView(
              message: loadFailureMessage(context, state.failure),
              onRetry: () => context.read<MeasurementsCubit>().load(),
            );
        }
      },
    );
  }

  Widget _pageForIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const HomeDashboardScreen();
      case 1:
        return const DailyLogScreen();
      case 2:
        return _progressTab(context);
      case 3:
        return const ProfileScreen();
      default:
        return const HomeDashboardScreen();
    }
  }

// Cohesive `_rounded` glyph set — every tab reads as the same family, and
  // the profile tab uses the filled-when-active person rather than an
  // avatar-with-badge that suggests an unread state.
  List<NavTab> _tabs(AppLocalizations l10n) => [
        NavTab(icon: Icons.home_rounded, label: l10n.navHome),
        NavTab(icon: Icons.event_note_rounded, label: l10n.navPlan),
        NavTab(icon: Icons.insights_rounded, label: l10n.navProgress),
        NavTab(icon: Icons.person_rounded, label: l10n.navAccount),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          // Canvas comes from the palette so the shell cannot drift away from
          // the `#F8FAFC` soft-light background the rest of the app paints.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.canvasSoft,
            ],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.04), end: Offset.zero)
                    .animate(animation),
                child: ScaleTransition(
                  scale:
                      Tween<double>(begin: 0.97, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          // The Progress tab animates when it changes between the prompt and
          // the dashboard. The other tabs keep their key, so a measurement
          // load never rebuilds them.
          child: KeyedSubtree(
            key: ValueKey<String>(_index == 2
                ? '$_index-${_progressView(context.watch<MeasurementsCubit>().state).name}'
                : '$_index'),
            child: _pageForIndex(context, _index),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavPill(
        tabs: _tabs(context.l10n),
        selectedIndex: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
      floatingActionButton: {0, 2}.contains(_index)
          ? FloatingActionButton(
              tooltip: context.l10n.navLogMealTooltip,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () => Navigator.of(context).push(
                  AppPageRoute(builder: (_) => const LogMealIntroScreen())),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }
}

enum _ProgressView { loading, error, prompt, progress }

/// The Progress tab while the measurements are being read for the first time.
class _ProgressTabLoading extends StatelessWidget {
  const _ProgressTabLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
