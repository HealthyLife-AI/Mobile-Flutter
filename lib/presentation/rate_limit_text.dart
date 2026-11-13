import '../core/errors/failure.dart';
import '../l10n/l10n.dart';

/// The message for a 429 (too many attempts). It says how long to wait when the
/// server's `Retry-After` is known, in seconds below a minute and in whole
/// minutes (rounded up) from there, and falls back to the general text when it
/// is not.
String rateLimitedText(AppLocalizations l10n, ApiFailure failure) {
  final seconds = failure.retryAfter?.inSeconds ?? 0;
  if (seconds <= 0) return l10n.loginErrorRateLimited;
  if (seconds < 60) return l10n.rateLimitedWaitSeconds(seconds);
  return l10n.rateLimitedWaitMinutes((seconds / 60).ceil());
}
