import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/screens/health_data_consent_screen.dart';
import 'package:healthylife_ai/presentation/widgets/privacy_policy.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/scripted_api.dart';

const _launcher = MethodChannel('plugins.flutter.io/url_launcher');

void main() {
  late List<String> opened;

  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  setUp(() {
    opened = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_launcher, (call) async {
      final url = (call.arguments as Map?)?['url'];
      if (url is String) opened.add(url);
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_launcher, null);
  });

  Future<void> open(WidgetTester tester, AppDependencies deps) async {
    await tester.pumpWidget(appProviders(
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => openPrivacyPolicy(context),
            child: const Text('privacy'),
          ),
        ),
      ),
      dependencies: deps,
      theme: AppTheme.light,
    ));
    await tester.pump();
    await tester.tap(find.text('privacy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('the policy_url the server sent is opened (API guide 4)',
      (tester) async {
    final deps = AppDependencies.inMemory(
      api: ScriptedApi({
        'GET me/consent': {
          'required': false,
          'current_version': '2026-10-01',
          'policy_url': 'https://site.example/ar/privacy',
        },
      }),
    );
    // Read once, as at start-up; the address is kept after sign-out too.
    await deps.auth.getConsent();

    await open(tester, deps);

    expect(opened, ['https://site.example/ar/privacy']);
  });

  testWidgets('without an address, only says the policy is on the website',
      (tester) async {
    await open(tester, AppDependencies.inMemory(api: ScriptedApi()));

    expect(opened, isEmpty);
    expect(find.text('سياسة الخصوصية متوفرة على موقعنا.'), findsOneWidget);
  });

  testWidgets('the consent screen makes no claim the policy does not',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 2600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        appProviders(const HealthDataConsentScreen(), theme: AppTheme.light));
    await tester.pump(const Duration(seconds: 2));

    final texts = [
      for (final text in tester.widgetList<Text>(find.byType(Text)))
        text.data ?? text.textSpan?.toPlainText() ?? '',
    ].join('\n');
    for (final claim in [
      'HIPAA',
      'AES',
      'معزولة',
      'منظومة الحماية',
      'طرف ثالث',
    ]) {
      expect(texts, isNot(contains(claim)), reason: claim);
    }
    expect(
        texts,
        contains(
            'الاتصال بين التطبيق وخوادمنا مشفّر، ونأخذ نسخة احتياطية مشفّرة يوميًا.'));
  });
}
