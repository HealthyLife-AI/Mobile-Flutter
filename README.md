# HealthyLife AI — patient app

The Flutter app a patient uses to follow the meal plan their nutritionist
wrote: log meals, record measurements, read the plan, ask for a change, and get
reminders. It talks to the Laravel API (`/api/v1`, JWT with rotating refresh
tokens). The nutritionist's side is the web dashboard, not this app.

Arabic (RTL, the default) and English. Android and iOS only.

## Run

```bash
flutter pub get
flutter run
```

Build-time settings (`--dart-define`), all optional:

| Name | Default | What it does |
| --- | --- | --- |
| `API_BASE_URL` | the production API | The API root. Point it at staging when testing writes. |
| `WEBSITE_URL` | the public website | Serves the privacy policy and the account-deletion page before sign-in. Empty turns the fallback off. |
| `FEATURE_BARCODE_SCANNER`, `FEATURE_HEALTH_SYNC` | off | Screens that are built but not wired to anything yet. |

## Structure

- `lib/core` — theme tokens (`AppColors`, `AppTextStyles`, `AppRadius`), the
  network stack (Dio, auth interceptor, token refresh), the offline queue,
  config, logging and crash reporting (Firebase Crashlytics, no patient data).
- `lib/domain` — entities, repository interfaces, use cases and the rules that
  have no UI (condition codes, measurement schedule, reminders).
- `lib/data` — DTOs, data sources and repository implementations.
- `lib/presentation` — Cubits (`bloc/`), screens and shared widgets.
  `widgets/state_views.dart` holds the loading, empty and error states every
  screen uses.
- `lib/l10n` — ARB files, Arabic is the template. Every user-facing string
  goes into both `app_ar.arb` and `app_en.arb`; run `flutter gen-l10n` after.

The conventions the code follows: Cubits for state, `Result`-style failures
from repositories, logical (start/end) layout so one tree serves both
directions, Latin digits in both languages, and the standard back arrow.

## Test

```bash
flutter analyze
flutter test
```

Screenshots of the main screens live in `test/goldens`. They show today's date,
so they are skipped in a normal run. A pull request that changes a screen
regenerates them, and the image diff is the before/after:

```bash
flutter test --run-skipped --tags golden --update-goldens test/goldens
```

CI (`.github/workflows/flutter-checks.yml`) runs analyze and the tests on every
pull request. The Android and iOS builds run only when native files or the
dependencies change, and on every push to `main`.

## Patient-app spec (phases 1–4): where each screen lives

Built from the "HealthyLife Mobile Screens" spec. Every endpoint below is
live on `AppConfig.apiBaseUrl`; the data layer is in
`lib/data/repositories/{patient_care,engagement,health_records}_repository_impl.dart`.

| Spec item | Endpoint(s) | Screen / widget |
| --- | --- | --- |
| Nutritionist's instructions | `GET /me/meal-plan` → `patient_instructions` | `widgets/patient_instructions_card.dart` on `screens/weekly_plan_screen.dart` |
| Physical activity | `GET /me/meal-plan` → `activities` | `PlanActivitiesSection` (same file) |
| Measurement reminder + schedule | `GET /me/measurement-schedule` | `widgets/measurement_schedule_card.dart` (home, measurement entry, measurements) |
| Quick contact / My requests | `GET`·`POST /me/quick-requests` | `screens/quick_request_screen.dart`, `screens/my_requests_screen.dart`, `widgets/quick_contact_card.dart` |
| Check-in | `GET /me/checkins/current`, `POST /me/checkins/{id}` | `screens/checkin_screen.dart` |
| Food likes/dislikes | `GET`·`PUT /me/food-preferences` | `screens/food_preferences_screen.dart` |
| Goal projection, weight insight | `GET /me/goal-projection`, `GET /me/weight-insight` | `widgets/insight_cards.dart` on the progress screen |
| Today card + reminders | `GET /me/today`, `GET /me/posts/unread-count` | `widgets/today_card.dart` on home |
| Advice posts | `GET /me/posts`, `GET /me/posts/{id}`, `POST …/read` | `screens/posts_screens.dart` |
| Notification categories | `GET`·`PUT /me/notification-preferences` | `screens/notification_settings_screen.dart` |
| Medical reports | `/me/consent`, `/me/reports` (404 = off) | `screens/medical_reports_screens.dart`, inside the health record |
| Cost/prep badges | `cost_tier`, `prep_level` on plan items | `foodTagBadges` in `widgets/spec_ui.dart`, meal detail |
| Sleep and mood | `/me/wellbeing` | `screens/wellbeing_screen.dart` |

Design tokens (Cairo, `#006572`, cards 16, buttons 52/14) are in `lib/core/theme`;
the shared building blocks are in `lib/presentation/widgets/spec_ui.dart`.
New push types are routed in `lib/core/navigation/push_destination.dart`.

### Before a store release

- Application id / bundle id: `com.healthylife.app` (permanent once the
  first build is uploaded to Google Play). Firebase project:
  `healthylife-3ce36`, the one the backend sends pushes from. Android reads it
  from `android/app/google-services.json` and Dart from
  `lib/firebase_options.dart`; both must stay on this project, or the
  backend's pushes stop reaching the app. To regenerate them:
  `flutterfire configure --project=healthylife-3ce36 --platforms=android,ios`.
- Android signing: create an upload keystore and `android/key.properties`
  (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). Without it a
  release build stops with a message. For an internal test build signed with
  the debug key, pass `-PallowDebugSigning=true` (Google Play refuses it).
- iOS: the project already declares push (`Runner.entitlements`, with
  `aps-environment`, and Background Modes → Remote notifications). What is
  still needed from the Apple account: the Push Notifications capability on
  the app id `com.healthylife.app`, an APNs key uploaded to the Firebase
  project, and signing. iPhone only, portrait only; the camera and photo
  texts are in `ar.lproj` and `en.lproj`; `PrivacyInfo.xcprivacy` lists what
  the app collects (keep it in step with `docs/store/data-safety.md`).
- Build: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols`
  and `flutter build ipa --release`.
