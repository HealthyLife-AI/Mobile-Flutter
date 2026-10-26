import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

/// "تعليمات أخصائيتك": the specialist's free-text instructions from
/// `patient_instructions` on `/me/meal-plan`, one bullet per line.
///
/// Renders nothing for an empty list; callers pass
/// [MealPlan.patientInstructions] straight through. Lines are never cut
/// with an ellipsis. Past [collapsedLines] lines, the rest sit behind
/// "عرض المزيد".
class PatientInstructionsCard extends StatefulWidget {
  const PatientInstructionsCard({super.key, required this.lines});

  final List<String> lines;

  static const int collapsedLines = 3;

  @override
  State<PatientInstructionsCard> createState() => _PatientInstructionsCardState();
}

class _PatientInstructionsCardState extends State<PatientInstructionsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.lines;
    if (lines.isEmpty) return const SizedBox.shrink();

    final collapsible = lines.length > PatientInstructionsCard.collapsedLines;
    final visible = collapsible && !_expanded ? lines.take(PatientInstructionsCard.collapsedLines) : lines;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // The text is Arabic whatever the UI locale, so the card pins RTL itself.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: const Text('تعليمات أخصائيتك', style: AppTextStyles.cardTitle),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSize(
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoftBg.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, line) in visible.indexed) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _Bullet(text: line),
                    ],
                  ],
                ),
              ),
            ),
            if (collapsible)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  icon: Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 20),
                  label: Text(
                    _expanded ? 'عرض أقل' : 'عرض المزيد',
                    style: AppTextStyles.secondary.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 9),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400, height: 1.6)),
        ),
      ],
    );
  }
}
