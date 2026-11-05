/// The patient's nutritionist, from `GET /me/nutritionist` (API guide 9.1).
/// Pure Dart. Only [name] is always present; the screens hide every other
/// field the server left out.
class NutritionistProfile {
  const NutritionistProfile({
    required this.name,
    this.clinicName,
    this.specialty,
    this.whatsappNumber,
    this.bio,
    this.replyHours,
    this.gender,
  });

  final String name;

  /// `male`, `female`, or null when the server doesn't say (9.1). Picks the
  /// Arabic wording: «أخصائيك» or «أخصائيتك».
  final String? gender;
  final String? clinicName;
  final String? specialty;

  /// The number as the server sends it, such as `+970599123456`.
  final String? whatsappNumber;

  /// A short text the nutritionist wrote about herself.
  final String? bio;

  /// Free text for when she usually replies, such as `الأحد–الخميس 9–5`.
  final String? replyHours;

  /// The `https://wa.me/` link for [whatsappNumber], with digits only. Null
  /// when there is no number to call.
  Uri? get whatsappUri {
    final digits = whatsappNumber?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    return digits.isEmpty ? null : Uri.parse('https://wa.me/$digits');
  }
}
