import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/screens/error_state_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/app_shell.dart';
import 'app_page_route.dart';

/// Central navigation policy: the two entry destinations (shell vs marketing
/// onboarding) are **guarded** by [AuthState], and unknown routes land on a
/// real error screen instead of a red screen. Individual pushes between
/// screens stay local to their screens — only flow-level transitions go
/// through here, so guards can never be bypassed by accident.
abstract final class AppRouter {
  AppRouter._();

  /// `MaterialApp.onUnknownRoute`: any route name without a handler shows
  /// the generic error state instead of throwing in release builds.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      AppPageRoute(builder: (_) => const ErrorStateScreen());

  /// True when the app shell may be shown; false routes to onboarding.
  static bool canEnterShell(BuildContext context) => context.read<AuthCubit>().state.canEnterShell;

  /// Guarded push of the main shell: unauthenticated/onboarding sessions are
  /// bounced to the marketing onboarding flow instead of an empty shell.
  static Future<T?> pushShell<T extends Object?>(BuildContext context) {
    if (!canEnterShell(context)) return pushOnboarding(context);
    return Navigator.of(context).pushAndRemoveUntil<T>(
      AppPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  /// Root-reset to the onboarding flow (pre-activation state).
  static Future<T?> pushOnboarding<T extends Object?>(BuildContext context) =>
      Navigator.of(context).pushAndRemoveUntil<T>(
        AppPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
}
