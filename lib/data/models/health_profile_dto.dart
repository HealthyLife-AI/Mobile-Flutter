import '../../domain/entities/patient_health_profile_entities.dart';

/// Maps the `GET /me/health-profile` object (API guide 11.1) to the domain.
///
/// Parsing is tolerant on purpose. A missing optional field becomes null, and
/// an item without enough to show is skipped. An allergy is never skipped for
/// lacking a label, because a patient must still see it. The whole answer is
/// refused only when one of its lists is not a list at all.
abstract final class HealthProfileDto {
  static PatientHealthProfile? fromJson(Object? raw) {
    if (raw is! Map) return null;

    final goal = raw['goal'];
    if (goal != null && goal is! Map) return null;

    final medications = _items(raw['medications'], _medication);
    final allergies = _items(raw['allergies'], _allergy);
    final proposals = _items(raw['proposals'], _proposal);
    if (medications == null || allergies == null || proposals == null) {
      return null;
    }

    return PatientHealthProfile(
      goal: goal is Map ? _goal(goal) : null,
      medications: medications,
      allergies: allergies,
      proposals: proposals,
    );
  }

  /// Null when [raw] is present but is not a list.
  static List<T>? _items<T>(Object? raw, T? Function(Map item) read) {
    if (raw == null) return const [];
    if (raw is! List) return null;
    final out = <T>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final value = read(item);
      if (value != null) out.add(value);
    }
    return out;
  }

  static HealthGoal? _goal(Map raw) {
    final goalType = _text(raw['goal_type']);
    if (goalType == null) return null;
    return HealthGoal(
      goalType: goalType,
      targetWeightKg: _number(raw['target_weight_kg']),
      targetDate: _date(raw['target_date']),
      activityLevel: _text(raw['activity_level']),
      trainingDaysPerWeek: _int(raw['training_days_per_week']),
      trainingLevel: _text(raw['training_level']),
      trainingType: _text(raw['training_type']),
      details: _text(raw['details']),
    );
  }

  static MedicationItem? _medication(Map raw) {
    final name = _text(raw['name']);
    if (name == null) return null;
    return MedicationItem(
      id: _int(raw['id']),
      name: name,
      dose: _text(raw['dose']),
      frequency: _text(raw['frequency']),
      timing: _text(raw['timing']) ?? 'any',
      reason: _text(raw['reason']),
      status: _text(raw['status']) ?? 'ongoing',
      untilDate: _date(raw['until_date']),
      reviewedAt: _date(raw['reviewed_at']),
      reviewNote: _text(raw['review_note']),
    );
  }

  static AllergyItem? _allergy(Map raw) {
    final group = _text(raw['group']);
    final label = _text(raw['label']) ?? _text(raw['other_text']) ?? group;
    if (label == null) return null;
    return AllergyItem(
      id: _int(raw['id']),
      group: group,
      label: label,
      otherText: _text(raw['other_text']),
      // A missing class is treated as the strictest reading, so the allergy
      // is still shown as something to avoid.
      allergyClass: _text(raw['class']) ?? 'avoid',
      note: _text(raw['note']),
    );
  }

  static ChangeProposal? _proposal(Map raw) {
    final kind = _text(raw['kind']);
    final action = _text(raw['action']);
    final status = _text(raw['status']);
    if (kind == null || action == null || status == null) return null;
    return ChangeProposal(
      id: _int(raw['id']),
      kind: kind,
      action: action,
      status: status,
      targetId: _int(raw['target_id']),
      payload: raw['payload'] is Map
          ? Map<String, dynamic>.from(raw['payload'] as Map)
          : const {},
      decisionNote: _text(raw['decision_note']),
      createdAt: _date(raw['created_at']),
    );
  }

  /// The body of `POST /me/proposals` (API guide 11.2). The request field is
  /// `data`. A removal sends no `data`, and only `edit` and `remove` send a
  /// `target_id`.
  static Map<String, dynamic> requestJson(ChangeRequestDraft draft) => {
        'kind': draft.kind,
        'action': draft.action,
        if (draft.targetId != null) 'target_id': draft.targetId,
        if (draft.data != null) 'data': draft.data,
      };

  /// The text with its spaces trimmed, or null when it is missing or blank.
  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : null;

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    return null;
  }

  /// A date, with or without a time. Null when it does not parse.
  static DateTime? _date(Object? value) {
    final text = _text(value);
    return text == null ? null : DateTime.tryParse(text);
  }
}
