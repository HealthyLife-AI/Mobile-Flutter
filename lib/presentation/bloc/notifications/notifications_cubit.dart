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
    this.page = 0,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final NotificationsStatus status;
  final List<NotificationDateGroup> groups;
  final Failure? failure;
  final bool processing;

  /// The last page shown (API guide 10.2: 20 rows a page). 0 before the
  /// first load.
  final int page;

  /// The server has older rows after [page].
  final bool hasMore;

  /// An older page is being read.
  final bool loadingMore;

  int get unreadCount =>
      groups.fold(0, (sum, g) => sum + g.items.where((e) => e.unread).length);

  bool get isEmpty => groups.every((g) => g.items.isEmpty);

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationDateGroup>? groups,
    Failure? failure,
    bool processing = false,
    bool clearFailure = true,
    int? page,
    bool? hasMore,
    bool loadingMore = false,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        groups: groups ?? this.groups,
        failure: failure ?? (clearFailure ? null : this.failure),
        processing: processing,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore,
      );
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationRepository _repository;

  /// Reads the newest page again. The older pages already shown are dropped:
  /// they are read again on request.
  Future<void> load() async {
    if (state.status == NotificationsStatus.initial) {
      emit(state.copyWith(status: NotificationsStatus.loading));
    }
    final result = await _repository.getPage(1);
    if (isClosed) return;
    result.when(
      success: (page) => emit(state.copyWith(
        status: page.groups.every((g) => g.items.isEmpty)
            ? NotificationsStatus.empty
            : NotificationsStatus.loaded,
        groups: page.groups,
        page: 1,
        hasMore: page.hasMore,
      )),
      failure: (failure) => emit(NotificationsState(
          status: NotificationsStatus.error, failure: failure)),
    );
  }

  /// Adds the next, older page under the rows shown. A failure keeps what is
  /// shown and the button to try again.
  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore) return;
    final next = state.page + 1;
    emit(state.copyWith(loadingMore: true, status: state.status));
    final result = await _repository.getPage(next);
    if (isClosed) return;
    result.when(
      success: (page) => emit(state.copyWith(
        status: state.status,
        groups: appendOlderNotifications(state.groups, page.groups),
        page: next,
        hasMore: page.hasMore,
      )),
      failure: (failure) =>
          emit(state.copyWith(status: state.status, failure: failure)),
    );
  }

  Future<void> markRead(String id) async {
    // Optimistic: flip locally, persist in background.
    final groups = _mapGroups((e) => e.id == id ? e.markRead() : e);
    emit(state.copyWith(groups: groups, status: state.status));
    final result = await _repository.markRead(id);
    if (isClosed) return;
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(
          failure: failure, status: state.status, groups: state.groups));
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
    emit(
        state.copyWith(groups: groups, status: state.status, processing: true));
    final result = await _repository.markAllRead(ids);
    if (isClosed) return;
    emit(state.copyWith(processing: false, status: state.status));
    if (result case Failed<void>(:final failure)) {
      emit(state.copyWith(
          failure: failure, status: state.status, groups: state.groups));
      await load();
    }
  }

  /// The groups with each row mapped. The day is kept, so the header still
  /// reads "today" or a date after a row is marked.
  List<NotificationDateGroup> _mapGroups(
          NotificationEntry Function(NotificationEntry) map) =>
      [
        for (final g in state.groups)
          NotificationDateGroup(
              label: g.label,
              day: g.day,
              items: [for (final e in g.items) map(e)]),
      ];

  /// Drops what is on screen. Called when the session ends, so the next
  /// patient never sees the previous one's inbox.
  void reset() => emit(const NotificationsState());
}
