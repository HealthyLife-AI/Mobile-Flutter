import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/app_dependencies.dart';
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
import '../widgets/load_error_view.dart';
import '../widgets/segmented_sliding_tabs.dart';
import '../widgets/spec_ui.dart';

import '../../l10n/l10n.dart';

/// "مواعيدي": the patient's upcoming or past appointments from
/// `GET /me/appointments` (API guide 12.4). The next one gets its own card
/// with the date, the time and how soon it is.
///
/// Booking in the app is not on the API yet (12.1 to 12.3), so the bottom
/// button asks the nutritionist for a time on WhatsApp, and is left out when
/// the profile has no number.
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

  Future<void> _ask(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      showSpecSnack(context, context.l10n.linkCouldNotOpen, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AppointmentsCubit>();
    final nutritionist = context.watch<NutritionistCubit>().state.dataOrNull;
    final whatsapp = nutritionist?.whatsappUri;
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
                    _NextAppointmentCard(item: next),
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
      bottomNavigationBar: whatsapp == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SpecPrimaryButton(
                label: l10n.callsAskForAppointment,
                icon: Icons.chat_outlined,
                onPressed: () => _ask(context, whatsapp),
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

/// The soonest upcoming appointment: date, time, channel and how soon.
class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.item});

  final Appointment item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = item.startsAt.toLocal();
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
                  text: _typeTitle(l10n, item.type)),
              if (channel != null)
                _HeroFact(icon: _channelIcon(item.channel), text: channel),
            ],
          ),
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
          message: loadFailureMessage(context, failure),
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
                        .copyWith(color: AppColors.primary, height: 1.1)),
                Text(
                    DateFormat.MMM(Localizations.localeOf(context).toString())
                        .format(start),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style:
                        AppTextStyles.tiny.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_typeTitle(l10n, item.type),
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

String _typeTitle(AppLocalizations l10n, AppointmentType type) =>
    switch (type) {
      AppointmentType.followUp => l10n.callsTypeFollowUp,
      AppointmentType.resultsReview => l10n.callsResultsReview,
      AppointmentType.quickConsult => l10n.callsTypeQuickConsult,
      AppointmentType.unknown => l10n.callsTypeOther,
    };

/// Null for a channel this version does not know: it is then left out.
String? _channelLabel(AppLocalizations l10n, AppointmentChannel channel) =>
    switch (channel) {
      AppointmentChannel.whatsapp => l10n.callsChannelWhatsapp,
      AppointmentChannel.phone => l10n.callsChannelPhone,
      AppointmentChannel.video => l10n.callsChannelVideo,
      AppointmentChannel.unknown => null,
    };

IconData _channelIcon(AppointmentChannel channel) => switch (channel) {
      AppointmentChannel.whatsapp => Icons.chat_outlined,
      AppointmentChannel.phone => Icons.call_outlined,
      AppointmentChannel.video => Icons.videocam_outlined,
      AppointmentChannel.unknown => Icons.event_outlined,
    };

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
