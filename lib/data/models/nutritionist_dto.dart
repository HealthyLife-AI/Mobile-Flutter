import '../../domain/entities/nutritionist_entities.dart';

/// Maps the `GET /me/nutritionist` object (API guide 9.1) to the domain, and
/// back again for the copy kept on the device.
abstract final class NutritionistDto {
  /// Null when the answer has no usable name, so there is nothing to show.
  static NutritionistProfile? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final name = _text(raw['name']);
    if (name == null) return null;
    return NutritionistProfile(
      name: name,
      clinicName: _text(raw['clinic_name']),
      specialty: _text(raw['specialty']),
      whatsappNumber: _text(raw['whatsapp_number']),
      bio: _text(raw['bio']),
      replyHours: _text(raw['reply_hours']),
      gender: switch (_text(raw['gender'])) {
        'male' => 'male',
        'female' => 'female',
        _ => null,
      },
    );
  }

  static Map<String, dynamic> toJson(NutritionistProfile profile) => {
        'name': profile.name,
        'clinic_name': profile.clinicName,
        'specialty': profile.specialty,
        'whatsapp_number': profile.whatsappNumber,
        'bio': profile.bio,
        'reply_hours': profile.replyHours,
        'gender': profile.gender,
      };

  /// The text with its spaces trimmed, or null when it is missing or blank.
  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
