import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/navigation/foreground_push.dart';
import 'package:healthylife_ai/core/navigation/push_destination.dart';
import 'package:healthylife_ai/core/navigation/push_tap_router.dart';

class _Notice {
  _Notice(this.title, this.body, this.onOpen);

  final String title;
  final String body;
  final void Function() onOpen;
}

void main() {
  late List<_Notice> shown;
  late List<String> events;
  late PushTapRouter taps;
  late ForegroundPushPresenter presenter;

  setUp(() {
    shown = [];
    events = [];
    taps = PushTapRouter(
      markRead: (id) async => events.add('mark:$id'),
      open: (destination, {reviewId}) => events.add('open:${destination.name}'),
      afterFrame: (callback) => callback(),
    );
    presenter = ForegroundPushPresenter(
      taps: taps,
      show: ({
        required String title,
        required String body,
        required void Function() onOpen,
      }) {
        shown.add(_Notice(title, body, onOpen));
      },
    );
  });

  test('nothing is drawn before the app is ready', () {
    presenter.present(
      data: {'notification_id': '42', 'type': 'plan_updated'},
      title: 'Plan updated',
      body: 'Your plan changed',
    );

    expect(shown, isEmpty);
  });

  test('a push is drawn with its own text once the app is ready', () {
    taps.updateGate(PushGate.open);

    presenter.present(
      data: {'notification_id': '42', 'type': 'plan_updated'},
      title: '  Plan updated ',
      body: 'Your plan changed',
    );

    expect(shown, hasLength(1));
    expect(shown.single.title, 'Plan updated');
    expect(shown.single.body, 'Your plan changed');
  });

  test('the notice opens its notification through the tap router', () async {
    taps.updateGate(PushGate.open);
    presenter.present(
      data: {'notification_id': '42', 'type': 'plan_updated'},
      title: 'Plan updated',
      body: 'Your plan changed',
    );

    shown.single.onOpen();
    await Future<void>.delayed(Duration.zero);

    expect(events, ['mark:42', 'open:myPlan']);
  });

  test('a push with no text is not drawn', () {
    taps.updateGate(PushGate.open);

    presenter.present(
      data: {'notification_id': '42'},
      title: null,
      body: '   ',
    );

    expect(shown, isEmpty);
  });

  test('a push with only a body is drawn with an empty title', () {
    taps.updateGate(PushGate.open);

    presenter.present(data: {}, title: null, body: 'Your plan changed');

    expect(shown.single.title, '');
    expect(shown.single.body, 'Your plan changed');
  });

  test('nothing is drawn after the session ends', () {
    taps.updateGate(PushGate.open);
    taps.updateGate(PushGate.closed);

    presenter.present(
      data: {'notification_id': '42', 'type': 'plan_updated'},
      title: 'Plan updated',
      body: 'Your plan changed',
    );

    expect(shown, isEmpty);
  });
}
