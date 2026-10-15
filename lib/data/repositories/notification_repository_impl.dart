import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/notification_entities.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_data_source.dart';

/// Feed + persisted read state. Read IDs live in storage so "mark as read"
/// survives navigation and app restarts (the mock feed's own `unread`
/// flags are the *initial* state only).
///
/// [specialistName] resolves the patient's real nutritionist so a specialist
/// note never shows a name baked into the app: the mock only marks where the
/// name goes ({specialist}), and it is filled in here.
class NotificationRepositoryImpl
    implements NotificationRepository, PatientCache {
  NotificationRepositoryImpl(this._storage, this._remote,
      {Future<String?> Function()? specialistName})
      : _specialistName = specialistName;

  /// The placeholder the mock feed uses for the nutritionist's name.
  static const String specialistPlaceholder = '{specialist}';

  /// The word used until the real profile is known (the mock copy already
  /// refers to her as "الأخصائية").
  static const String specialistFallback = 'الأخصائية';

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final NotificationDataSource _remote;
  final Future<String?> Function()? _specialistName;
  Set<String>? _readCache;

  @override
  Future<Result<NotificationPage>> getPage(int page) => guard(() async {
        final fetched = await _remote.fetchPage(page);
        final groups = fetched.groups;
        final specialist = await _resolveSpecialist();
        final read = await _readIds();
        final seen = <String>{};
        final deduped = <NotificationDateGroup>[];
        for (final g in groups) {
          final items = <NotificationEntry>[];
          for (var e in g.items) {
            // The same notification can arrive twice (a re-sent push, a feed
            // that repeats an entry). Keep the first occurrence only.
            if (!seen.add(e.id)) continue;
            e = _withSpecialist(e, specialist);
            items.add(e.unread && !read.contains(e.id) ? e : e.markRead());
          }
          if (items.isNotEmpty) {
            deduped.add(NotificationDateGroup(
                label: g.label, day: g.day, items: items));
          }
        }
        return NotificationPage(deduped, hasMore: fetched.hasMore);
      });

  /// Fills the specialist note with the patient's real nutritionist. When the
  /// profile is not known (not fetched yet, or no connection) a neutral word
  /// stands in, so a name is never invented and no placeholder leaks out.
  NotificationEntry _withSpecialist(NotificationEntry e, String? name) {
    if (e.variant != NotificationVariant.specialistNote) return e;
    final hasName = name != null && name.isNotEmpty;
    final shown = hasName ? name : specialistFallback;
    return e.copyWith(
      title: e.title.replaceAll(specialistPlaceholder, shown),
      body: e.body.replaceAll(specialistPlaceholder, shown),
      specialistName: hasName ? name : null,
      clearSpecialistName: !hasName,
    );
  }

  Future<String?> _resolveSpecialist() async {
    try {
      return await _specialistName?.call();
    } on Object {
      return null;
    }
  }

  /// Kept read on this device first, then told to the server
  /// (`POST /me/notifications/{id}/read`, 10.2). Offline, the device copy
  /// keeps the row read until the server hears of it on a later tap.
  @override
  Future<Result<void>> markRead(String id) => guard(() async {
        final read = await _readIds();
        read.add(id);
        await _persist(read);
        await _tellServer(() => _remote.markRead(id));
      });

  /// `POST /me/notifications/read-all` (10.2), after the device copy.
  @override
  Future<Result<void>> markAllRead(List<String> ids) => guard(() async {
        final read = await _readIds();
        read.addAll(ids);
        await _persist(read);
        await _tellServer(_remote.markAllRead);
      });

  /// The server call is best effort: the row is already read on the device,
  /// and both calls are safe to repeat.
  Future<void> _tellServer(Future<void> Function() call) async {
    try {
      await call();
    } on AppException catch (error) {
      _log.warn('The read state did not reach the server', error: error);
    }
  }

  @override
  Future<void> forgetPatientData() async {
    _readCache = null;
    await _storage.remove(StorageKeys.notificationsRead);
  }

  Future<Set<String>> _readIds() async {
    final cached = _readCache;
    if (cached != null) return cached;
    try {
      final raw = await _storage.readMap(StorageKeys.notificationsRead);
      final list = raw?['ids'];
      _readCache = list is List ? list.whereType<String>().toSet() : <String>{};
    } on Object {
      _readCache = <String>{};
    }
    return _readCache!;
  }

  Future<void> _persist(Set<String> read) async {
    _readCache = read;
    await _storage
        .writeMap(StorageKeys.notificationsRead, {'ids': read.toList()});
  }
}
