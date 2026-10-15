import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Generated Firebase options for each platform.
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/app_dependencies.dart';
import 'core/logging/app_logger.dart';
import 'core/navigation/app_navigator.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/push_destination.dart';
import 'core/navigation/push_navigation.dart';
import 'core/navigation/push_tap_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/l10n.dart';
import 'presentation/bloc/auth/auth_cubit.dart';
import 'presentation/bloc/meal_log/meal_log_cubit.dart';
import 'presentation/bloc/meal_plan/meal_plan_cubit.dart';
import 'presentation/bloc/measurements/measurements_cubit.dart';
import 'presentation/bloc/notifications/notifications_cubit.dart';
import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Pushes that arrive while the app is closed or in the background. Must be
    // registered before runApp.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (error, stackTrace) {
    const DefaultAppLogger().error(
      'Firebase initialization failed; running without Firebase',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Built exactly once, before the first frame, and handed down, so the whole
  // app shares one dependency graph and one session.
  final dependencies = await _createDependencies();
  _listenForPushTaps(dependencies);

  runApp(
    // The preview is a desktop/web tool for trying phone sizes: it is on only
    // in debug builds there. On a real phone it would wrap the app in a
    // simulated device and its own screen and keyboard metrics, which made
    // the keyboard and text fields lag. Disabled, `DevicePreview` falls
    // through to `builder`, so the app is the untouched widget tree.
    DevicePreview(
      enabled: kDebugMode && _isDesktopOrWeb,
      // Curated rather than the full `Devices.all` list: the sizes this app
      // actually has to survive, smallest first.
      devices: [
        Devices.ios.iPhoneSE, // smallest realistic target: catches overflow
        Devices.ios.iPhone13, // default
        Devices.ios.iPhone16ProMax, // largest common phone
        Devices.android.googlePixel9, // Android reference
        Devices.android.samsungGalaxyS25, // non-Google Android
        Devices.ios.iPad, // tablet: the 5-tab shell is width-sensitive
        Devices.macOS.macBookPro, // desktop, since macos/ is a target here
      ],
      defaultDevice: Devices.ios.iPhone13,
      // Limits the preview's own locale menu to the two app languages. The app
      // does NOT read that menu: its language is the in-app setting
      // (Profile → language), the single source of truth for the locale.
      availableLocales: const [Locale('ar'), Locale('en')],
      builder: (context) => HealthyLifeApp(dependencies: dependencies),
    ),
  );
}

/// Where the device preview is useful: a desktop window or a browser.
final bool _isDesktopOrWeb = kIsWeb ||
    switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux =>
        true,
      _ => false,
    };

/// Opens the app from a push tap (API guide 10.4). Taps during start-up wait
/// inside `PushTapRouter`. Without Firebase, push taps are simply unavailable.
void _listenForPushTaps(AppDependencies deps) {
  try {
    // The app was in the background when the patient tapped the push.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _rereadPlanIfChanged(deps, message.data);
      deps.pushTaps.handle(message.data);
    });
    // The app is open when this arrives. It draws its own notice (10.4).
    FirebaseMessaging.onMessage.listen((message) {
      // An appointment changed: plan its reminders again from the server (10.6).
      if (isAppointmentChangePush(message.data)) {
        unawaited(deps.appointments.refreshReminders());
      }
      _rereadPlanIfChanged(deps, message.data);
      deps.foregroundPush.present(
        data: message.data,
        title: message.notification?.title,
        body: message.notification?.body,
      );
    });
    // The app was closed when the patient tapped the push.
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        _rereadPlanIfChanged(deps, message?.data);
        deps.pushTaps.handle(message?.data);
      },
      onError: (Object _) {},
    );
  } catch (error) {
    const DefaultAppLogger().warn('Push taps unavailable', error: error);
  }
}

/// The nutritionist activated or changed the plan: read it again (5.1, 10.3).
void _rereadPlanIfChanged(AppDependencies deps, Map<String, dynamic>? data) {
  if (isPlanChangePush(data)) deps.planChanges.notify();
}

/// Runs in its own isolate when a push arrives while the app is closed or in
/// the background. Must be a top-level function. The OS shows the notification
/// itself, so this only makes sure Firebase is ready in this isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Already initialised in this isolate, or unavailable. Nothing to do.
  }
}

/// The production graph keeps the session in the platform keystore. If that
/// fails to start, fall back to the in-memory graph: nothing persists, but the
/// app still opens instead of failing before its first frame.
Future<AppDependencies> _createDependencies() async {
  try {
    return await AppDependencies.create();
  } catch (error, stackTrace) {
    const DefaultAppLogger().error(
        'Persistent storage unavailable; using in-memory storage',
        error: error,
        stackTrace: stackTrace);
    return AppDependencies.inMemory();
  }
}

class HealthyLifeApp extends StatelessWidget {
  const HealthyLifeApp(
      {super.key, this.home = const SplashScreen(), this.dependencies});

  /// Overridable so tests can mount the app without SplashScreen's
  /// deliberately never-settling particle animation and status timer.
  final Widget home;

  /// The composition root built in `main()`. Tests may leave it null to get
  /// an isolated in-memory graph, created once per mounted app.
  final AppDependencies? dependencies;

  @override
  Widget build(BuildContext context) {
    // App-scoped providers sit ABOVE MaterialApp so every route, sheet and
    // dialog pushed on its Navigator can read them. Each `create` runs once
    // per mounted app, so DevicePreview rebuilding `builder` reuses the same
    // instances: one graph and one of each cubit, never duplicates.
    return RepositoryProvider<AppDependencies>(
      create: (_) => dependencies ?? AppDependencies.inMemory(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) {
              final deps = context.read<AppDependencies>();
              return AuthCubit(
                auth: deps.auth,
                signIn: deps.signIn,
                changePassword: deps.changePassword,
                push: deps.push,
                preferences: deps.preferences,
                events: deps.sessionEvents,
                hasReadings: deps.hasMeasurementHistory,
              );
            },
          ),
          // Persisted theme mode and app language (one SettingsCubit owns
          // both; Arabic and light unless the user chose otherwise).
          BlocProvider<SettingsCubit>(
            create: (context) =>
                SettingsCubit(context.read<AppDependencies>().settings),
          ),
          // The patient's meal log. It is loaded and reset with the patient's
          // session (see the listener below).
          BlocProvider<MealLogCubit>(
            create: (context) {
              final deps = context.read<AppDependencies>();
              return MealLogCubit(deps.mealLog, deps.logMeal);
            },
          ),
          // The plan the nutritionist set (5.1). Loaded and reset with the
          // session like the meal log, and read again on a plan push.
          BlocProvider<MealPlanCubit>(
            create: (context) {
              final deps = context.read<AppDependencies>();
              return MealPlanCubit(deps.mealPlan,
                  changes: deps.planChanges.changes);
            },
          ),
          // The notification inbox. Loaded with the session so the home bell's
          // unread badge and the notifications center read the same state, and
          // the read/unread marks persist across restarts.
          BlocProvider<NotificationsCubit>(
            create: (context) => NotificationsCubit(
                context.read<AppDependencies>().notification),
          ),
          // The patient's measurements. Loaded with the session so the shell's
          // Progress tab can decide between the "first measurement" explainer
          // and the progress dashboard from real data, not a session flag.
          BlocProvider<MeasurementsCubit>(
            create: (context) =>
                MeasurementsCubit(context.read<AppDependencies>().measurement),
          ),
        ],
        // Rebuilds MaterialApp only when the theme mode or language changes;
        // the navigation stack survives both.
        child: BlocSelector<SettingsCubit, SettingsState, (ThemeMode, Locale)>(
          selector: (state) => (state.themeMode, state.effectiveLocale),
          builder: (context, prefs) =>
              _buildMaterialApp(context, prefs.$1, prefs.$2),
        ),
      ),
    );
  }

  Widget _buildMaterialApp(
      BuildContext context, ThemeMode themeMode, Locale locale) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Always an explicit app language (Arabic unless the user chose English)
      // so neither the device locale nor DevicePreview's locale menu can
      // silently switch it.
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Text direction comes from `locale` through Localizations: RTL for
      // Arabic, LTR for English. No extra Directionality wrapper is needed.
      // The auth listener sits above the Navigator, so it moves the whole app
      // (sign-in, consent, wizard, shell, follow-up ended) on status changes.
      builder: (context, child) => BlocListener<AuthCubit, AuthState>(
        listenWhen: AppRouter.shouldNavigate,
        listener: (_, state) => AppRouter.showFor(state),
        // Push taps open screens only once the shell is the root.
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              previous.launching != current.launching ||
              previous.canEnterShell != current.canEnterShell,
          listener: (gateContext, state) {
            final deps = gateContext.read<AppDependencies>();
            final gate = pushGateFor(state);
            deps.pushTaps.updateGate(gate);
            // The meal log is read once the patient is in the app and
            // forgotten when they leave it (2.5).
            final mealLog = gateContext.read<MealLogCubit>();
            final mealPlan = gateContext.read<MealPlanCubit>();
            final notifications = gateContext.read<NotificationsCubit>();
            final measurements = gateContext.read<MeasurementsCubit>();
            if (state.canEnterShell) {
              unawaited(mealLog.load());
              unawaited(mealPlan.load());
              unawaited(notifications.load());
              unawaited(measurements.load());
            } else {
              mealLog.reset();
              mealPlan.reset();
              notifications.reset();
              measurements.reset();
            }
            // Writes queued offline go out once the patient is in the app
            // (14). Start-up, sign-in and consent all end here.
            if (gate == PushGate.open) {
              unawaited(deps.offlineQueue.flush());
              // The appointment reminders follow the server each time the
              // patient is in the app, in case a change came while it was shut (10.6).
              unawaited(deps.appointments.refreshReminders());
            }
          },
          // The weekly weigh-in reminder follows the latest reading (10.6):
          // planned again each time the readings are read.
          child: BlocListener<MeasurementsCubit, MeasurementsState>(
            listenWhen: (previous, current) =>
                current.snapshot != null &&
                !identical(previous.snapshot, current.snapshot),
            listener: (listenerContext, state) => unawaited(listenerContext
                .read<AppDependencies>()
                .weighInReminder
                .plan(state.snapshot!)),
            child: DevicePreview.appBuilder(context, child),
          ),
        ),
      ),
      home: home,
    );
  }
}
