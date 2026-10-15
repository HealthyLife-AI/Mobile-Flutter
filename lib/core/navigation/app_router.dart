import 'package:flutter/material.dart';

import '../../domain/entities/auth_entities.dart';
import '../../presentation/app_shell.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/screens/error_state_screen.dart';
import '../../presentation/screens/follow_up_ended_screen.dart';
import '../../presentation/screens/health_data_consent_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/onboarding_measurements_screen.dart';
import 'app_navigator.dart';
import 'app_page_route.dart';

/// Central navigation policy for the patient's session.
///
/// The screen for each [AuthStatus] is defined in exactly one place
/// ([destinationFor]). When the status changes, [showFor] replaces the whole
/// stack, so a patient can never end up behind a screen their state forbids.
/// Pushes between screens stay local to those screens.
abstract final class AppRouter {
  AppRouter._();

  /// `MaterialApp.onUnknownRoute`: an unknown route name shows the generic
  /// error state instead of throwing in release builds.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      AppPageRoute(builder: (_) => const ErrorStateScreen());

  /// The screen for [state], or null while start-up has not finished.
  static Widget? destinationFor(AuthState state) => switch (state.status) {
        AuthStatus.unknown => null,
        AuthStatus.signedOut => const LoginScreen(),
        AuthStatus.consentRequired => const HealthDataConsentScreen(),
        AuthStatus.onboarding => const OnboardingMeasurementsScreen(),
        AuthStatus.ready => const AppShell(),
        AuthStatus.followUpEnded => FollowUpEndedScreen(
            followUp: state.followUp ?? FollowUpEnded.fallback,
          ),
      };

  /// Used as the `listenWhen` of the app-wide auth listener. Status changes
  /// are ignored while the splash runs, because the splash picks the first screen.
  static bool shouldNavigate(AuthState previous, AuthState current) =>
      !current.launching && previous.status != current.status;

  /// Replaces the whole navigation stack with the screen for [state].
  static void showFor(AuthState state) {
    final screen = destinationFor(state);
    final navigator = appNavigatorKey.currentState;
    if (screen == null || navigator == null) return;
    navigator.pushAndRemoveUntil(
      AppPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}
