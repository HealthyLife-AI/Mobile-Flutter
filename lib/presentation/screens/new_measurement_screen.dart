import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../domain/usecases/save_measurement_use_case.dart';
import '../../l10n/l10n.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/directional_icon.dart';
import '../widgets/gradient_cta_button.dart';
import 'measurement_guide_screen.dart';

/// "تفاصيل القياس" — POST /me/measurements. Weight is required; every
/// circumference field is optional ("سجّلي ما يتوفر لديك فقط دون أي إلزام").
///
/// The stepper, the quick picks and the field hints start from the patient's
/// saved readings. Until a weight is picked, save stays off.
class MeasurementEntryScreen extends StatefulWidget {
  /// Called after a reading is saved, before this screen closes.
  final VoidCallback? onSaved;

  const MeasurementEntryScreen({super.key, this.onSaved});

  @override
  State<MeasurementEntryScreen> createState() => _MeasurementEntryScreenState();
}

class _MeasurementEntryScreenState extends State<MeasurementEntryScreen>
    with SingleTickerProviderStateMixin {
  /// Where the stepper starts when the patient has no saved weight yet.
  static const double _startWeight = 70.0;

  static const List<String> _partKeys = ['waist', 'hip', 'thigh', 'arm'];

  late final AnimationController _enter;

  /// The weight on the stepper. Shown as '—' until [_weightChosen].
  double _weight = _startWeight;

  /// False until a weight is picked: from the stepper, a quick pick, or the
  /// last saved reading.
  bool _weightChosen = false;

  bool _saving = false;
  bool _circumferenceExpanded = true;

  /// The latest saved weight and circumferences, when there are any.
  double? _lastWeight;
  final Map<String, double?> _lastCm = {};

  /// Messages under each field, from the last refused save.
  final Map<String, String> _errors = {};

  final Map<String, TextEditingController> _controllers = {
    for (final key in _partKeys) key: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loadLast();
  }

  @override
  void dispose() {
    _enter.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Reads the saved readings for the hints. If the read fails the screen
  /// simply has no hints: the patient can still pick a weight and save.
  Future<void> _loadLast() async {
    final deps = context.read<AppDependencies>();
    final snapshot = (await deps.measurement.getSnapshot()).valueOrNull;
    if (!mounted || snapshot == null) return;

    // Newest first, so each part keeps its latest value.
    final latest = <String, double?>{};
    for (final entry in snapshot.savedEntries.reversed) {
      latest['waist'] ??= entry.waistCm;
      latest['hip'] ??= entry.hipCm;
      latest['thigh'] ??= entry.thighCm;
      latest['arm'] ??= entry.armCm;
    }

    final weight = snapshot.currentWeight;
    setState(() {
      _lastCm
        ..clear()
        ..addAll(latest);
      _lastWeight = weight;
      if (weight != null && !_weightChosen) {
        _weight = weight;
        _weightChosen = true;
      }
    });
  }

  bool get _canSave => _weightChosen && !_saving;

  void _pickWeight() {
    _weightChosen = true;
    _errors.remove('weight');
  }

  void _changeWeight(double delta) {
    final double next = ((_weight + delta) * 10).round() / 10;
    setState(() {
      _weight = next.clamp(20.0, 300.0).toDouble();
      _pickWeight();
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final l10n = context.l10n;

    // Typed text becomes numbers here. Text that is not a number is refused
    // before anything is sent.
    final cm = <String, double?>{};
    final invalid = <String, String>{};
    for (final key in _partKeys) {
      final text = _controllers[key]!.text.trim().replaceAll(',', '.');
      if (text.isEmpty) {
        cm[key] = null;
        continue;
      }
      final value = double.tryParse(text);
      if (value == null) {
        invalid[key] = l10n.validationInvalidNumber;
      } else {
        cm[key] = value;
      }
    }
    if (invalid.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(invalid);
      });
      return;
    }

    setState(() {
      _saving = true;
      _errors.clear();
    });

    final deps = context.read<AppDependencies>();
    final now = DateTime.now();
    final result = await deps.saveMeasurement(MeasurementEntry(
      id: now.microsecondsSinceEpoch.toString(),
      recordedAt: now,
      weightKg: double.parse(_weight.toStringAsFixed(1)),
      waistCm: cm['waist'],
      hipCm: cm['hip'],
      thighCm: cm['thigh'],
      armCm: cm['arm'],
    ));
    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure == null) {
      widget.onSaved?.call();
      Navigator.of(context).pop();
      return;
    }

    final messages = failure is ValidationFailure
        ? {
            for (final e in failure.fieldErrors.entries)
              e.key: _errorText(e.key, e.value),
          }
        : <String, String>{};
    setState(() {
      _saving = false;
      _errors
        ..clear()
        ..addAll(messages);
    });
    if (failure is! ValidationFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(failure is NetworkFailure
            ? l10n.commonOfflineBody
            : l10n.commonErrorBody),
      ));
    }
  }

  /// The message for a field the use case refused. The codes come from
  /// [SaveMeasurementUseCase].
  String _errorText(String field, String code) {
    final l10n = context.l10n;
    if (code == 'validation.required') return l10n.validationRequired;
    final range = field == 'weight'
        ? SaveMeasurementUseCase.weightRangeKg
        : SaveMeasurementUseCase.circumferenceRangeCm[field];
    if (range == null) return l10n.commonErrorBody;
    return l10n.validationOutOfRange(range.$1, range.$2);
  }

  /// The last saved value of [key] as shown in its hint, or null.
  String? _lastText(String key) {
    final value = _lastCm[key];
    return value == null ? null : context.localizeDigits(_cmText(value));
  }

  void _openGuide() {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const MeasurementGuideScreen()),
    );
  }

  /// Staggered entrance: fade + slide up, each section starts a bit later.
  Widget _reveal(int index, Widget child) {
    final double start = (index * 0.12).clamp(0.0, 0.7).toDouble();
    final double end = (start + 0.5).clamp(0.0, 1.0).toDouble();
    final Animation<double> curved = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NutritionistCubit>(
      create: (context) =>
          NutritionistCubit(context.read<AppDependencies>().nutritionist)
            ..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeaderBar(title: context.l10n.measurementEntryTitle),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
          children: [
            _reveal(0, _buildGuideCard()),
            const SizedBox(height: 14),
            _reveal(1, _buildDateCard()),
            const SizedBox(height: 14),
            _reveal(2, _buildWeightCard()),
            const SizedBox(height: 14),
            _reveal(3, _buildCircumferenceCard()),
            const SizedBox(height: 14),
            _reveal(4, _buildPrivacyCard()),
            const SizedBox(height: 18),
            _reveal(
              5,
              Column(
                children: [
                  _PressScale(
                    child: GradientCtaButton(
                      label: context.l10n.measurementEntrySave,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _canSave ? _save : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.measurementEntryCancel,
                        style: AppTextStyles.secondary),
                  ),
                  const ClinicalTrustFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Sections ─────────────────────────

  Widget _buildGuideCard() {
    return _SectionCard(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 310;

          final button = Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _PressScale(
              child: GestureDetector(
                onTap: _openGuide,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.measurementEntryView,
                          style: AppTextStyles.pillLabel),
                      const SizedBox(width: 4),
                      Icon(
                          directionalIcon(context,
                              rtl: Icons.arrow_back_rounded,
                              ltr: Icons.arrow_forward_rounded),
                          size: 14,
                          color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconSquare(
                icon: Icons.lightbulb_outline_rounded,
                circle: true,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.measurementEntryGuideTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle),
                    const SizedBox(height: 2),
                    Text(context.l10n.measurementEntryGuideSubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption),
                    if (compact) ...[
                      const SizedBox(height: 10),
                      button,
                    ],
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                button,
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(context.l10n.measurementEntryDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle),
              ),
              const SizedBox(width: 8),
              Icon(Icons.event_busy_outlined,
                  size: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  context.l10n.measurementEntryNoFuture,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            ),
            child: Row(
              children: [
                const _IconSquare(icon: Icons.calendar_today_rounded, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.measurementEntryToday,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body),
                      const SizedBox(height: 2),
                      Text(context.l10n.measurementEntrySuggestedTime,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    final l10n = context.l10n;
    final double? last = _lastWeight;
    // Three quick picks around the last saved weight, with no saved weight
    // there is nothing to pick around.
    final List<_QuickChip> chips = last == null
        ? const []
        : [
            for (final offset in const [-0.5, 0.0, 0.5])
              _QuickChip(
                label: context
                    .localizeDigits(_tenth(last + offset).toStringAsFixed(1)),
                value: _tenth(last + offset),
              ),
          ];
    final String? weightError = _errors['weight'];
    final String shown = _weightChosen ? _weight.toStringAsFixed(1) : '—';

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconSquare(icon: Icons.monitor_weight_outlined, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.measurementsCurrentWeight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sectionHeading),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(l10n.measurementEntryRequired,
                    style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (last != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.measurementEntryLastValueHint(context.localizeDigits(
                          '${_tenth(last).toStringAsFixed(1)} ${l10n.commonKgUnit}')),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              _RoundStepBtn(
                icon: Icons.remove_rounded,
                filled: true,
                onTap: () => _changeWeight(-0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1.0)
                                .animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          context.localizeDigits(shown),
                          key: ValueKey<String>(shown),
                          style:
                              AppTextStyles.metricLarge.copyWith(fontSize: 30),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(l10n.commonKgUnit, style: AppTextStyles.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _RoundStepBtn(
                icon: Icons.add_rounded,
                filled: false,
                onTap: () => _changeWeight(0.1),
              ),
            ],
          ),
          if (weightError != null) ...[
            const SizedBox(height: 8),
            Text(weightError,
                style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 8;
                final double chipWidth = constraints.maxWidth >= 330
                    ? (constraints.maxWidth - spacing * 2) / 3
                    : (constraints.maxWidth - spacing) / 2;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 8,
                  children: chips.map((chip) {
                    final bool selected =
                        _weightChosen && (_weight - chip.value).abs() < 0.001;
                    return SizedBox(
                      width: chipWidth,
                      child: _PressScale(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _weight = chip.value;
                            _pickWeight();
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.primaryTint,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.cardSmall),
                            ),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: AppTextStyles.caption.copyWith(
                                color:
                                    selected ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              child: Text(chip.label,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            ),
            child: Row(
              children: [
                const Text('🙂', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.measurementEntryRegularNote,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircumferenceCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(
                () => _circumferenceExpanded = !_circumferenceExpanded),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _IconSquare(icon: Icons.straighten_rounded, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.measurementEntryCircumferenceTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sectionHeading,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(context.l10n.commonOptional,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.primary)),
                    ),
                    AnimatedRotation(
                      turns: _circumferenceExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: const Icon(Icons.expand_more_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(context.l10n.measurementEntryOptionalNote,
              style: AppTextStyles.caption),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: _circumferenceExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _openGuide,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.cardSmall),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final detailsWidth =
                                    (constraints.maxWidth - 180)
                                        .clamp(90.0, double.infinity)
                                        .toDouble();

                                return Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    const Icon(Icons.open_in_new_rounded,
                                        size: 14, color: AppColors.primary),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 120),
                                      child: Text(
                                        context
                                            .l10n.measurementEntryHowToMeasure,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.pillLabel,
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: detailsWidth),
                                      child: Text(
                                        context.l10n.measurementEntryUnitCm,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        style: AppTextStyles.caption,
                                      ),
                                    ),
                                    const Icon(Icons.straighten_rounded,
                                        size: 14, color: AppColors.primary),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CircField(
                          label: context.l10n.measurementWaist,
                          hint: context.l10n.measurementWaistHint,
                          controller: _controllers['waist']!,
                          lastValue: _lastText('waist'),
                          error: _errors['waist'],
                        ),
                        _CircField(
                          label: context.l10n.measurementHip,
                          hint: context.l10n.measurementHipHint,
                          controller: _controllers['hip']!,
                          lastValue: _lastText('hip'),
                          error: _errors['hip'],
                        ),
                        _CircField(
                          label: context.l10n.measurementThigh,
                          hint: context.l10n.measurementThighHint,
                          controller: _controllers['thigh']!,
                          lastValue: _lastText('thigh'),
                          error: _errors['thigh'],
                        ),
                        _CircField(
                          label: context.l10n.measurementArm,
                          hint: context.l10n.measurementArmHint,
                          controller: _controllers['arm']!,
                          lastValue: _lastText('arm'),
                          error: _errors['arm'],
                          isLast: true,
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Builder(
      builder: (context) {
        final nutritionist =
            context.watch<NutritionistCubit>().state.dataOrNull;
        return _SectionCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconSquare(icon: Icons.verified_user_outlined, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.measurementEntryPrivacyTitle,
                        style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.measurementEntryPrivacyBody(
                          nutritionist?.gender ?? 'unknown',
                          nutritionist?.name ?? ''),
                      textAlign: TextAlign.start,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────────── Helpers ─────────────────────────

/// Rounds to one decimal, the precision the screen and the API use for weight.
double _tenth(double value) => (value * 10).round() / 10;

/// A centimetre value without a trailing `.0`.
String _cmText(double cm) =>
    cm == cm.roundToDouble() ? cm.round().toString() : cm.toStringAsFixed(1);

class _QuickChip {
  final String label;
  final double value;
  const _QuickChip({required this.label, required this.value});
}

/// White rounded card with a soft border and shadow.
class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Tinted icon container used in section headers.
class _IconSquare extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool circle;

  const _IconSquare({
    required this.icon,
    this.size = 36,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: size * 0.5),
    );
  }
}

/// Wraps any child with a subtle "press down" scale animation without
/// stealing the child's own tap handling.
class _PressScale extends StatefulWidget {
  final Widget child;
  const _PressScale({required this.child});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _RoundStepBtn extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _RoundStepBtn({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : AppColors.surface,
            border: filled
                ? null
                : Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Icon(
            icon,
            color: filled ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _CircField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  /// The last saved value, shown as the field's hint. Null when there is none.
  final String? lastValue;

  /// The message from a refused save, shown under the field.
  final String? error;
  final bool isLast;

  const _CircField({
    required this.label,
    required this.hint,
    required this.controller,
    this.lastValue,
    this.error,
    this.isLast = false,
  });

  @override
  State<_CircField> createState() => _CircFieldState();
}

class _CircFieldState extends State<_CircField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String? last = widget.lastValue;
    final String? error = widget.error;

    final Color borderColor = error != null
        ? AppColors.danger
        : (_focus.hasFocus ? AppColors.primary : Colors.transparent);

    return Container(
      margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.label, style: AppTextStyles.cardTitle),
          const SizedBox(height: 2),
          Text(widget.hint, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
              border: Border.all(color: borderColor, width: 1.4),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              textAlign: TextAlign.start,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: last == null
                    ? null
                    : l10n.measurementEntryLastValueHint(last),
                suffixText: l10n.commonCmUnit,
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error,
                style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ],
        ],
      ),
    );
  }
}
