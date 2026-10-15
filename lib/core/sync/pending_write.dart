/// One write waiting for the network (API guide 14). Stored as JSON, so it
/// survives a restart.
class PendingWrite {
  const PendingWrite({
    required this.id,
    required this.path,
    required this.body,
    required this.queuedAt,
    this.attempts = 0,
    this.nextAttemptAt,
    this.retriedWithout = const <String>{},
  });

  /// Local identifier. It is not sent to the server.
  final String id;

  /// Endpoint relative to the API base, such as `me/measurements`.
  final String path;

  /// JSON body. Idempotency keys stay in it across every retry (14.1).
  final Map<String, dynamic> body;

  /// When the patient made the entry, in UTC on the device clock.
  final DateTime queuedAt;

  /// Failed sends so far. This sets the backoff.
  final int attempts;

  /// Earliest time for the next attempt. Null means as soon as possible.
  final DateTime? nextAttemptAt;

  /// Fields taken out of [body] after a refusal (14.2). Each is removed once.
  final Set<String> retriedWithout;

  bool isDueAt(DateTime now) {
    final next = nextAttemptAt;
    return next == null || !now.isBefore(next);
  }

  /// The same write without [field]. Everything else, including the
  /// idempotency key, is unchanged.
  PendingWrite withoutField(String field) => PendingWrite(
        id: id,
        path: path,
        body: Map<String, dynamic>.of(body)..remove(field),
        queuedAt: queuedAt,
        attempts: attempts,
        nextAttemptAt: nextAttemptAt,
        retriedWithout: {...retriedWithout, field},
      );

  /// The same write after a failed send, due again at [next].
  PendingWrite failedUntil(DateTime next) => PendingWrite(
        id: id,
        path: path,
        body: body,
        queuedAt: queuedAt,
        attempts: attempts + 1,
        nextAttemptAt: next,
        retriedWithout: retriedWithout,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'body': body,
        'queuedAt': queuedAt.toIso8601String(),
        'attempts': attempts,
        if (nextAttemptAt != null)
          'nextAttemptAt': nextAttemptAt!.toIso8601String(),
        'retriedWithout': retriedWithout.toList(),
      };

  /// Null for a malformed entry. Such an entry is skipped, never sent.
  static PendingWrite? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final path = json['path'];
    final body = json['body'];
    final queued = json['queuedAt'];
    final queuedAt = queued is String ? DateTime.tryParse(queued) : null;
    if (id is! String ||
        path is! String ||
        body is! Map<String, dynamic> ||
        queuedAt == null) {
      return null;
    }
    final attempts = json['attempts'];
    final next = json['nextAttemptAt'];
    final removed = json['retriedWithout'];
    return PendingWrite(
      id: id,
      path: path,
      body: body,
      queuedAt: queuedAt,
      attempts: attempts is int ? attempts : 0,
      nextAttemptAt: next is String ? DateTime.tryParse(next) : null,
      retriedWithout: removed is List
          ? removed.whereType<String>().toSet()
          : const <String>{},
    );
  }
}
