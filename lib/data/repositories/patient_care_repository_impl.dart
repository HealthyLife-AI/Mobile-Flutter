import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/time/date_only.dart';
import '../../domain/entities/patient_care_entities.dart';
import '../../domain/repositories/patient_care_repository.dart';
import '../models/json_read.dart';
import 'cached_response.dart';

/// `GET /me/measurement-schedule` → `{interval_days, next_due_on}` or null.
/// The last answer is kept for offline reading.
class MeasurementScheduleRepositoryImpl
    implements MeasurementScheduleRepository, PatientCache {
  MeasurementScheduleRepositoryImpl(this._api, this._cache);

  final ApiClient _api;
  final CachedResponse _cache;

  @override
  Future<Result<MeasurementSchedule?>> getSchedule() => guard(
        () => _cache.read(() => _api.get('me/measurement-schedule'), parse),
        context: 'MeasurementScheduleRepository.getSchedule',
      );

  /// Null, an empty body, or a schedule without a usable date: no schedule.
  static MeasurementSchedule? parse(Object? raw) {
    final json = jsonMap(unwrapData(raw));
    if (json == null) return null;
    final due = jsonDate(json['next_due_on']);
    final interval = jsonInt(json['interval_days']);
    if (due == null || interval == null || interval <= 0) return null;
    return MeasurementSchedule(intervalDays: interval, nextDueOn: due);
  }

  @override
  Future<void> forgetPatientData() => _cache.forgetPatientData();
}

/// `GET` / `POST /me/quick-requests`. The list is kept for offline reading;
/// sending needs a connection (no request is queued).
class QuickRequestRepositoryImpl
    implements QuickRequestRepository, PatientCache {
  QuickRequestRepositoryImpl(this._api, this._cache);

  final ApiClient _api;
  final CachedResponse _cache;

  @override
  Future<Result<List<QuickRequest>>> getRequests() => guard(
        () => _cache.read(() => _api.get('me/quick-requests'), parseList),
        context: 'QuickRequestRepository.getRequests',
      );

  @override
  Future<Result<QuickRequest>> send(QuickRequestDraft draft) => guard(
        () async {
          final note = draft.note?.trim();
          final raw = await _api.post('me/quick-requests', body: {
            'reason': draft.reason.wire,
            if (note != null && note.isNotEmpty) 'note': note,
            if (draft.reason == QuickRequestReason.specialOccasion &&
                draft.occasionDate != null)
              'occasion_date': dateOnly(draft.occasionDate!),
          });
          final request = parse(jsonMap(unwrapData(raw)));
          if (request == null) {
            throw const ParseException('The quick request has no id');
          }
          return request;
        },
        context: 'QuickRequestRepository.send',
      );

  /// Newest first, whatever order the server used.
  static List<QuickRequest> parseList(Object? raw) {
    final requests = [
      for (final json in jsonMaps(unwrapData(raw)))
        if (parse(json) case final request?) request,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  static QuickRequest? parse(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = jsonInt(json['id']);
    if (id == null) return null;
    return QuickRequest(
      id: id,
      reason: QuickRequestReason.fromWire(json['reason']),
      status: switch (json['status']) {
        'open' => QuickRequestStatus.open,
        'answered' => QuickRequestStatus.answered,
        'closed' => QuickRequestStatus.closed,
        _ => QuickRequestStatus.unknown,
      },
      createdAt: jsonDateTime(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      note: jsonText(json['note']),
      occasionDate: jsonDate(json['occasion_date']),
      response: jsonBody(json['response']),
      respondedAt: jsonDateTime(json['responded_at']),
    );
  }

  @override
  Future<void> forgetPatientData() => _cache.forgetPatientData();
}
