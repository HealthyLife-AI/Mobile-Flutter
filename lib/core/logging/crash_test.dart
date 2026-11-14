import 'dart:async';

/// The error a test crash throws. Crash reports carry an error's type only
/// (see `RedactedError`), so this name is what shows in Crashlytics.
class CrashTestError implements Exception {
  const CrashTestError();

  @override
  String toString() => 'CrashTestError';
}

/// Throws [CrashTestError] outside any handler, a moment from now, so it
/// reaches the app's uncaught-error handler and is reported as a crash, as a
/// real one would be.
void triggerTestCrash({Duration after = const Duration(seconds: 1)}) {
  Timer(after, () => throw const CrashTestError());
}
