import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/navigation/push_destination.dart';
import 'package:healthylife_ai/data/models/meal_plan_dto.dart';
import 'package:healthylife_ai/data/models/notification_preferences_dto.dart';
import 'package:healthylife_ai/data/repositories/engagement_repository_impl.dart';
import 'package:healthylife_ai/data/repositories/health_records_repository_impl.dart';
import 'package:healthylife_ai/data/repositories/patient_care_repository_impl.dart';
import 'package:healthylife_ai/domain/achievements.dart';
import 'package:healthylife_ai/domain/entities/engagement_entities.dart';
import 'package:healthylife_ai/domain/entities/health_records_entities.dart';
import 'package:healthylife_ai/domain/entities/meal_plan_entities.dart';
import 'package:healthylife_ai/domain/entities/patient_care_entities.dart';

import '../helpers/sample_meal_plan.dart';

/// The rules of the patient-app spec that live in the data and domain layers.
void main() {
  group('patient_instructions', () {
    test('one bullet per line', () {
      expect(
        parsePatientInstructions(
            'قلّل الصوديوم والأطعمة المصنّعة.\nقِس السكر قبل الوجبات وبعدها.\nحافظ على هدوئك.'),
        [
          'قلّل الصوديوم والأطعمة المصنّعة.',
          'قِس السكر قبل الوجبات وبعدها.',
          'حافظ على هدوئك.',
        ],
      );
    });

    test('null, empty and blank give no lines (the card is hidden)', () {
      for (final raw in <Object?>[null, '', '   ', ' \n\t\n \r\n', 7]) {
        expect(parsePatientInstructions(raw), isEmpty, reason: '$raw');
      }
    });

    test('CRLF, blank lines, typed bullets and invisible-only lines', () {
      final rlm = String.fromCharCode(0x200F);
      expect(
        parsePatientInstructions('  - أولًا \r\n\r\n• ثانيًا\n$rlm \n-5 كغ'),
        ['أولًا', 'ثانيًا', '-5 كغ'],
      );
    });

    test('read with the plan, with its activities and food tags', () {
      final json = samplePlanJson()
        ..['patient_instructions'] = 'سطر أول\nسطر ثاني'
        ..['activities'] = [
          {
            'id': 2,
            'title': 'تمارين تمدد',
            'duration_minutes': 10,
            'times_per_day': 2,
            'days_per_week': null,
            'sort_order': 1,
          },
          {
            'id': 1,
            'title': 'مشي خفيف',
            'description': 'بعد الغداء بساعة',
            'duration_minutes': 30,
            'times_per_day': 1,
            'days_per_week': 5,
            'sort_order': 0,
          },
          {'id': 3, 'title': 'بدون مدة', 'duration_minutes': 0},
        ];
      final meals = json['meals'] as List;
      final item = ((meals.first as Map)['items'] as List).first as Map;
      item['cost_tier'] = 'economical';
      item['prep_level'] = 'no_cook';

      final plan = MealPlanDto.fromJson(json)!;
      expect(plan.patientInstructions, ['سطر أول', 'سطر ثاني']);
      expect([
        for (final a in plan.activities) a.title
      ], [
        'مشي خفيف',
        'تمارين تمدد'
      ], reason: 'sorted by sort_order; one without a duration skipped');
      expect(plan.activities.first.daysPerWeek, 5);
      expect(plan.activities.last.daysPerWeek, isNull);
      expect(plan.activities.first.description, 'بعد الغداء بساعة');
      final first = plan.meals.first.items.first;
      expect(first.isEconomical, isTrue);
      expect(first.prepLevel, FoodPrepLevel.noCook);
    });

    test('a plan without the new fields still reads', () {
      final plan = MealPlanDto.fromJson(samplePlanJson())!;
      expect(plan.patientInstructions, isEmpty);
      expect(plan.activities, isEmpty);
      expect(plan.meals.first.items.first.costTier, FoodCostTier.unknown);
    });

    test('economical and no-cook alternatives come first', () {
      PlanItem item(int id,
              {FoodCostTier cost = FoodCostTier.unknown,
              FoodPrepLevel prep = FoodPrepLevel.unknown}) =>
          MealPlanDto.fromJson({
            'id': 1,
            'meals': [
              {
                'id': 1,
                'name': 'lunch',
                'items': [
                  {
                    'id': id,
                    'quantity_grams': 100,
                    'cost_tier':
                        cost == FoodCostTier.economical ? 'economical' : null,
                    'prep_level':
                        prep == FoodPrepLevel.noCook ? 'no_cook' : null,
                    'food': {'id': id, 'name_ar': 'صنف $id', 'name_en': 'x'},
                  }
                ],
              }
            ],
          })!
              .meals
              .first
              .items
              .first;
      final parent = PlanItem(
        id: 99,
        food: item(1).food,
        quantityGrams: 100,
        macros: Macros.zero,
        alternatives: [
          item(1),
          item(2, prep: FoodPrepLevel.noCook),
          item(3, cost: FoodCostTier.economical),
        ],
      );
      expect([for (final a in parent.alternativesByEase) a.id], [3, 2, 1]);
    });
  });

  group('measurement schedule', () {
    test('null and a schedule without a date mean none', () {
      expect(MeasurementScheduleRepositoryImpl.parse(null), isNull);
      expect(MeasurementScheduleRepositoryImpl.parse({'interval_days': 14}),
          isNull);
    });

    test('days until: ahead, today, late', () {
      final s = MeasurementScheduleRepositoryImpl.parse(
          {'interval_days': 14, 'next_due_on': '2026-11-09'})!;
      expect(s.intervalDays, 14);
      expect(s.daysUntil(DateTime(2026, 11, 3, 23, 59)), 6);
      expect(s.daysUntil(DateTime(2026, 11, 9, 8)), 0);
      expect(s.isDue(DateTime(2026, 11, 9)), isTrue);
      expect(s.daysUntil(DateTime(2026, 11, 12)), -3);
      expect(s.isDue(DateTime(2026, 11, 8)), isFalse);
    });
  });

  group('quick requests', () {
    test('newest first, statuses and replies', () {
      final list = QuickRequestRepositoryImpl.parseList([
        {
          'id': 1,
          'reason': 'food_unavailable',
          'status': 'closed',
          'response': 'بدّلي الشوفان بخبز قمح كامل.',
          'created_at': '2026-10-15T08:00:00+00:00',
        },
        {
          'id': 7,
          'reason': 'special_occasion',
          'note': 'عرس صديقتي',
          'occasion_date': '2026-11-02',
          'status': 'open',
          'response': null,
          'created_at': '2026-10-24T10:00:00+00:00',
        },
        {'reason': 'craving'},
      ]);
      expect([for (final r in list) r.id], [7, 1]);
      expect(list.first.reason, QuickRequestReason.specialOccasion);
      expect(list.first.isOpen, isTrue);
      expect(list.first.occasionDate, DateTime(2026, 11, 2));
      expect(list.last.status, QuickRequestStatus.closed);
      expect(list.last.response, isNotNull,
          reason: 'a closed request keeps its reply');
    });
  });

  group('check-in', () {
    test('questions come from the API; unusable ones are skipped', () {
      final checkin = CheckinRepositoryImpl.parseCheckin({
        'id': 12,
        'due_on': '2026-10-31',
        'questions': [
          {
            'key': 'adherence',
            'type': 'single',
            'label': 'كيف كان التزامك؟',
            'options': [
              {'value': 'good', 'label': 'جيد'},
            ],
          },
          {'key': 'empty', 'type': 'single', 'label': 'بلا خيارات'},
          {
            'key': 'barriers',
            'type': 'multi',
            'max': 3,
            'label': 'شو صعّب عليك؟',
            'options': [
              {'value': 'time', 'label': 'الوقت'},
              {'value': 'none', 'label': 'ولا شي'},
            ],
          },
          {'key': 'note', 'type': 'text', 'max': 280, 'label': 'ملاحظة'},
        ],
      })!;
      expect([for (final q in checkin.questions) q.key],
          ['adherence', 'barriers', 'note']);
      expect(checkin.questions[1].max, 3);
      expect(CheckinRepositoryImpl.parseCheckin(null), isNull);
    });

    test('"none" is exclusive and the maximum is enforced', () {
      expect(toggleMultiChoice(['time'], 'none', max: 3), ['none']);
      expect(toggleMultiChoice(['none'], 'time', max: 3), ['time']);
      expect(toggleMultiChoice(['a', 'b', 'c'], 'd', max: 3), isNull);
      expect(toggleMultiChoice(['a', 'b', 'c'], 'b', max: 3), ['a', 'c'],
          reason: 'a chosen option can always be cleared');
    });
  });

  group('food preferences', () {
    test("the nutritionist's entries are marked", () {
      final prefs = FoodPreferencesRepositoryImpl.parse({
        'likes': [
          {'food_id': 36, 'name_ar': 'خبز عربي', 'source': 'patient'},
          {'food_id': 4, 'name_ar': 'عدس', 'source': 'nutritionist'},
        ],
        'dislikes': [
          {'food_id': 1841, 'name_ar': 'باذنجان'},
        ],
      });
      expect(prefs.likes.map((f) => f.byNutritionist), [false, true]);
      expect(prefs.dislikes.single.foodId, 1841);
      expect(prefs.contains(4), isTrue);
    });
  });

  group('goal projection and weight insight', () {
    test('scenarios in high, medium, low order; null hides the card', () {
      final p = InsightsRepositoryImpl.parseProjection({
        'remaining_kg': 5.6,
        'direction': 'gain',
        'scenarios': [
          {'level': 'low', 'weeks': 42, 'reachable': false},
          {'level': 'high', 'weeks': 14, 'estimated_date': '2027-01-31'},
          {'level': 'medium', 'weeks': 21},
        ],
        'current_level': null,
        'disclaimer_ar': 'تقدير تقريبي',
      })!;
      expect([for (final s in p.scenarios) s.level],
          [ProjectionLevel.high, ProjectionLevel.medium, ProjectionLevel.low]);
      expect(p.direction, WeightDirection.gain);
      expect(p.currentLevel, isNull);
      expect(p.scenarios.last.reachable, isFalse);
      expect(InsightsRepositoryImpl.parseProjection(null), isNull);
    });

    test('the insight text is kept exactly', () {
      final insight = InsightsRepositoryImpl.parseInsight({
        'from_date': '2026-10-04',
        'to_date': '2026-10-10',
        'change_kg': -1.2,
        'text_ar': 'نزل وزنك\n\nلأنك التزمت.',
      })!;
      expect(insight.text, 'نزل وزنك\n\nلأنك التزمت.');
      expect(insight.changeKg, -1.2);
      expect(InsightsRepositoryImpl.parseInsight(null), isNull);
    });
  });

  group('today and posts', () {
    test('reminder types map to their screens', () {
      final today = TodayRepositoryImpl.parse({
        'date': '2026-10-26',
        'meals': [
          {'name': 'breakfast', 'name_ar': 'الفطور', 'window': 'الصبح'},
        ],
        'reminders': [
          {'type': 'checkin', 'text_ar': 'عندك استبيان قصير.'},
          {'type': 'wellbeing', 'text_ar': 'كيف كان نومك مبارح؟'},
          {'type': 'future_type', 'text_ar': '…'},
        ],
      });
      expect(today.meals.single.window, 'الصبح');
      expect([
        for (final r in today.reminders) r.type
      ], [
        TodayReminderType.checkin,
        TodayReminderType.wellbeing,
        TodayReminderType.unknown,
      ]);
      expect(today.motivation, isNull);
    });

    test('a posts page and its paging', () {
      final page = PostsRepositoryImpl.parsePage({
        'data': [
          {
            'id': 5,
            'title': 'قبل العزومة',
            'body': 'سطر\n\nسطر',
            'pinned': true,
            'is_read': false,
          },
        ],
        'meta': {'current_page': 1, 'last_page': 2},
      });
      expect(page.posts.single.pinned, isTrue);
      expect(page.posts.single.body, 'سطر\n\nسطر');
      expect(page.hasMore, isTrue);
    });
  });

  group('reports and wellbeing', () {
    test('upload codes map to their messages', () {
      ApiFailure failure(int status, String code) =>
          ApiFailure(statusCode: status, code: code);
      expect(reportUploadErrorOf(failure(403, 'reports_consent_required')),
          ReportUploadError.consentRequired);
      expect(reportUploadErrorOf(failure(422, 'report_too_large')),
          ReportUploadError.tooLarge);
      expect(reportUploadErrorOf(failure(422, 'unsupported_image_format')),
          ReportUploadError.typeNotAllowed);
      expect(reportUploadErrorOf(failure(422, 'reports_limit_reached')),
          ReportUploadError.limitReached);
      expect(reportUploadErrorOf(const NetworkFailure()), isNull);
    });

    test('a report and its review', () {
      final report = MedicalReportsRepositoryImpl.parseReport({
        'id': 3,
        'category': 'lab_test',
        'title': 'فحص السكر التراكمي',
        'mime': 'application/pdf',
        'size_bytes': 348160,
        'reviewed': true,
        'nutritionist_note': 'النتيجة أحسن.',
      })!;
      expect(report.category, ReportCategory.labTest);
      expect(report.isPdf, isTrue);
      expect(report.reviewed, isTrue);
    });

    test('nights oldest first', () {
      final nights = WellbeingRepositoryImpl.parseList([
        {'date': '2026-10-25', 'sleep_hours': 6.5, 'mood': 'low'},
        {'date': '2026-10-19', 'sleep_quality': 'good', 'stress': 'high'},
      ]);
      expect([for (final n in nights) n.date.day], [19, 25]);
      expect(nights.last.mood, MoodLevel.low);
      expect(nights.first.stress, StressLevel.high);
    });
  });

  group('notification categories', () {
    test("the server's categories, in its order, new ones included", () {
      final prefs = NotificationPreferencesDto.fromJson({
        'categories': {
          'morning': true,
          'meals': false,
          'education': false,
          'plan': true,
          'something_new': true,
        },
      });
      expect(prefs.categoryOrder, ['morning', 'meals', 'education', 'plan']);
      expect(prefs.education, isFalse);
      final request = NotificationPreferencesDto.toRequest(prefs);
      expect(request['education'], isFalse);
      expect(request.containsKey('something_new'), isFalse);
    });

    test('new categories are not sent when the server did not return them', () {
      final prefs = NotificationPreferencesDto.fromJson({
        'categories': {'meals': true, 'plan': true},
      });
      final request = NotificationPreferencesDto.toRequest(prefs);
      expect(request.containsKey('morning'), isFalse);
      expect(request.containsKey('education'), isFalse);
    });
  });

  group('pushes', () {
    test('the new types open their screens', () {
      expect(destinationForType('quick_request_answered'),
          PushDestination.myRequests);
      expect(destinationForType('measurement_due'),
          PushDestination.measurementSchedule);
      expect(destinationForType('morning'), PushDestination.home);
      expect(destinationForType('education'), PushDestination.post);
      expect(
          PushTap.fromData({'type': 'education', 'post_id': '5'})?.postId, '5');
    });
  });

  group('achievements', () {
    final today = DateTime(2026, 11, 3);

    test('streaks count consecutive logged days', () {
      final days = [
        DateTime(2026, 10, 28, 9),
        DateTime(2026, 10, 29, 13),
        DateTime(2026, 10, 29, 20),
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 2),
      ];
      expect(bestStreak(days), 2);
      expect(currentStreak(days, today: today), 2,
          reason: 'today not logged yet does not break the streak');
      expect(currentStreak(days, today: DateTime(2026, 11, 5)), 0);
    });

    test('nothing is earned without data', () {
      final all = computeAchievements(
          const AchievementInputs(mealDays: [], readingWeights: []));
      expect(all.where((a) => a.earned), isEmpty);
      expect(all.any((a) => a.kind == AchievementKind.firstKilos), isFalse,
          reason: 'no direction and no reading: no weight milestone');
    });

    test('weight milestones follow the goal direction', () {
      final all = computeAchievements(const AchievementInputs(
        mealDays: [],
        readingWeights: [80, 78.5, 77.6],
        goalType: 'weight_loss',
        targetWeightKg: 72,
      ));
      Achievement of(AchievementKind k) => all.firstWhere((a) => a.kind == k);
      expect(of(AchievementKind.firstKilos).earned, isTrue);
      expect(of(AchievementKind.halfway).earned, isFalse);
      expect(of(AchievementKind.halfway).progress, closeTo(0.6, 0.01));
      expect(of(AchievementKind.firstReading).earned, isTrue);
    });
  });
}
