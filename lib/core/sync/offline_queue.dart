import 'dart:async';

import '../errors/app_exception.dart';
import '../logging/app_logger.dart';
import '../network/api_client.dart';
import '../storage/patient_cache.dart';
import '../storage/storage_service.dart';
import 'pending_write.dart';
import 'sync_policy.dart';

/// A write the server refused for good. The patient must be told (14.2).
class DroppedWrite {
  const DroppedWrite({required this.path, required this.reason});

  final String path;
  final DropReason reason;
}

/// What one [OfflineQueue.flush] did.
class OfflineQueueReport {
  const OfflineQueueReport({
    this.sent = 0,
    this.dropped = const [],
    this.halt,
    this.retryAt,
  });

  /// Writes the server saved (201 or 200).
  final int sent;

  /// Writes removed without being saved.
  final List<DroppedWrite> dropped;

  /// Why the flush stopped before the queue was empty. Null when it emptied.
  final QueueHalt? halt;

  /// When the next attempt is due, for [QueueHalt.waitingForRetry].
  final DateTime? retryAt;
}

/// Writes made without a connection, sent in creation order (API guide 14).
///
/// Only `POST` writes are queued: meal logs and measurements. Each write stays
/// in storage until the server answers, so a restart does not lose it. The
/// queue is cleared when the session ends (2.5), so one patient's writes are
/// never sent under another patient's session.
class OfflineQueue implements PatientCache {
  OfflineQueue({
    required StorageService storage,
    required ApiClient api,
    DateTime Function()? clock,
    Future<void> Function(Duration delay)? pause,
    void Function(DroppedWrite write)? onDropped,
    this.minGap = const Duration(milliseconds: 500),
  })  : _storage = storage,
        _api = api,
        _clock = clock ?? DateTime.now,
        _pause = pause ?? _delay,
        _onDropped = onDropped;

  final StorageService _storage;
  final ApiClient _api;
  final DateTime Function() _clock;
  final Future<void> Function(Duration delay) _pause;

  /// Told about each write the server refuses, so the patient can be shown
  /// it (API guide 14.2).
  final void Function(DroppedWrite write)? _onDropped;

  /// Gap between two sends in one flush. The limit is 120 requests a minute
  /// (1.4).
  final Duration minGap;

  static const DefaultAppLogger _log = DefaultAppLogger();

  Future<void> _storageLock = Future<void>.value();
  Future<OfflineQueueReport>? _flushing;
  int _sequence = 0;

  static Future<void> _delay(Duration delay) => Future<void>.delayed(delay);

  /// How many writes are waiting.
  Future<int> pendingCount() async => (await _load()).length;

  /// The writes waiting, oldest first. Only the queue's own copy is read, so
  /// callers can show what has not reached the server yet.
  Future<List<PendingWrite>> pendingWrites() => _load();

  /// Stores a write. Nothing is sent until [flush] runs.
  Future<void> enqueue({
    required String path,
    required Map<String, dynamic> body,
  }) =>
      _edit((items) => [
            ...items,
            PendingWrite(
              id: _nextId(),
              path: path,
              body: body,
              queuedAt: _clock().toUtc(),
            ),
          ]);

  /// Forgets every queued write. Called when the session ends.
  Future<void> clear() => _edit((_) => const []);

  @override
  Future<void> forgetPatientData() => clear();

  /// Sends the queued writes in order and reports what happened. Only one
  /// flush runs at a time: a call made during a flush gets that flush's
  /// result. Storage failures are logged and reported as a wait, so this does
  /// not throw.
  Future<OfflineQueueReport> flush() {
    return _flushing ??= _runSafely().whenComplete(() {
      _flushing = null;
    });
  }

  Future<OfflineQueueReport> _runSafely() async {
    try {
      return await _run();
    } on StorageException catch (error) {
      _log.warn('Queued writes could not be updated', error: error);
      return const OfflineQueueReport(halt: QueueHalt.waitingForRetry);
    }
  }

  Future<OfflineQueueReport> _run() async {
    var sent = 0;
    final dropped = <DroppedWrite>[];
    var paced = false;

    while (true) {
      final items = await _load();
      if (items.isEmpty) {
        return OfflineQueueReport(sent: sent, dropped: dropped);
      }

      final head = items.first;
      if (!head.isDueAt(_clock())) {
        return OfflineQueueReport(
          sent: sent,
          dropped: dropped,
          halt: QueueHalt.waitingForRetry,
          retryAt: head.nextAttemptAt,
        );
      }

      if (paced) await _pause(minGap);
      paced = true;

      final decision = await _trySend(head);
      if (decision == null) {
        await _replace(head.id, null);
        sent++;
        continue;
      }

      switch (decision) {
        case SyncDrop(:final reason):
          await _replace(head.id, null);
          final refused = DroppedWrite(path: head.path, reason: reason);
          dropped.add(refused);
          _notifyDropped(refused);
          break;
        case SyncResendWithout(:final field):
          await _replace(head.id, head.withoutField(field));
          break;
        case SyncWait(:final delay):
          final until = _clock().add(delay);
          await _replace(head.id, head.failedUntil(until));
          return OfflineQueueReport(
            sent: sent,
            dropped: dropped,
            halt: QueueHalt.waitingForRetry,
            retryAt: until,
          );
        case SyncHalt(:final halt):
          return OfflineQueueReport(
            sent: sent,
            dropped: dropped,
            halt: halt,
          );
      }
    }
  }

  /// Sends one write. Returns null when the server saved it, or the decision
  /// about what to do next when it did not.
  Future<SyncDecision?> _trySend(PendingWrite write) async {
    try {
      await _api.post(write.path, body: write.body);
      return null;
    } on AppException catch (error) {
      return decideSync(write: write, error: error, now: _clock());
    } on Object catch (error) {
      _log.warn('Unexpected error while sending a queued write', error: error);
      return SyncWait(backoffFor(write.attempts));
    }
  }

  /// Tells the caller about a refused write. A failure there is logged and
  /// does not stop the queue.
  void _notifyDropped(DroppedWrite write) {
    final notify = _onDropped;
    if (notify == null) return;
    try {
      notify(write);
    } catch (error) {
      _log.warn('A refused write could not be reported', error: error);
    }
  }

  /// Replaces the write with [id] by [next], or removes it when [next] is
  /// null. If the queue was cleared meanwhile, nothing is re-added.
  Future<void> _replace(String id, PendingWrite? next) => _edit((items) => [
        for (final item in items)
          if (item.id != id) item else if (next != null) next,
      ]);

  /// Runs one change to the stored queue, after any change already running.
  Future<void> _edit(
    List<PendingWrite> Function(List<PendingWrite> items) change,
  ) {
    final edit = _storageLock.then((_) async => _save(change(await _load())));
    _storageLock = edit.catchError((Object _) {});
    return edit;
  }

  Future<List<PendingWrite>> _load() async {
    final Map<String, dynamic>? raw;
    try {
      raw = await _storage.readMap(StorageKeys.pendingWrites);
    } on StorageException catch (error) {
      _log.warn('Stored writes were unreadable and were dropped', error: error);
      return <PendingWrite>[];
    }
    final list = raw?['items'];
    if (list is! List) return <PendingWrite>[];

    final items = <PendingWrite>[];
    for (final entry in list) {
      if (entry is! Map<String, dynamic>) continue;
      final write = PendingWrite.fromJson(entry);
      if (write != null) items.add(write);
    }
    return items;
  }

  Future<void> _save(List<PendingWrite> items) => items.isEmpty
      ? _storage.remove(StorageKeys.pendingWrites)
      : _storage.writeMap(StorageKeys.pendingWrites, {
          'items': [for (final item in items) item.toJson()],
        });

  String _nextId() => '${_clock().microsecondsSinceEpoch}-${_sequence++}';
}
