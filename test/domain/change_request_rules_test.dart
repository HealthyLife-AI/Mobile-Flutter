import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/change_request_rules.dart';

void main() {
  final today = DateTime(2026, 10, 14);

  group('goal', () {
    Map<String, String> goal({
      double? weight,
      DateTime? date,
      int? days,
      String goalType = 'weight_loss',
      String details = '',
    }) =>
        goalErrors(
          goalType: goalType,
          targetWeightKg: weight,
          targetDate: date,
          trainingDaysPerWeek: days,
          details: details,
          today: today,
        );

    test('a weight from 20 to 400 kg is accepted, outside it is not', () {
      expect(goal(weight: 20), isEmpty);
      expect(goal(weight: 400), isEmpty);
      expect(goal(weight: 19.5), {'target_weight_kg': 'out_of_range'});
      expect(goal(weight: 401), {'target_weight_kg': 'out_of_range'});
    });

    test('the target date must be after today, not today', () {
      expect(goal(date: DateTime(2026, 10, 14)),
          {'target_date': 'not_after_today'});
      expect(goal(date: DateTime(2026, 10, 15)), isEmpty);
    });

    test('training days run from 0 to 7', () {
      expect(goal(days: 0), isEmpty);
      expect(goal(days: 7), isEmpty);
      expect(goal(days: 8), {'training_days_per_week': 'out_of_range'});
    });

    test('a goal type is required, and the details are limited to 300', () {
      expect(goal(goalType: 'unknown'), {'goal_type': 'required'});
      expect(goal(details: 'x' * 300), isEmpty);
      expect(goal(details: 'x' * 301), {'details': 'too_long'});
    });

    test('training level and type are kept only for muscle gain', () {
      Map<String, dynamic> data(String goalType) => goalData(
            goalType: goalType,
            targetWeightKg: 70,
            targetDate: DateTime(2027, 1, 31),
            activityLevel: 'light',
            trainingDaysPerWeek: 3,
            trainingLevel: 'advanced',
            trainingType: 'cardio',
            details: '  ',
          );

      final loss = data('weight_loss');
      expect(loss['training_level'], isNull);
      expect(loss['training_type'], isNull);
      expect(loss['target_date'], '2027-01-31');
      expect(loss['details'], isNull);

      final muscle = data('muscle_gain');
      expect(muscle['training_level'], 'advanced');
      expect(muscle['training_type'], 'cardio');
    });
  });

  group('medication', () {
    Map<String, String> medication({
      String name = 'Vitamin D',
      String status = 'ongoing',
      DateTime? until,
    }) =>
        medicationErrors(
          name: name,
          dose: '',
          frequency: '',
          reason: '',
          status: status,
          untilDate: until,
          today: today,
        );

    test('a name is required', () {
      expect(medication(name: '   '), {'name': 'required'});
    });

    test('a course needs an end date today or later', () {
      expect(medication(status: 'until'), {'until_date': 'required'});
      expect(medication(status: 'until', until: DateTime(2026, 10, 13)),
          {'until_date': 'before_today'});
      expect(medication(status: 'until', until: today), isEmpty);
    });

    test('an ongoing medication sends no end date', () {
      final data = medicationData(
        name: '  Vitamin D  ',
        dose: '',
        frequency: '',
        timing: 'any',
        reason: '',
        status: 'ongoing',
        untilDate: DateTime(2026, 11, 1),
      );
      expect(data['name'], 'Vitamin D');
      expect(data['until_date'], isNull);
      expect(data['dose'], isNull);
    });
  });

  group('allergy', () {
    test('an other allergy needs its own text', () {
      expect(
          allergyErrors(
              group: 'other', otherText: ' ', allergyClass: 'avoid', note: ''),
          {'other_text': 'required'});
      expect(
          allergyErrors(
              group: 'other',
              otherText: 'الكزبرة',
              allergyClass: 'avoid',
              note: ''),
          isEmpty);
    });

    test('a group and a class are both required', () {
      expect(
          allergyErrors(
              group: null, otherText: '', allergyClass: null, note: ''),
          {'group': 'required', 'class': 'required'});
    });

    test('the other text is kept only for the other group', () {
      expect(
          allergyData(
              group: 'egg',
              otherText: 'ignored',
              allergyClass: 'intolerance',
              note: '')['other_text'],
          isNull);
      expect(
          allergyData(
              group: 'other',
              otherText: ' الكزبرة ',
              allergyClass: 'avoid',
              note: '')['other_text'],
          'الكزبرة');
    });
  });
}
