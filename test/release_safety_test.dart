import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Checks on files a widget test cannot exercise: they hold in release builds
/// and in the Android packaging, which tests do not run.
void main() {
  test('only main.dart uses device_preview, and only in debug builds', () {
    final users = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            file.readAsStringSync().contains('package:device_preview/'))
          file.path.replaceAll(r'\', '/'),
    ];
    expect(users, ['lib/main.dart']);

    final main = File('lib/main.dart').readAsStringSync();
    // The release path returns before the preview wrapper is built.
    final earlyExit = main.indexOf('if (!kDebugMode) {');
    final wrapper = main.indexOf('DevicePreview(');
    expect(earlyExit, greaterThan(0));
    expect(wrapper, greaterThan(earlyExit));
    // Every other mention is the guarded `appBuilder`.
    expect(
      RegExp(r'kDebugMode\s*\?\s*DevicePreview\.appBuilder').hasMatch(main),
      isTrue,
    );
    expect('DevicePreview.appBuilder'.allMatches(main).length, 1);
  });

  test('Android keeps nothing in backups and has a notification icon', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
    expect(manifest,
        contains('com.google.firebase.messaging.default_notification_icon'));

    const res = 'android/app/src/main/res';
    expect(File('$res/xml/data_extraction_rules.xml').existsSync(), isTrue);
    expect(File('$res/drawable/ic_stat_notification.xml').existsSync(), isTrue);
    // Named from Dart only, so the shrinker must be told to keep it.
    expect(File('$res/raw/keep.xml').readAsStringSync(),
        contains('@drawable/ic_stat_notification'));
    expect(
      File('lib/data/services/local_reminder_notifications.dart')
          .readAsStringSync(),
      contains("AndroidInitializationSettings('ic_stat_notification')"),
    );
  });

  test('a release build does not fall back to the debug key silently', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('allowDebugSigning'));
    expect(gradle, contains('Release signing is not set up'));
  });
}
