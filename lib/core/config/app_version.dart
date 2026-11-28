import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The installed app's version, read from the platform once.
///
/// `1.0.0` is the version name and `(3)` the build number, as set by
/// `version:` in pubspec.yaml. Null where the platform cannot answer (a widget
/// test, say): the screens then show no version instead of a made-up one.
class AppVersion {
  AppVersion._();

  static Future<String?>? _label;
  static String? _cachedHeader;

  static Future<String?> label() => _label ??= _read();

  /// `1.4.2+17`: the value of the `X-App-Version` header the server compares
  /// with its minimum (audit MO-06), read from the platform and kept. Call it
  /// once at start-up. Null where the platform cannot answer.
  static Future<String?> loadHeader() async => _cachedHeader ??= await _readHeader();

  /// What [loadHeader] found, with no platform call: the request path reads
  /// this. Null until it has been loaded, and the server never blocks a
  /// request that carries no version.
  static String? get header => _cachedHeader;

  /// Forgets the version read, so a test reads it again in its own zone.
  @visibleForTesting
  static void reset() {
    _label = null;
    _cachedHeader = null;
  }

  static Future<String?> _readHeader() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isEmpty) return null;
      return info.buildNumber.isEmpty
          ? info.version
          : '${info.version}+${info.buildNumber}';
    } on Object {
      return null;
    }
  }

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
