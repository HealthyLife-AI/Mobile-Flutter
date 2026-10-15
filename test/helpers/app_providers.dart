import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/presentation/bloc/auth/auth_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/meal_log/meal_log_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/meal_plan/meal_plan_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/measurements/measurements_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/notifications/notifications_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/settings/settings_cubit.dart';

import 'localized_app.dart';
import 'sample_meal_plan.dart';

/// Mounts [child] under the same app-scoped providers `HealthyLifeApp` builds
/// (dependencies, auth, settings, meal log, meal plan, notifications,
/// measurements), but without the auth router listeners that would replace
/// [home] with another screen.
///
/// Screens read these cubits and the [AppDependencies] graph directly, so any
/// widget test mounting a screen in isolation needs them. The graph is
/// in-memory: the session and preferences persist nothing. Unless
/// [dependencies] says otherwise, the nutritionist's plan is [samplePlanJson],
/// loaded as the app loads it on entry.
Widget appProviders(
  Widget child, {
  AppDependencies? dependencies,
  Locale locale = const Locale('ar'),
  ThemeData? theme,
  bool debugShowCheckedModeBanner = false,
}) {
  final deps = dependencies ??
      AppDependencies.inMemory(
          mealPlanSource: FakeMealPlanSource(samplePlanJson()));
  return RepositoryProvider<AppDependencies>(
    create: (_) => deps,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            auth: deps.auth,
            signIn: deps.signIn,
            changePassword: deps.changePassword,
            push: deps.push,
            preferences: deps.preferences,
            events: deps.sessionEvents,
            hasReadings: deps.hasMeasurementHistory,
          ),
        ),
        BlocProvider(create: (_) => SettingsCubit(deps.settings)),
        BlocProvider(create: (_) => MealLogCubit(deps.mealLog, deps.logMeal)),
        BlocProvider(
          create: (_) =>
              MealPlanCubit(deps.mealPlan, changes: deps.planChanges.changes)
                ..load(),
        ),
        // Not loaded here: the app loads them once the patient is signed in,
        // and a test decides for itself what each should start as.
        BlocProvider(create: (_) => NotificationsCubit(deps.notification)),
        BlocProvider(create: (_) => MeasurementsCubit(deps.measurement)),
      ],
      child: localizedApp(
        locale: locale,
        theme: theme,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        home: child,
      ),
    ),
  );
}
