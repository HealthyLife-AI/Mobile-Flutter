// The account, requests, appointments, notifications and settings screens must
// fit a 360dp phone with a large system font, in both languages.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/presentation/screens/about_app_screen.dart';
import 'package:healthylife_ai/presentation/screens/achievements_screen.dart';
import 'package:healthylife_ai/presentation/screens/checkin_screen.dart';
import 'package:healthylife_ai/presentation/screens/delete_account_screen.dart';
import 'package:healthylife_ai/presentation/screens/food_preferences_screen.dart';
import 'package:healthylife_ai/presentation/screens/health_record_screen.dart';
import 'package:healthylife_ai/presentation/screens/language_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/my_requests_screen.dart';
import 'package:healthylife_ai/presentation/screens/notification_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/notifications_center_screen.dart';
import 'package:healthylife_ai/presentation/screens/password_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/posts_screens.dart';
import 'package:healthylife_ai/presentation/screens/quick_request_screen.dart';
import 'package:healthylife_ai/presentation/screens/reviews_screen.dart';
import 'package:healthylife_ai/presentation/screens/schedule_calls_screen.dart';
import 'package:healthylife_ai/presentation/screens/specialist_profile_screen.dart';
import 'package:healthylife_ai/presentation/screens/wellbeing_screen.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';

const _phone = Size(360, 800);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });

  final screens = <String, Widget Function()>{
    'profile': () => const AppShell(),
    'notifications': () => const NotificationsCenterScreen(),
    'appointments': () => const ScheduleCallsScreen(),
    'quick request': () => const QuickRequestScreen(),
    'my requests': () => const MyRequestsScreen(),
    'notification settings': () => const NotificationSettingsScreen(),
    'about': () => const AboutAppScreen(),
    'password': () => const PasswordSettingsScreen(),
    'delete account': () => const DeleteAccountScreen(),
    'language': () => const LanguageSettingsScreen(),
    'specialist profile': () => const SpecialistProfileScreen(),
    'health record': () => const HealthRecordScreen(),
    'check-in': () => const CheckinScreen(),
    'food preferences': () => const FoodPreferencesScreen(),
    'sleep and mood': () => const WellbeingScreen(),
    'advice posts': () => const PostsScreen(),
    'reviews': () => const ReviewsScreen(),
    'achievements': () => const AchievementsScreen(),
  };

  screens.forEach((name, build) {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final scale in const [1.0, 1.3]) {
        testWidgets('$name fits ${locale.languageCode} x$scale',
            (tester) async {
          await pumpScreen(tester, _phone, (_) => build(),
              locale: locale,
              textScale: scale,
              act: name == 'profile'
                  ? (t) async => t.tap(find.byIcon(Icons.person_rounded).first,
                      warnIfMissed: false)
                  : null);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 6));
        });
      }
    }
  });
}
