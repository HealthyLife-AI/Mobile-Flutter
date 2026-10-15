import '../errors/app_exception.dart';
import 'pending_write.dart';

/// A device time this close to the moment a write was made is trusted enough
/// to send the write without its time (API guide 14.2).
const Duration justMadeWindow = Duration(minutes: 15);

/// The wait after the [failures]th failure: 2 seconds, doubling, at most
/// 5 minutes.
Duration backoffFor(int failures) {
  const baseSeconds = 2;
  const capSeconds = 300;
  final shift = failures < 0 ? 0 : (failures > 16 ? 16 : failures);
  final seconds = baseSeconds * (1 << shift);
  return Duration(seconds: seconds > capSeconds ? capSeconds : seconds);
}

/// Why a write was removed without being saved on the server.
enum DropReason {
  /// `422 entry_too_old`: the date is more than 90 days back, so the device
  /// clock is wrong.
  tooOld,

  /// The server refused a time or date (a future `logged_at` or
  /// `recorded_at`), and the write is too old to send without it.
  clockAhead,

  /// `403 log_locked`: the edit window has passed and the figures differ.
  locked,

  /// Any other refusal. Sending the same write again cannot succeed.
  rejected,
}

/// Where the queue stops. [waitingForRetry] is temporary. The others need the
/// patient or the session to change first.
enum QueueHalt { waitingForRetry, consentRequired, unauthorized, followUpEnded }

/// What to do after one send failed.
sealed class SyncDecision {
  const SyncDecision();
}

/// Remove the write, and tell the patient why.
final class SyncDrop extends SyncDecision {
  const SyncDrop(this.reason);

  final DropReason reason;
}

/// Send again once, without [field]. The rest of the write, including its
/// idempotency key, is kept.
final class SyncResendWithout extends SyncDecision {
  const SyncResendWithout(this.field);

  final String field;
}

/// Try again after [delay].
final class SyncWait extends SyncDecision {
  const SyncWait(this.delay);

  final Duration delay;
}

/// Stop the queue. The write stays where it is.
final class SyncHalt extends SyncDecision {
  const SyncHalt(this.halt);

  final QueueHalt halt;
}

/// Decides what to do after [error] for [write], at device time [now].
/// The table is API guide 14.2.
SyncDecision decideSync({
  required PendingWrite write,
  required AppException error,
  required DateTime now,
}) {
  if (error is NetworkException || error is ServerException) {
    return SyncWait(backoffFor(write.attempts));
  }
  if (error is UnauthorizedException) {
    return const SyncHalt(QueueHalt.unauthorized);
  }
  if (error is! ApiException) {
    return const SyncDrop(DropReason.rejected);
  }
  final status = error.statusCode;
  if (status == null) return const SyncDrop(DropReason.rejected);
  if (status >= 500) return SyncWait(backoffFor(write.attempts));
  if (status == 401) return const SyncHalt(QueueHalt.unauthorized);
  if (status == 429) {
    return SyncWait(error.retryAfter ?? backoffFor(write.attempts));
  }
  if (status == 403) return _forbidden(error);
  if (status == 422) return _invalid(write, error, now);
  return const SyncDrop(DropReason.rejected);
}

SyncDecision _forbidden(ApiException error) => switch (error.code) {
      'follow_up_ended' => const SyncHalt(QueueHalt.followUpEnded),
      'consent_required' => const SyncHalt(QueueHalt.consentRequired),
      'log_locked' => const SyncDrop(DropReason.locked),
      _ => const SyncDrop(DropReason.rejected),
    };

SyncDecision _invalid(PendingWrite write, ApiException error, DateTime now) {
  if (error.code == 'entry_too_old') return const SyncDrop(DropReason.tooOld);

  final refused = error.fieldErrors.keys.toSet();

  // The plan item was removed while the patient was offline. Send the meal
  // once more as an off-plan log, with the same key (14.2).
  if (refused.contains('meal_item_id')) {
    return write.retriedWithout.contains('meal_item_id')
        ? const SyncDrop(DropReason.rejected)
        : const SyncResendWithout('meal_item_id');
  }

  // A time or date ahead of the server's. The device clock is probably ahead.
  // A write made just now can go without it, and the server stamps it.
  // The API gives no separate code for "in the future", so the field name
  // is what identifies it.
  for (final field in const ['logged_at', 'recorded_at']) {
    if (!refused.contains(field)) continue;
    final justMade = now.difference(write.queuedAt) <= justMadeWindow;
    if (justMade && !write.retriedWithout.contains(field)) {
      return SyncResendWithout(field);
    }
    return const SyncDrop(DropReason.clockAhead);
  }

  return const SyncDrop(DropReason.rejected);
}
