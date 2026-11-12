/// The health conditions the server knows, in its order.
///
/// Mirrors `App\Support\ConditionCodes::CODES` in the backend
/// (Backend-Laravel, app/Support/ConditionCodes.php). The server validates a
/// condition against exactly this set and serves no endpoint for the list, so
/// it is kept here; change both together. The labels are in the ARB files
/// (`conditionLabel` in presentation/health_profile_labels.dart) and follow
/// the server's Arabic `LABELS_AR`.
///
/// `other` carries free text. Anything the server has no code for (thyroid,
/// PCOS, IBS, cholesterol…) is entered that way.
const conditionCodes = [
  'diabetes_type1',
  'diabetes_type2',
  'gestational_diabetes',
  'insulin_resistance',
  'prediabetes',
  'hypertension',
  'kidney_disease',
  'liver_disease',
  'cancer',
  'celiac',
  'fluid_retention',
  'other',
];

/// The note that carries the conditions and free notes chosen in onboarding
/// to the nutritionist.
///
/// A patient cannot propose a condition through the API (proposals cover the
/// goal, medications and allergies only), so the choices travel as one quick
/// request note, which the server caps at [maxLength] characters. The text is
/// never cut: [fits] says whether it can be sent as written.
class OnboardingHealthNote {
  const OnboardingHealthNote(this.text, {this.maxLength = 280});

  /// The longest free text for the "other" condition.
  static const int otherMaxLength = 40;

  final String text;
  final int maxLength;

  bool get fits => text.length <= maxLength;

  /// Characters over the limit; zero when it fits.
  int get excess => fits ? 0 : text.length - maxLength;

  /// Builds the note, or null when there is nothing to say.
  ///
  /// [conditions] are the labels of the chosen coded conditions; [other] is
  /// the "other" label and [otherText] what the patient typed for it.
  /// [conditionsLine] and [notesLine] wrap each part in its heading.
  static OnboardingHealthNote? compose({
    required List<String> conditions,
    String? other,
    String otherText = '',
    String notes = '',
    required String separator,
    required String Function(String list) conditionsLine,
    required String Function(String notes) notesLine,
    int maxLength = 280,
  }) {
    final typedOther = otherText.trim();
    final items = [
      ...conditions,
      if (other != null && typedOther.isNotEmpty) '$other: $typedOther',
    ];
    final typedNotes = notes.trim();
    if (items.isEmpty && typedNotes.isEmpty) return null;
    return OnboardingHealthNote(
      [
        if (items.isNotEmpty) conditionsLine(items.join(separator)),
        if (typedNotes.isNotEmpty) notesLine(typedNotes),
      ].join('\n'),
      maxLength: maxLength,
    );
  }
}
