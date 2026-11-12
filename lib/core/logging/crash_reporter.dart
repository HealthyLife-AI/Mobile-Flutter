import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// What a crash report says about an error: its type, never its text.
///
/// An error's message can quote what was on screen or what the server said
/// (a name, a note, a health value), so it never leaves the device. The
/// report keeps the error's type and the stack trace, which name code only.
@immutable
class RedactedError implements Exception {
  const RedactedError(this.type);

  /// The reported form of [error].
  factory RedactedError.of(Object error) => RedactedError(
      error is FlutterError ? 'FlutterError' : '${error.runtimeType}');

  final String type;

  @override
  String toString() => type;
}

/// Where a crash is sent. The app talks to this, not to Crashlytics, so a
/// test can check exactly what would leave the device.
abstract interface class CrashSink {
  Future<void> setEnabled(bool enabled);
  Future<void> record(RedactedError error, StackTrace stack,
      {required bool fatal});
}

class CrashlyticsSink implements CrashSink {
  const CrashlyticsSink();

  @override
  Future<void> setEnabled(bool enabled) =>
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);

  @override
  Future<void> record(RedactedError error, StackTrace stack,
          {required bool fatal}) =>
      // `printDetails: false`: nothing more than the type is logged either.
      FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: fatal, printDetails: false);
}

/// Sends crashes to Firebase Crashlytics, with no patient data.
///
/// * Off in debug builds.
/// * No user identifier, no custom keys and no log lines (breadcrumbs) are
///   ever set: this class has no way to set them.
/// * An error is reported as its type and stack trace only ([RedactedError]).
class CrashReporter {
  CrashReporter(this._sink, {bool? enabled}) : enabled = enabled ?? !kDebugMode;

  final CrashSink _sink;

  /// False in debug builds.
  final bool enabled;

  /// Turns collection on or off and takes over the two places an uncaught
  /// error surfaces. Call once, after Firebase is ready.
  Future<void> install() async {
    await _sink.setEnabled(enabled);
    if (!enabled) return;

    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      previous?.call(details);
      report(details.exception, details.stack, fatal: true);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack, fatal: true);
      // Handled: the app keeps running where it can.
      return true;
    };
  }

  /// Reports [error] as its type and [stack]. Never throws.
  void report(Object error, StackTrace? stack, {bool fatal = false}) {
    if (!enabled) return;
    try {
      _sink
          .record(RedactedError.of(error), stack ?? StackTrace.empty,
              fatal: fatal)
          .catchError((Object _) {});
    } on Object {
      // Reporting a crash must not cause one.
    }
  }
}
