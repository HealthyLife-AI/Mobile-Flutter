import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/appointment_entities.dart';
import '../../domain/entities/nutritionist_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/appointments/appointments_cubit.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../widgets/detail_hero_header.dart';
import '../widgets/directional_icon.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/load_error_view.dart';
import '../widgets/segmented_sliding_tabs.dart';
import '../widgets/sticky_bottom_bar.dart';

/// Schedule / Accountability Calls: the patient's upcoming or past appointments
/// from `GET /me/appointments` (API guide 12.4). DetailHeroHeader (primaryDark
/// panel and white sheet), SegmentedSlidingTabs (Upcoming/Past), sticky bottom
/// bar.
///
/// Booking is not here yet (12.1 to 12.3). The button does nothing until the
/// booking flow is designed.
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

/// The line shown after "With": the nutritionist's name, then the specialty
/// when the server gives one.
String _nutritionistLine(NutritionistProfile profile) {
  final specialty = profile.specialty;
  return specialty == null ? profile.name : '${profile.name} — $specialty';
}

class _ScheduleCallsView extends StatelessWidget {
  const _ScheduleCallsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AppointmentsCubit>();
    final nutritionist = context.watch<NutritionistCubit>().state.dataOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DetailHeroHeader(
                  topPanelHeight: 180,
                  topPanelChild: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                              directionalIcon(context,
                                  rtl: Icons.arrow_forward_rounded,
                                  ltr: Icons.arrow_back_rounded),
                              color: Colors.white)),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.profileAppointments,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          if (nutritionist != null) ...[
                            const SizedBox(height: 6),
                            Text(
                                context.l10n.callsWithNutritionist(
                                    _nutritionistLine(nutritionist)),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ],
                      ),
                    ],
                  ),
                  sheetChild: BlocBuilder<AppointmentsCubit,
                      AsyncState<List<Appointment>>>(
                    builder: (context, state) {
                      final scope = cubit.scope;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedSlidingTabs(
                            tabs: [l10n.callsPast, l10n.callsUpcoming],
                            selectedIndex:
                                scope == AppointmentScope.upcoming ? 1 : 0,
                            onChanged: (i) => cubit.load(
                              scope: i == 1
                                  ? AppointmentScope.upcoming
                                  : AppointmentScope.past,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _AppointmentsBody(state: state, scope: scope),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          StickyBottomBar(
            left: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.chipInactiveBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: const Icon(Icons.calendar_month_rounded,
                  color: AppColors.primary),
            ),
            right: GradientCtaButton(
                label: l10n.callsBookNew,
                icon: Icons.add_rounded,
                onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

/// The list for the tab on screen: a spinner while it loads, the message and a
/// retry when it failed, a line when there is nothing, otherwise the cards.
class _AppointmentsBody extends StatelessWidget {
  const _AppointmentsBody({required this.state, required this.scope});

  final AsyncState<List<Appointment>> state;
  final AppointmentScope scope;

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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Text(
          scope == AppointmentScope.upcoming
              ? l10n.callsEmptyUpcoming
              : l10n.callsEmptyPast,
          textAlign: TextAlign.center,
          style: AppTextStyles.secondary,
        ),
      );
    }
    return Column(
      children: [for (final item in items) _AppointmentCard(item: item)],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.item});

  final Appointment item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = item.startsAt;
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(start));
    final channel = _channelLabel(l10n, item.channel);
    final caption = [
      numericDate(start),
      time,
      if (channel != null) channel,
    ].join(' • ');
    final status = _status(l10n, item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                gradient: AppColors.primaryDarkGradient,
                borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text(context.localizeDigits('${start.day}'),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_typeTitle(l10n, item.type),
                    textAlign: TextAlign.start, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(context.localizeDigits(caption),
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text(status.label,
                  style: AppTextStyles.caption.copyWith(color: status.color)),
            ),
        ],
      ),
    );
  }

  static String _typeTitle(AppLocalizations l10n, AppointmentType type) =>
      switch (type) {
        AppointmentType.followUp => l10n.callsTypeFollowUp,
        AppointmentType.resultsReview => l10n.callsResultsReview,
        AppointmentType.quickConsult => l10n.callsTypeQuickConsult,
        AppointmentType.unknown => l10n.callsTypeOther,
      };

  /// Null for a channel this version does not know. The caption then leaves it
  /// out.
  static String? _channelLabel(
          AppLocalizations l10n, AppointmentChannel channel) =>
      switch (channel) {
        AppointmentChannel.whatsapp => l10n.callsChannelWhatsapp,
        AppointmentChannel.phone => l10n.callsChannelPhone,
        AppointmentChannel.video => l10n.callsChannelVideo,
        AppointmentChannel.unknown => null,
      };

  /// The pill's label and colour. Null for a status this version does not
  /// know, so no pill is shown.
  static ({String label, Color color})? _status(
          AppLocalizations l10n, AppointmentStatus status) =>
      switch (status) {
        AppointmentStatus.booked => (
            label: l10n.callsStatusBooked,
            color: AppColors.primary
          ),
        AppointmentStatus.cancelled => (
            label: l10n.callsStatusCancelled,
            color: AppColors.accentOrange
          ),
        AppointmentStatus.completed => (
            label: l10n.callsCompleted,
            color: AppColors.accentGreen
          ),
        AppointmentStatus.noShow => (
            label: l10n.callsStatusNoShow,
            color: AppColors.accentOrange
          ),
        AppointmentStatus.unknown => null,
      };
}
