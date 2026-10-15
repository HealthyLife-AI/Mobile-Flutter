import '../core/time/date_only.dart';

/// The rules for the change requests of API guide 11.2. The server checks the
/// same rules. These checks let the patient see a problem before anything is
/// sent. Each check returns field → error code, and an empty map is valid.
///
/// Error codes: `required`, `not_a_number`, `out_of_range`, `too_long`,
/// `not_after_today` (a goal's target date) and `before_today` (the end of a
/// course).

const goalTypes = [
  'weight_loss',
  'weight_gain',
  'muscle_gain',
  'weight_maintenance',
  'health_energy',
  'medical_condition',
  'other',
];
const activityLevels = [
  'sedentary',
  'light',
  'moderate',
  'active',
  'very_active'
];
const trainingLevels = ['beginner', 'intermediate', 'advanced'];
const trainingTypes = ['strength', 'cardio', 'mixed', 'sports'];
const medicationTimings = ['before', 'with', 'after', 'empty_stomach', 'any'];
const medicationStatuses = ['ongoing', 'until'];
const allergyGroups = [
  'tree_nuts',
  'peanuts',
  'milk_lactose',
  'egg',
  'wheat_gluten',
  'sesame',
  'fish',
  'shellfish',
  'soy',
  'other',
];
const allergyClasses = ['confirmed_allergy', 'intolerance', 'avoid'];

/// Maximum length in characters, by field.
const lengthLimits = <String, int>{
  'name': 100,
  'dose': 100,
  'frequency': 100,
  'reason': 200,
  'other_text': 100,
  'details': 300,
  'note': 300,
};

/// Inclusive range, by field.
const rangeLimits = <String, (num, num)>{
  'target_weight_kg': (20, 400),
  'training_days_per_week': (0, 7),
};

DateTime _dayOf(DateTime date) => DateTime(date.year, date.month, date.day);

String? _blankToNull(String? text) {
  final trimmed = text?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

Map<String, String> _tooLong(
    Map<String, String> errors, String field, String text) {
  if (text.length > lengthLimits[field]!) errors[field] = 'too_long';
  return errors;
}

// ── Goal (kind goal) ────────────────────────────────────────────────────────

Map<String, String> goalErrors({
  required String? goalType,
  required double? targetWeightKg,
  required DateTime? targetDate,
  required int? trainingDaysPerWeek,
  required String details,
  required DateTime today,
}) {
  final errors = <String, String>{};
  if (goalType == null || !goalTypes.contains(goalType)) {
    errors['goal_type'] = 'required';
  }
  final (minKg, maxKg) = rangeLimits['target_weight_kg']!;
  if (targetWeightKg != null &&
      (targetWeightKg < minKg || targetWeightKg > maxKg)) {
    errors['target_weight_kg'] = 'out_of_range';
  }
  if (targetDate != null && !_dayOf(targetDate).isAfter(_dayOf(today))) {
    errors['target_date'] = 'not_after_today';
  }
  final (minDays, maxDays) = rangeLimits['training_days_per_week']!;
  if (trainingDaysPerWeek != null &&
      (trainingDaysPerWeek < minDays || trainingDaysPerWeek > maxDays)) {
    errors['training_days_per_week'] = 'out_of_range';
  }
  return _tooLong(errors, 'details', details);
}

/// The goal's data. Training level and type are kept only for muscle gain,
/// as the guide says.
Map<String, dynamic> goalData({
  required String goalType,
  required double? targetWeightKg,
  required DateTime? targetDate,
  required String? activityLevel,
  required int? trainingDaysPerWeek,
  required String? trainingLevel,
  required String? trainingType,
  required String details,
}) {
  final muscle = goalType == 'muscle_gain';
  return {
    'goal_type': goalType,
    'target_weight_kg': targetWeightKg,
    'target_date': targetDate == null ? null : dateOnly(targetDate),
    'activity_level': activityLevel,
    'training_days_per_week': trainingDaysPerWeek,
    'training_level': muscle ? trainingLevel : null,
    'training_type': muscle ? trainingType : null,
    'details': _blankToNull(details),
  };
}

// ── Medication (kind medication) ────────────────────────────────────────────

Map<String, String> medicationErrors({
  required String name,
  required String dose,
  required String frequency,
  required String reason,
  required String status,
  required DateTime? untilDate,
  required DateTime today,
}) {
  final errors = <String, String>{};
  if (name.trim().isEmpty) errors['name'] = 'required';
  _tooLong(errors, 'name', name.trim());
  _tooLong(errors, 'dose', dose.trim());
  _tooLong(errors, 'frequency', frequency.trim());
  _tooLong(errors, 'reason', reason.trim());
  if (!medicationStatuses.contains(status)) {
    errors['status'] = 'required';
  } else if (status == 'until') {
    if (untilDate == null) {
      errors['until_date'] = 'required';
    } else if (_dayOf(untilDate).isBefore(_dayOf(today))) {
      errors['until_date'] = 'before_today';
    }
  }
  return errors;
}

Map<String, dynamic> medicationData({
  required String name,
  required String dose,
  required String frequency,
  required String timing,
  required String reason,
  required String status,
  required DateTime? untilDate,
}) {
  return {
    'name': name.trim(),
    'dose': _blankToNull(dose),
    'frequency': _blankToNull(frequency),
    'timing': timing,
    'reason': _blankToNull(reason),
    'status': status,
    'until_date':
        status == 'until' && untilDate != null ? dateOnly(untilDate) : null,
  };
}

// ── Allergy (kind allergy) ──────────────────────────────────────────────────

Map<String, String> allergyErrors({
  required String? group,
  required String otherText,
  required String? allergyClass,
  required String note,
}) {
  final errors = <String, String>{};
  if (group == null || !allergyGroups.contains(group)) {
    errors['group'] = 'required';
  } else if (group == 'other') {
    if (otherText.trim().isEmpty) errors['other_text'] = 'required';
    _tooLong(errors, 'other_text', otherText.trim());
  }
  if (allergyClass == null || !allergyClasses.contains(allergyClass)) {
    errors['class'] = 'required';
  }
  return _tooLong(errors, 'note', note);
}

Map<String, dynamic> allergyData({
  required String group,
  required String otherText,
  required String allergyClass,
  required String note,
}) {
  return {
    'group': group,
    'other_text': group == 'other' ? otherText.trim() : null,
    'class': allergyClass,
    'note': _blankToNull(note),
  };
}
