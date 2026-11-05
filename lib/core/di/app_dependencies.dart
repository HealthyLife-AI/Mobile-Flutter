import '../../data/datasources/appointment_remote_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/food_remote_data_source.dart';
import '../../data/datasources/health_profile_remote_data_source.dart';
import '../../data/datasources/progress_remote_data_source.dart';
import '../../data/datasources/review_remote_data_source.dart';
import '../../data/datasources/meal_plan_data_source.dart';
import '../../data/datasources/measurement_remote_data_source.dart';
import '../../data/datasources/nutritionist_remote_data_source.dart';
import '../../data/datasources/notification_data_source.dart';
import '../../data/datasources/session_local_data_source.dart';
import '../../data/models/auth_dto.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../data/repositories/health_profile_repository_impl.dart';
import '../../data/repositories/meal_log_repository_impl.dart';
import '../../data/repositories/meal_plan_repository_impl.dart';
import '../../data/repositories/measurement_repository_impl.dart';
import '../../data/repositories/nutritionist_repository_impl.dart';
<<<<<<< HEAD
import '../../data/repositories/password_help_contact.dart';
import '../../data/repositories/privacy_policy_link.dart';
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
<<<<<<< HEAD
import '../../data/repositories/cached_response.dart';
import '../../data/repositories/engagement_repository_impl.dart';
import '../../data/repositories/health_records_repository_impl.dart';
import '../../data/repositories/patient_care_repository_impl.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../domain/repositories/patient_care_repository.dart';
import '../state/change_signal.dart';
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
import '../../data/services/flutter_device_timezone.dart';
import '../../data/services/local_appointment_reminder_scheduler.dart';
import '../../data/services/local_reminder_notifications.dart';
import '../../data/services/firebase_push_registrar.dart';
import '../../data/services/notification_preferences_sync.dart';
import '../../data/services/notification_read_receipt.dart';
<<<<<<< HEAD
import '../../data/services/push_channel.dart';
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
import '../../data/services/system_notification_permissions.dart';
import '../../data/services/weigh_in_reminder.dart';
import '../navigation/dropped_write_notice.dart';
import '../navigation/push_navigation.dart';
import '../navigation/foreground_push.dart';
import '../navigation/plan_change_signal.dart';
import '../navigation/push_tap_router.dart';
import '../storage/patient_cache.dart';
import '../sync/offline_queue.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/appointment_reminder_scheduler.dart';
import '../../domain/repositories/device_timezone.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/health_profile_repository.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/repositories/meal_log_repository.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../../domain/repositories/nutritionist_repository.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/notification_permissions.dart';
import '../../domain/repositories/preferences_sync.dart';
import '../../domain/repositories/push_registrar.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/change_password_use_case.dart';
import '../../domain/usecases/log_meal_use_case.dart';
import '../../domain/usecases/save_measurement_use_case.dart';
import '../../domain/usecases/search_foods_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../network/api_client.dart';
import '../network/api_client_factory.dart';
import '../network/session_events.dart';
import '../network/token_refresh_coordinator.dart';
import '../storage/legacy_storage.dart';
import '../storage/secure_vault.dart';
import '../storage/storage_service.dart';

/// Composition root: the single place that knows how concrete repositories,
/// data sources, network clients and use cases fit together.
///
/// Manual constructor injection on purpose: the app has one wiring site, so a
/// DI framework would add weight without removing code. Tests use
/// [AppDependencies.inMemory], which builds the same graph on in-memory storage.
class AppDependencies {
  AppDependencies._({
    required this.storage,
    required this.vault,
    MealPlanRemoteDataSource? mealPlanSource,
    NotificationDataSource? notificationSource,
    ApiClient? api,
  })  : _mealPlanSource = mealPlanSource,
        _notificationSource = notificationSource,
        _apiOverride = api;

  /// Production graph: shared-preferences for preferences, the platform
  /// keystore for the session.
  static Future<AppDependencies> create() async {
    final storage = await SharedPrefsStorageService.init();
    await removeLegacyStorage(storage);
    return AppDependencies._(storage: storage, vault: FlutterSecureVault());
  }

  /// Deterministic graph that persists nothing. Used by tests and as the
  /// fallback when the platform storage cannot start.
  ///
  /// [mealPlanSource] and [notificationSource] stand in for
  /// `GET /me/meal-plan` and the inbox in tests that need them. [api] answers
  /// every other request, for a test that scripts the server.
  factory AppDependencies.inMemory({
    MealPlanRemoteDataSource? mealPlanSource,
    NotificationDataSource? notificationSource,
    ApiClient? api,
  }) =>
      AppDependencies._(
        storage: MemoryStorageService(),
        vault: MemorySecureVault(),
        mealPlanSource: mealPlanSource,
        notificationSource: notificationSource,
        api: api,
      );

  final StorageService storage;
  final SecureVault vault;

  /// Session-wide events from the network stack: session expired, follow-up
  /// ended, consent required. The auth cubit listens to these.
  final SessionEvents sessionEvents = SessionEvents();

  /// Raised by a plan push (API guide 10.3), so the plan is read again.
  final PlanChangeSignal planChanges = PlanChangeSignal();

<<<<<<< HEAD
  /// Raised after a reading is saved: the server moves the measurement
  /// schedule then, so it is read again.
  final ChangeSignal measurementChanges = ChangeSignal();

  /// Raised by a push that answers a quick request or publishes a post, so
  /// the badges are read again.
  final ChangeSignal requestChanges = ChangeSignal();
  final ChangeSignal postChanges = ChangeSignal();

  /// Raised by a push that arrives while the app is open, so the inbox and
  /// its unread badge are read again (API guide 10.4).
  final ChangeSignal notificationChanges = ChangeSignal();

=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  final MealPlanRemoteDataSource? _mealPlanSource;
  final NotificationDataSource? _notificationSource;
  final ApiClient? _apiOverride;

  // ── Network and session ─────────────────────────────────────────────────

  /// Clearing the session also forgets the patient's data on this device
  /// (API guide 2.5).
  late final SessionLocalDataSource session = SessionLocalDataSource(
    vault,
    onCleared: () => forgetPatientCaches(_patientCaches),
  );

  late final TokenRefreshCoordinator _coordinator = TokenRefreshCoordinator(
    store: session,
    events: sessionEvents,
    // Resolved when called, not when built, so the graph has no cycle.
    refresh: (refreshToken) async => AuthMapper.tokensFromJson(
      await _authRemote.refresh(refreshToken),
    ),
  );

  late final ApiClient api = _apiOverride ??
      createApiClient(
        store: session,
        coordinator: _coordinator,
        events: sessionEvents,
      );

  /// Writes made without a connection, sent in order once the app is
  /// ready (API guide 14). A write the server refuses is shown to the
  /// patient.
  late final OfflineQueue offlineQueue = OfflineQueue(
    storage: storage,
    api: api,
    onDropped: showDroppedWriteNotice,
<<<<<<< HEAD
    // A saved meal log's server id, so it can be deleted later (6.4).
    onSaved: (write, response) => _mealLog.recordSaved(write, response),
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  );

  late final AuthRemoteDataSource _authRemote = AuthRemoteDataSource(api);

<<<<<<< HEAD
  late final PushRegistrar push = FirebasePushRegistrar(
    api: api,
    prepareChannel: () => createPushChannel(_reminderNotifications, settings),
  );
=======
  late final PushRegistrar push = FirebasePushRegistrar(api: api);
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a

  /// Reads/requests the OS notification permission and opens the system
  /// settings page. Used by the notification settings and onboarding screens;
  /// nothing calls it automatically on start-up.
  late final NotificationPermissions notificationPermissions =
      SystemNotificationPermissions();

  /// The device's IANA timezone, from the flutter_timezone package. The sync
  /// sends it with the notification preferences (API guide 10.5).
  late final DeviceTimezone _deviceTimezone = const FlutterDeviceTimezone();

  late final PreferencesSync preferences = NotificationPreferencesSync(
    api: api,
    settings: settings,
    timezone: _deviceTimezone,
  );

  late final NotificationReadReceipt _notificationReceipts =
      NotificationReadReceipt(inbox: notification);

  /// Opens the screen behind a tapped push once the app is ready (10.4).
  late final PushTapRouter pushTaps = PushTapRouter(
    markRead: _notificationReceipts.send,
    open: openPushDestination,
  );

  /// Draws a notice for a push that arrives while the app is open (10.4).
  late final ForegroundPushPresenter foregroundPush =
      ForegroundPushPresenter(taps: pushTaps, show: showPushNotice);

  // ── Repositories ────────────────────────────────────────────────────────
  late final AuthRepository auth = AuthRepositoryImpl(
    remote: _authRemote,
    local: session,
    coordinator: _coordinator,
    push: push,
<<<<<<< HEAD
    onAccountDeleted: passwordHelp.forget,
    onConsent: (consent) => privacyPolicy.remember(consent.policyUrl),
  );

  /// The published privacy policy's address (API guide 4). It outlives the
  /// session, so it is not in [_patientCaches].
  late final PrivacyPolicyLink privacyPolicy = PrivacyPolicyLink(storage);

  /// The nutritionist's WhatsApp number for the forgot-password message
  /// (3.6). It outlives the session, so it is not in [_patientCaches].
  late final PasswordHelpContact passwordHelp = PasswordHelpContact(storage);
=======
  );
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  late final SettingsRepository settings = SettingsRepositoryImpl(storage);
  late final MealPlanRepositoryImpl _mealPlan = MealPlanRepositoryImpl(
    storage,
    _mealPlanSource ?? HttpMealPlanRemoteDataSource(api),
  );
  late final MealPlanRepository mealPlan = _mealPlan;
  late final FoodRepository food =
      FoodRepositoryImpl(FoodRemoteDataSource(api));

  // The patient-scoped repositories are kept as their concrete types too, so
  // [_patientCaches] can clear them.
  late final MealLogRepositoryImpl _mealLog =
<<<<<<< HEAD
      MealLogRepositoryImpl(storage, offlineQueue, api);
=======
      MealLogRepositoryImpl(storage, offlineQueue);
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  late final MealLogRepository mealLog = _mealLog;

  late final MeasurementRepositoryImpl _measurement = MeasurementRepositoryImpl(
    storage,
    MeasurementRemoteDataSource(api),
    offlineQueue,
  );
  late final MeasurementRepository measurement = _measurement;

  late final NutritionistRepositoryImpl _nutritionist =
<<<<<<< HEAD
      NutritionistRepositoryImpl(storage, NutritionistRemoteDataSource(api),
          passwordHelp: passwordHelp);
=======
      NutritionistRepositoryImpl(storage, NutritionistRemoteDataSource(api));
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  late final NutritionistRepository nutritionist = _nutritionist;

  late final HealthProfileRepositoryImpl _healthProfile =
      HealthProfileRepositoryImpl(storage, HealthProfileRemoteDataSource(api));
  late final HealthProfileRepository patientHealthProfile = _healthProfile;

  late final ReviewRepositoryImpl _reviews =
      ReviewRepositoryImpl(storage, ReviewRemoteDataSource(api));
  late final ReviewRepository reviews = _reviews;

  late final ProgressRepositoryImpl _progressData =
      ProgressRepositoryImpl(storage, ProgressRemoteDataSource(api));
  late final ProgressRepository progress = _progressData;

  /// The device's own reminders as local notifications (API guide 10.6):
<<<<<<< HEAD
  /// appointments and the weekly weigh-in share the plugin, which also
  /// creates the push channel (10.4).
  late final FlutterReminderNotifications _reminderNotifications =
=======
  /// appointments and the weekly weigh-in share the plugin.
  late final ReminderNotifications _reminderNotifications =
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
      FlutterReminderNotifications();

  late final AppointmentReminderScheduler _appointmentReminders =
      LocalAppointmentReminderScheduler(_reminderNotifications, settings);

  /// The notification settings on the server (10.5).
  late final NotificationPreferencesRepositoryImpl _notificationPreferences =
      NotificationPreferencesRepositoryImpl(storage, api);
  late final NotificationPreferencesRepository notificationPreferences =
      _notificationPreferences;

  /// The weekly weigh-in reminder (10.6), planned from the readings.
  late final WeighInReminder weighInReminder = WeighInReminder(
    notifications: _reminderNotifications,
    preferences: notificationPreferences,
    settings: settings,
  );

  late final AppointmentRepositoryImpl _appointmentsData =
      AppointmentRepositoryImpl(
    storage,
    AppointmentRemoteDataSource(api),
    reminders: _appointmentReminders,
  );
  late final AppointmentRepository appointments = _appointmentsData;

  /// The real inbox (API guide 10.2).
  late final NotificationRepositoryImpl _notification =
      NotificationRepositoryImpl(
    storage,
    _notificationSource ?? HttpNotificationDataSource(api),
    // The feed's specialist note names the patient's real nutritionist.
    specialistName: () async =>
        (await _nutritionist.getProfile()).valueOrNull?.name,
  );
  late final NotificationRepository notification = _notification;

<<<<<<< HEAD
  // ── Patient-app spec features (phases 1–4) ─────────────────────────────

  CachedResponse _kept(String key) => CachedResponse(storage, key);

  late final MeasurementScheduleRepositoryImpl _schedule =
      MeasurementScheduleRepositoryImpl(
          api, _kept(StorageKeys.measurementSchedule));
  late final MeasurementScheduleRepository measurementSchedule = _schedule;

  late final QuickRequestRepositoryImpl _quickRequests =
      QuickRequestRepositoryImpl(api, _kept(StorageKeys.quickRequests));
  late final QuickRequestRepository quickRequests = _quickRequests;

  late final CheckinRepositoryImpl _checkins =
      CheckinRepositoryImpl(api, storage);
  late final CheckinRepository checkins = _checkins;

  late final FoodPreferencesRepositoryImpl _foodPreferences =
      FoodPreferencesRepositoryImpl(api, _kept(StorageKeys.foodPreferences));
  late final FoodPreferencesRepository foodPreferences = _foodPreferences;

  late final InsightsRepositoryImpl _insights = InsightsRepositoryImpl(
      api, _kept(StorageKeys.goalProjection), _kept(StorageKeys.weightInsight));
  late final InsightsRepository insights = _insights;

  late final TodayRepositoryImpl _today =
      TodayRepositoryImpl(api, _kept(StorageKeys.today));
  late final TodayRepository today = _today;

  late final PostsRepositoryImpl _posts =
      PostsRepositoryImpl(api, _kept(StorageKeys.postsFirstPage));
  late final PostsRepository posts = _posts;

  /// Never kept on the device: reports are read fresh each time.
  late final MedicalReportsRepository medicalReports =
      MedicalReportsRepositoryImpl(
          api, api is FileTransferClient ? api as FileTransferClient : null);

  late final WellbeingRepositoryImpl _wellbeing =
      WellbeingRepositoryImpl(api, _kept(StorageKeys.wellbeing));
  late final WellbeingRepository wellbeing = _wellbeing;

=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  /// Everything that holds this patient's data on the device. Cleared when the
  /// session ends (2.5). The offline queue comes first, so nothing is sent
  /// while the rest is being cleared.
  late final List<PatientCache> _patientCaches = [
    offlineQueue,
    _mealPlan,
    _mealLog,
    _measurement,
    _nutritionist,
    _healthProfile,
    _reviews,
    _progressData,
    _appointmentsData,
    _notification,
    _notificationPreferences,
<<<<<<< HEAD
    _schedule,
    _quickRequests,
    _checkins,
    _foodPreferences,
    _insights,
    _today,
    _posts,
    _wellbeing,
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
    StoredPatientData(
      storage,
      const [StorageKeys.session],
    ),
  ];

  // ── Use cases ───────────────────────────────────────────────────────────
  late final SignInUseCase signIn = SignInUseCase(auth);
  late final ChangePasswordUseCase changePassword = ChangePasswordUseCase(auth);
  late final LogMealUseCase logMeal = LogMealUseCase(mealLog);
  late final SaveMeasurementUseCase saveMeasurement =
<<<<<<< HEAD
      SaveMeasurementUseCase(measurement, onSaved: measurementChanges.notify);
=======
      SaveMeasurementUseCase(measurement);
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  late final SearchFoodsUseCase searchFoods = SearchFoodsUseCase(food);

  /// Whether the signed-in patient already has readings on the server (7.2).
  /// The first-run wizard takes the first reading, so `AuthCubit` skips it
  /// for a patient who has some.
  Future<bool> hasMeasurementHistory() async =>
      (await measurement.getSnapshot()).valueOrNull?.isEmpty == false;
}
