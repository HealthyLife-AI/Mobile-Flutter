import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/data/models/auth_dto.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';

void main() {
  group('AuthMapper.userFromJson', () {
    test('reads the id and uses defaults for the rest', () {
      final user = AuthMapper.userFromJson({'id': 1});
      expect(user.id, 1);
      expect(user.name, '');
      expect(user.username, isNull);
      expect(user.passwordIsTemporary, isFalse);
    });

    test('keeps the username and the temporary-password flag', () {
      final user = AuthMapper.userFromJson({
        'id': 31,
        'name': 'سارة أحمد',
        'username': 'sara.k',
        'password_is_temporary': true,
        'gender': 'female',
        'nutritionist_id': 4,
      });
      expect(user.name, 'سارة أحمد');
      expect(user.username, 'sara.k');
      expect(user.passwordIsTemporary, isTrue);
      expect(user.gender, 'female');
      expect(user.nutritionistId, 4);
    });

    test('throws ParseException without an id', () {
      expect(() => AuthMapper.userFromJson({'name': 'x'}),
          throwsA(isA<ParseException>()));
    });

    test('throws ParseException when the body is not an object', () {
      expect(() => AuthMapper.userFromJson('nope'),
          throwsA(isA<ParseException>()));
    });
  });

  group('AuthMapper token parsing', () {
    test('defaults expires_in to 15 minutes when the server omits it', () {
      final tokens = AuthMapper.tokensFromJson({
        'access_token': 'a',
        'refresh_token': 'r',
      });
      expect(tokens.accessToken, 'a');
      expect(tokens.refreshToken, 'r');
      expect(tokens.expiresIn, 900);
    });

    test('rejects an empty or missing refresh token', () {
      expect(
        () => AuthMapper.tokensFromJson(
            {'access_token': 'a', 'refresh_token': ''}),
        throwsA(isA<ParseException>()),
      );
      expect(
        () => AuthMapper.tokensFromJson({'access_token': 'a'}),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('AuthMapper.signedInFromJson', () {
    test('splits a sign-in body into tokens and user', () {
      final signedIn = AuthMapper.signedInFromJson({
        'access_token': 'a',
        'refresh_token': 'r',
        'expires_in': 900,
        'user': {'id': 31, 'name': 'Sara'},
      });
      expect(signedIn.tokens.refreshToken, 'r');
      expect(signedIn.user.id, 31);
    });
  });

  group('AuthMapper session cache', () {
    test('a stored session reads back as it was saved', () {
      const session = StoredSession(
        tokens: AuthTokens(accessToken: 'a', refreshToken: 'r', expiresIn: 600),
        user: PatientUser(
          id: 7,
          name: 'Lina',
          username: 'lina.k',
          passwordIsTemporary: true,
        ),
        onboardingCompleted: true,
      );
      final restored =
          AuthMapper.sessionFromJson(AuthMapper.sessionToJson(session));
      expect(restored.tokens.accessToken, 'a');
      expect(restored.tokens.expiresIn, 600);
      expect(restored.user.username, 'lina.k');
      expect(restored.user.passwordIsTemporary, isTrue);
      expect(restored.onboardingCompleted, isTrue);
    });

    test('a corrupt entry is rejected rather than half-read', () {
      expect(() => AuthMapper.sessionFromJson('nope'),
          throwsA(isA<ParseException>()));
    });
  });

  group('AuthMapper.consentFromJson', () {
    test('a null policy_url stays null, so the screen shows no link', () {
      final consent = AuthMapper.consentFromJson({
        'required': true,
        'current_version': '2026-10-01',
        'policy_url': null,
      });
      expect(consent.isRequired, isTrue);
      expect(consent.currentVersion, '2026-10-01');
      expect(consent.policyUrl, isNull);
    });
  });
}
