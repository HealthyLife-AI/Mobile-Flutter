// Audit harness (pre-launch 2026-11): serves REAL backend JSON captured by
// Backend-Laravel/docs/audit/evidence/mobile/capture_fixtures.py through the
// app's real Dio client (DioApiClient + its JSON decoding and error mapping),
// so a contract test exercises exactly what the installed app runs.
//
// Re-capture against another backend branch, then run:
//   flutter test test/audit
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:healthylife_ai/core/network/api_client.dart';

/// One captured exchange.
class Fixture {
  Fixture(this.name, this.method, this.path, this.status, this.body);

  final String name;
  final String method;
  final String path;
  final int status;
  final Object? body;

  static final String dir = '${Directory.current.path}/test/audit/fixtures';

  static Fixture load(String name) {
    final raw = jsonDecode(File('$dir/$name.json').readAsStringSync())
        as Map<String, dynamic>;
    return Fixture(name, raw['method'] as String, raw['path'] as String,
        raw['status'] as int, raw['body']);
  }

  static bool exists(String name) => File('$dir/$name.json').existsSync();
}

/// Routes `METHOD path` (no query, numeric ids replaced by `{id}`) to a
/// fixture name. [prefix] selects a variant (`empty_` = an account with no
/// plan and no data); a missing variant falls back to the plain name.
class FixtureAdapter implements HttpClientAdapter {
  FixtureAdapter(this.routes, {this.prefix = ''});

  final Map<String, String> routes;
  final String prefix;
  final List<String> served = [];
  final List<String> unrouted = [];

  static String keyOf(String method, String path) {
    final clean = path.split('?').first.replaceAll(RegExp(r'/[\d-]+(?=/|$)'), '/{id}');
    return '$method $clean';
  }

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final key = keyOf(options.method, options.uri.path.replaceFirst(
        RegExp(r'^.*/api/v1/'), ''));
    final name = routes[key];
    if (name == null) {
      unrouted.add(key);
      return ResponseBody.fromString(
          '{"message":"no fixture for $key"}', 404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          });
    }
    final chosen = Fixture.exists('$prefix$name') ? '$prefix$name' : name;
    served.add(chosen);
    final f = Fixture.load(chosen);
    return ResponseBody.fromString(
      f.body == null ? '' : jsonEncode(f.body),
      f.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// The default routing: every GET the app makes, plus the writes the app's
/// repositories parse an answer from.
const Map<String, String> defaultRoutes = {
  'GET auth/me': 'auth_me_after_consent',
  'GET me/consent': 'me_consent_post',
  'GET me/meal-plan': 'me_meal_plan',
  'GET me/meal-logs': 'me_meal_logs_index',
  'POST me/meal-logs': 'me_meal_logs_post_offplan',
  'PATCH me/meal-logs/{id}': 'me_meal_logs_patch',
  'GET me/measurements': 'me_measurements_get',
  'POST me/measurements': 'me_measurements_post',
  'GET me/nutritionist': 'me_nutritionist',
  'GET me/health-profile': 'me_health_profile_after_proposal',
  'GET me/measurement-schedule': 'me_measurement_schedule',
  'GET me/goal-projection': 'me_goal_projection',
  'GET me/weight-insight': 'me_weight_insight',
  'GET me/today': 'me_today',
  'GET me/posts': 'me_posts',
  'GET me/posts/unread-count': 'me_posts_unread_count',
  'GET me/reports': 'me_reports',
  'GET me/wellbeing': 'me_wellbeing_get',
  'PUT me/wellbeing/{id}': 'me_wellbeing_put',
  'GET me/food-preferences': 'me_food_preferences_get',
  'PUT me/food-preferences': 'me_food_preferences_put',
  'GET me/checkins/current': 'me_checkins_current',
  'GET me/quick-requests': 'me_quick_requests_get',
  'POST me/quick-requests': 'me_quick_requests_post',
  'POST me/proposals': 'me_proposals_post',
  'GET me/appointments/slots': 'me_appointments_slots',
  'POST me/appointments': 'me_appointments_post',
  'GET me/appointments': 'me_appointments_upcoming',
  'GET me/reviews': 'me_reviews',
  'GET me/notifications': 'me_notifications',
  'GET me/notifications/unread-count': 'me_notifications_unread_count',
  'GET me/notification-preferences': 'me_notification_preferences_get',
  'PUT me/notification-preferences': 'me_notification_preferences_put',
  'GET me/progress': 'me_progress',
  'GET foods/search': 'foods_search',
};

/// The app's real JSON client over [adapter].
DioApiClient fixtureClient(FixtureAdapter adapter) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://fixture.invalid/api/v1/',
    headers: const {'Accept': 'application/json'},
    contentType: Headers.jsonContentType,
  ))
    ..httpClientAdapter = adapter;
  return DioApiClient(dio);
}
