/// Phase 4 of the patient-app spec: consent for medical reports, the reports
/// themselves, and the daily sleep and mood log.
///
/// Pure Dart: no Flutter imports, no wire format.
library;

// ── Consent (`/me/consent?type=medical_reports`) ───────────────────────────

class ReportsConsent {
  const ReportsConsent({
    required this.currentVersion,
    required this.text,
    this.acceptedVersion,
    this.acceptedAt,
  });

  final String currentVersion;
  final String? acceptedVersion;
  final DateTime? acceptedAt;

  /// `text_ar`: the full consent text.
  final String text;

  /// A new version needs a new agreement.
  bool get needsAgreement => acceptedVersion != currentVersion;
}

// ── Medical reports (`/me/reports`) ────────────────────────────────────────

enum ReportCategory {
  labTest('lab_test'),
  imaging('imaging'),
  prescription('prescription'),
  medicalLetter('medical_letter'),
  other('other');

  const ReportCategory(this.wire);

  final String wire;

  static ReportCategory fromWire(Object? value) =>
      values.firstWhere((c) => c.wire == value, orElse: () => other);
}

class MedicalReport {
  const MedicalReport({
    required this.id,
    required this.category,
    required this.title,
    required this.mime,
    this.reportDate,
    this.sizeBytes,
    this.pages,
    this.nutritionistNote,
    this.reviewed = false,
    this.reviewedAt,
    this.uploadedAt,
  });

  /// Reports a patient can keep; uploading stops at this count.
  static const int maxReports = 30;

  /// Largest file the server accepts.
  static const int maxBytes = 10 * 1024 * 1024;

  static const int titleMaxLength = 120;

  final int id;
  final ReportCategory category;
  final String title;
  final String mime;
  final DateTime? reportDate;
  final int? sizeBytes;
  final int? pages;
  final String? nutritionistNote;
  final bool reviewed;
  final DateTime? reviewedAt;
  final DateTime? uploadedAt;

  bool get isPdf => mime == 'application/pdf';
}

/// What the patient sends from the upload screen. Images are already JPEG.
class ReportUpload {
  const ReportUpload({
    required this.bytes,
    required this.filename,
    required this.mime,
    required this.category,
    required this.title,
    this.reportDate,
  });

  final List<int> bytes;
  final String filename;
  final String mime;
  final ReportCategory category;
  final String title;
  final DateTime? reportDate;
}

/// The upload errors with their own message (422 codes, 403 consent).
enum ReportUploadError {
  consentRequired,
  tooLarge,
  typeNotAllowed,
  invalidImage,
  limitReached,
}

// ── Sleep and mood (`/me/wellbeing`) ───────────────────────────────────────

enum SleepQuality { good, ok, poor }

enum StressLevel { low, medium, high }

enum MoodLevel { good, ok, low }

/// One night: every field optional, but at least one is set.
class WellbeingEntry {
  const WellbeingEntry({
    required this.date,
    this.sleepHours,
    this.sleepQuality,
    this.stress,
    this.mood,
    this.note,
  });

  /// Hours run from 0 to 16 in half-hour steps.
  static const double maxHours = 16;
  static const int noteMaxLength = 280;

  /// Days back a night can still be edited.
  static const int editableDays = 7;

  /// A night under this many hours is drawn in the warning color.
  static const double shortNightHours = 6;

  /// The night the entry is for (its date, at local midnight).
  final DateTime date;
  final double? sleepHours;
  final SleepQuality? sleepQuality;
  final StressLevel? stress;
  final MoodLevel? mood;
  final String? note;

  bool get isEmpty =>
      sleepHours == null &&
      sleepQuality == null &&
      stress == null &&
      mood == null &&
      (note == null || note!.trim().isEmpty);
}
