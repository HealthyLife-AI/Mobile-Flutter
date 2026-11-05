import 'dart:async';

/// A hint that some data changed and should be read again, e.g. a reading was
/// saved, so the server-side measurement schedule moved. Carries no data.
class ChangeSignal {
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  void notify() {
    if (!_changes.isClosed) _changes.add(null);
  }
}
