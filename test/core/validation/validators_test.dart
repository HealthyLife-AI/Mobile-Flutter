import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/validation/validators.dart';

void main() {
  group('PasswordPolicy.firstFailure (server rule, API guide 3.5)', () {
    test('reports a short password first', () {
      expect(PasswordPolicy.firstFailure('Ab1'), ValidationCode.tooShort);
    });

    test('then asks for an upper-case letter', () {
      expect(PasswordPolicy.firstFailure('abcdefg1'),
          ValidationCode.missingUppercase);
    });

    test('then asks for a lower-case letter', () {
      expect(PasswordPolicy.firstFailure('ABCDEFG1'),
          ValidationCode.missingLowercase);
    });

    test('then asks for a digit', () {
      expect(
          PasswordPolicy.firstFailure('Abcdefgh'), ValidationCode.missingDigit);
    });

    test('accepts upper, lower and a digit at eight characters', () {
      expect(PasswordPolicy.firstFailure('Abcdefg1'), isNull);
    });

    test('does not require a special character', () {
      expect(PasswordPolicy.firstFailure('Abcdef1x'), isNull);
    });
  });

  group('PasswordPolicy.score', () {
    test('counts one point per satisfied rule', () {
      expect(PasswordPolicy.score(''), 0);
      expect(PasswordPolicy.score('abc'), 1);
      expect(PasswordPolicy.score('Abcdefg1'), 4);
    });
  });

  group('PasswordPolicy.matchesConfirm', () {
    test('needs a non-empty confirmation that matches', () {
      expect(PasswordPolicy.matchesConfirm('Abcdefg1', 'Abcdefg1'), isTrue);
      expect(PasswordPolicy.matchesConfirm('', ''), isFalse);
      expect(PasswordPolicy.matchesConfirm('Abcdefg1', 'Abcdefg2'), isFalse);
    });
  });

  group('Validators', () {
    test('required rejects null and blank input', () {
      expect(Validators.required(null)?.code, ValidationCode.required);
      expect(Validators.required('   ')?.code, ValidationCode.required);
      expect(Validators.required('x'), isNull);
    });

    test('email accepts a plain address and rejects a malformed one', () {
      expect(Validators.email('a@b.co'), isNull);
      expect(Validators.email('bad')?.code, ValidationCode.invalidEmail);
    });

    test('length reports the bound it broke', () {
      final short = Validators.length('ab', min: 3);
      expect(short?.code, ValidationCode.tooShort);
      expect(short?.min, 3);
      expect(Validators.length('abcd', max: 3)?.code, ValidationCode.tooLong);
      expect(Validators.length('abc', min: 3, max: 3), isNull);
    });

    test('numberInRange accepts a comma as the decimal separator', () {
      expect(Validators.numberInRange('12,5', min: 0, max: 300), isNull);
    });

    test('numberInRange reports unparseable and out-of-range input', () {
      expect(Validators.numberInRange('abc', min: 0, max: 300)?.code,
          ValidationCode.invalidNumber);
      expect(Validators.numberInRange('400', min: 0, max: 300)?.code,
          ValidationCode.outOfRange);
    });
  });
}
