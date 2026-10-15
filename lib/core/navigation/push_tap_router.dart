import 'dart:async';

import 'package:flutter/scheduler.dart';

import 'push_destination.dart';

/// Whether the app can open screens right now.
enum PushGate {
  /// Start-up is still running. Taps wait.
  waiting,

  /// The shell is the root. Taps open their screen.
  open,

  /// Signed out, or on a gate screen. Taps are dropped.
  closed,
}

/// Routes a tapped push. It marks the inbox row read on the server, then opens
/// the screen for its type (API guide 10.4). A review push also passes on the
/// note it names.
///
/// A tap that arrives during start-up waits until the gate opens, so the
/// splash does not swallow it. Only the latest tap is kept. A tap that arrives
/// after the session has ended is dropped, rather than opened later for
/// whoever signs in next.
///
/// Opening waits for the next frame. The splash replaces the navigation stack
/// in the same call that ends launch, so a screen pushed earlier would be
/// removed with it.
class PushTapRouter {
  PushTapRouter({
    required Future<void> Function(String notificationId) markRead,
    required void Function(PushDestination destination, {String? reviewId})
        open,
    void Function(void Function() callback)? afterFrame,
  })  : _markRead = markRead,
        _open = open,
        _afterFrame = afterFrame ?? _nextFrame;

  final Future<void> Function(String notificationId) _markRead;
  final void Function(PushDestination destination, {String? reviewId}) _open;
  final void Function(void Function() callback) _afterFrame;

  /// The longest the screen waits for the read to be confirmed.
  static const Duration markReadTimeout = Duration(seconds: 5);

  PushGate _gate = PushGate.waiting;

  /// Where the app stands right now. Read-only.
  PushGate get gate => _gate;
  PushTap? _pending;

  /// Called with the `data` of each tap, from the app's open and
  /// initial-message streams. Empty data is ignored.
  void handle(Map<String, dynamic>? data) {
    final tap = PushTap.fromData(data);
    if (tap == null || _gate == PushGate.closed) return;
    _pending = tap;
    _flushWhenOpen();
  }

  /// Called whenever the app's readiness changes.
  void updateGate(PushGate gate) {
    _gate = gate;
    if (gate == PushGate.closed) {
      _pending = null;
      return;
    }
    _flushWhenOpen();
  }

  void _flushWhenOpen() {
    if (_gate == PushGate.open && _pending != null) {
      _afterFrame(_flush);
    }
  }

  void _flush() {
    final tap = _pending;
    if (_gate != PushGate.open || tap == null) return;
    _pending = null;
    unawaited(_route(tap));
  }

  Future<void> _route(PushTap tap) async {
    final id = tap.notificationId;
    if (id != null) {
      try {
        await _markRead(id).timeout(markReadTimeout);
      } catch (_) {
        // Best effort. The screen still opens, and the row stays unread.
      }
    }
    // The session may have ended while the read was in flight.
    if (_gate != PushGate.open) return;
    _open(destinationForType(tap.type), reviewId: tap.reviewId);
  }
}

void _nextFrame(void Function() callback) {
  final binding = SchedulerBinding.instance;
  binding.addPostFrameCallback((_) => callback());
  // Without a frame request, a post-frame callback can wait for the next
  // unrelated frame.
  binding.scheduleFrame();
}
