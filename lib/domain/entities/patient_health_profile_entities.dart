/// The patient's approved health profile from `GET /me/health-profile` (API
/// guide 11.1), and the change requests they have sent.
///
/// Coded values (goal type, timing, status, allergy class) stay as the server
/// sends them. A value this version does not know is still shown, through its
/// fallback label, instead of breaking the screen.
class PatientHealthProfile {
  const PatientHealthProfile({
    this.goal,
    this.medications = const [],
    this.allergies = const [],
    this.proposals = const [],
  });

  /// Null until the nutritionist or the patient sets one.
  final HealthGoal? goal;
  final List<MedicationItem> medications;
  final List<AllergyItem> allergies;

  /// The patient's own requests from the last 60 days, in any status.
  final List<ChangeProposal> proposals;
}

class HealthGoal {
  const HealthGoal({
    required this.goalType,
    this.targetWeightKg,
    this.targetDate,
    this.activityLevel,
    this.trainingDaysPerWeek,
    this.trainingLevel,
    this.trainingType,
    this.details,
  });

  /// `weight_loss`, `weight_gain`, `muscle_gain`, `weight_maintenance`,
  /// `health_energy`, `medical_condition` or `other`.
  final String goalType;
  final double? targetWeightKg;

  /// A calendar date, without a time.
  final DateTime? targetDate;
  final String? activityLevel;
  final int? trainingDaysPerWeek;
  final String? trainingLevel;
  final String? trainingType;
  final String? details;
}

class MedicationItem {
  const MedicationItem({
    required this.name,
    this.id,
    this.dose,
    this.frequency,
    this.timing = 'any',
    this.reason,
    this.status = 'ongoing',
    this.untilDate,
    this.reviewedAt,
    this.reviewNote,
  });

  final int? id;
  final String name;
  final String? dose;

  /// Free text written by the nutritionist, such as «مرتين يوميًا».
  final String? frequency;

  /// `before`, `with`, `after`, `empty_stomach` or `any`.
  final String timing;
  final String? reason;

  /// `ongoing` or `until`.
  final String status;
  final DateTime? untilDate;

  /// When the nutritionist last reviewed this medication. Shown as their
  /// note, never as advice from the app.
  final DateTime? reviewedAt;
  final String? reviewNote;
}

class AllergyItem {
  const AllergyItem({
    required this.label,
    required this.allergyClass,
    this.id,
    this.group,
    this.otherText,
    this.note,
  });

  final int? id;

  /// The group key, such as `tree_nuts`, or `other`.
  final String? group;

  /// The Arabic group name from the server, or the free text for `other`.
  final String label;
  final String? otherText;

  /// `confirmed_allergy`, `intolerance` or `avoid`.
  final String allergyClass;
  final String? note;
}

class ChangeProposal {
  const ChangeProposal({
    required this.kind,
    required this.action,
    required this.status,
    this.id,
    this.targetId,
    this.payload = const {},
    this.decisionNote,
    this.createdAt,
  });

  final int? id;

  /// `goal`, `medication` or `allergy`.
  final String kind;

  /// `add`, `edit` or `remove`.
  final String action;
  final int? targetId;

  /// What the patient asked for, as the server echoes it: the medication's
  /// name, the allergy's group, the goal's type.
  final Map<String, dynamic> payload;

  /// `pending`, `approved`, `rejected` or `withdrawn`.
  final String status;
  final String? decisionNote;
  final DateTime? createdAt;
}

/// A change the patient asks for (API guide 11.2). It takes effect only after
/// the nutritionist approves it.
class ChangeRequestDraft {
  const ChangeRequestDraft({
    required this.kind,
    required this.action,
    this.targetId,
    this.data,
  });

  /// `goal`, `medication` or `allergy`.
  final String kind;

  /// `add`, `edit` or `remove`. A goal is always sent as `edit`.
  final String action;

  /// Required for `edit` and `remove` of a medication or allergy.
  final int? targetId;

  /// The full item for `add` and `edit`. Null for `remove`.
  final Map<String, dynamic>? data;
}
