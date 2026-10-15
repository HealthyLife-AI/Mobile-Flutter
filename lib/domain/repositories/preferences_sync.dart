/// Sends the patient's notification settings to the server (API guide 10.5): the
/// app language and, once it can be read, the device timezone.
///
/// `sync` runs at start-up after consent (guide 2.1, step 4) and whenever the
/// patient changes the app language. `syncIfZoneChanged` runs when the app comes
/// back to the foreground, and sends the settings only when the device timezone
/// differs from the one last sent (guide 10.5: send it whenever it changes).
/// Neither throws: a failure is logged and the app keeps working.
abstract interface class PreferencesSync {
  Future<void> sync();

  Future<void> syncIfZoneChanged();
}
