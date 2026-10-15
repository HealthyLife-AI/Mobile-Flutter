import '../core/errors/failure.dart';
import '../domain/change_request_rules.dart';
import '../domain/entities/patient_health_profile_entities.dart';
import '../l10n/l10n.dart';

/// The patient's words for the server's coded values (API guide 16). An
/// unknown goal or timing gets its fallback label, and an unknown allergy
/// class gets none, so a raw code is never shown.

String goalTypeLabel(AppLocalizations l10n, String goalType) =>
    switch (goalType) {
      'weight_loss' => l10n.healthGoalWeightLoss,
      'weight_gain' => l10n.healthGoalWeightGain,
      'muscle_gain' => l10n.healthGoalMuscleGain,
      'weight_maintenance' => l10n.healthGoalWeightMaintenance,
      'health_energy' => l10n.healthGoalHealthEnergy,
      'medical_condition' => l10n.healthGoalMedicalCondition,
      _ => l10n.healthGoalOther,
    };

String timingLabel(AppLocalizations l10n, String timing) => switch (timing) {
      'before' => l10n.healthTimingBefore,
      'with' => l10n.healthTimingWith,
      'after' => l10n.healthTimingAfter,
      'empty_stomach' => l10n.healthTimingEmptyStomach,
      _ => l10n.healthTimingAny,
    };

String? allergyClassLabel(AppLocalizations l10n, String allergyClass) =>
    switch (allergyClass) {
      'confirmed_allergy' => l10n.healthAllergyClassConfirmed,
      'intolerance' => l10n.healthAllergyClassIntolerance,
      'avoid' => l10n.healthAllergyClassAvoid,
      _ => null,
    };

/// "Ongoing", or "Until <date>" for a course with an end date. [formatDate]
/// lets the screen write the date in the active language's digits.
String medicationStatusLabel(
  AppLocalizations l10n,
  MedicationItem medication, {
  required String Function(DateTime date) formatDate,
}) {
  final until = medication.untilDate;
  if (medication.status == 'until' && until != null) {
    return l10n.healthMedStatusUntil(formatDate(until));
  }
  return l10n.healthMedStatusOngoing;
}

/// One line for a medication: dose, timing and duration, joined with dots.
String medicationDetails(
  AppLocalizations l10n,
  MedicationItem medication, {
  required String Function(DateTime date) formatDate,
}) {
  final dose = medication.dose;
  return [
    if (dose != null) dose,
    timingLabel(l10n, medication.timing),
    medicationStatusLabel(l10n, medication, formatDate: formatDate),
  ].join(' · ');
}

String? allergyGroupLabel(AppLocalizations l10n, String group) =>
    switch (group) {
      'tree_nuts' => l10n.healthAllergyGroupTreeNuts,
      'peanuts' => l10n.healthAllergyGroupPeanuts,
      'milk_lactose' => l10n.healthAllergyGroupMilk,
      'egg' => l10n.healthAllergyGroupEgg,
      'wheat_gluten' => l10n.healthAllergyGroupWheat,
      'sesame' => l10n.healthAllergyGroupSesame,
      'fish' => l10n.healthAllergyGroupFish,
      'shellfish' => l10n.healthAllergyGroupShellfish,
      'soy' => l10n.healthAllergyGroupSoy,
      'other' => l10n.healthAllergyGroupOther,
      _ => null,
    };

String? activityLabel(AppLocalizations l10n, String level) => switch (level) {
      'sedentary' => l10n.healthActivitySedentary,
      'light' => l10n.healthActivityLight,
      'moderate' => l10n.healthActivityModerate,
      'active' => l10n.healthActivityActive,
      'very_active' => l10n.healthActivityVeryActive,
      _ => null,
    };

String? trainingLevelLabel(AppLocalizations l10n, String level) =>
    switch (level) {
      'beginner' => l10n.healthTrainingBeginner,
      'intermediate' => l10n.healthTrainingIntermediate,
      'advanced' => l10n.healthTrainingAdvanced,
      _ => null,
    };

String? trainingTypeLabel(AppLocalizations l10n, String type) => switch (type) {
      'strength' => l10n.healthTrainingStrength,
      'cardio' => l10n.healthTrainingCardio,
      'mixed' => l10n.healthTrainingMixed,
      'sports' => l10n.healthTrainingSports,
      _ => null,
    };

/// The section a request belongs to: goal, medication or allergy.
String? requestKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
      'goal' => l10n.healthRequestGoalSection,
      'medication' => l10n.healthRequestMedicationsSection,
      'allergy' => l10n.healthRequestAllergiesSection,
      _ => null,
    };

String? requestActionLabel(AppLocalizations l10n, String action) =>
    switch (action) {
      'add' => l10n.healthRequestActionAdd,
      'edit' => l10n.healthRequestActionEdit,
      'remove' => l10n.healthRequestActionRemove,
      _ => null,
    };

String? requestStatusLabel(AppLocalizations l10n, String status) =>
    switch (status) {
      'pending' => l10n.healthRequestStatusPending,
      'approved' => l10n.healthRequestStatusApproved,
      'rejected' => l10n.healthRequestStatusRejected,
      'withdrawn' => l10n.healthRequestStatusWithdrawn,
      _ => null,
    };

/// The message under one field of a request form, for a rule's error code.
String requestFieldError(AppLocalizations l10n, String field, String code) {
  switch (code) {
    case 'required':
      return l10n.healthRequestFieldRequired;
    case 'not_a_number':
      return l10n.healthRequestFieldNumber;
    case 'out_of_range':
      {
        final (min, max) = rangeLimits[field]!;
        return l10n.healthRequestFieldRange('$min', '$max');
      }
    case 'too_long':
      return l10n.healthRequestFieldTooLong('${lengthLimits[field]}');
    case 'not_after_today':
      return l10n.healthRequestFieldNotAfterToday;
    case 'before_today':
      return l10n.healthRequestFieldBeforeToday;
    default:
      return l10n.healthRequestInvalid;
  }
}

/// The snackbar text for a request the server or the network refused.
String requestFailureMessage(AppLocalizations l10n, Failure failure) {
  if (failure is NetworkFailure) return l10n.commonOfflineBody;
  if (failure is ValidationFailure) return l10n.healthRequestInvalid;
  if (failure is ApiFailure) {
    return switch (failure.code) {
      'proposal_invalid' => l10n.healthRequestInvalid,
      'proposal_exists' => l10n.healthRequestAlreadyPending,
      'already_recorded' => l10n.healthRequestAlreadyRecorded,
      'proposal_not_pending' => l10n.healthRequestNotPending,
      _ => l10n.commonErrorBody,
    };
  }
  return l10n.commonErrorBody;
}
