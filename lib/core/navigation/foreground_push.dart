import 'push_tap_router.dart';

/// Draws one notice: the server's title and body, and an action that opens
/// the notification. [title] and [body] are already trimmed.
typedef PushNoticeDrawer = void Function({
  required String title,
  required String body,
  required void Function() onOpen,
});

/// Shows a push that arrives while the app is open. The OS shows nothing for a
/// foreground message, so the app draws its own notice (API guide 10.4).
///
/// Notices appear only once the patient is in the main shell. On the splash or
/// on a sign-in screen the inbox still gets the row, and no notice is drawn.
class ForegroundPushPresenter {
  ForegroundPushPresenter({
    required PushTapRouter taps,
    required PushNoticeDrawer show,
  })  : _taps = taps,
        _show = show;

  final PushTapRouter _taps;
  final PushNoticeDrawer _show;

  /// Draws the notice for a push. The text is the notification's own, which
  /// the server keeps generic (10.4). Nothing is drawn when both parts are
  /// empty.
  void present({
    required Map<String, dynamic> data,
    required String? title,
    required String? body,
  }) {
    if (_taps.gate != PushGate.open) return;
    final headline = title?.trim() ?? '';
    final text = body?.trim() ?? '';
    if (headline.isEmpty && text.isEmpty) return;
    _show(
      title: headline,
      body: text,
      onOpen: () => _taps.handle(data),
    );
  }
}
