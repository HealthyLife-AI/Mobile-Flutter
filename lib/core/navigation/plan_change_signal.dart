import 'dart:async';

/// Tells the app the nutritionist changed the plan: a `plan_activated` or
/// `plan_updated` push arrived (API guide 10.3). The plan is then read again;
/// a push is a hint to re-read, never the data itself.
class PlanChangeSignal {
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  void notify() {
    if (!_changes.isClosed) _changes.add(null);
  }
}
