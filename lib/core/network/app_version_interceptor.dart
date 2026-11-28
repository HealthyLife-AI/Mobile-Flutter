import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_version.dart';

/// Sends `X-App-Version` and `X-App-Platform` on every request, so the server
/// can refuse a build older than its minimum with 426 (audit MO-06). Where the
/// platform cannot name the version (a widget test), or has not yet, nothing
/// is sent, and the server never blocks a request without the header. It reads
/// the version kept at start-up ([AppVersion.loadHeader]); it never waits for
/// the platform on the request path.
class AppVersionInterceptor extends Interceptor {
  AppVersionInterceptor({String? Function()? version})
      : _version = version ?? (() => AppVersion.header);

  final String? Function() _version;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final version = _version();
    if (version != null) {
      options.headers['X-App-Version'] = version;
      options.headers['X-App-Platform'] =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    }
    handler.next(options);
  }
}
