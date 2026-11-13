import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/rate_limit_text.dart';

ApiFailure _limited(int? seconds) => ApiFailure(
    statusCode: 429,
    retryAfter: seconds == null ? null : Duration(seconds: seconds));

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('under a minute it says the seconds', () {
    expect(rateLimitedText(en, _limited(30)), contains('30 seconds'));
    expect(rateLimitedText(en, _limited(1)), contains('1 second.'));
    expect(rateLimitedText(ar, _limited(30)), contains('30 ثانية'));
    expect(rateLimitedText(ar, _limited(5)), contains('5 ثوانٍ'));
    expect(rateLimitedText(ar, _limited(2)), contains('ثانيتين'));
  });

  test('from a minute on it says whole minutes, rounded up', () {
    expect(rateLimitedText(en, _limited(60)), contains('1 minute.'));
    expect(rateLimitedText(en, _limited(61)), contains('2 minutes'));
    expect(rateLimitedText(ar, _limited(60)), contains('دقيقة.'));
    expect(rateLimitedText(ar, _limited(121)), contains('3 دقائق'));
  });

  test('with no Retry-After it keeps the general message', () {
    expect(rateLimitedText(en, _limited(null)), en.loginErrorRateLimited);
    expect(rateLimitedText(ar, _limited(0)), ar.loginErrorRateLimited);
  });
}
