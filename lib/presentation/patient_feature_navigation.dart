import 'package:flutter/material.dart';

import '../core/navigation/app_page_route.dart';
import '../domain/entities/engagement_entities.dart';
import 'screens/checkin_screen.dart';
import 'screens/food_preferences_screen.dart';
import 'screens/posts_screens.dart';
import 'screens/schedule_calls_screen.dart';
import 'screens/wellbeing_screen.dart';
import 'widgets/measurement_schedule_card.dart';
import 'widgets/quick_contact_card.dart';

/// Where each screen of the patient-app spec opens from: home reminders,
/// pushes and the profile all go through these, so the routes never drift.

void _push(BuildContext context, Widget screen) =>
    Navigator.of(context).push(AppPageRoute(builder: (_) => screen));

void openCheckin(BuildContext context) => _push(context, const CheckinScreen());

void openPosts(BuildContext context) => _push(context, const PostsScreen());

void openPost(BuildContext context, int id) =>
    _push(context, PostDetailScreen(postId: id));

void openWellbeing(BuildContext context) =>
    _push(context, const WellbeingScreen());

void openFoodPreferences(BuildContext context) =>
    _push(context, const FoodPreferencesScreen());

/// A "today" reminder's button: measurement → measurements, check-in → the
/// questionnaire, quick request → my requests, appointment → appointments,
/// posts → advice, wellbeing → sleep and mood.
void openReminder(BuildContext context, TodayReminderType type) {
  switch (type) {
    case TodayReminderType.measurement:
      openMeasurementEntry(context);
    case TodayReminderType.checkin:
      openCheckin(context);
    case TodayReminderType.quickRequest:
      openMyRequests(context);
    case TodayReminderType.appointment:
      _push(context, const ScheduleCallsScreen());
    case TodayReminderType.posts:
      openPosts(context);
    case TodayReminderType.wellbeing:
      openWellbeing(context);
    case TodayReminderType.unknown:
      break;
  }
}
