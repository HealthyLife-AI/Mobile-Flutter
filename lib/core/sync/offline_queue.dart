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
/// in storage until the server answers, so a restart does not lose it.
///
/// Audit MO-02: a write is never lost because the session ended. Ending the
/// session (a refused refresh, the follow-up ending, signing out) keeps the
/// queue; only deleting the account drops it ([forgetOwner]). Each write
/// carries the patient it belongs to ([PendingWrite.owner]) and is sent only
/// while that same patient is signed in: after the patient signs in again it
/// goes out; if another patient signs in on this phone it is kept, never
/// shown or sent under their account, and waits for its owner.
class OfflineQueue implements PatientCache {
  OfflineQueue({
    required StorageService storage,
    required ApiClient api,
    DateTime Function()? clock,
    Future<void> Function(Duration delay)? pause,
    void Function(DroppedWrite write)? onDropped,
    Future<void> Function(PendingWrite write, Object? response)? onSaved,
    Timer Function(Duration delay, void Function() run)? scheduleRetry,
    Future<String?> Function()? currentOwner,
    this.minGap = const Duration(milliseconds: 500),
  })  : _storage = storage,
        _currentOwner = currentOwner,
        _scheduleRetry = scheduleRetry,
        _api = api,
        _clock = clock ?? DateTime.now,
        _pause = pause ?? _delay,
        _onDropped = onDropped,
        _onSaved = onSaved;

  final StorageService _storage;
  final ApiClient _api;

  /// The signed-in patient's user id, or null when nobody is signed in. When
  /// not given (tests of the sending rules), every write is the caller's.
  final Future<String?> Function()? _currentOwner;
  final DateTime Function() _clock;
  final Future<void> Function(Duration delay) _pause;

  /// Told about each write the server refuses, so the patient can be shown
  /// it (API guide 14.2).
  final void Function(DroppedWrite write)? _onDropped;

  /// Told about each write the server saved, with its answer (the saved
  /// object), before the write leaves the queue. A meal log keeps the
  /// server's id this way, so it can be deleted later (6.4).
  final Future<void> Function(PendingWrite write, Object? response)? _onSaved;

  /// Gap between two sends in one flush. The limit is 120 requests a minute
  /// (1.4).
  final Duration minGap;

  /// Starts a timer. When given, a flush that stops to wait (no connection, a
  /// server error, a 429) comes back by itself at the time it named, so a
  /// write made offline goes out while the app stays open.
  final Timer Function(Duration delay, void Function() run)? _scheduleRetry;
  Timer? _retry;

  static const DefaultAppLogger _log = DefaultAppLogger();

  Future<void> _storageLock = Future<void>.value();
  Future<OfflineQueueReport>? _flushing;

  /// Set while [paused] runs. A flush asked for meanwhile starts after it.
  Future<void>? _hold;
  int _sequence = 0;

  static Future<void> _delay(Duration delay) => Future<void>.delayed(delay);

  /// How many of the signed-in patient's writes are waiting.
  Future<int> pendingCount() async => (await pendingWrites()).length;

  /// The signed-in patient's writes waiting, oldest first. Only the queue's
  /// own copy is read, so callers can show what has not reached the server
  /// yet. Another patient's writes are never listed.
  Future<List<PendingWrite>> pendingWrites() async {
    final owner = await _owner();
    return [
      for (final item in await _load())
        if (_belongsTo(item, owner)) item,
    ];
  }

  /// Stores a write for the signed-in patient. Nothing is sent until [flush]
  /// runs.
  Future<void> enqueue({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final owner = await _owner();
    await _edit((items) => [
          ...items,
          PendingWrite(
            id: _nextId(),
            path: path,
            body: body,
            queuedAt: _clock().toUtc(),
            owner: owner,
          ),
        ]);
  }

  /// Drops [owner]'s writes. Called when the account is deleted: its data
  /// must not be sent or kept. Writes with no owner (an older build's, which
  /// were the signed-in patient's) go too, since that patient is the one
  /// deleted.
  Future<void> forgetOwner(String owner) => _edit((items) => [
        for (final item in items)
          if (item.owner != null && item.owner != owner) item,
      ]);

  Future<String?> _owner() async {
    final read = _currentOwner;
    if (read == null) return null;
    try {
      return await read();
    } catch (error) {
      _log.warn('The signed-in patient could not be read', error: error);
      return null;
    }
  }

  /// A write stored without an owner was made by an older build, under the
  /// session that is still signed in: it is that patient's.
  static bool _belongsTo(PendingWrite write, String? owner) =>
      write.owner == null || write.owner == owner;

  /// Forgets every queued write. Called when the session ends.
  Future<void> clear() => _edit((_) => const []);

  /// Takes the writes that match [test] out of the queue, unsent, and returns
  /// them. Use it inside [paused], so none of them is being sent meanwhile.
  Future<List<PendingWrite>> removeWhere(
      bool Function(PendingWrite write) test) async {
    final removed = <PendingWrite>[];
    await _edit((items) {
      final kept = <PendingWrite>[];
      for (final item in items) {
        (test(item) ? removed : kept).add(item);
      }
      return kept;
    });
    return removed;
  }

  /// Runs [action] while no write is being sent. A flush in progress is
  /// waited for first, and a flush asked for during [action] starts after it.
  Future<T> paused<T>(Future<T> Function() action) async {
    while (true) {
      final running = _flushing ?? _hold;
      if (running == null) break;
      await running.then((_) {}, onError: (Object _) {});
    }
    final done = Completer<void>();
    _hold = done.future;
    try {
      return await action();
    } finally {
      _hold = null;
      done.complete();
    }
  }

  /// The session ended. The planned retry stops, but the writes are KEPT
  /// (audit MO-02): they go out after the same patient signs in again.
  @override
  Future<void> forgetPatientData() async {
    _retry?.cancel();
    _retry = null;
  }

  /// Sends the queued writes in order and reports what happened. Only one
  /// flush runs at a time: a call made during a flush gets that flush's
  /// result. Storage failures are logged and reported as a wait, so this does
  /// not throw.
  Future<OfflineQueueReport> flush() {
    return _flushing ??= _runSafely().then((report) {
      _planRetry(report);
      return report;
    }).whenComplete(() {
      _flushing = null;
    });
  }

  /// Comes back at [OfflineQueueReport.retryAt] when the flush stopped to
  /// wait. A halt that needs the patient (consent, sign-in) plans nothing.
  void _planRetry(OfflineQueueReport report) {
    _retry?.cancel();
    _retry = null;
    final schedule = _scheduleRetry;
    final at = report.retryAt;
    if (schedule == null ||
        at == null ||
        report.halt != QueueHalt.waitingForRetry) {
      return;
    }
    final wait = at.difference(_clock());
    _retry = schedule(wait.isNegative ? Duration.zero : wait, () {
      _retry = null;
      unawaited(flush());
    });
  }

  Future<OfflineQueueReport> _runSafely() async {
    try {
      for (var hold = _hold; hold != null; hold = _hold) {
        await hold;
      }
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

    // Nothing is sent while nobody is signed in: the writes wait for their owner.
    final owner = await _owner();
    if (_currentOwner != null && owner == null) {
      return const OfflineQueueReport(halt: QueueHalt.unauthorized);
    }

    while (true) {
      final items = [
        for (final item in await _load())
          if (_belongsTo(item, owner)) item,
      ];
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

      final (:decision, :response) = await _trySend(head);
      if (decision == null) {
        await _notifySaved(head, response);
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

  /// Sends one write. The decision is null when the server saved it, and the
  /// response is its answer; otherwise the decision says what to do next.
  Future<({SyncDecision? decision, Object? response})> _trySend(
      PendingWrite write) async {
    try {
      final response = await _api.post(write.path, body: write.body);
      return (decision: null, response: response);
    } on AppException catch (error) {
      return (
        decision: decideSync(write: write, error: error, now: _clock()),
        response: null,
      );
    } on Object catch (error) {
      _log.warn('Unexpected error while sending a queued write', error: error);
      return (decision: SyncWait(backoffFor(write.attempts)), response: null);
    }
  }

  /// Tells the caller about a saved write. A failure there is logged and does
  /// not stop the queue: the write was saved either way.
  Future<void> _notifySaved(PendingWrite write, Object? response) async {
    final notify = _onSaved;
    if (notify == null) return;
    try {
      await notify(write, response);
    } catch (error) {
      _log.warn('A saved write could not be reported', error: error);
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
