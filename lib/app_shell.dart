import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'widgets/animated_bottom_nav_pill.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/daily_log_screen.dart';
import 'screens/first_measurement_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/log_meal_intro_screen.dart';
import 'core/navigation/app_page_route.dart';

/// Bottom-nav shell. extendBody: true so the floating pill never sits
/// flush against the screen edge (section 2.3).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0; // Home tab selected by default
  bool _progressMeasurementLogged = false;

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeDashboardScreen();
      case 1:
        return const DailyLogScreen();
      case 2:
        return _progressMeasurementLogged
            ? const ProgressScreen()
            : FirstMeasurementScreen(
                showBack: false,
                showExitAction: false,
                replaceEntryRoute: false,
                onMeasurementSaved: () => setState(() => _progressMeasurementLogged = true),
              );
      case 3:
        return const ProfileScreen();
      default:
        return const HomeDashboardScreen();
    }
  }

// Cohesive `_rounded` glyph set — every tab reads as the same family, and
  // the profile tab uses the filled-when-active person rather than an
  // avatar-with-badge that suggests an unread state.
  final List<NavTab> _tabs = const [
    NavTab(icon: Icons.home_rounded, label: 'الرئيسية'),
    NavTab(icon: Icons.event_note_rounded, label: 'الخطة'),
    NavTab(icon: Icons.insights_rounded, label: 'التقدم'),
    NavTab(icon: Icons.person_rounded, label: 'حسابي'),
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
                position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(animation),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<String>('$_index-$_progressMeasurementLogged'),
            child: _pageForIndex(_index),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavPill(
        tabs: _tabs,
        selectedIndex: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
      floatingActionButton: {0, 2}.contains(_index)
          ? FloatingActionButton(
              tooltip: 'تسجيل وجبة جديدة',
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const LogMealIntroScreen())),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }
}
