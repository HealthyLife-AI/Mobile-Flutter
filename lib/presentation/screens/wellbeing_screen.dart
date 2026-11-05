import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/health_records_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/confirm_action_sheet.dart';
import '../widgets/spec_ui.dart';

/// "النوم والمزاج" — `/me/wellbeing`, one entry per night.
///
/// Last night by default; only the last 7 days can be edited. Hours run from
/// 0 to 16 in half-hour steps, and one field is enough. A save replaces the
/// whole day, so every field on screen is sent. The chart shows the last 7
/// nights without numbers, nights under 6 hours in the warning color.
class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  late final WellbeingRepository _repository =
      context.read<AppDependencies>().wellbeing;
  final TextEditingController _note = TextEditingController();

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _date = _today.subtract(const Duration(days: 1));
  Map<DateTime, WellbeingEntry> _entries = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  double? _hours;
  SleepQuality? _quality;
  StressLevel? _stress;
  MoodLevel? _mood;

  @override
  void initState() {
    super.initState();
    _note.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final to = _today;
    final from = to.subtract(const Duration(days: 13));
    final result = await _repository.getRange(from, to);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _entries = {
        for (final e in result.valueOrNull ?? const <WellbeingEntry>[])
          e.date: e,
      };
      _fillForm();
    });
  }

  void _fillForm() {
    final entry = _entries[_date];
    _hours = entry?.sleepHours;
    _quality = entry?.sleepQuality;
    _stress = entry?.stress;
    _mood = entry?.mood;
    _note.text = entry?.note ?? '';
    _error = null;
  }

  bool get _canGoBack =>
      calendarDaysBetween(_date, _today) < WellbeingEntry.editableDays;
  bool get _canGoForward => _date.isBefore(_today);

  void _moveDay(int delta) => setState(() {
        _date = DateTime(_date.year, _date.month, _date.day + delta);
        _fillForm();
      });

  WellbeingEntry get _draft => WellbeingEntry(
        date: _date,
        sleepHours: _hours,
        sleepQuality: _quality,
        stress: _stress,
        mood: _mood,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await _repository.save(_draft);
    if (!mounted) return;
    setState(() {
      _saving = false;
      result.when(
        success: (saved) {
          _entries = {..._entries, _date: saved};
          showSpecSnack(context, l10n.commonSaved);
          context.read<TodayCubit>().load();
        },
        failure: (failure) => _error = switch (failure) {
          ApiFailure(code: 'wellbeing_date_future') =>
            l10n.wellbeingErrorFuture,
          ApiFailure(code: 'wellbeing_date_too_old') => l10n.wellbeingErrorOld,
          NetworkFailure() => l10n.commonOfflineBody,
          ApiFailure(:final fieldErrors) when fieldErrors.isNotEmpty =>
            fieldErrors.values.first,
          _ => l10n.commonErrorBody,
        },
      );
    });
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await ConfirmActionSheet.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: l10n.wellbeingDeleteTitle,
      message: fullDayLabel(context, _date),
      confirmLabel: l10n.reportDelete,
    );
    if (confirmed != true || !mounted) return;
    final result = await _repository.delete(_date);
    if (!mounted) return;
    if (result.failureOrNull != null) {
      showSpecSnack(context, l10n.commonErrorBody, error: true);
      return;
    }
    setState(() {
      _entries = {..._entries}..remove(_date);
      _fillForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = calendarDaysBetween(_date, _today);
    final dayTitle = switch (days) {
      0 => l10n.wellbeingTonight,
      1 => l10n.wellbeingLastNight,
      _ => null,
    };
    final saved = _entries.containsKey(_date);
    final count = _note.text.characters.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.wellbeingTitle),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  SpecCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: l10n.wellbeingPreviousNight,
                          onPressed: _canGoBack ? () => _moveDay(-1) : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Text(
                            [
                              if (dayTitle != null) dayTitle,
                              fullDayLabel(context, _date),
                            ].join(' • '),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.wellbeingNextNight,
                          onPressed: _canGoForward ? () => _moveDay(1) : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SpecCard(
                    child: SpecColumn(
                      children: [
                        Text(l10n.wellbeingHoursQuestion,
                            style: AppTextStyles.cardTitle),
                        _HoursStepper(
                          hours: _hours,
                          onChanged: (h) => setState(() => _hours = h),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SpecCard(
                    child: SpecColumn(
                      gap: 14,
                      children: [
                        _ChoiceRow<SleepQuality>(
                          title: l10n.wellbeingQualityQuestion,
                          values: SleepQuality.values,
                          selected: _quality,
                          label: (q) => switch (q) {
                            SleepQuality.good => l10n.wellbeingQualityGood,
                            SleepQuality.ok => l10n.wellbeingQualityOk,
                            SleepQuality.poor => l10n.wellbeingQualityPoor,
                          },
                          onChanged: (v) => setState(() => _quality = v),
                        ),
                        _ChoiceRow<StressLevel>(
                          title: l10n.wellbeingStressQuestion,
                          values: StressLevel.values,
                          selected: _stress,
                          label: (s) => switch (s) {
                            StressLevel.low => l10n.wellbeingStressLow,
                            StressLevel.medium => l10n.wellbeingStressMedium,
                            StressLevel.high => l10n.wellbeingStressHigh,
                          },
                          onChanged: (v) => setState(() => _stress = v),
                        ),
                        _ChoiceRow<MoodLevel>(
                          title: l10n.wellbeingMoodQuestion,
                          values: MoodLevel.values,
                          selected: _mood,
                          label: (m) => switch (m) {
                            MoodLevel.good => l10n.wellbeingMoodGood,
                            MoodLevel.ok => l10n.wellbeingMoodOk,
                            MoodLevel.low => l10n.wellbeingMoodLow,
                          },
                          onChanged: (v) => setState(() => _mood = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.wellbeingNote, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _note,
                    maxLength: WellbeingEntry.noteMaxLength,
                    minLines: 2,
                    maxLines: 4,
                    decoration: specInputDecoration(l10n.wellbeingNoteHint)
                        .copyWith(counterText: ''),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                        l10n.commonCharCount(
                            context.localizeDigits(count),
                            context
                                .localizeDigits(WellbeingEntry.noteMaxLength)),
                        style: AppTextStyles.tiny),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: AppTextStyles.secondary
                            .copyWith(color: AppColors.danger)),
                  ],
                  const SizedBox(height: 14),
                  SpecPrimaryButton(
                    label: l10n.commonSave,
                    loading: _saving,
                    onPressed: _draft.isEmpty ? null : _save,
                  ),
                  if (saved)
                    Center(
                      child: TextButton.icon(
                        onPressed: _delete,
                        icon:
                            const Icon(Icons.delete_outline_rounded, size: 18),
                        label: Text(l10n.wellbeingDeleteNight),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.danger),
                      ),
                    ),
                  const SizedBox(height: 14),
                  _SleepChart(
                      entries: _entries,
                      lastNight: _today.subtract(const Duration(days: 1))),
                ],
              ),
      ),
    );
  }
}

class _HoursStepper extends StatelessWidget {
  const _HoursStepper({required this.hours, required this.onChanged});

  final double? hours;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = hours;
    String text(double h) =>
        context.localizeDigits(h == h.roundToDouble() ? h.toInt() : h);
    Widget button(IconData icon, String tip, VoidCallback? onTap) =>
        IconButton.filledTonal(
          tooltip: tip,
          onPressed: onTap,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryTint,
            foregroundColor: AppColors.primary,
            minimumSize: const Size(48, 48),
          ),
        );
    return Row(
      children: [
        button(
          Icons.remove_rounded,
          l10n.wellbeingLessSleep,
          value == null || value <= 0 ? null : () => onChanged(value - 0.5),
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Column(
              children: [
                Text(value == null ? '—' : text(value),
                    style: AppTextStyles.metricLarge
                        .copyWith(color: AppColors.primary)),
                Text(l10n.wellbeingHoursUnit, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        button(
          Icons.add_rounded,
          l10n.wellbeingMoreSleep,
          value != null && value >= WellbeingEntry.maxHours
              ? null
              // The first tap starts at 7 h, a usual night.
              : () => onChanged(value == null ? 7 : value + 0.5),
        ),
      ],
    );
  }
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTextStyles.cardTitle),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (i, value) in values.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _Segment(
                  label: label(value),
                  selected: selected == value,
                  // A second tap clears the choice.
                  onTap: () => onChanged(selected == value ? null : value),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primaryTint : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.panel),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.panel),
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.5 : 1),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: AppTextStyles.secondary.copyWith(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}

/// The last 7 nights, oldest first. Bars only, no numbers on top; a night
/// under 6 hours in the warning color, a night with no hours as a stub.
class _SleepChart extends StatelessWidget {
  const _SleepChart({required this.entries, required this.lastNight});

  final Map<DateTime, WellbeingEntry> entries;
  final DateTime lastNight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final letters = l10n.wellbeingWeekdayLetters.split(' ');
    final nights = [
      for (var i = 6; i >= 0; i--)
        DateTime(lastNight.year, lastNight.month, lastNight.day - i),
    ];
    const maxBar = 110.0;
    return SpecCard(
      child: SpecColumn(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(l10n.wellbeingLast7,
                      style: AppTextStyles.cardTitle)),
              Text(l10n.wellbeingHoursOfSleep, style: AppTextStyles.tiny),
            ],
          ),
          SizedBox(
            height: maxBar + 26,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final night in nights)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Builder(builder: (context) {
                          final hours = entries[night]?.sleepHours;
                          final short = hours != null &&
                              hours < WellbeingEntry.shortNightHours;
                          return Semantics(
                            label: hours == null
                                ? fullDayLabel(context, night)
                                : '${fullDayLabel(context, night)}: '
                                    '${context.localizeDigits(hours)} '
                                    '${l10n.wellbeingHoursUnit}',
                            child: Container(
                              width: 22,
                              height: hours == null
                                  ? 6
                                  : (hours / WellbeingEntry.maxHours * 1.6)
                                          .clamp(0.06, 1.0) *
                                      maxBar,
                              decoration: BoxDecoration(
                                color: hours == null
                                    ? AppColors.border
                                    : short
                                        ? AppColors.warningCardBorder
                                        : AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 6),
                        ExcludeSemantics(
                          child: Text(
                              letters.length == 7
                                  ? letters[night.weekday - 1]
                                  : '',
                              style: AppTextStyles.tiny),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: AppColors.warningCardBorder,
                    borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    l10n.wellbeingShortNight(context.localizeDigits(
                        WellbeingEntry.shortNightHours.toInt())),
                    style: AppTextStyles.tiny),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
