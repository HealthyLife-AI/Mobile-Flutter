import 'package:flutter/foundation.dart';

/// The parts of the `GET /me/meal-plan` response that are read from the API
/// so far. Meals still render from [MockData] in meal_models.dart.
@immutable
class MealPlan {
  const MealPlan({this.patientInstructions = const []});

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      MealPlan(patientInstructions: parsePatientInstructions(json['patient_instructions']));

  /// The specialist's instructions to the patient, one entry per line.
  /// Empty when they wrote nothing, so the card is hidden, never blank.
  final List<String> patientInstructions;

  // Health data: the text itself must never reach logs or crash reports.
  @override
  String toString() => 'MealPlan(patientInstructions: ${patientInstructions.length} lines)';
}

// A "- " or "• " the specialist typed would otherwise render as a second
// bullet next to the card's own dot.
final RegExp _listMarker = RegExp(r'^[•·\-–*]\s+');

// Zero-width and bidi control characters (U+200B-U+200F, U+202A-U+202E,
// U+2060-U+206F): a line made only of these and spaces looks empty on
// screen, so it is treated as empty.
bool _isInvisible(int rune) =>
    (rune >= 0x200B && rune <= 0x200F) || (rune >= 0x202A && rune <= 0x202E) || (rune >= 0x2060 && rune <= 0x206F);

bool _looksEmpty(String line) => String.fromCharCodes(line.runes.where((r) => !_isInvisible(r))).trim().isEmpty;

/// Splits `patient_instructions` (plain text, lines separated by `\n`) into
/// bullet lines. `null`, a non-string, an empty string and whitespace-only
/// text all give `[]`.
List<String> parsePatientInstructions(Object? raw) {
  if (raw is! String) return const [];
  return raw
      .split(RegExp(r'\r\n|\r|\n'))
      .map((line) => line.trim().replaceFirst(_listMarker, ''))
      .where((line) => !_looksEmpty(line))
      .toList(growable: false);
}
