import '../../core/state/async_state.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../domain/entities/patient_care_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../domain/repositories/patient_care_repository.dart';
import 'resource_cubit.dart';

/// The cubits of the patient-app spec. The first four live for the whole
/// session (loaded on entering the app, reset on leaving, like the plan);
/// the rest belong to the screen that shows them.

/// `GET /me/measurement-schedule`. Read again after every saved reading
/// ([changes]), since the server moves the date then.
class MeasurementScheduleCubit extends ResourceCubit<MeasurementSchedule?> {
  MeasurementScheduleCubit(MeasurementScheduleRepository repository,
      {Stream<void>? changes})
      : super(repository.getSchedule, changes: changes);
}

/// The patient's quick requests: the list, and the "N awaiting reply" badge.
class QuickRequestsCubit extends ResourceCubit<List<QuickRequest>> {
  QuickRequestsCubit(this._repository, {Stream<void>? changes})
      : super(_repository.getRequests, changes: changes);

  final QuickRequestRepository _repository;

  QuickRequestRepository get repository => _repository;

  int get openCount => openCountOf(state);

  static int openCountOf(AsyncState<List<QuickRequest>> state) =>
      state.dataOrNull?.where((r) => r.isOpen).length ?? 0;

  /// Shows a request the patient just sent at the top, before the next read.
  void added(QuickRequest request) => put([
        request,
        ...?state.dataOrNull?.where((r) => r.id != request.id),
      ]);
}

/// `GET /me/today`: the morning card and its reminders.
class TodayCubit extends ResourceCubit<TodaySummary> {
  TodayCubit(TodayRepository repository, {Stream<void>? changes})
      : super(repository.getToday, changes: changes);
}

/// Unread posts, for the bell badge (with the unread notifications).
class PostsUnreadCubit extends ResourceCubit<int> {
  PostsUnreadCubit(PostsRepository repository, {Stream<void>? changes})
      : super(repository.unreadCount, changes: changes);
}

class GoalProjectionCubit extends ResourceCubit<GoalProjection?> {
  GoalProjectionCubit(InsightsRepository repository)
      : super(repository.getGoalProjection);
}

class WeightInsightCubit extends ResourceCubit<WeightInsight?> {
  WeightInsightCubit(InsightsRepository repository)
      : super(repository.getWeightInsight);
}
