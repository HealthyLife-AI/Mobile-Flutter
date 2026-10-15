import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/push_registrar.dart';

/// Registers this device's FCM token with the API (API guide 10.1 and 2.5).
///
/// * `start`: sends the token with `PUT /me/fcm-token`. The token is sent
///   again whenever FCM rotates it. It does **not** ask for the notification
///   permission: the OS prompt is shown only when the person asks for it (the
///   onboarding or notification-settings screen), never automatically.
/// * `stop`: sends `{"fcm_token": null}` while the access token still works,
///   then deletes the local token, so pushes stop after sign-out.
///
/// Push is best-effort. Missing Firebase, a denied permission or a network
/// error is logged and never blocks sign-in or sign-out.
class FirebasePushRegistrar implements PushRegistrar {
  FirebasePushRegistrar({
    required ApiClient api,
    FirebaseMessaging Function()? messaging,
  })  : _api = api,
        _messaging = messaging ?? _defaultMessaging;

  final ApiClient _api;
  final FirebaseMessaging Function() _messaging;
  StreamSubscription<String>? _tokenRefreshes;

  static FirebaseMessaging _defaultMessaging() => FirebaseMessaging.instance;

  static const DefaultAppLogger _log = DefaultAppLogger();

  @override
  Future<void> start() async {
    try {
      final messaging = _messaging();
      // No requestPermission() here: registering the token is independent of
      // whether the person has allowed notifications. The prompt is shown only
      // from the notification setup/settings screens.
      final token = await messaging.getToken();
      if (token != null) await _register(token);
      _tokenRefreshes ??= messaging.onTokenRefresh.listen(_register);
    } catch (error) {
      _log.warn('Push registration skipped', error: error);
    }
  }

  @override
  Future<void> stop() async {
    await _tokenRefreshes?.cancel();
    _tokenRefreshes = null;
    try {
      await _api.put('me/fcm-token', body: {'fcm_token': null});
    } catch (error) {
      _log.warn('Could not clear the push token on the server', error: error);
    }
    try {
      await _messaging().deleteToken();
    } catch (error) {
      _log.warn('Could not delete the local push token', error: error);
    }
  }

  Future<void> _register(String token) async {
    try {
      await _api.put('me/fcm-token', body: {'fcm_token': token});
    } catch (error) {
      _log.warn('Could not register the push token', error: error);
    }
  }
}
