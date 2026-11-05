import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/domain/entities/engagement_entities.dart';
import 'package:healthylife_ai/domain/entities/health_records_entities.dart';
import 'package:healthylife_ai/domain/entities/patient_care_entities.dart';

import '../helpers/scripted_api.dart';

const _offline = NetworkException('offline', kind: NetworkFailureKind.offline);

void main() {
  late ScriptedApi api;
  late AppDependencies deps;

  setUp(() {
    api = ScriptedApi();
    deps = AppDependencies.inMemory(api: api);
  });

  test('the schedule is kept, shown offline, and forgotten at sign-out',
      () async {
    api.routes['GET me/measurement-schedule'] = {
      'interval_days': 14,
      'next_due_on': '2026-11-09',
    };
    expect(
        (await deps.measurementSchedule.getSchedule())
            .valueOrNull
            ?.intervalDays,
        14);

    api.failAll = _offline;
    expect(
        (await deps.measurementSchedule.getSchedule())
            .valueOrNull
            ?.intervalDays,
        14,
        reason: 'the kept copy, without a connection');

    await deps.session.clear();
    expect(await deps.storage.readMap(StorageKeys.measurementSchedule), isNull);
    final afterSignOut = await deps.measurementSchedule.getSchedule();
    expect(afterSignOut.failureOrNull, isA<NetworkFailure>());
  });

  test('"no schedule" (null) is an answer, not an error', () async {
    api.routes['GET me/measurement-schedule'] = null;
    final result = await deps.measurementSchedule.getSchedule();
    expect(result.failureOrNull, isNull);
    expect(result.valueOrNull, isNull);
  });

  test('a quick request sends the date only for a special occasion', () async {
    api.routes['POST me/quick-requests'] = (SentRequest r) => {
          'id': 9,
          'status': 'open',
          ...(r.body as Map),
          'created_at': '2026-11-03T10:00:00+00:00',
        };
    await deps.quickRequests.send(QuickRequestDraft(
      reason: QuickRequestReason.craving,
      note: '  جوع بالليل  ',
      occasionDate: DateTime(2026, 11, 9),
    ));
    await deps.quickRequests.send(QuickRequestDraft(
      reason: QuickRequestReason.specialOccasion,
      occasionDate: DateTime(2026, 11, 9),
    ));
    final bodies = [
      for (final r in api.to('POST', 'me/quick-requests')) r.body as Map,
    ];
    expect(bodies.first, {'reason': 'craving', 'note': 'جوع بالليل'});
    expect(bodies.last,
        {'reason': 'special_occasion', 'occasion_date': '2026-11-09'});
  });

  test('the daily limit comes back with its code', () async {
    api.routes['POST me/quick-requests'] = const ApiException('limit',
        statusCode: 429, code: 'quick_request_limit');
    final result = await deps.quickRequests
        .send(const QuickRequestDraft(reason: QuickRequestReason.other));
    expect((result.failureOrNull as ApiFailure).code, 'quick_request_limit');
  });

  test('a night is replaced whole: unset fields are not sent', () async {
    api.routes['PUT me/wellbeing/2026-10-25'] =
        (SentRequest r) => {'date': '2026-10-25', ...(r.body as Map)};
    final saved = await deps.wellbeing.save(WellbeingEntry(
      date: DateTime(2026, 10, 25),
      sleepHours: 6.5,
      mood: MoodLevel.low,
    ));
    expect(api.sent.single.body, {'sleep_hours': 6.5, 'mood': 'low'});
    expect(saved.valueOrNull?.mood, MoodLevel.low);
  });

  test('reports answer null (feature off) on a 404, with no error', () async {
    final consent = await deps.medicalReports.getConsent();
    final reports = await deps.medicalReports.getReports();
    expect(consent.failureOrNull, isNull);
    expect(consent.valueOrNull, isNull);
    expect(reports.failureOrNull, isNull);
    expect(reports.valueOrNull, isNull);
  });

  test('a new consent version asks for agreement again', () async {
    api.routes['GET me/consent'] = {
      'type': 'medical_reports',
      'current_version': 'reports-2',
      'accepted_version': 'reports-1',
      'text_ar': 'النص الكامل',
    };
    final consent = (await deps.medicalReports.getConsent()).valueOrNull!;
    expect(consent.needsAgreement, isTrue);
    expect(api.sent.single.query, {'type': 'medical_reports'});
  });

  test('an upload sends its fields and keeps the file off any cache', () async {
    api.routes['POST me/reports'] = {
      'id': 4,
      'category': 'lab_test',
      'title': 'فحص',
      'mime': 'image/jpeg',
    };
    final progress = <double>[];
    final result = await deps.medicalReports.upload(
      ReportUpload(
        bytes: const [1, 2, 3],
        filename: 'scan.jpg',
        mime: 'image/jpeg',
        category: ReportCategory.labTest,
        title: ' فحص ',
        reportDate: DateTime(2026, 10, 20),
      ),
      onProgress: progress.add,
    );
    expect(result.valueOrNull?.id, 4);
    expect(progress.last, 1.0);
    expect(api.sent.single.body, {
      'category': 'lab_test',
      'title': 'فحص',
      'report_date': '2026-10-20',
      'file': 'scan.jpg',
      'content_type': 'image/jpeg',
    });
  });

  test('check-in answers are kept as a draft until sent', () async {
    await deps.checkins
        .saveDraft(const CheckinDraft(checkinId: 12, step: 2, answers: {
      'adherence': 'good',
      'barriers': ['time']
    }));
    expect((await deps.checkins.readDraft(12))?.step, 2);
    expect((await deps.checkins.readDraft(13)), isNull,
        reason: 'a draft belongs to its check-in only');

    api.routes['POST me/checkins/12'] = {'status': 'submitted'};
    await deps.checkins.submit(12, {'adherence': 'good'});
    expect(await deps.checkins.readDraft(12), isNull);
    expect(api.sent.last.body, {
      'answers': {'adherence': 'good'}
    });
  });

  test('saving food preferences reads them again when the reply has no lists',
      () async {
    api.routes['PUT me/food-preferences'] = {'message': 'ok'};
    api.routes['GET me/food-preferences'] = {
      'likes': [
        {'food_id': 36, 'name_ar': 'خبز عربي'},
      ],
      'dislikes': <Object>[],
    };
    final saved =
        await deps.foodPreferences.save(likes: [36], dislikes: const []);
    expect(saved.valueOrNull?.likes.single.foodId, 36);
    expect(api.to('PUT', 'me/food-preferences').single.body, {
      'likes': [36],
      'dislikes': <int>[]
    });
  });
}
