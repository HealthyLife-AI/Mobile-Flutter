import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/sync/pending_write.dart';
import 'package:healthylife_ai/core/sync/sync_policy.dart';

final DateTime _now = DateTime.utc(2026, 10, 7, 9);

PendingWrite _write({
  DateTime? queuedAt,
  int attempts = 0,
  Set<String> retried = const <String>{},
}) =>
    PendingWrite(
      id: 'w',
      path: 'me/meal-logs',
      body: const {'food_id': 3},
      queuedAt: queuedAt ?? _now,
      attempts: attempts,
      retriedWithout: retried,
    );

ApiException _api(int status,
        {String? code,
        Map<String, dynamic> body = const {},
        Duration? retryAfter}) =>
    ApiException('refused',
        statusCode: status, code: code, body: body, retryAfter: retryAfter);

SyncDecision _decide(PendingWrite write, AppException error) =>
    decideSync(write: write, error: error, now: _now);

void main() {
  group('backoffFor', () {
    test('starts at 2 seconds, doubles, and stops at 5 minutes', () {
      expect(backoffFor(0), const Duration(seconds: 2));
      expect(backoffFor(1), const Duration(seconds: 4));
      expect(backoffFor(3), const Duration(seconds: 16));
      expect(backoffFor(20), const Duration(minutes: 5));
    });
  });

  group('transient failures wait', () {
    test('no connection waits with backoff', () {
      final decision = _decide(
        _write(),
        NetworkException('offline', kind: NetworkFailureKind.offline),
      );

      expect(
          decision,
          isA<SyncWait>()
              .having((d) => d.delay, 'delay', const Duration(seconds: 2)));
    });

    test('a 5xx waits with backoff that grows with the failures', () {
      final decision = _decide(
        _write(attempts: 2),
        ServerException('down', statusCode: 503),
      );

      expect(
          decision,
          isA<SyncWait>()
              .having((d) => d.delay, 'delay', const Duration(seconds: 8)));
    });

    test('429 waits for Retry-After', () {
      final decision = _decide(
        _write(),
        _api(429, retryAfter: const Duration(seconds: 30)),
      );

      expect(
          decision,
          isA<SyncWait>()
              .having((d) => d.delay, 'delay', const Duration(seconds: 30)));
    });

    test('429 without Retry-After falls back to backoff', () {
      final decision = _decide(_write(), _api(429));

      expect(
          decision,
          isA<SyncWait>()
              .having((d) => d.delay, 'delay', const Duration(seconds: 2)));
    });
  });

  group('the queue stops', () {
    test('401 pauses until the session is back', () {
      expect(
        _decide(_write(), _api(401)),
        isA<SyncHalt>().having((d) => d.halt, 'halt', QueueHalt.unauthorized),
      );
      expect(
        _decide(
            _write(), const UnauthorizedException('no body', statusCode: 401)),
        isA<SyncHalt>().having((d) => d.halt, 'halt', QueueHalt.unauthorized),
      );
    });

    test('consent_required pauses the queue', () {
      expect(
        _decide(_write(), _api(403, code: 'consent_required')),
        isA<SyncHalt>()
            .having((d) => d.halt, 'halt', QueueHalt.consentRequired),
      );
    });

    test('follow_up_ended stops the queue', () {
      expect(
        _decide(_write(), _api(403, code: 'follow_up_ended')),
        isA<SyncHalt>().having((d) => d.halt, 'halt', QueueHalt.followUpEnded),
      );
    });
  });

  group('refusals', () {
    test('a locked entry is dropped as locked', () {
      expect(
        _decide(_write(), _api(403, code: 'log_locked')),
        isA<SyncDrop>().having((d) => d.reason, 'reason', DropReason.locked),
      );
    });

    test('any other 403 is dropped as rejected', () {
      expect(
        _decide(_write(), _api(403)),
        isA<SyncDrop>().having((d) => d.reason, 'reason', DropReason.rejected),
      );
    });

    test('entry_too_old is dropped as too old', () {
      expect(
        _decide(_write(), _api(422, code: 'entry_too_old')),
        isA<SyncDrop>().having((d) => d.reason, 'reason', DropReason.tooOld),
      );
    });

    test('an unrelated 422 is dropped as rejected', () {
      expect(
        _decide(
            _write(),
            _api(422, body: {
              'errors': {
                'food_id': ['unknown food']
              },
            })),
        isA<SyncDrop>().having((d) => d.reason, 'reason', DropReason.rejected),
      );
    });

    test('other client errors are dropped as rejected', () {
      expect(
        _decide(_write(), _api(409, code: 'slot_taken')),
        isA<SyncDrop>().having((d) => d.reason, 'reason', DropReason.rejected),
      );
    });

    test('a validation exception with no status is dropped as rejected', () {
      expect(
        _decide(_write(), const ValidationException('bad')),
        isA<SyncDrop>().having((d) => d.reason, 'reason', DropReason.rejected),
      );
    });
  });

  group('a removed meal item', () {
    final refused = {
      'errors': {
        'meal_item_id': ['not on the plan']
      },
    };

    test('is sent once more without it', () {
      expect(
        _decide(_write(), _api(422, body: refused)),
        isA<SyncResendWithout>()
            .having((d) => d.field, 'field', 'meal_item_id'),
      );
    });

    test('refused again after that is dropped', () {
      expect(
        _decide(_write(retried: {'meal_item_id'}), _api(422, body: refused)),
        isA<SyncDrop>().having((d) => d.reason, 'reason', DropReason.rejected),
      );
    });
  });

  group('a time ahead of the server', () {
    final refusedTime = {
      'errors': {
        'logged_at': ['must not be in the future']
      },
    };

    test('a write made just now is sent without its time', () {
      expect(
        _decide(_write(queuedAt: _now.subtract(const Duration(minutes: 3))),
            _api(422, body: refusedTime)),
        isA<SyncResendWithout>().having((d) => d.field, 'field', 'logged_at'),
      );
    });

    test('an older write is dropped as a clock problem', () {
      expect(
        _decide(_write(queuedAt: _now.subtract(const Duration(hours: 1))),
            _api(422, body: refusedTime)),
        isA<SyncDrop>()
            .having((d) => d.reason, 'reason', DropReason.clockAhead),
      );
    });

    test('recorded_at follows the same rule', () {
      final refusedDate = {
        'errors': {
          'recorded_at': ['after today']
        },
      };

      expect(
        _decide(_write(), _api(422, body: refusedDate)),
        isA<SyncResendWithout>().having((d) => d.field, 'field', 'recorded_at'),
      );
      expect(
        _decide(_write(queuedAt: _now.subtract(const Duration(days: 1))),
            _api(422, body: refusedDate)),
        isA<SyncDrop>()
            .having((d) => d.reason, 'reason', DropReason.clockAhead),
      );
    });

    test('a time already removed and refused again is dropped', () {
      expect(
        _decide(_write(retried: {'logged_at'}), _api(422, body: refusedTime)),
        isA<SyncDrop>()
            .having((d) => d.reason, 'reason', DropReason.clockAhead),
      );
    });
  });
}
