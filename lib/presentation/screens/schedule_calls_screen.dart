import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/appointment_entities.dart';
import '../../domain/entities/nutritionist_entities.dart';
import '../bloc/appointments/appointments_cubit.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/confirm_action_sheet.dart';
import '../widgets/external_link.dart';
import '../widgets/load_error_view.dart';
import '../widgets/segmented_sliding_tabs.dart';
import '../widgets/spec_ui.dart';
import 'book_appointment_screen.dart';

import '../../l10n/l10n.dart';

/// "مواعيدي": the patient's upcoming or past appointments from
/// `GET /me/appointments` (API guide 12.4). The next one gets its own card
/// with the date, the time and how soon it is, and the buttons that change,
/// cancel or join it (12.3).
///
/// One upcoming appointment is allowed at a time (12.2), so the bottom button
/// books one only while the upcoming list has none.
class ScheduleCallsScreen extends StatelessWidget {
  const ScheduleCallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppointmentsCubit(deps.appointments)..load(),
        ),
        BlocProvider(
          create: (_) => NutritionistCubit(deps.nutritionist)..load(),
        ),
      ],
      child: const _ScheduleCallsView(),
    );
  }
}

class _ScheduleCallsView extends StatelessWidget {
  const _ScheduleCallsView();

  /// Opens the booking screen, or the one that moves [moving]. A saved
  /// appointment reads the list again.
  Future<void> _book(BuildContext context, {Appointment? moving}) async {
    final l10n = context.l10n;
    final cubit = context.read<AppointmentsCubit>();
    final saved = await Navigator.of(context).push<Appointment>(AppPageRoute(
      builder: (_) => BookAppointmentScreen(reschedule: moving),
    ));
    if (!context.mounted) return;
    await cubit.load(scope: AppointmentScope.upcoming);
    if (saved != null && context.mounted) {
      showSpecSnack(
          context, moving == null ? l10n.callsBooked : l10n.callsRescheduled);
    }
  }

  Future<void> _cancel(BuildContext context, Appointment item) async {
    final l10n = context.l10n;
    final cubit = context.read<AppointmentsCubit>();
    final confirmed = await ConfirmActionSheet.show(
      context,
      icon: Icons.event_busy_outlined,
      title: l10n.callsCancelConfirmTitle,
      message: l10n.callsCancelConfirmBody,
      confirmLabel: l10n.callsCancelAction,
      cancelLabel: l10n.callsKeep,
    );
    if (confirmed != true || !context.mounted) return;
    final failure = await cubit.cancel(item);
    if (!context.mounted) return;
    if (failure == null) {
      showSpecSnack(context, l10n.callsCancelled);
    } else {
      await showAppointmentFailure(context, failure);
      // A closed appointment is out of date on screen.
      if (context.mounted) unawaited(cubit.load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AppointmentsCubit>();
    final nutritionist = context.watch<NutritionistCubit>().state.dataOrNull;
    final upcoming = cubit.scope == AppointmentScope.upcoming
        ? context.watch<AppointmentsCubit>().state
        : null;
    final now = DateTime.now();
    final canBook = upcoming is AsyncSuccess<List<Appointment>> &&
        !upcoming.data.any((item) => item.isOpenAt(now));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.profileAppointments),
      body: SafeArea(
        child: BlocBuilder<AppointmentsCubit, AsyncState<List<Appointment>>>(
          builder: (context, state) {
            final scope = cubit.scope;
            final items = state.dataOrNull;
            final next = scope == AppointmentScope.upcoming &&
                    items != null &&
                    items.isNotEmpty
                ? items.first
                : null;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => cubit.load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  if (nutritionist != null) ...[
                    _NutritionistRow(profile: nutritionist),
                    const SizedBox(height: 14),
                  ],
                  SegmentedSlidingTabs(
                    tabs: [l10n.callsPast, l10n.callsUpcoming],
                    selectedIndex: scope == AppointmentScope.upcoming ? 1 : 0,
                    onChanged: (i) => cubit.load(
                      scope: i == 1
                          ? AppointmentScope.upcoming
                          : AppointmentScope.past,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (next != null) ...[
                    _NextAppointmentCard(
                      item: next,
                      onChange: () => _book(context, moving: next),
                      onCancel: () => _cancel(context, next),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _AppointmentsBody(
                    state: state,
                    scope: scope,
                    skipFirst: next != null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: !canBook
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SpecPrimaryButton(
                label: l10n.callsBookNew,
                icon: Icons.add_rounded,
                onPressed: () => _book(context),
              ),
            ),
    );
  }
}

class _NutritionistRow extends StatelessWidget {
  const _NutritionistRow({required this.profile});

  final NutritionistProfile profile;

  @override
  Widget build(BuildContext context) {
    final specialty = profile.specialty;
    return SpecCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SpecCardHeader(
        icon: Icons.verified_user_outlined,
        title: context.l10n.callsWithNutritionist(profile.name),
        subtitle: specialty,
      ),
    );
  }
}

/// The soonest upcoming appointment: date, time, channel and how soon, and
/// while it is still on, the buttons that change or cancel it (12.3) and join
/// a video call (12.4).
class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard(
      {required this.item, required this.onChange, required this.onCancel});

  final Appointment item;
  final VoidCallback onChange;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = item.startsAt.toLocal();
    final open = item.isOpenAt(DateTime.now());
    final link = item.meetingLink == null
        ? null
        : Uri.tryParse(item.meetingLink!);
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill)),
      visualDensity: VisualDensity.compact,
    );
    final days = calendarDaysBetween(DateTime.now(), start);
    final when = days <= 0
        ? l10n.commonToday
        : l10n.scheduleInDays(days, context.localizeDigits(days));
    final time = context.localizeDigits(MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(start)));
    final channel = _channelLabel(l10n, item.channel);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.callsNextTitle,
                  style: AppTextStyles.secondary.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(when,
                    style:
                        AppTextStyles.pillLabel.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(fullDayLabel(context, start),
              style:
                  AppTextStyles.sectionHeading.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _HeroFact(icon: Icons.schedule_rounded, text: time),
              _HeroFact(
                  icon: Icons.medical_services_outlined,
                  text: appointmentTypeTitle(l10n, item.type)),
              if (channel != null)
                _HeroFact(
                    icon: appointmentChannelIcon(item.channel), text: channel),
            ],
          ),
          if (open) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (link != null && item.channel == AppointmentChannel.video)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryInk,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => openExternalLink(context, link),
                    icon: const Icon(Icons.videocam_outlined, size: 18),
                    label: Text(l10n.callsJoinCall),
                  ),
                // A kind this version does not know has no times to move to.
                if (item.type != AppointmentType.unknown)
                  OutlinedButton(
                    style: buttonStyle,
                    onPressed: onChange,
                    child: Text(l10n.callsChangeTitle),
                  ),
                OutlinedButton(
                  style: buttonStyle,
                  onPressed: onCancel,
                  child: Text(l10n.callsCancelAction),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroFact extends StatelessWidget {
  const _HeroFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 5),
        Text(text,
            style: AppTextStyles.secondary
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// The tab's list: a spinner while it loads, the message and a retry when it
/// failed, an empty state when there is nothing, otherwise the cards.
class _AppointmentsBody extends StatelessWidget {
  const _AppointmentsBody(
      {required this.state, required this.scope, required this.skipFirst});

  final AsyncState<List<Appointment>> state;
  final AppointmentScope scope;

  /// The first one already has its own card above.
  final bool skipFirst;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = state.dataOrNull;
    if (items == null) {
      if (state case AsyncError<List<Appointment>>(:final failure)) {
        return LoadErrorView(
          failure: failure,
          onRetry: () => context.read<AppointmentsCubit>().load(),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (items.isEmpty) {
      return SpecEmptyState(
        icon: Icons.event_available_outlined,
        title: scope == AppointmentScope.upcoming
            ? l10n.callsEmptyUpcoming
            : l10n.callsEmptyPast,
      );
    }
    final rest = skipFirst ? items.skip(1).toList() : items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (skipFirst && rest.isNotEmpty) ...[
          Text(l10n.callsLaterTitle, style: AppTextStyles.cardTitle),
          const SizedBox(height: 10),
        ],
        for (final item in rest)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AppointmentCard(item: item),
          ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.item});

  final Appointment item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = item.startsAt.toLocal();
    final material = MaterialLocalizations.of(context);
    final time = material.formatTimeOfDay(TimeOfDay.fromDateTime(start));
    final channel = _channelLabel(l10n, item.channel);
    final caption = [
      fullDayLabel(context, start),
      context.localizeDigits(time),
      if (channel != null) channel,
    ].join(' • ');
    final status = _status(l10n, item.status);
    final dim = item.status == AppointmentStatus.cancelled ||
        item.status == AppointmentStatus.noShow;

    final card = SpecCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.panel),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.localizeDigits('${start.day}'),
                    style: AppTextStyles.metricMedium
                        .copyWith(color: AppColors.primaryInk, height: 1.1)),
                Text(
                    DateFormat.MMM(Localizations.localeOf(context).toString())
                        .format(start),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style:
                        AppTextStyles.tiny.copyWith(color: AppColors.primaryInk)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointmentTypeTitle(l10n, item.type),
                    style: AppTextStyles.cardTitle),
                const SizedBox(height: 2),
                Text(caption,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (status != null) ...[
            const SizedBox(width: 8),
            StatusPill(status.label, tone: status.tone),
          ],
        ],
      ),
    );
    return dim ? Opacity(opacity: 0.75, child: card) : card;
  }
}

/// Null for a channel this version does not know: it is then left out.
String? _channelLabel(AppLocalizations l10n, AppointmentChannel channel) =>
    channel == AppointmentChannel.unknown
        ? null
        : appointmentChannelLabel(l10n, channel);

/// The pill's label and tone. Null for a status this version does not know,
/// so no pill is shown.
({String label, PillTone tone})? _status(
        AppLocalizations l10n, AppointmentStatus status) =>
    switch (status) {
      AppointmentStatus.booked => (
          label: l10n.callsStatusBooked,
          tone: PillTone.primary
        ),
      AppointmentStatus.cancelled => (
          label: l10n.callsStatusCancelled,
          tone: PillTone.danger
        ),
      AppointmentStatus.completed => (
          label: l10n.callsCompleted,
          tone: PillTone.success
        ),
      AppointmentStatus.noShow => (
          label: l10n.callsStatusNoShow,
          tone: PillTone.warning
        ),
      AppointmentStatus.unknown => null,
    };
