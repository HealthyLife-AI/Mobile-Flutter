import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/screens/health_record_screen.dart';
import '../../presentation/screens/log_meal_intro_screen.dart';
import '../../presentation/screens/notifications_center_screen.dart';
import '../../presentation/screens/reviews_screen.dart';
import '../../presentation/screens/schedule_calls_screen.dart';
import '../../presentation/screens/weekly_plan_screen.dart';
import 'app_navigator.dart';
import 'app_page_route.dart';
import 'push_destination.dart';
import 'push_tap_router.dart';

/// The gate for push taps, from the auth state. A tap opens only when the
/// shell is the root, so the splash and the sign-in flow are never covered.
PushGate pushGateFor(AuthState state) {
  if (state.launching) return PushGate.waiting;
  return state.canEnterShell ? PushGate.open : PushGate.closed;
}

/// Opens [destination] on the app's root navigator. Home is the shell at the
/// bottom of the stack, so it pops back to that. [reviewId] is the note to show
/// first on the notes screen; other screens ignore it.
void openPushDestination(PushDestination destination, {String? reviewId}) {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return;
  switch (destination) {
    case PushDestination.home:
      navigator.popUntil((route) => route.isFirst);
      break;
    case PushDestination.myPlan:
      _push(navigator, const WeeklyPlanScreen());
      break;
    case PushDestination.healthProfile:
      _push(navigator, const HealthRecordScreen());
      break;
    case PushDestination.appointments:
      _push(navigator, const ScheduleCallsScreen());
      break;
    case PushDestination.logMeal:
      _push(navigator, const LogMealIntroScreen());
      break;
    case PushDestination.notes:
      _push(navigator, ReviewsScreen(focusReviewId: reviewId));
      break;
    case PushDestination.inbox:
      _push(navigator, const NotificationsCenterScreen());
      break;
  }
}

void _push(NavigatorState navigator, Widget screen) {
  navigator.push(AppPageRoute(builder: (_) => screen));
}

/// Draws a push notice as a snackbar over the current screen. Its action
/// opens the notification (API guide 10.4).
void showPushNotice({
  required String title,
  required String body,
  required void Function() onOpen,
}) {
  final context = appNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final text = [title, body].where((part) => part.isNotEmpty).join('\n');
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: context.l10n.commonViewDetails,
          onPressed: onOpen,
        ),
      ),
    );
}
