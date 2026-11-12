import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../date_labels.dart';
import 'spec_ui.dart';

/// Progress: "متى بتوصل لهدفك؟" from `GET /me/goal-projection`. Hidden when
/// null (not enabled, or the goal is reached). No calorie number here.
class GoalProjectionCard extends StatelessWidget {
  const GoalProjectionCard({super.key, this.padding = EdgeInsets.zero});

  /// Around the card, only while it is shown.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final projection = context.watch<GoalProjectionCubit>().state.dataOrNull;
    if (projection == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final kg =
        context.localizeDigits(projection.remainingKg.toStringAsFixed(1));
    return Padding(
      padding: padding,
      child: SpecCard(
        child: SpecColumn(
          children: [
            SpecCardHeader(
              icon: Icons.track_changes_rounded,
              title: l10n.projectionTitle,
              subtitle: projection.direction == WeightDirection.gain
                  ? l10n.projectionRemainingGain(kg)
                  : l10n.projectionRemainingLoss(kg),
            ),
            for (final scenario in projection.scenarios)
              _ScenarioRow(
                  scenario: scenario,
                  current: scenario.level == projection.currentLevel),
            Text(l10n.projectionFaster,
                style: AppTextStyles.secondary.copyWith(
                    color: AppColors.success, fontWeight: FontWeight.w600)),
            if (projection.disclaimer.isNotEmpty)
              Text(projection.disclaimer, style: AppTextStyles.tiny),
          ],
        ),
      ),
    );
  }
}

class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({required this.scenario, required this.current});

  final ProjectionScenario scenario;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = switch (scenario.level) {
      ProjectionLevel.high => l10n.projectionHigh,
      ProjectionLevel.medium => l10n.projectionMedium,
      ProjectionLevel.low => l10n.projectionLow,
    };
    final weeks = scenario.weeks;
    final date = scenario.estimatedDate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: current
            ? AppColors.primaryTint
            : AppColors.panel.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border:
            current ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(label,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
                if (current)
                  StatusPill(l10n.projectionYourLevel, tone: PillTone.solid),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!scenario.reachable || weeks == null)
            Flexible(
              child: Text(l10n.projectionHard,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.secondary
                      .copyWith(color: AppColors.warning)),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.weeksCount(weeks, context.localizeDigits(weeks)),
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryInk, fontWeight: FontWeight.w700)),
                if (date != null)
                  Text(l10n.projectionAbout(shortDateLabel(context, date)),
                      style: AppTextStyles.tiny),
              ],
            ),
        ],
      ),
    );
  }
}

/// Progress, under the weight chart: "تفسير تغيّر الوزن" from
/// `GET /me/weight-insight`. Hidden until the nutritionist enables it.
/// `text_ar` is shown exactly as sent, with no number added.
class WeightInsightCard extends StatelessWidget {
  const WeightInsightCard({super.key, this.padding = EdgeInsets.zero});

  /// Around the card, only while it is shown.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final insight = context.watch<WeightInsightCubit>().state.dataOrNull;
    if (insight == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final gainGoal = context.select<GoalProjectionCubit, bool>(
        (c) => c.state.dataOrNull?.direction == WeightDirection.gain);
    final from = insight.fromDate;
    final to = insight.toDate;
    return Padding(
      padding: padding,
      child: SpecCard(
        child: SpecColumn(
          children: [
            SpecCardHeader(
              icon: Icons.insights_rounded,
              title: l10n.weightInsightTitle,
              subtitle: from != null && to != null
                  ? '${shortDateLabel(context, from)} – ${shortDateLabel(context, to)}'
                  : null,
              trailing: _changePill(context, insight.changeKg, gainGoal),
            ),
            Text(insight.text,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w400, height: 1.6)),
            Text(l10n.weightInsightDisclaimer, style: AppTextStyles.tiny),
          ],
        ),
      ),
    );
  }

  /// Down is green, up is green only for a weight-gain goal, zero is stable.
  static Widget? _changePill(BuildContext context, double? kg, bool gainGoal) {
    if (kg == null) return null;
    final l10n = context.l10n;
    final rounded = (kg * 10).round() / 10;
    if (rounded == 0) {
      return StatusPill(l10n.weightStable, tone: PillTone.neutral);
    }
    final value = context.localizeDigits(rounded.abs().toStringAsFixed(1));
    return rounded < 0
        ? StatusPill(l10n.weightDown(value), tone: PillTone.success)
        : StatusPill(l10n.weightUp(value),
            tone: gainGoal ? PillTone.success : PillTone.neutral);
  }
}
