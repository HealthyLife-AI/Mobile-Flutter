import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/logging/crash_reporter.dart';

class _RecordingSink implements CrashSink {
  bool? enabled;
  final List<({RedactedError error, StackTrace stack, bool fatal})> records =
      [];

  @override
  Future<void> setEnabled(bool value) async => enabled = value;

  @override
  Future<void> record(RedactedError error, StackTrace stack,
      {required bool fatal}) async {
    records.add((error: error, stack: stack, fatal: fatal));
  }
}

void main() {
  const secret = 'سارة أحمد: ضغط الدم 150/95';

  test('an error is reported as its type, never its text', () {
    final sink = _RecordingSink();
    CrashReporter(sink, enabled: true).report(
        const ApiException(secret, statusCode: 422), StackTrace.current);

    final sent = sink.records.single;
    expect('${sent.error}', 'ApiException');
    expect('${sent.error}', isNot(contains('سارة')));
    expect(sent.fatal, isFalse);
  });

  test('a framework error keeps no description of what was on screen', () {
    final reported =
        RedactedError.of(FlutterError('Text("$secret") overflowed'));
    expect('$reported', 'FlutterError');
  });

  test('nothing is sent when reporting is off, as in debug builds', () async {
    final sink = _RecordingSink();
    final reporter = CrashReporter(sink, enabled: false);

    await reporter.install();
    reporter.report(StateError(secret), StackTrace.current, fatal: true);

    expect(sink.enabled, isFalse);
    expect(sink.records, isEmpty);
  });

  test('reporting is off by default in a debug build', () {
    expect(kDebugMode, isTrue, reason: 'tests run in debug mode');
    expect(CrashReporter(_RecordingSink()).enabled, isFalse);
  });

  test('an uncaught framework error is reported as fatal', () async {
    final sink = _RecordingSink();
    final previous = FlutterError.onError;
    final previousPlatform = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = previous;
      PlatformDispatcher.instance.onError = previousPlatform;
    });
    FlutterError.onError = (_) {};

    await CrashReporter(sink, enabled: true).install();
    FlutterError.onError!(FlutterErrorDetails(
        exception: StateError(secret), stack: StackTrace.current));

    expect(sink.enabled, isTrue);
    expect('${sink.records.single.error}', 'StateError');
    expect(sink.records.single.fatal, isTrue);
  });
}
