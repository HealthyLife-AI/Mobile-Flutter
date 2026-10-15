import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/models/health_profile_dto.dart';

void main() {
  test('maps the health profile of guide 11.1', () {
    final profile = HealthProfileDto.fromJson({
      'goal': {
        'goal_type': 'weight_loss',
        'target_weight_kg': 70,
        'target_date': '2027-01-31',
        'activity_level': 'light',
        'training_days_per_week': 3,
        'training_level': null,
        'training_type': null,
        'details': null,
      },
      'medications': [
        {
          'id': 5,
          'name': 'Metformin',
          'dose': '500mg',
          'frequency': 'مرتين يوميًا',
          'timing': 'with',
          'reason': '…',
          'status': 'ongoing',
          'until_date': null,
          'reviewed_at': '2026-10-05T10:00:00+00:00',
          'review_note': '…',
        }
      ],
      'allergies': [
        {
          'id': 2,
          'group': 'tree_nuts',
          'other_text': null,
          'label': 'المكسرات',
          'class': 'confirmed_allergy',
          'note': null,
        }
      ],
      'proposals': [
        {
          'id': 14,
          'kind': 'allergy',
          'action': 'add',
          'target_id': null,
          'payload': {'group': 'egg', 'class': 'intolerance'},
          'status': 'pending',
          'decision_note': null,
          'decided_at': null,
          'created_at': '2026-10-12T09:00:00+00:00',
        }
      ],
    });

    final goal = profile?.goal;
    expect(goal?.goalType, 'weight_loss');
    expect(goal?.targetWeightKg, 70.0);
    expect(goal?.targetDate, DateTime(2027, 1, 31));
    expect(goal?.trainingDaysPerWeek, 3);

    expect(profile?.medications.single.name, 'Metformin');
    expect(profile?.medications.single.timing, 'with');
    expect(profile?.medications.single.reviewedAt, isNotNull);
    expect(profile?.medications.single.reviewNote, '…');

    expect(profile?.allergies.single.label, 'المكسرات');
    expect(profile?.allergies.single.allergyClass, 'confirmed_allergy');

    expect(profile?.proposals.single.status, 'pending');
    expect(profile?.proposals.single.targetId, isNull);
  });

  test('a profile with no goal and nothing recorded is still a profile', () {
    final profile = HealthProfileDto.fromJson({
      'goal': null,
      'medications': [],
      'allergies': [],
      'proposals': [],
    });

    expect(profile, isNotNull);
    expect(profile?.goal, isNull);
    expect(profile?.medications, isEmpty);
    expect(profile?.allergies, isEmpty);
  });

  test(
      'an answer that is not an object, or a list that is not a list, is refused',
      () {
    expect(HealthProfileDto.fromJson('not an object'), isNull);
    expect(HealthProfileDto.fromJson({'medications': 'oops'}), isNull);
    expect(
        HealthProfileDto.fromJson({
          'allergies': {'id': 1}
        }),
        isNull);
    expect(HealthProfileDto.fromJson({'goal': 'weight loss'}), isNull);
  });

  test('a medication without a name is skipped, the others are kept', () {
    final profile = HealthProfileDto.fromJson({
      'medications': [
        {'id': 1},
        {'id': 2, 'name': 'Vitamin D'},
      ],
    });

    expect(profile?.medications.map((m) => m.name), ['Vitamin D']);
  });

  test('an allergy is never dropped for lacking a label', () {
    final profile = HealthProfileDto.fromJson({
      'allergies': [
        {'group': 'other', 'other_text': 'الكزبرة', 'class': 'intolerance'},
        {'group': 'egg', 'class': 'intolerance'},
      ],
    });

    expect(profile?.allergies.map((a) => a.label), ['الكزبرة', 'egg']);
  });

  test('a missing allergy class is read as the strictest one', () {
    final profile = HealthProfileDto.fromJson({
      'allergies': [
        {'group': 'egg', 'label': 'البيض'},
      ],
    });

    expect(profile?.allergies.single.allergyClass, 'avoid');
  });

  test('a medication with no timing or status gets the server defaults', () {
    final profile = HealthProfileDto.fromJson({
      'medications': [
        {'name': 'Vitamin D'},
      ],
    });

    expect(profile?.medications.single.timing, 'any');
    expect(profile?.medications.single.status, 'ongoing');
    expect(profile?.medications.single.untilDate, isNull);
  });
}
