/// Keeps this device registered for push notifications (API guide section 10.1).
///
/// `start` runs after every sign-in, on start-up and when the FCM token rotates.
/// `stop` runs on logout and clears the token server-side so pushes stop.
/// Neither throws: push is best-effort and must never block sign-in.
abstract interface class PushRegistrar {
  Future<void> start();
  Future<void> stop();
}
