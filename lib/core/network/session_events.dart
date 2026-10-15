import 'dart:async';

import 'package:flutter/foundation.dart';

/// Session-wide events raised by the network stack. The auth cubit listens and
/// moves the whole app (login screen, follow-up ended, consent) without each
/// screen having to handle these codes itself.
enum SessionEventType {
  /// The refresh token was rejected: the patient must sign in again.
  expired,

  /// The nutritionist ended follow-up (403 `follow_up_ended`). Tokens were
  /// already cleared by the interceptor.
  followUpEnded,

  /// The privacy policy changed or was never accepted (403 `consent_required`).
  consentRequired,
}

@immutable
class SessionEvent {
  const SessionEvent(this.type, {this.body = const {}});

  final SessionEventType type;

  /// The response body that caused the event (for example `current_version`
  /// and `policy_url`, or `nutritionist` and `weeks_followed`).
  final Map<String, dynamic> body;
}

/// Broadcast bus for [SessionEvent]s. One instance per app, owned by the
/// composition root.
class SessionEvents {
  final StreamController<SessionEvent> _controller =
      StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get stream => _controller.stream;

  void emit(SessionEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> close() => _controller.close();
}
