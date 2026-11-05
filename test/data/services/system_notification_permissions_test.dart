import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/services/system_notification_permissions.dart';
import 'package:healthylife_ai/domain/repositories/notification_permissions.dart';

void main() {
  group('SystemNotificationPermissions.status', () {
    test('authorized and provisional are both "granted"', () async {
      for (final status in [
        AuthorizationStatus.authorized,
        AuthorizationStatus.provisional,
      ]) {
        final permissions =
            SystemNotificationPermissions(readStatus: () async => status);
        expect(
            await permissions.status(), NotificationPermissionStatus.granted);
      }
    });

    test('denied maps to denied', () async {
      final permissions = SystemNotificationPermissions(
          readStatus: () async => AuthorizationStatus.denied);
      expect(await permissions.status(), NotificationPermissionStatus.denied);
    });

    test('notDetermined maps to notDetermined', () async {
      final permissions = SystemNotificationPermissions(
          readStatus: () async => AuthorizationStatus.notDetermined);
      expect(await permissions.status(),
          NotificationPermissionStatus.notDetermined);
    });

    test('a platform failure is "not determined", never thrown', () async {
      final permissions = SystemNotificationPermissions(
          readStatus: () async => throw StateError('no firebase'));
      expect(await permissions.status(),
          NotificationPermissionStatus.notDetermined);
    });
  });

  group('SystemNotificationPermissions.request', () {
    test('the chosen answer is mapped back', () async {
      final permissions = SystemNotificationPermissions(
          requestPermission: () async => AuthorizationStatus.denied);
      expect(await permissions.request(), NotificationPermissionStatus.denied);
    });

    test('a platform failure is "not determined", never thrown', () async {
      final permissions = SystemNotificationPermissions(
          requestPermission: () async => throw StateError('no firebase'));
      expect(await permissions.request(),
          NotificationPermissionStatus.notDetermined);
    });
  });

  group('SystemNotificationPermissions.openSystemSettings', () {
    test('passes through the platform answer', () async {
      final permissions =
          SystemNotificationPermissions(openSettings: () async => true);
      expect(await permissions.openSystemSettings(), isTrue);
    });

    test('a failure is false, never thrown', () async {
      final permissions = SystemNotificationPermissions(
          openSettings: () async => throw StateError('no platform'));
      expect(await permissions.openSystemSettings(), isFalse);
    });
  });
}
