import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../../domain/entities/notification_entities.dart';
import '../../../domain/repositories/notification_repository.dart';

enum NotificationsStatus { initial, loading, loaded, empty, error }

@immutable
class NotificationsState {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.groups = const [],
    this.failure,
    this.processing = false,
  });

  final NotificationsStatus status;
  final List<NotificationDateGroup> groups;
  final Failure? failure;
  final bool processing;

  int get unreadCount => groups.fold(0, (sum, g) => sum + g.items.where((e) => e.unread).length);

  bool get isEmpty => groups.every((g) => g.items.isEmpty);

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationDateGroup>? groups,
    Failure? failure,
    bool processing = false,
    bool clearFailure = true,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        groups: groups ?? this.groups,
        failure: failure ?? (clearFailure ? null : this.failure),
        processing: processing,
      );
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationRepository _repository;

  Future<void> load() async {
    if (state.status == NotificationsStatus.initial) {
      emit(state.copyWith(status: NotificationsStatus.loading));
    }
    final result = await _repository.getGroups();
    if (isClosed) return;
    result.when(
      success: (groups) => emit(state.copyWith(
        status: groups.isEmpty || groups.every((g) => g.items.isEmpty)
            ? NotificationsStatus.empty
            : NotificationsStatus.loaded,
        groups: groups,
      )),
      failure: (failure) => emit(NotificationsState(status: NotificationsStatus.error, failure: failure)),
    );
  }

  Future<void> markRead(String id) async {
    // Optimistic: flip locally, persist in background.
    final groups = _mapGroups((e) => e.id == id ? e.markRead() : e);
    emit(state.copyWith(groups: groups, status: state.status));
    final result = await _repository.markRead(id);
    if (isClosed) return;
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(failure: failure, status: state.status, groups: state.groups));
      await load(); // reconcile with persisted state
    }
  }

  Future<void> markAllRead() async {
    final ids = [
      for (final g in state.groups)
        for (final e in g.items)
          if (e.unread) e.id,
    ];
    if (ids.isEmpty) return;
    final groups = _mapGroups((e) => e.unread ? e.markRead() : e);
    emit(state.copyWith(groups: groups, status: state.status, processing: true));
    final result = await _repository.markAllRead(ids);
    if (isClosed) return;
    emit(state.copyWith(processing: false, status: state.status));
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(failure: failure, status: state.status, groups: state.groups));
      await load();
    }
  }

  List<NotificationDateGroup> _mapGroups(NotificationEntry Function(NotificationEntry) map) => [
        for (final g in state.groups)
          NotificationDateGroup(label: g.label, items: [for (final e in g.items) map(e)]),
      ];
}
