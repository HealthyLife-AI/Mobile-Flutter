import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/notification_entities.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_data_source.dart';

/// Feed + persisted read state. Read IDs live in storage so "mark as read"
/// survives navigation and app restarts (the mock feed's own `unread`
/// flags are the *initial* state only).
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._storage, this._remote);

  final StorageService _storage;
  final NotificationDataSource _remote;
  Set<String>? _readCache;

  @override
  Future<Result<List<NotificationDateGroup>>> getGroups() => guard(() async {
        final groups = await _remote.fetchGroups();
        final read = await _readIds();
        return groups
            .map(
              (g) => NotificationDateGroup(
                label: g.label,
                items: g.items.map((e) => e.unread && !read.contains(e.id) ? e : e.markRead()).toList(),
              ),
            )
            .toList();
      });

  @override
  Future<Result<void>> markRead(String id) => guard(() async {
        final read = await _readIds();
        read.add(id);
        await _persist(read);
      });

  @override
  Future<Result<void>> markAllRead(List<String> ids) => guard(() async {
        final read = await _readIds();
        read.addAll(ids);
        await _persist(read);
      });

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
    await _storage.writeMap(StorageKeys.notificationsRead, {'ids': read.toList()});
  }
}
