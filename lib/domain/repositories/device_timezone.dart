/// The device's timezone as an IANA name, such as `Asia/Hebron` (API guide
/// 10.5). Null when it cannot be read. The server then uses the clinic's
/// timezone.
abstract interface class DeviceTimezone {
  Future<String?> ianaName();
}
