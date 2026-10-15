import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../domain/weight_range.dart';
import '../../l10n/l10n.dart';
import '../bloc/measurements/measurements_cubit.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/load_error_view.dart';
import '../widgets/segmented_sliding_tabs.dart';
import '../widgets/weight_trend_chart.dart';
import 'new_measurement_screen.dart';

/// Weight and body measurements (API guide 7.2): the current weight and its
/// change, a trend chart that marks clinic readings, a circumference grid and
/// the logging count. The readings come from [MeasurementsCubit].
class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MeasurementsCubit>(
          create: (context) {
            final deps = context.read<AppDependencies>();
            return MeasurementsCubit(deps.measurement)..load();
          },
        ),
        BlocProvider<NutritionistCubit>(
          create: (context) =>
              NutritionistCubit(context.read<AppDependencies>().nutritionist)
                ..load(),
        ),
      ],
      child: const _MeasurementsView(),
    );
  }
}

class _MeasurementsView extends StatefulWidget {
  const _MeasurementsView();

  @override
  State<_MeasurementsView> createState() => _MeasurementsViewState();
}

class _MeasurementsViewState extends State<_MeasurementsView> {
  // الكل | 30 يوم | 90 يوم. The chart is filtered by this range.
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.measurementsTitle),
      body: BlocBuilder<MeasurementsCubit, MeasurementsState>(
        builder: (context, state) {
          final snapshot = state.snapshot;
          if (snapshot != null) return _content(context, snapshot);
          if (state.status == MeasurementsStatus.error) {
            return LoadErrorView(
              message: loadFailureMessage(context, state.failure),
              onRetry: () => context.read<MeasurementsCubit>().load(),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _content(BuildContext context, MeasurementSnapshot snapshot) {
    final l10n = context.l10n;
    final nutritionist = context.watch<NutritionistCubit>().state.dataOrNull;
    final current = snapshot.currentWeight;
    final previous = snapshot.previousWeight;
    final double? delta =
        current != null && previous != null ? current - previous : null;
    final bool clinicLatest = snapshot.weightTrend.isNotEmpty &&
        snapshot.weightTrend.last.clinicVerified;
    // Only said when the weight has barely moved since the previous reading.
    final bool steady = delta != null && delta.abs() <= 0.5;
    final int? days = switch (_range) { 1 => 30, 2 => 90, _ => null };
    final points = weightPointsInRange(
      snapshot.weightTrend,
      days: days,
      now: DateTime.now(),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      children: [
        if (snapshot.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Text(l10n.measurementsNoReadingsYet,
                style: AppTextStyles.caption),
          ),
          const SizedBox(height: 18),
        ],
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textSecondary),
                const Spacer(),
                if (snapshot.weightTrend.isNotEmpty)
                  Text(
                      context.localizeDigits(
                          numericDate(snapshot.weightTrend.last.date)),
                      style: AppTextStyles.caption),
                const SizedBox(width: 6),
                Text(l10n.measurementsCurrentWeight,
                    style: AppTextStyles.cardTitle),
              ]),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      current == null
                          ? '—'
                          : context.localizeDigits(current.toStringAsFixed(1)),
                      style: AppTextStyles.metricLarge.copyWith(fontSize: 40)),
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.only(bottom: 6, start: 6),
                      child: Text(l10n.commonKgUnit,
                          style: AppTextStyles.secondary)),
                ],
              ),
              const SizedBox(height: 8),
              if (delta != null)
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                          delta < 0
                              ? Icons.trending_down_rounded
                              : Icons.trending_up_rounded,
                          size: 14,
                          color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                          l10n.measurementsDeltaVsLast(context
                              .localizeDigits(delta.abs().toStringAsFixed(1))),
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primary)),
                    ]),
                  ),
                ),
              const SizedBox(height: 12),
              if (clinicLatest)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.verified_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                      l10n.measurementsClinicVerified(
                          nutritionist?.gender ?? 'unknown',
                          nutritionist?.name ?? ''),
                      style: AppTextStyles.caption),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SegmentedSlidingTabs(tabs: [
          l10n.notificationCategoryAll,
          l10n.measurementsRange30,
          l10n.measurementsRange90
        ], selectedIndex: _range, onChanged: (i) => setState(() => _range = i)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                if (steady)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Text(l10n.measurementsSmoothStable,
                        style: AppTextStyles.caption),
                  ),
                const Spacer(),
                Text(l10n.measurementsTrend, style: AppTextStyles.cardTitle),
              ]),
              const SizedBox(height: 12),
              WeightTrendChart(points: points),
              if (points.isEmpty && snapshot.weightTrend.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.measurementsNoReadingsInRange,
                    style: AppTextStyles.caption),
              ],
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Legend(ring: true, label: l10n.measurementsClinicReading),
                const SizedBox(width: 18),
                _Legend(ring: false, label: l10n.measurementsHomeReading),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
                child: Row(children: [
                  const Icon(Icons.sync_alt_rounded,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.measurementsSyncNote,
                        textAlign: TextAlign.start,
                        style: AppTextStyles.caption),
                  ),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Spacer(),
          Text(l10n.measurementsBodyCircumference,
              style: AppTextStyles.sectionHeading),
        ]),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            for (final s in snapshot.circumference) _CircumferenceCard(stat: s)
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(l10n.measurementsOngoingStep,
                      style: AppTextStyles.caption),
                ),
                const Spacer(),
                Text(l10n.measurementsLoggingCommitment,
                    style: AppTextStyles.cardTitle),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          l10n.measurementsDaysThisWeek(context.localizeDigits(
                              '${snapshot.daysLoggedThisWeek}')),
                          textAlign: TextAlign.start,
                          style: AppTextStyles.body),
                      Text(
                          l10n.measurementsDaysThisMonth(context.localizeDigits(
                              '${snapshot.daysLoggedThisMonth}')),
                          textAlign: TextAlign.start,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.eco_rounded,
                    size: 16, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.measurementsRegularNote,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.caption,
                  ),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GradientCtaButton(
          label: l10n.measurementsLogDaily,
          icon: Icons.add_rounded,
          onPressed: () => Navigator.of(context).push(
            AppPageRoute(
              builder: (_) => MeasurementEntryScreen(
                onSaved: () => context.read<MeasurementsCubit>().load(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final bool ring;
  final String label;
  const _Legend({required this.ring, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (ring)
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2)),
        )
      else
        Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.caption),
    ]);
  }
}

/// A centimetre value in the active digits, without a trailing `.0`.
String _cmText(BuildContext context, double cm) => context.localizeDigits(
    cm == cm.roundToDouble() ? cm.round().toString() : cm.toStringAsFixed(1));

class _CircumferenceCard extends StatelessWidget {
  final CircumferenceStat stat;
  const _CircumferenceCard({required this.stat});

  /// The part's name in the patient's language.
  String _label(AppLocalizations l10n) => switch (stat.part) {
        CircumferencePart.waist => l10n.measurementWaist,
        CircumferencePart.hip => l10n.measurementHip,
        CircumferencePart.thigh => l10n.measurementThigh,
        CircumferencePart.arm => l10n.measurementArm,
      };

  @override
  Widget build(BuildContext context) {
    final double? delta = stat.deltaCm;
    final bool improving = (delta ?? 0) < 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Spacer(),
            Text(_label(context.l10n), style: AppTextStyles.caption),
            const SizedBox(width: 6),
            const Icon(Icons.straighten_rounded,
                size: 14, color: AppColors.textSecondary),
          ]),
          const SizedBox(height: 6),
          Text(context.l10n.commonCmValue(_cmText(context, stat.valueCm)),
              style: AppTextStyles.metricMedium),
          const SizedBox(height: 4),
          // No earlier reading of this part: there is nothing to compare with.
          if (delta == null)
            const SizedBox(height: 16)
          else if (delta == 0)
            Text(context.l10n.measurementsSteady, style: AppTextStyles.caption)
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(context.l10n.commonCmValue(_cmText(context, delta.abs())),
                  style: AppTextStyles.caption.copyWith(
                      color: improving
                          ? AppColors.primary
                          : AppColors.accentOrange)),
              const SizedBox(width: 4),
              Icon(
                  improving
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 12,
                  color:
                      improving ? AppColors.primary : AppColors.accentOrange),
            ]),
        ],
      ),
    );
  }
}
