import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../patient_feature_navigation.dart';
import 'spec_ui.dart';

/// Home: the reminders from `GET /me/today` (a questionnaire, a weigh-in, a
/// reply, a new post…), one card each, below today's meals.
///
/// The rest of "يومك اليوم" lives in the home's day card: the nutritionist's
/// sentence and the day's activities. Its list of meals is not repeated, since
/// the meals are right there. Hidden until the first answer arrives.
class TodayReminders extends StatelessWidget {
  const TodayReminders({super.key});

  @override
  Widget build(BuildContext context) {
    final today = context.watch<TodayCubit>().state.dataOrNull;
    if (today == null) return const SizedBox.shrink();
    final reminders = [
      for (final r in today.reminders)
        if (r.type != TodayReminderType.unknown) r,
    ];
    if (reminders.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SpecColumn(
        children: [
          for (final reminder in reminders) _ReminderCard(reminder: reminder),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});

  final TodayReminder reminder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, action) = switch (reminder.type) {
      TodayReminderType.measurement => (
          Icons.event_repeat_rounded,
          l10n.reminderActionMeasure
        ),
      TodayReminderType.checkin => (
          Icons.assignment_outlined,
          l10n.reminderActionStart
        ),
      TodayReminderType.quickRequest => (
          Icons.forum_outlined,
          l10n.myRequestsLink
        ),
      TodayReminderType.appointment => (
          Icons.event_available_rounded,
          l10n.reminderActionAppointments
        ),
      TodayReminderType.posts => (
          Icons.lightbulb_outline_rounded,
          l10n.reminderActionPosts
        ),
      TodayReminderType.wellbeing => (
          Icons.bedtime_outlined,
          l10n.reminderActionLog
        ),
      TodayReminderType.unknown => (Icons.notifications_none_rounded, ''),
    };
    return SpecCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: () => openReminder(context, reminder.type),
      child: Row(
        children: [
          SpecIconTile(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(reminder.text,
                style: AppTextStyles.body.copyWith(height: 1.4)),
          ),
          const SizedBox(width: 8),
          SpecSecondaryButton(
            label: action,
            expand: false,
            compact: true,
            onPressed: () => openReminder(context, reminder.type),
          ),
        ],
      ),
    );
  }
}
