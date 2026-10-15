import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/navigation/push_destination.dart';
import 'package:healthylife_ai/core/navigation/push_tap_router.dart';

/// Holds post-frame callbacks until a test runs a frame.
class _Frames {
  final List<void Function()> _queued = [];

  void schedule(void Function() callback) => _queued.add(callback);

  void run() {
    final callbacks = List<void Function()>.of(_queued);
    _queued.clear();
    for (final callback in callbacks) {
      callback();
    }
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

Map<String, dynamic> _plan({String id = '42'}) =>
    {'notification_id': id, 'type': 'plan_updated'};

void main() {
  late _Frames frames;
  late List<String> events;
  late bool failMarks;
  late PushTapRouter router;

  setUp(() {
    frames = _Frames();
    events = [];
    failMarks = false;
    router = PushTapRouter(
      markRead: (id) async {
        events.add('mark:$id');
        if (failMarks) throw StateError('offline');
      },
      open: (destination, {reviewId}) => events.add('open:${destination.name}'),
      afterFrame: frames.schedule,
    );
  });

  test('a tap during start-up waits until the gate opens', () async {
    router.handle(_plan());
    router.updateGate(PushGate.waiting);
    frames.run();
    await _settle();
    expect(events, isEmpty);

    router.updateGate(PushGate.open);
    frames.run();
    await _settle();
    expect(events, ['mark:42', 'open:myPlan']);
  });

  test('marks the row read before opening its screen', () async {
    router.updateGate(PushGate.open);
    router.handle(_plan());
    frames.run();
    await _settle();

    expect(events, ['mark:42', 'open:myPlan']);
  });

  test('opening waits for the next frame', () async {
    router.updateGate(PushGate.open);
    router.handle(_plan());
    await _settle();
    expect(events, isEmpty);

    frames.run();
    await _settle();
    expect(events, ['mark:42', 'open:myPlan']);
  });

  test('the screen still opens when the read fails', () async {
    failMarks = true;
    router.updateGate(PushGate.open);
    router.handle(_plan());
    frames.run();
    await _settle();

    expect(events, ['mark:42', 'open:myPlan']);
  });

  test('a tap without a notification id opens without marking', () async {
    router.updateGate(PushGate.open);
    router.handle({'type': 'log_reminder'});
    frames.run();
    await _settle();

    expect(events, ['open:logMeal']);
  });

  test('an unknown type opens the inbox', () async {
    router.updateGate(PushGate.open);
    router.handle({'notification_id': '7', 'type': 'future_type'});
    frames.run();
    await _settle();

    expect(events, ['mark:7', 'open:inbox']);
  });

  test('only the latest tap is kept while waiting', () async {
    router.handle(_plan(id: '1'));
    router.handle(_plan(id: '2'));
    router.updateGate(PushGate.open);
    frames.run();
    await _settle();

    expect(events, ['mark:2', 'open:myPlan']);
  });

  test('a waiting tap is dropped when the session ends first', () async {
    router.handle(_plan());
    router.updateGate(PushGate.closed);
    router.updateGate(PushGate.open);
    frames.run();
    await _settle();

    expect(events, isEmpty);
  });

  test('a tap that arrives while signed out is ignored', () async {
    router.updateGate(PushGate.closed);
    router.handle(_plan());
    router.updateGate(PushGate.open);
    frames.run();
    await _settle();

    expect(events, isEmpty);
  });

  test('a tap is opened once even if the gate opens twice', () async {
    router.updateGate(PushGate.open);
    router.handle(_plan());
    router.updateGate(PushGate.open);
    frames.run();
    await _settle();

    expect(events, ['mark:42', 'open:myPlan']);
  });

  test('nothing opens if the session ends while the read is in flight',
      () async {
    final read = Completer<void>();
    final inFlight = PushTapRouter(
      markRead: (_) => read.future,
      open: (destination, {reviewId}) => events.add('open:${destination.name}'),
      afterFrame: frames.schedule,
    );
    inFlight.updateGate(PushGate.open);
    inFlight.handle(_plan());
    frames.run();

    inFlight.updateGate(PushGate.closed);
    read.complete();
    await _settle();

    expect(events, isEmpty);
  });

  test('a review push passes on the note it names; other pushes pass none',
      () async {
    final opened = <String?>[];
    final noteRouter = PushTapRouter(
      markRead: (_) async {},
      open: (destination, {reviewId}) => opened.add(reviewId),
      afterFrame: frames.schedule,
    );
    noteRouter.updateGate(PushGate.open);

    noteRouter.handle({
      'notification_id': '42',
      'type': 'review_new',
      'review_id': '12',
    });
    frames.run();
    await _settle();
    noteRouter.handle({'notification_id': '43', 'type': 'plan_updated'});
    frames.run();
    await _settle();

    expect(opened, ['12', null]);
  });
}
