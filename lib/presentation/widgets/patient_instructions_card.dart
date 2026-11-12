import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../l10n/l10n.dart';
import 'spec_ui.dart';

/// "تعليمات أخصائيتك": `patient_instructions` from `/me/meal-plan`, one bullet
/// per line (design spec, phase 1).
///
/// Renders nothing for an empty list: callers pass
/// [MealPlan.patientInstructions] straight through, and a null, empty or
/// blank field has already become `[]`. Lines are never cut with an ellipsis.
/// Past [collapsedLines] lines, the rest sit behind "عرض الكل".
class PatientInstructionsCard extends StatefulWidget {
  const PatientInstructionsCard({super.key, required this.lines});

  final List<String> lines;

  static const int collapsedLines = 3;

  @override
  State<PatientInstructionsCard> createState() =>
      _PatientInstructionsCardState();
}

class _PatientInstructionsCardState extends State<PatientInstructionsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.lines;
    if (lines.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;

    final collapsible = lines.length > PatientInstructionsCard.collapsedLines;
    final visible = collapsible && !_expanded
        ? lines.take(PatientInstructionsCard.collapsedLines)
        : lines;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // The text is Arabic whatever the UI language, so the card pins RTL.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SpecCard(
        highlighted: true,
        child: SpecColumn(
          children: [
            SpecCardHeader(
                icon: Icons.assignment_outlined,
                title: l10n.planInstructionsTitle),
            AnimatedSize(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: SpecPanel(
                child: SpecColumn(
                  gap: 8,
                  children: [for (final line in visible) BulletLine(line)],
                ),
              ),
            ),
            if (collapsible)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryInk,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20),
                  label: Text(
                    _expanded ? l10n.commonShowLess : l10n.commonShowAll,
                    style: AppTextStyles.secondary.copyWith(
                        color: AppColors.primaryInk, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "النشاط البدني": the plan's `activities`, one card each. Renders nothing
/// when the nutritionist set none.
class PlanActivitiesSection extends StatelessWidget {
  const PlanActivitiesSection({super.key, required this.activities});

  final List<PlanActivity> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();
    return SpecColumn(
      children: [
        SpecSectionTitle(context.l10n.planActivitiesTitle,
            icon: Icons.monitor_heart_outlined),
        for (final activity in activities) PlanActivityCard(activity: activity),
      ],
    );
  }
}

class PlanActivityCard extends StatelessWidget {
  const PlanActivityCard({super.key, required this.activity});

  final PlanActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final description = activity.description;
    final days = activity.daysPerWeek;
    String n(int value) => context.localizeDigits(value);
    return SpecCard(
      child: SpecColumn(
        children: [
          SpecCardHeader(
              icon: Icons.directions_walk_rounded, title: activity.title),
          if (description != null)
            Text(description,
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.textSecondary, height: 1.5)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(l10n.durationMinutes(
                  activity.durationMinutes, n(activity.durationMinutes))),
              StatusPill(l10n.timesPerDay(
                  activity.timesPerDay, n(activity.timesPerDay))),
              if (days != null) StatusPill(l10n.daysPerWeek(days, n(days))),
            ],
          ),
        ],
      ),
    );
  }
}
