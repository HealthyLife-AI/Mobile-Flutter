import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The iOS project is built only on a Mac, so the settings the store review
/// looks at are pinned here, where every pull request runs them.
void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();
  final project =
      File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

  test('the app is iPhone only, in portrait', () {
    expect('TARGETED_DEVICE_FAMILY = 1;'.allMatches(project), hasLength(3));
    expect(project, isNot(contains('TARGETED_DEVICE_FAMILY = "1,2"')));
    expect(plist, contains('UIInterfaceOrientationPortrait'));
    expect(plist, isNot(contains('UIInterfaceOrientationLandscape')));
    expect(plist, isNot(contains('UIInterfaceOrientationPortraitUpsideDown')));
    expect(plist, isNot(contains('UISupportedInterfaceOrientations~ipad')));
  });

  test('the minimum iOS version is the highest one a plugin needs', () {
    // file_picker_darwin needs iOS 14; a lower target makes CocoaPods fail
    // to resolve it, and the app cannot be built at all.
    expect(
        'IPHONEOS_DEPLOYMENT_TARGET = 14.0;'.allMatches(project), hasLength(3));
    expect(project, isNot(contains('IPHONEOS_DEPLOYMENT_TARGET = 13.0;')));
  });

  test('push notifications are declared', () {
    final entitlements =
        File('ios/Runner/Runner.entitlements').readAsStringSync();
    expect(entitlements, contains('aps-environment'));
    expect(plist, contains('<string>remote-notification</string>'));
    // Debug, Release and Profile all sign with the entitlements file.
    expect(
        'CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;'
            .allMatches(project),
        hasLength(3));
  });

  test('the permission texts are localized in Arabic and English', () {
    for (final language in ['ar', 'en']) {
      final strings = File('ios/Runner/$language.lproj/InfoPlist.strings')
          .readAsStringSync();
      expect(strings, contains('NSCameraUsageDescription'), reason: language);
      expect(strings, contains('NSPhotoLibraryUsageDescription'),
          reason: language);
    }
    // The base texts hold one language each, not both in one line.
    final camera = RegExp(
            r'<key>NSCameraUsageDescription</key>\s*<string>([^<]*)</string>')
        .firstMatch(plist)!
        .group(1)!;
    expect(RegExp(r'[؀-ۿ]').hasMatch(camera), isFalse);
    expect(plist, contains('<key>CFBundleLocalizations</key>'));
    expect(project, contains('ar,'));
    expect(project, contains('InfoPlist.strings'));
  });

  test('the app declares what it collects and that it does not track', () {
    final privacy = File('ios/Runner/PrivacyInfo.xcprivacy').readAsStringSync();
    expect(privacy, contains('<key>NSPrivacyTracking</key>\n\t<false/>'));
    expect(privacy, contains('NSPrivacyCollectedDataTypeHealth'));
    expect(privacy, contains('NSPrivacyCollectedDataTypeCrashData'));
    expect(project, contains('PrivacyInfo.xcprivacy in Resources'));
  });

  test('encryption is declared exempt (HTTPS only)', () {
    expect(plist, contains('ITSAppUsesNonExemptEncryption'));
  });

  test('no permission text is left for a feature that is not shipped', () {
    // Only medical reports use the camera and the photo library. The barcode
    // scanner and Health sync are hidden, so nothing else is asked for.
    expect(plist, isNot(contains('NSHealthShareUsageDescription')));
    expect(plist, isNot(contains('NSMicrophoneUsageDescription')));
    expect(plist, isNot(contains('NSLocation')));
  });
}
