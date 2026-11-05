import 'package:flutter_timezone/flutter_timezone.dart';

import '../../domain/repositories/device_timezone.dart';

/// Reads the device's IANA timezone name, such as `Asia/Hebron`, with the
/// `flutter_timezone` package (API guide 10.5).
///
/// A read that fails throws. `NotificationPreferencesSync` catches that and
/// sends its request without a timezone, so the server uses the clinic's.
class FlutterDeviceTimezone implements DeviceTimezone {
  const FlutterDeviceTimezone();

  @override
  Future<String?> ianaName() async {
    final zone = await FlutterTimezone.getLocalTimezone();
    return zone.identifier;
  }
}
