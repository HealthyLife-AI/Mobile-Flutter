import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/state/async_state.dart';
import 'package:healthylife_ai/domain/entities/appointment_entities.dart';
import 'package:healthylife_ai/domain/repositories/appointment_repository.dart';
import 'package:healthylife_ai/presentation/bloc/appointments/appointments_cubit.dart';

/// Records each scope asked for and answers with the next future in line.
class _ScriptedAppointments implements AppointmentRepository {
  final List<AppointmentScope> scopes = [];
  final List<Future<Result<List<Appointment>>>> answers = [];

  @override
  Future<Result<List<Appointment>>> getAppointments({
    required AppointmentScope scope,
  }) {
    scopes.add(scope);
    return answers.removeAt(0);
  }

  @override
  Future<void> refreshReminders() async {}
}

Appointment _visit(int id) => Appointment(
      id: id,
      type: AppointmentType.followUp,
      channel: AppointmentChannel.whatsapp,
      startsAt: DateTime(2026, 10, id),
      endsAt: null,
      status: AppointmentStatus.booked,
    );

void main() {
  test('the first load asks for the upcoming list', () async {
    final repo = _ScriptedAppointments()
      ..answers.add(Future.value(Success([_visit(1)])));
    final cubit = AppointmentsCubit(repo);
    addTearDown(cubit.close);

    await cubit.load();

    expect(repo.scopes, [AppointmentScope.upcoming]);
    expect(cubit.scope, AppointmentScope.upcoming);
    expect(cubit.state.dataOrNull!.single.id, 1);
  });

  test('switching tabs drops the other tab\'s list while the new one loads',
      () async {
    final past = Completer<Result<List<Appointment>>>();
    final repo = _ScriptedAppointments()
      ..answers.addAll([
        Future.value(Success([_visit(1)])),
        past.future,
      ]);
    final cubit = AppointmentsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();

    final switching = cubit.load(scope: AppointmentScope.past);

    expect(cubit.scope, AppointmentScope.past);
    expect(cubit.state, isA<AsyncLoading<List<Appointment>>>());
    expect(cubit.state.dataOrNull, isNull);

    past.complete(Success([_visit(2)]));
    await switching;
    expect(cubit.state.dataOrNull!.single.id, 2);
  });

  test('a result for a tab the patient has left is dropped', () async {
    final slowUpcoming = Completer<Result<List<Appointment>>>();
    final repo = _ScriptedAppointments()
      ..answers.addAll([
        slowUpcoming.future,
        Future.value(Success([_visit(2)])),
      ]);
    final cubit = AppointmentsCubit(repo);
    addTearDown(cubit.close);

    final firstLoad = cubit.load();
    await cubit.load(scope: AppointmentScope.past);
    slowUpcoming.complete(Success([_visit(1)]));
    await firstLoad;

    expect(cubit.scope, AppointmentScope.past);
    expect(cubit.state.dataOrNull!.single.id, 2);
  });

  test('a failed refresh keeps the list already on screen', () async {
    final repo = _ScriptedAppointments()
      ..answers.addAll([
        Future.value(Success([_visit(1)])),
        Future.value(Failed<List<Appointment>>(const NetworkFailure())),
      ]);
    final cubit = AppointmentsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.load();

    expect(cubit.state, isA<AsyncError<List<Appointment>>>());
    expect(cubit.state.dataOrNull!.single.id, 1);
  });
}
