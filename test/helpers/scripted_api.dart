import 'dart:typed_data';

import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';

/// One request the app sent.
class SentRequest {
  const SentRequest(this.method, this.path, {this.query, this.body});

  final String method;
  final String path;
  final Map<String, dynamic>? query;
  final Object? body;

  @override
  String toString() => '$method $path';
}

/// An [ApiClient] that answers from a script, for the patient-app spec
/// features: `routes['GET me/today'] = {...}`. An answer that is an
/// [AppException] is thrown. A function answer gets the request and returns
/// the body. An unscripted route answers 404, like an unknown route.
class ScriptedApi implements ApiClient, FileTransferClient {
  ScriptedApi([Map<String, Object?>? routes]) : routes = {...?routes};

  final Map<String, Object?> routes;
  final List<SentRequest> sent = [];

  /// When set, every request fails with it (no connection, say).
  AppException? failAll;

  Future<dynamic> _answer(String method, String path,
      {Map<String, dynamic>? query, Object? body}) async {
    final request = SentRequest(method, path, query: query, body: body);
    sent.add(request);
    final everything = failAll;
    if (everything != null) throw everything;
    final key = '$method $path';
    if (!routes.containsKey(key)) {
      throw NotFoundException('No route for $key');
    }
    var answer = routes[key];
    if (answer is Object? Function(SentRequest)) answer = answer(request);
    if (answer is AppException) throw answer;
    return answer;
  }

  /// The requests sent to [method] [path].
  List<SentRequest> to(String method, String path) => [
        for (final r in sent)
          if (r.method == method && r.path == path) r,
      ];

  @override
  Future<dynamic> get(String path,
          {Map<String, dynamic>? query, bool auth = true}) =>
      _answer('GET', path, query: query);

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _answer('POST', path, body: body);

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      _answer('PUT', path, body: body);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      _answer('PATCH', path, body: body);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      _answer('DELETE', path, body: body);

  @override
  Future<Uint8List> getBytes(String path) async {
    final answer = await _answer('GET', path);
    if (answer is Uint8List) return answer;
    if (answer is List<int>) return Uint8List.fromList(answer);
    throw const ParseException('No bytes scripted');
  }

  @override
  Future<dynamic> upload(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required List<int> bytes,
    required String filename,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) {
    onProgress?.call(bytes.length, bytes.length);
    return _answer('POST', path, body: {
      ...fields,
      fileField: filename,
      'content_type': contentType,
    });
  }
}
