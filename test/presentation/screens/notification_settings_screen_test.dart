import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/screens/notification_settings_screen.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';

/// The settings endpoint (API guide 10.5): answers with [saved], and records
/// each PUT. A PUT fails when [refuse] is set.
class _Server implements ApiClient {
  Map<String, dynamic> saved = {
    'locale': 'ar',
    'categories': {
      'meals': false,
      'measurements': true,
      'nutritionist': true,
      'plan': true,
      'system': true,
    },
    'quiet_hours': {'enabled': true, 'start': '22:00', 'end': '07:00'},
  };
  final List<Map<String, dynamic>> puts = [];
  bool refuse = false;

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    if (path == 'me/notification-preferences') return saved;
    throw const NetworkException('not scripted');
  }

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final flat = body! as Map<String, dynamic>;
    puts.add(flat);
    if (refuse) throw const NetworkException('offline');
    saved = {
      ...saved,
      'categories': {
        'meals': flat['meals'],
        'measurements': flat['measurements'],
        'nutritionist': flat['nutritionist'],
        'plan': flat['plan'],
        'system': true,
      },
    };
    return saved;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      throw const NetworkException('not scripted');

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

/// The switch labelled [label].
Finder _switch(String label) => find
    .byWidgetPredicate((w) => w is Semantics && w.properties.label == label);

bool _isOn(WidgetTester tester, String label) =>
    tester.widget<Semantics>(_switch(label)).properties.toggled!;

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Future<_Server> open(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 2400);
    addTearDown(tester.view.reset);
    final server = _Server();
    await tester.pumpWidget(appProviders(
      const NotificationSettingsScreen(),
      dependencies: AppDependencies.inMemory(api: server),
      theme: AppTheme.light,
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    return server;
  }

  testWidgets('the switches show what the server holds', (tester) async {
    await open(tester);

    expect(_isOn(tester, 'تذكير الوجبات'), isFalse);
    expect(_isOn(tester, 'تذكير القياسات'), isTrue);
  });

  testWidgets('a switch is saved on the server', (tester) async {
    final server = await open(tester);

    await tester.tap(_switch('تذكير القياسات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(server.puts.single['measurements'], isFalse);
    expect(_isOn(tester, 'تذكير القياسات'), isFalse);
  });

  testWidgets('a save that fails puts the switch back and says so',
      (tester) async {
    final server = await open(tester);
    server.refuse = true;

    await tester.tap(_switch('تذكير القياسات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(_isOn(tester, 'تذكير القياسات'), isTrue);
    expect(find.text('تعذّر حفظ الإعداد. تحقق من اتصالك ثم حاول مرة أخرى.'),
        findsOneWidget);
  });
}
