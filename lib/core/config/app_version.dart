import 'package:package_info_plus/package_info_plus.dart';

/// The installed app's version, read from the platform once.
///
/// `1.0.0` is the version name and `(3)` the build number, as set by
/// `version:` in pubspec.yaml. Null where the platform cannot answer (a widget
/// test, say): the screens then show no version instead of a made-up one.
class AppVersion {
  AppVersion._();

  static Future<String?>? _label;

  static Future<String?> label() => _label ??= _read();

  static Future<String?> _read() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isEmpty) return null;
      return info.buildNumber.isEmpty
          ? info.version
          : '${info.version} (${info.buildNumber})';
    } on Object {
      return null;
    }
  }
}
