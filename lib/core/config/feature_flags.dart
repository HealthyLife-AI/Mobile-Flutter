/// Features that are built but not part of this release.
///
/// Each flag is a compile-time constant that is off unless the build turns it
/// on, so a release build carries no way into the feature:
///
///   flutter run --dart-define=FEATURE_BARCODE_SCANNER=true
class FeatureFlags {
  FeatureFlags._();

  /// The barcode scanner behind the food search field. Its screen is a
  /// design prototype: it reads no camera and looks up no product.
  static const bool barcodeScanner =
      bool.fromEnvironment('FEATURE_BARCODE_SCANNER');

  /// "Connect the Health app" in the account screen. Apple Health and Health
  /// Connect are not wired yet.
  static const bool healthSync = bool.fromEnvironment('FEATURE_HEALTH_SYNC');

  /// "Send a test crash" in About, to check on a phone that a crash reaches
  /// Crashlytics. Only the internal-test APK built by CI turns it on; a store
  /// build never does.
  static const bool crashTest = bool.fromEnvironment('CRASH_TEST');
}
