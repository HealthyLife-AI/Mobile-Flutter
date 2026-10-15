import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/appointment_reminder_rules.dart';
import '../../domain/entities/appointment_entities.dart';
import '../../domain/repositories/appointment_reminder_scheduler.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';
import '../models/appointment_dto.dart';

/// The patient's appointments (API guide 12.4). The last list of each scope is
/// kept on the device, so it can be read offline. A kept list is shown only for
/// its own scope. The copies are cleared at sign-out (2.5).
///
/// Each fresh upcoming list also replaces the device's appointment reminders
/// (10.6), and sign-out removes them. A failure in the reminders never fails a
/// read.
class AppointmentRepositoryImpl implements AppointmentRepository, PatientCache {
  AppointmentRepositoryImpl(
    this._storage,
    this._remote, {
    AppointmentReminderScheduler? reminders,
    DateTime Function()? clock,
  })  : _reminders = reminders,
        _clock = clock ?? DateTime.now;

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final AppointmentRemoteDataSource _remote;
  final AppointmentReminderScheduler? _reminders;
  final DateTime Function() _clock;

  /// Each read takes the next number when it starts. A reminder plan is written
  /// only if no read that started later has been planned, so an older answer that
  /// arrives last cannot put its reminders back (10.6).
  int _readSequence = 0;
  int _plannedSequence = 0;

  /// The reminder writes, one after another, so two writes never interleave.
  Future<void> _reminderWrites = Future<void>.value();

  @override
  Future<Result<List<Appointment>>> getAppointments({
    required AppointmentScope scope,
  }) =>
      guard(() async {
        final sequence = ++_readSequence;
        try {
          final raw = await _remote.fetch(scope: scope);
          await _remember(scope, raw);
          final items = _parse(scope, raw);
          if (scope == AppointmentScope.upcoming) {
            await _planReminders(sequence, items);
          }
          return items;
        } on NetworkException {
          // No connection: the last list of the same scope, when there is one.
          // The reminders already planned from it stay as they are.
          final kept = await _remembered(scope);
          if (kept == null) rethrow;
          return kept;
        }
      });

  @override
  Future<void> refreshReminders() async {
    await getAppointments(scope: AppointmentScope.upcoming);
  }

  @override
  Future<void> forgetPatientData() async {
    await _storage.remove(StorageKeys.appointmentsUpcoming);
    await _storage.remove(StorageKeys.appointmentsPast);
    // A read still in flight must not plan reminders for the patient who left.
    _plannedSequence = ++_readSequence;
    final reminders = _reminders;
    if (reminders == null) return;
    await _writeReminders(() async {
      try {
        await reminders.cancelAll();
      } on Object catch (error) {
        _log.warn('The appointment reminders could not be cancelled',
            error: error);
      }
    });
  }

  static String _key(AppointmentScope scope) => switch (scope) {
        AppointmentScope.upcoming => StorageKeys.appointmentsUpcoming,
        AppointmentScope.past => StorageKeys.appointmentsPast,
      };

  /// The order the screen shows: soonest first for upcoming, newest first for
  /// past. The server already sends this order; the sort keeps it either way.
  static List<Appointment> _parse(
    AppointmentScope scope,
    List<Map<String, dynamic>> raw,
  ) {
    final items =
        raw.map(AppointmentDto.fromJson).whereType<Appointment>().toList();
    items.sort((a, b) => scope == AppointmentScope.upcoming
        ? a.startsAt.compareTo(b.startsAt)
        : b.startsAt.compareTo(a.startsAt));
    return items;
  }

  Future<List<Appointment>?> _remembered(AppointmentScope scope) async {
    try {
      final kept = await _storage.readMap(_key(scope));
      final items = kept?['items'];
      if (items is! List) return null;
      return _parse(scope, [
        for (final item in items)
          if (item is Map) Map<String, dynamic>.from(item),
      ]);
    } on Object catch (error) {
      _log.warn('The kept appointments could not be read', error: error);
      return null;
    }
  }

  /// A failure to keep the copy does not fail a read that succeeded.
  Future<void> _remember(
    AppointmentScope scope,
    List<Map<String, dynamic>> raw,
  ) async {
    try {
      await _storage.writeMap(_key(scope), {'items': raw});
    } on Object catch (error) {
      _log.warn('The appointments could not be kept on this device',
          error: error);
    }
  }

  /// Replaces the device's reminders with the ones [upcoming] needs at the
  /// current time. A plan from a read that a later read, or a sign-out, has
  /// overtaken is dropped. A failure is logged and does not fail the read.
  Future<void> _planReminders(int sequence, List<Appointment> upcoming) {
    final reminders = _reminders;
    if (reminders == null) return Future<void>.value();
    return _writeReminders(() async {
      if (sequence < _plannedSequence) return;
      _plannedSequence = sequence;
      try {
        await reminders
            .replaceAll(planAppointmentReminders(upcoming, _clock()));
      } on Object catch (error) {
        _log.warn('The appointment reminders could not be updated',
            error: error);
      }
    });
  }

  /// Runs [write] after every reminder write queued before it. The returned
  /// future completes when [write] has run. A write that throws does not block
  /// the ones queued after it.
  Future<void> _writeReminders(Future<void> Function() write) {
    final next = _reminderWrites.then((_) => write());
    _reminderWrites = next.catchError((Object _) {});
    return next;
  }
}
