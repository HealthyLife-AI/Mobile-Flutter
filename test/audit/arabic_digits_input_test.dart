// Audit (pre-launch 2026-11), sweep: numeric inputs typed on an Arabic
// keyboard (Arabic-Indic digits ٠-٩ and the Arabic decimal separator ٫).
// The parsers below are the ones the screens use (file:line in each reason).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/validation/validators.dart';

void main() {
  test('circumference / target weight: double.tryParse after , -> . '
      '(new_measurement_screen.dart:138-143, onboarding_measurements_screen.dart:191-196, '
      'change_request_forms.dart:675)', () {
    String norm(String t) => t.trim().replaceAll(',', '.');
    expect(double.tryParse(norm('90.5')), 90.5);
    expect(double.tryParse(norm('٩٠٫٥')), isNotNull,
        reason: 'Arabic keyboard input "٩٠٫٥" is rejected as not a number');
  });

  test('Validators.numberInRange (validators.dart:66-67)', () {
    expect(Validators.numberInRange('٩٠', min: 20, max: 300), isNull,
        reason: 'Arabic-Indic digits fail validation');
  });

  test('daily log grams field: FilteringTextInputFormatter.digitsOnly '
      '(daily_log_screen.dart:507) + int.tryParse (:481)', () {
    final out = FilteringTextInputFormatter.digitsOnly.formatEditUpdate(
        TextEditingValue.empty, const TextEditingValue(text: '١٥٠'));
    expect(out.text, '١٥٠',
        reason: 'typed Arabic digits are silently removed: field stays empty');
  });

  test('training days: int.tryParse (change_request_forms.dart:683)', () {
    expect(int.tryParse('٣'), 3, reason: 'Arabic digit 3 rejected');
  });
}
