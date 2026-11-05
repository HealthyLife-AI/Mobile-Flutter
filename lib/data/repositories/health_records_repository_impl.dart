import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/time/date_only.dart';
import '../../domain/entities/health_records_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../models/json_read.dart';
import 'cached_response.dart';

/// Consent and `/me/reports`.
///
/// Every reports endpoint answers 404 until the privacy policy is published;
/// that 404 is read as "the feature is off" (null), never as an error. The
/// list and the files are never kept on the device.
class MedicalReportsRepositoryImpl implements MedicalReportsRepository {
  MedicalReportsRepositoryImpl(this._api, this._files);

  final ApiClient _api;

  /// Null when the API client cannot move files (a test fake).
  final FileTransferClient? _files;

  @override
  Future<Result<ReportsConsent?>> getConsent() => guard(
        () => _orOff(() async {
          final json = jsonMap(unwrapData(await _api
              .get('me/consent', query: {'type': 'medical_reports'})));
          final version =
              json == null ? null : jsonText(json['current_version']);
          if (json == null || version == null) return null;
          return ReportsConsent(
            currentVersion: version,
            acceptedVersion: jsonText(json['accepted_version']),
            acceptedAt: jsonDateTime(json['accepted_at']),
            text: jsonBody(json['text_ar']) ?? '',
          );
        }),
        context: 'MedicalReportsRepository.getConsent',
      );

  @override
  Future<Result<void>> acceptConsent() => guard(
        () async {
          await _api.post('me/consent', body: {'type': 'medical_reports'});
        },
        context: 'MedicalReportsRepository.acceptConsent',
      );

  @override
  Future<Result<List<MedicalReport>?>> getReports() => guard(
        () => _orOff(() async => parseReports(await _api.get('me/reports'))),
        context: 'MedicalReportsRepository.getReports',
      );

  @override
  Future<Result<List<int>>> downloadFile(int id) => guard(
        () async {
          final files = _files;
          if (files == null) {
            throw const UnexpectedException('File transfer unavailable');
          }
          return files.getBytes('me/reports/$id/file');
        },
        context: 'MedicalReportsRepository.downloadFile',
      );

  @override
  Future<Result<void>> delete(int id) => guard(
        () async {
          await _api.delete('me/reports/$id');
        },
        context: 'MedicalReportsRepository.delete',
      );

  @override
  Future<Result<MedicalReport>> upload(ReportUpload upload,
          {void Function(double progress)? onProgress}) =>
      guard(
        () async {
          final files = _files;
          if (files == null) {
            throw const UnexpectedException('File transfer unavailable');
          }
          final raw = await files.upload(
            'me/reports',
            fields: {
              'category': upload.category.wire,
              'title': upload.title.trim(),
              if (upload.reportDate != null)
                'report_date': dateOnly(upload.reportDate!),
            },
            fileField: 'file',
            bytes: upload.bytes,
            filename: upload.filename,
            contentType: upload.mime,
            onProgress: onProgress == null
                ? null
                : (sent, total) {
                    if (total > 0) onProgress((sent / total).clamp(0, 1));
                  },
          );
          final report = parseReport(jsonMap(unwrapData(raw)));
          if (report == null) {
            throw const ParseException('The uploaded report has no id');
          }
          return report;
        },
        context: 'MedicalReportsRepository.upload',
      );

  /// An uncoded 404 means the feature is off.
  static Future<T?> _orOff<T>(Future<T?> Function() read) async {
    try {
      return await read();
    } on NotFoundException {
      return null;
    }
  }

  static List<MedicalReport> parseReports(Object? raw) => [
        for (final r in jsonMaps(unwrapData(raw)))
          if (parseReport(r) case final report?) report,
      ];

  static MedicalReport? parseReport(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = jsonInt(json['id']);
    if (id == null) return null;
    return MedicalReport(
      id: id,
      category: ReportCategory.fromWire(json['category']),
      title: jsonText(json['title']) ?? '',
      mime: jsonText(json['mime']) ?? '',
      reportDate: jsonDate(json['report_date']),
      sizeBytes: jsonInt(json['size_bytes']),
      pages: jsonInt(json['pages']),
      nutritionistNote: jsonBody(json['nutritionist_note']),
      reviewed: jsonBool(json['reviewed']) ?? false,
      reviewedAt: jsonDateTime(json['reviewed_at']),
      uploadedAt: jsonDateTime(json['uploaded_at']),
    );
  }
}

/// The message an upload failure gets, from its code (or null for a failure
/// with no specific message).
ReportUploadError? reportUploadErrorOf(Failure failure) {
  if (failure is! ApiFailure) return null;
  final codes = {
    if (failure.code != null) failure.code!,
    ...failure.fieldErrors.values,
  };
  if (codes.contains('reports_consent_required')) {
    return ReportUploadError.consentRequired;
  }
  if (codes.contains('report_too_large')) return ReportUploadError.tooLarge;
  if (codes.contains('report_type_not_allowed') ||
      codes.contains('unsupported_image_format')) {
    return ReportUploadError.typeNotAllowed;
  }
  if (codes.contains('invalid_image')) return ReportUploadError.invalidImage;
  if (codes.contains('reports_limit_reached')) {
    return ReportUploadError.limitReached;
  }
  return null;
}

/// `/me/wellbeing`. The last range read is kept for offline reading.
class WellbeingRepositoryImpl implements WellbeingRepository, PatientCache {
  WellbeingRepositoryImpl(this._api, this._cache);

  final ApiClient _api;
  final CachedResponse _cache;

  @override
  Future<Result<List<WellbeingEntry>>> getRange(DateTime from, DateTime to) =>
      guard(
        () => _cache.read(
          () => _api.get('me/wellbeing',
              query: {'from': dateOnly(from), 'to': dateOnly(to)}),
          parseList,
        ),
        context: 'WellbeingRepository.getRange',
      );

  @override
  Future<Result<WellbeingEntry>> save(WellbeingEntry entry) => guard(
        () async {
          final note = entry.note?.trim();
          // The whole day is replaced: a field not sent is cleared.
          final raw =
              await _api.put('me/wellbeing/${dateOnly(entry.date)}', body: {
            if (entry.sleepHours != null) 'sleep_hours': entry.sleepHours,
            if (entry.sleepQuality != null)
              'sleep_quality': entry.sleepQuality!.name,
            if (entry.stress != null) 'stress': entry.stress!.name,
            if (entry.mood != null) 'mood': entry.mood!.name,
            if (note != null && note.isNotEmpty) 'note': note,
          });
          return parseEntry(jsonMap(unwrapData(raw))) ?? entry;
        },
        context: 'WellbeingRepository.save',
      );

  @override
  Future<Result<void>> delete(DateTime date) => guard(
        () async {
          await _api.delete('me/wellbeing/${dateOnly(date)}');
        },
        context: 'WellbeingRepository.delete',
      );

  /// Oldest first.
  static List<WellbeingEntry> parseList(Object? raw) => [
        for (final e in jsonMaps(unwrapData(raw)))
          if (parseEntry(e) case final entry?) entry,
      ]..sort((a, b) => a.date.compareTo(b.date));

  static WellbeingEntry? parseEntry(Map<String, dynamic>? json) {
    if (json == null) return null;
    final date = jsonDate(json['date']);
    if (date == null) return null;
    T? pick<T extends Enum>(List<T> values, Object? wire) {
      for (final v in values) {
        if (v.name == wire) return v;
      }
      return null;
    }

    return WellbeingEntry(
      date: date,
      sleepHours: jsonDouble(json['sleep_hours']),
      sleepQuality: pick(SleepQuality.values, json['sleep_quality']),
      stress: pick(StressLevel.values, json['stress']),
      mood: pick(MoodLevel.values, json['mood']),
      note: jsonText(json['note']),
    );
  }

  @override
  Future<void> forgetPatientData() => _cache.forgetPatientData();
}
