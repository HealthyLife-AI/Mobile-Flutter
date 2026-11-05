import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../date_labels.dart';
import '../patient_feature_navigation.dart';
import 'spec_ui.dart';

/// Home, at the top: "يومك اليوم" from `GET /me/today`.
///
/// No calorie number anywhere. Without a plan the meal and activity lists are
/// hidden and the reminders and the sentence stay. The green frame shows
/// only with a `motivation_ar`. Hidden until the first answer arrives.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final today = context.watch<TodayCubit>().state.dataOrNull;
    if (today == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final motivation = today.motivation;
    final reminders = [
      for (final r in today.reminders)
        if (r.type != TodayReminderType.unknown) r,
    ];
    final hasPlan = today.meals.isNotEmpty || today.activities.isNotEmpty;
    if (!hasPlan && motivation == null && reminders.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SpecColumn(
        children: [
          SpecCard(
            child: SpecColumn(
              gap: 10,
              children: [
                SpecCardHeader(
                  icon: Icons.wb_sunny_outlined,
                  iconColor: const Color(0xFFB45309),
                  iconBackground: const Color(0x26F59E0B),
                  title: l10n.todayTitle,
                  subtitle: fullDayLabel(context, today.date),
                ),
                if (today.meals.isNotEmpty)
                  SpecPanel(
                    child: SpecColumn(
                      gap: 6,
                      children: [
                        for (final meal in today.meals)
                          Row(
                            children: [
                              Expanded(
                                  child: Text(meal.name,
                                      style: AppTextStyles.body)),
                              if (meal.window != null)
                                Text(meal.window!,
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary)),
                            ],
                          ),
                      ],
                    ),
                  ),
                for (final activity in today.activities)
                  Row(
                    children: [
                      const Icon(Icons.directions_walk_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            activity.title,
                            if (activity.durationMinutes case final m?)
                              l10n.durationMinutes(
                                  m, context.localizeDigits(m)),
                            if (activity.timesPerDay case final t?)
                              l10n.timesPerDay(t, context.localizeDigits(t)),
                          ].join(' • '),
                          style: AppTextStyles.secondary
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                if (motivation != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(AppRadius.panel),
                    ),
                    child: Text(motivation,
                        style: AppTextStyles.secondary.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            height: 1.5)),
                  ),
              ],
            ),
          ),
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
