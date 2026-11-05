import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../domain/usecases/save_measurement_use_case.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/onboarding_reveal.dart';
import '../widgets/onboarding_step_header.dart';
import 'measurement_guide_screen.dart';
import 'onboarding_health_screen.dart';
import '../../core/navigation/app_page_route.dart';

import '../../l10n/l10n.dart';

/// Onboarding step 1/3 — "القياسات الأولية": the mandatory baseline weight
/// plus optional body-circumference fields the specialist uses to gauge
/// fat distribution. This is the very first data point ever recorded for
/// the patient, distinct from [MeasurementEntryScreen] which is used for
/// every later re-measurement once a plan is already active.
///
/// "Save and continue" sends the reading (`POST /me/measurements`, API guide
/// 7.1; queued when offline). That reading is also what tells the app the
/// patient has been through the wizard, on this phone or another.
class OnboardingMeasurementsScreen extends StatefulWidget {
  const OnboardingMeasurementsScreen({super.key});

  @override
  State<OnboardingMeasurementsScreen> createState() =>
      _OnboardingMeasurementsScreenState();
}

class _OnboardingMeasurementsScreenState
    extends State<OnboardingMeasurementsScreen> {
  static const double _minWeight = 20.0;
  static const double _maxWeight = 300.0;

  /// Where the picker starts. It is not saved until the patient sets it.
  double _weight = 70.5;

  /// The patient has set the weight (stepper or picker). A starting value is
  /// never sent as their reading.
  bool _weightChosen = false;
  bool _saving = false;

  /// Messages for refused fields, by field: `weight`, `waist`, `hip`, `thigh`.
  final Map<String, String> _errors = {};

  late final List<double> _weightOptions = List<double>.generate(
    ((_maxWeight - _minWeight) * 10).round() + 1,
    (index) => _minWeight + (index / 10),
  );
  final Map<String, TextEditingController> _circumference = {
    'waist': TextEditingController(),
    'hip': TextEditingController(),
    'thigh': TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _circumference.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _changeWeight(double delta) => setState(() {
        _weight = (((_weight + delta) * 10).round() / 10)
            .clamp(_minWeight, _maxWeight)
            .toDouble();
        _weightChosen = true;
        _errors.remove('weight');
      });

  Future<void> _openWeightPicker() async {
    final initialIndex = (_weight - _minWeight) * 10;
    final controller = FixedExtentScrollController(
        initialItem: initialIndex.round().clamp(0, _weightOptions.length - 1));
    double selectedWeight = _weight;

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(context.l10n.commonCancel,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                        ),
                        const Spacer(),
                        Text(context.l10n.onboardingMeasurementsPickWeight,
                            style: AppTextStyles.sectionHeading),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(selectedWeight),
                          child: Text(context.l10n.commonConfirm,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 220,
                      child: ListWheelScrollView.useDelegate(
                        controller: controller,
                        itemExtent: 52,
                        perspective: 0.01,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setSheetState(
                              () => selectedWeight = _weightOptions[index]);
                        },
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: _weightOptions
                              .map(
                                (value) => Center(
                                  child: Text(
                                    context.l10n.commonKilogramsValue(
                                        value.toStringAsFixed(1)),
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: value == selectedWeight
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _weight = result;
        _weightChosen = true;
        _errors.remove('weight');
      });
    }
  }

  /// Saves the first reading, then opens the next step. A refused field stays
  /// on this screen with its message; an offline save is queued and counts.
  Future<void> _continue() async {
    if (!_weightChosen || _saving) return;
    final l10n = context.l10n;

    final cm = <String, double?>{};
    final invalid = <String, String>{};
    for (final MapEntry(:key, :value) in _circumference.entries) {
      final text = value.text.trim().replaceAll(',', '.');
      if (text.isEmpty) {
        cm[key] = null;
        continue;
      }
      final number = double.tryParse(text);
      if (number == null) {
        invalid[key] = l10n.validationInvalidNumber;
      } else {
        cm[key] = number;
      }
    }
    if (invalid.isNotEmpty) {
      setState(() => _errors
        ..clear()
        ..addAll(invalid));
      return;
    }

    setState(() {
      _saving = true;
      _errors.clear();
    });
    final now = DateTime.now();
    final result =
        await context.read<AppDependencies>().saveMeasurement(MeasurementEntry(
              id: now.microsecondsSinceEpoch.toString(),
              recordedAt: now,
              weightKg: double.parse(_weight.toStringAsFixed(1)),
              waistCm: cm['waist'],
              hipCm: cm['hip'],
              thighCm: cm['thigh'],
            ));
    if (!mounted) return;

    final failure = result.failureOrNull;
    setState(() {
      _saving = false;
      if (failure is ValidationFailure) {
        _errors
          ..clear()
          ..addAll({
            for (final e in failure.fieldErrors.entries)
              e.key: _errorText(e.key, e.value),
          });
      }
    });
    if (failure == null) {
      Navigator.of(context)
          .push(AppPageRoute(builder: (_) => const OnboardingHealthScreen()));
    } else if (failure is! ValidationFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(failure is NetworkFailure
            ? l10n.commonOfflineBody
            : l10n.commonErrorBody),
      ));
    }
  }

  /// The message for a field the use case refused (see
  /// [SaveMeasurementUseCase]).
  String _errorText(String field, String code) {
    final l10n = context.l10n;
    if (code == 'validation.required') return l10n.validationRequired;
    final range = field == 'weight'
        ? SaveMeasurementUseCase.weightRangeKg
        : SaveMeasurementUseCase.circumferenceRangeCm[field];
    if (range == null) return l10n.commonErrorBody;
    return l10n.validationOutOfRange(range.$1, range.$2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingReveal(
              dy: -0.08,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: OnboardingStepHeader(
                    title: context.l10n.onboardingMeasurementsTitle, step: 1),
              ),
            ),
            Expanded(
              child: OnboardingReveal(
                delay: const Duration(milliseconds: 120),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(context.l10n.onboardingMeasurementsYours,
                          style: AppTextStyles.sectionHeading),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.l10n.onboardingMeasurementsIntro,
                        style: AppTextStyles.caption,
                      ),
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
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.monitor_weight_outlined,
                                    color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    context.l10n.measurementsCurrentWeight,
                                    textAlign: TextAlign.start,
                                    style: AppTextStyles.sectionHeading),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color:
                                        AppColors.danger.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill)),
                                child: Text(
                                    context
                                        .l10n.onboardingMeasurementsMandatory,
                                    style: const TextStyle(
                                        color: AppColors.danger,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _RoundStepBtn(
                                  icon: Icons.add_rounded,
                                  onTap: () => _changeWeight(0.1)),
                              Expanded(
                                child: GestureDetector(
                                  key:
                                      const ValueKey('weight_selector_trigger'),
                                  onTap: _openWeightPicker,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.cardSmall),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Muted until the patient sets
                                            // it: only a value they chose is
                                            // saved.
                                            Text(_weight.toStringAsFixed(1),
                                                style: AppTextStyles.metricLarge
                                                    .copyWith(
                                                        fontSize: 34,
                                                        color: _weightChosen
                                                            ? null
                                                            : AppColors
                                                                .textSecondary)),
                                            const SizedBox(width: 6),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: Text(
                                                  context
                                                      .l10n.commonKilogramsUnit,
                                                  style:
                                                      AppTextStyles.secondary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            context.l10n
                                                .onboardingMeasurementsTapToChoose,
                                            style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              _RoundStepBtn(
                                  icon: Icons.remove_rounded,
                                  onTap: () => _changeWeight(-0.1)),
                            ],
                          ),
                          if (_errors['weight'] case final error?) ...[
                            const SizedBox(height: 8),
                            Text(error,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.danger)),
                          ],
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: ((_weight - 40) / (160 - 40)).clamp(0, 1),
                              minHeight: 6,
                              backgroundColor: AppColors.neutralTrack,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(context.l10n.onboardingMeasurementsMaxWeight,
                                  style: AppTextStyles.caption),
                              const Spacer(),
                              Text(
                                  context.l10n.onboardingMeasurementsIdealRange,
                                  style: AppTextStyles.caption),
                              const Spacer(),
                              Text(context.l10n.onboardingMeasurementsMinWeight,
                                  style: AppTextStyles.caption),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.cardSmall)),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.l10n.onboardingMeasurementsTip,
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(AppPageRoute(
                          builder: (_) => const MeasurementGuideScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.card)),
                        child: Row(
                          children: [
                            const Icon(Icons.image_outlined,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.l10n.onboardingMeasurementsHowTo,
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                                context.l10n
                                    .onboardingMeasurementsIllustratedGuide,
                                style: AppTextStyles.pillLabel),
                            const Icon(Icons.expand_more_rounded,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.straighten_rounded,
                            color: AppColors.textPrimary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                context.l10n.measurementsBodyCircumference,
                                textAlign: TextAlign.start,
                                style: AppTextStyles.sectionHeading)),
                        Text(context.l10n.commonOptional,
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.l10n.onboardingMeasurementsExtraNote,
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CircumferenceField(
                        index: 1,
                        label: context.l10n.measurementWaist,
                        hint: context.l10n.onboardingMeasurementsWaistHint,
                        error: _errors['waist'],
                        controller: _circumference['waist']!),
                    _CircumferenceField(
                        index: 2,
                        label: context.l10n.measurementHip,
                        hint: context.l10n.onboardingMeasurementsHipHint,
                        error: _errors['hip'],
                        controller: _circumference['hip']!),
                    _CircumferenceField(
                        index: 3,
                        label: context.l10n.measurementThigh,
                        hint: context.l10n.onboardingMeasurementsThighHint,
                        error: _errors['thigh'],
                        controller: _circumference['thigh']!),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card)),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.onboardingMeasurementsPrivacyNote,
                              textAlign: TextAlign.start,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            OnboardingReveal(
              dy: 0.18,
              delay: const Duration(milliseconds: 260),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: GradientCtaButton(
                    label: context.l10n.onboardingMeasurementsSaveContinue,
                    loading: _saving,
                    onPressed: _weightChosen ? _continue : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundStepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundStepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border)),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _CircumferenceField extends StatelessWidget {
  final int index;
  final String label;
  final String hint;
  final String? error;
  final TextEditingController controller;

  const _CircumferenceField(
      {required this.index,
      required this.label,
      required this.hint,
      required this.controller,
      this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.primaryTint, shape: BoxShape.circle),
            child: Text('$index',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(hint,
                    textAlign: TextAlign.start, style: AppTextStyles.caption),
                if (error != null)
                  Text(error!,
                      textAlign: TextAlign.start,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.danger)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.cardTitle,
              decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  suffixText: context.l10n.commonCmUnit,
                  suffixStyle: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }
}
