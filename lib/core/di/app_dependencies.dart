import 'package:flutter/material.dart';

import '../../data/datasources/food_data_source.dart';
import '../../data/datasources/meal_plan_data_source.dart';
import '../../data/datasources/measurement_data_source.dart';
import '../../data/datasources/notification_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../data/repositories/meal_log_repository_impl.dart';
import '../../data/repositories/meal_plan_repository_impl.dart';
import '../../data/repositories/measurement_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/meal_log_repository.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/activate_account_use_case.dart';
import '../../domain/usecases/change_password_use_case.dart';
import '../../domain/usecases/log_meal_use_case.dart';
import '../../domain/usecases/save_measurement_use_case.dart';
import '../../domain/usecases/search_foods_use_case.dart';
import '../storage/storage_service.dart';

/// Composition root: the single place that knows how concrete repositories,
/// data sources and use cases fit together.
///
/// Manual constructor injection on purpose — the app has one wiring site, so
/// a DI framework would add dependency weight without removing any code.
/// Tests build the same object graph with [AppDependencies.inMemory].
class AppDependencies {
  AppDependencies._({required this.storage});

  /// Production graph: persisted shared-preferences storage.
  static Future<AppDependencies> create() async =>
      AppDependencies._(storage: await SharedPrefsStorageService.init());

  /// Deterministic graph: nothing survives the process. Used by tests and
  /// as the default so `HealthyLifeApp` can be mounted without setup.
  factory AppDependencies.inMemory() => AppDependencies._(storage: MemoryStorageService());

  final StorageService storage;

  // ── Repositories ────────────────────────────────────────────────────────
  late final AuthRepository auth = AuthRepositoryImpl(storage);
  late final SettingsRepository settings = SettingsRepositoryImpl(storage);
  late final MealPlanRepository mealPlan = MealPlanRepositoryImpl(MockMealPlanRemoteDataSource());
  late final FoodRepository food = FoodRepositoryImpl(MockFoodDataSource());
  late final MealLogRepository mealLog = MealLogRepositoryImpl(storage);
  late final MeasurementRepository measurement =
      MeasurementRepositoryImpl(storage, MockMeasurementDataSource());
  late final NotificationRepository notification =
      NotificationRepositoryImpl(storage, MockNotificationDataSource());

  // ── Use cases ───────────────────────────────────────────────────────────
  late final ActivateAccountUseCase activateAccount = ActivateAccountUseCase(auth);
  late final ChangePasswordUseCase changePassword = ChangePasswordUseCase();
  late final LogMealUseCase logMeal = LogMealUseCase(mealLog);
  late final SaveMeasurementUseCase saveMeasurement = SaveMeasurementUseCase(measurement);
  late final SearchFoodsUseCase searchFoods = SearchFoodsUseCase(food);
}
