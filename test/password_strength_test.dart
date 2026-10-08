import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/widgets/password_strength_meter.dart';

void main() {
  group('evaluatePasswordStrength', () {
    test('empty input is "empty"', () {
      expect(evaluatePasswordStrength(''), PasswordStrength.empty);
    });

    test('short lowercase-only is weak', () {
      expect(evaluatePasswordStrength('abc'), PasswordStrength.weak);
    });

    test('length + uppercase + digit is good', () {
      expect(evaluatePasswordStrength('SalimHealth2024'), PasswordStrength.good);
    });

    test('all four rules met is strong', () {
      expect(evaluatePasswordStrength('SalimHealth2024!'), PasswordStrength.strong);
    });
  });
}
