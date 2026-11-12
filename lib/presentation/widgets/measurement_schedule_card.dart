import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/patient_care_entities.dart';
import '../../domain/measurement_schedule.dart';
import '../../l10n/l10n.dart';
import '../bloc/measurements/measurements_cubit.dart';
import '../bloc/patient_features_cubits.dart';
import '../date_labels.dart';
import '../screens/new_measurement_screen.dart';
import 'spec_ui.dart';

/// `interval_days` in words: 7 "كل أسبوع", 14 "كل أسبوعين", 30 "كل شهر",
/// otherwise "كل N يومًا".
String measurementIntervalLabel(
        AppLocalizations l10n, int days, String Function(Object) digits) =>
    switch (days) {
      7 => l10n.scheduleWeekly,
      14 => l10n.scheduleBiweekly,
      30 => l10n.scheduleMonthly,
      _ => l10n.scheduleEveryDays(days, digits(days)),
    };

/// When the latest reading was taken, if the patient has one.
DateTime? _lastReadingDay(BuildContext context) {
  final snapshot = context.watch<MeasurementsCubit>().state.snapshot;
  return snapshot == null ? null : latestReading(snapshot)?.recordedAt;
}

/// Home: "حان موعد تسجيل قياساتك", only when `next_due_on` is today or
/// earlier. Hidden without a schedule.
class MeasurementDueReminder extends StatelessWidget {
  const MeasurementDueReminder({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<MeasurementScheduleCubit>().state.dataOrNull;
    if (schedule == null || !schedule.isDue(DateTime.now())) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final last = _lastReadingDay(context);
    final interval = measurementIntervalLabel(
        l10n, schedule.intervalDays, context.localizeDigits);
    final ago = last == null ? null : calendarDaysBetween(last, DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SpecCard(
        color: AppColors.warningCardBg,
        borderColor: AppColors.warningCardBorder,
        child: SpecColumn(
          children: [
            SpecCardHeader(
              icon: Icons.event_repeat_rounded,
              iconColor: AppColors.warning,
              title: l10n.scheduleDueTitle,
              subtitle: [
                l10n.scheduleYourInterval(interval),
                if (ago != null)
                  l10n.scheduleLastAgo(ago, context.localizeDigits(ago)),
              ].join(' • '),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SpecPrimaryButton(
                expand: false,
                label: l10n.scheduleRecordNow,
                onPressed: () => openMeasurementEntry(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openMeasurementEntry(BuildContext context) {
  Navigator.of(context).push(AppPageRoute(
    builder: (_) => MeasurementEntryScreen(
      onSaved: () => context.read<MeasurementsCubit>().load(),
    ),
  ));
}

/// The measurement screens: "موعد قياسك القادم" ahead of time, "اليوم" on
/// the day, and a red "قياسك متأخر" card once late. Hidden without a
/// schedule.
class MeasurementScheduleCard extends StatelessWidget {
  const MeasurementScheduleCard({super.key, this.padding = EdgeInsets.zero});

  /// Around the card, only while it is shown.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<MeasurementScheduleCubit>().state.dataOrNull;
    if (schedule == null) return const SizedBox.shrink();
    final days = schedule.daysUntil(DateTime.now());
    return Padding(
      padding: padding,
      child: days < 0
          ? _LateCard(schedule: schedule, daysLate: -days)
          : _UpcomingCard(
              schedule: schedule, days: days, last: _lastReadingDay(context)),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard(
      {required this.schedule, required this.days, required this.last});

  final MeasurementSchedule schedule;
  final int days;
  final DateTime? last;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final interval = measurementIntervalLabel(
        l10n, schedule.intervalDays, context.localizeDigits);
    return SpecCard(
      highlighted: true,
      child: SpecColumn(
        children: [
          SpecCardHeader(
            icon: Icons.event_repeat_rounded,
            title:
                days == 0 ? l10n.scheduleDueTodayTitle : l10n.scheduleNextTitle,
            subtitle: l10n.scheduleSetBy(interval),
            trailing: days == 0
                ? StatusPill(l10n.commonToday, tone: PillTone.warning)
                : StatusPill(
                    l10n.scheduleInDays(days, context.localizeDigits(days)),
                    tone: PillTone.success),
          ),
          SpecPanel(
            child: Column(
              children: [
                Text(fullDayLabel(context, schedule.nextDueOn),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.metricMedium
                        .copyWith(color: AppColors.primaryInk, fontSize: 20)),
                if (last != null)
                  Text(l10n.scheduleLastReading(shortDateLabel(context, last!)),
                      style: AppTextStyles.tiny),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LateCard extends StatelessWidget {
  const _LateCard({required this.schedule, required this.daysLate});

  final MeasurementSchedule schedule;
  final int daysLate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SpecCard(
      color: AppColors.dangerBg,
      borderColor: AppColors.danger.withValues(alpha: 0.4),
      child: SpecColumn(
        children: [
          SpecCardHeader(
            icon: Icons.event_busy_rounded,
            iconColor: AppColors.danger,
            title: l10n.scheduleLateTitle(
                daysLate, context.localizeDigits(daysLate)),
            subtitle:
                l10n.scheduleWasDue(fullDayLabel(context, schedule.nextDueOn)),
          ),
          Text(l10n.scheduleLateBody,
              style: AppTextStyles.secondary
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
