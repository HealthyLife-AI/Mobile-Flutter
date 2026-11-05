import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../domain/change_request_rules.dart';
import '../../domain/entities/patient_health_profile_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/health_profile/health_profile_cubit.dart';
import '../health_profile_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';

/// The three request forms (API guide 11.2). Each one checks the fields with
/// the rules in `change_request_rules.dart` before anything is sent, and
/// shows the server's refusal when it still refuses.

// ── Goal ────────────────────────────────────────────────────────────────────

class GoalRequestScreen extends StatefulWidget {
  const GoalRequestScreen({super.key, this.current});

  final HealthGoal? current;

  @override
  State<GoalRequestScreen> createState() => _GoalRequestScreenState();
}

class _GoalRequestScreenState extends State<GoalRequestScreen>
    with _RequestFormState<GoalRequestScreen> {
  late String? _goalType = _knownOrNull(goalTypes, widget.current?.goalType);
  late final TextEditingController _weight =
      TextEditingController(text: _numberText(widget.current?.targetWeightKg));
  late final TextEditingController _days = TextEditingController(
      text: widget.current?.trainingDaysPerWeek?.toString() ?? '');
  late final TextEditingController _details =
      TextEditingController(text: widget.current?.details ?? '');
  late DateTime? _targetDate = widget.current?.targetDate;
  late String? _activity =
      _knownOrNull(activityLevels, widget.current?.activityLevel);
  late String? _trainingLevel =
      _knownOrNull(trainingLevels, widget.current?.trainingLevel);
  late String? _trainingType =
      _knownOrNull(trainingTypes, widget.current?.trainingType);

  @override
  void dispose() {
    _weight.dispose();
    _days.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final errors = <String, String>{};
    final weight = _parseNumber(_weight.text, 'target_weight_kg', errors);
    final days = _parseInteger(_days.text, 'training_days_per_week', errors);
    errors.addAll(goalErrors(
      goalType: _goalType,
      targetWeightKg: weight,
      targetDate: _targetDate,
      trainingDaysPerWeek: days,
      details: _details.text,
      today: DateTime.now(),
    ));
    if (!_accept(errors)) return;

    await send(ChangeRequestDraft(
      kind: 'goal',
      action: 'edit',
      data: goalData(
        goalType: _goalType!,
        targetWeightKg: weight,
        targetDate: _targetDate,
        activityLevel: _activity,
        trainingDaysPerWeek: days,
        trainingLevel: _trainingLevel,
        trainingType: _trainingType,
        details: _details.text,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _FormScaffold(
      title: l10n.healthRequestGoalTitle,
      busy: busy,
      formError: formError,
      onSubmit: _submit,
      children: [
        _Dropdown(
          label: l10n.healthRequestGoalType,
          value: _goalType,
          options: [for (final t in goalTypes) (t, goalTypeLabel(l10n, t))],
          onChanged: (v) => setState(() => _goalType = v),
          error: messageFor('goal_type'),
        ),
        _TextInput(
          label: l10n.healthRequestTargetWeight,
          controller: _weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          error: messageFor('target_weight_kg'),
        ),
        _DateInput(
          label: l10n.healthRequestTargetDate,
          value: _targetDate,
          onPick: _pickTargetDate,
          error: messageFor('target_date'),
        ),
        _Dropdown(
          label: l10n.healthRequestActivity,
          value: _activity,
          options: [
            for (final a in activityLevels) (a, activityLabel(l10n, a) ?? a)
          ],
          onChanged: (v) => setState(() => _activity = v),
        ),
        _TextInput(
          label: l10n.healthRequestTrainingDays,
          controller: _days,
          keyboardType: TextInputType.number,
          error: messageFor('training_days_per_week'),
        ),
        if (_goalType == 'muscle_gain') ...[
          _Dropdown(
            label: l10n.healthRequestTrainingLevel,
            value: _trainingLevel,
            options: [
              for (final t in trainingLevels)
                (t, trainingLevelLabel(l10n, t) ?? t)
            ],
            onChanged: (v) => setState(() => _trainingLevel = v),
          ),
          _Dropdown(
            label: l10n.healthRequestTrainingType,
            value: _trainingType,
            options: [
              for (final t in trainingTypes)
                (t, trainingTypeLabel(l10n, t) ?? t)
            ],
            onChanged: (v) => setState(() => _trainingType = v),
          ),
        ],
        _TextInput(
          label: l10n.healthRequestDetails,
          controller: _details,
          maxLines: 3,
          error: messageFor('details'),
        ),
      ],
    );
  }

  Future<void> _pickTargetDate() async {
    final first = DateTime.now().add(const Duration(days: 1));
    final current = _targetDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          current != null && !current.isBefore(first) ? current : first,
      firstDate: first,
      lastDate: DateTime(first.year + 10),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }
}

// ── Medication ──────────────────────────────────────────────────────────────

class MedicationRequestScreen extends StatefulWidget {
  const MedicationRequestScreen({super.key, this.existing});

  /// Null to add a medication. Its `id` is required to change or remove one.
  final MedicationItem? existing;

  @override
  State<MedicationRequestScreen> createState() =>
      _MedicationRequestScreenState();
}

class _MedicationRequestScreenState extends State<MedicationRequestScreen>
    with _RequestFormState<MedicationRequestScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _dose =
      TextEditingController(text: widget.existing?.dose ?? '');
  late final TextEditingController _frequency =
      TextEditingController(text: widget.existing?.frequency ?? '');
  late final TextEditingController _reason =
      TextEditingController(text: widget.existing?.reason ?? '');
  late String _timing =
      _knownOrNull(medicationTimings, widget.existing?.timing) ?? 'any';
  late String _status =
      _knownOrNull(medicationStatuses, widget.existing?.status) ?? 'ongoing';
  late DateTime? _untilDate = widget.existing?.untilDate;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _frequency.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final today = DateTime.now();
    final errors = medicationErrors(
      name: _name.text,
      dose: _dose.text,
      frequency: _frequency.text,
      reason: _reason.text,
      status: _status,
      untilDate: _untilDate,
      today: today,
    );
    if (!_accept(errors)) return;

    final data = medicationData(
      name: _name.text,
      dose: _dose.text,
      frequency: _frequency.text,
      timing: _timing,
      reason: _reason.text,
      status: _status,
      untilDate: _untilDate,
    );
    final id = widget.existing?.id;
    await send(id == null
        ? ChangeRequestDraft(kind: 'medication', action: 'add', data: data)
        : ChangeRequestDraft(
            kind: 'medication', action: 'edit', targetId: id, data: data));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _FormScaffold(
      title: widget.existing == null
          ? l10n.healthRequestAddMedication
          : l10n.healthRequestMedicationTitleEdit,
      busy: busy,
      formError: formError,
      onSubmit: _submit,
      children: [
        _TextInput(
          label: l10n.healthRequestName,
          controller: _name,
          error: messageFor('name'),
        ),
        _TextInput(
          label: l10n.healthRequestDose,
          controller: _dose,
          error: messageFor('dose'),
        ),
        _TextInput(
          label: l10n.healthRequestFrequency,
          controller: _frequency,
          error: messageFor('frequency'),
        ),
        _Dropdown(
          label: l10n.healthRequestTiming,
          value: _timing,
          options: [
            for (final t in medicationTimings) (t, timingLabel(l10n, t))
          ],
          onChanged: (v) => setState(() => _timing = v ?? _timing),
        ),
        _TextInput(
          label: l10n.healthRequestReason,
          controller: _reason,
          maxLines: 2,
          error: messageFor('reason'),
        ),
        _LabelledField(
          label: l10n.healthRequestDuration,
          child: Wrap(spacing: 8, children: [
            ChoiceChip(
              label: Text(l10n.healthMedStatusOngoing),
              selected: _status == 'ongoing',
              onSelected: (_) => setState(() => _status = 'ongoing'),
            ),
            ChoiceChip(
              label: Text(l10n.healthRequestUntilDate),
              selected: _status == 'until',
              onSelected: (_) => setState(() => _status = 'until'),
            ),
          ]),
        ),
        if (_status == 'until')
          _DateInput(
            label: l10n.healthRequestUntilDate,
            value: _untilDate,
            onPick: _pickUntilDate,
            error: messageFor('until_date'),
          ),
      ],
    );
  }

  Future<void> _pickUntilDate() async {
    final today = DateTime.now();
    final first = DateTime(today.year, today.month, today.day);
    final current = _untilDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          current != null && !current.isBefore(first) ? current : first,
      firstDate: first,
      lastDate: DateTime(first.year + 5),
    );
    if (picked != null) setState(() => _untilDate = picked);
  }
}

// ── Allergy ─────────────────────────────────────────────────────────────────

class AllergyRequestScreen extends StatefulWidget {
  const AllergyRequestScreen({super.key, this.existing});

  /// Null to add an allergy. Its `id` is required to change or remove one.
  final AllergyItem? existing;

  @override
  State<AllergyRequestScreen> createState() => _AllergyRequestScreenState();
}

class _AllergyRequestScreenState extends State<AllergyRequestScreen>
    with _RequestFormState<AllergyRequestScreen> {
  late String? _group = _knownOrNull(allergyGroups, widget.existing?.group) ??
      (widget.existing == null ? null : 'other');
  late final TextEditingController _otherText = TextEditingController(
      text: widget.existing == null
          ? ''
          : (widget.existing!.otherText ??
              (widget.existing!.group == null ? widget.existing!.label : '')));
  late String? _class =
      _knownOrNull(allergyClasses, widget.existing?.allergyClass);
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');

  @override
  void dispose() {
    _otherText.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final errors = allergyErrors(
      group: _group,
      otherText: _otherText.text,
      allergyClass: _class,
      note: _note.text,
    );
    if (!_accept(errors)) return;

    final data = allergyData(
      group: _group!,
      otherText: _otherText.text,
      allergyClass: _class!,
      note: _note.text,
    );
    final id = widget.existing?.id;
    await send(id == null
        ? ChangeRequestDraft(kind: 'allergy', action: 'add', data: data)
        : ChangeRequestDraft(
            kind: 'allergy', action: 'edit', targetId: id, data: data));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _FormScaffold(
      title: widget.existing == null
          ? l10n.healthRequestAddAllergy
          : l10n.healthRequestAllergyTitleEdit,
      busy: busy,
      formError: formError,
      onSubmit: _submit,
      children: [
        _Dropdown(
          label: l10n.healthRequestAllergy,
          value: _group,
          options: [
            for (final g in allergyGroups) (g, allergyGroupLabel(l10n, g) ?? g)
          ],
          onChanged: (v) => setState(() => _group = v),
          error: messageFor('group'),
        ),
        if (_group == 'other')
          _TextInput(
            label: l10n.healthRequestOtherText,
            controller: _otherText,
            error: messageFor('other_text'),
          ),
        _Dropdown(
          label: l10n.healthRequestClass,
          value: _class,
          options: [
            for (final c in allergyClasses) (c, allergyClassLabel(l10n, c) ?? c)
          ],
          onChanged: (v) => setState(() => _class = v),
          error: messageFor('class'),
        ),
        _TextInput(
          label: l10n.healthRequestNote,
          controller: _note,
          maxLines: 2,
          error: messageFor('note'),
        ),
      ],
    );
  }
}

// ── Shared form state and widgets ───────────────────────────────────────────

/// The state every request form shares: the field errors, the server's
/// refusal, and the sending flag.
mixin _RequestFormState<T extends StatefulWidget> on State<T> {
  Map<String, String> _errors = const {};
  String? _formError;
  bool _busy = false;

  bool get busy => _busy;
  String? get formError => _formError;

  String? messageFor(String field) {
    final code = _errors[field];
    return code == null ? null : requestFieldError(context.l10n, field, code);
  }

  /// Shows the field errors. True when the form may be sent.
  bool _accept(Map<String, String> errors) {
    setState(() {
      _errors = errors;
      _formError = errors.isEmpty ? null : context.l10n.healthRequestInvalid;
    });
    return errors.isEmpty;
  }

  /// Sends the request. On success the form closes and the health record
  /// shows the new request. On a refusal the form stays with the reason.
  Future<void> send(ChangeRequestDraft draft) async {
    setState(() {
      _busy = true;
      _formError = null;
    });
    final result = await context.read<HealthProfileCubit>().submit(draft);
    if (!mounted) return;
    final failure = result.failureOrNull;
    if (failure == null) {
      final messenger = ScaffoldMessenger.of(context);
      final text = context.l10n.healthRequestSent;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(text)));
      return;
    }
    // A 422 from the server arrives as ApiFailure with the fields it names.
    // Those fields show the generic invalid text under them.
    final serverFields = switch (failure) {
      ApiFailure(:final fieldErrors) => fieldErrors,
      ValidationFailure(:final fieldErrors) => fieldErrors,
      _ => const <String, String>{},
    };
    setState(() {
      _busy = false;
      _errors = {for (final field in serverFields.keys) field: 'server'};
      _formError = requestFailureMessage(context.l10n, failure);
    });
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({
    super.key,
    required this.title,
    required this.busy,
    required this.formError,
    required this.onSubmit,
    required this.children,
  });

  final String title;
  final bool busy;
  final String? formError;
  final VoidCallback onSubmit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeaderBar(title: title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Text(l10n.healthRequestIntro, style: AppTextStyles.secondary),
          const SizedBox(height: 16),
          ...children,
          if (formError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(formError!,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.danger, fontWeight: FontWeight.w700)),
            ),
          GradientCtaButton(
            label: l10n.healthRequestSend,
            loading: busy,
            onPressed: busy ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

/// A label above a field.
class _LabelledField extends StatelessWidget {
  const _LabelledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}

InputDecoration _decoration(String? error) => InputDecoration(
      filled: true,
      fillColor: AppColors.surface,
      errorText: error,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        borderSide: BorderSide.none,
      ),
    );

class _TextInput extends StatelessWidget {
  const _TextInput({
    super.key,
    required this.label,
    required this.controller,
    this.error,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? error;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return _LabelledField(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _decoration(error),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.error,
  });

  final String label;
  final String? value;
  final List<(String, String)> options;
  final ValueChanged<String?> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return _LabelledField(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: _decoration(error),
        items: [
          for (final (code, text) in options)
            DropdownMenuItem<String>(value: code, child: Text(text)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
    this.error,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = value;
    return _LabelledField(
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        onTap: onPick,
        child: InputDecorator(
          decoration: _decoration(error),
          child: Text(
            date == null
                ? l10n.healthRequestChooseDate
                : context.localizeDigits(numericDate(date)),
            style: AppTextStyles.body,
          ),
        ),
      ),
    );
  }
}

// ── Parsing helpers ─────────────────────────────────────────────────────────

/// The value when it is one the rules know, otherwise null. A stored value the
/// app does not know must not reach a dropdown that cannot show it.
String? _knownOrNull(List<String> known, String? value) =>
    value != null && known.contains(value) ? value : null;

String _numberText(double? value) {
  if (value == null) return '';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

/// Null for an empty field. A text that is not a number is recorded in
/// [errors] and returns null.
double? _parseNumber(String text, String field, Map<String, String> errors) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final value = double.tryParse(trimmed.replaceAll(',', '.'));
  if (value == null) errors[field] = 'not_a_number';
  return value;
}

int? _parseInteger(String text, String field, Map<String, String> errors) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final value = int.tryParse(trimmed);
  if (value == null) errors[field] = 'not_a_number';
  return value;
}
