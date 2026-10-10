import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../logging/app_logger.dart';

/// Abstraction over HTTP so screens/repositories never depend on a concrete
/// transport. `HttpApiClient` is the real implementation; tests inject a
/// fake through the same interface.
///
/// Endpoints are deliberately NOT hardcoded here: the base URL comes from
/// [AppConfig.apiBaseUrl] and paths are supplied by the data sources that
/// own them. No real backend is wired yet — see `lib/data/`.
abstract interface class ApiClient {
  Future<dynamic> get(String path, {Map<String, String>? queryParameters});
  Future<dynamic> post(String path, {Object? body});
  Future<dynamic> put(String path, {Object? body});
  Future<dynamic> delete(String path);
}

typedef TokenProvider = Future<String?> Function();

class HttpApiClient implements ApiClient {
  HttpApiClient({
    Uri? baseUri,
    http.Client? client,
    this.timeout = AppConfig.connectTimeout,
    TokenProvider? tokenProvider,
    AppLogger? logger,
  })  : _baseUri = baseUri ?? Uri.parse(AppConfig.apiBaseUrl),
        _client = client ?? http.Client(),
        _tokenProvider = tokenProvider,
        _logger = logger ?? const DefaultAppLogger();

  final Uri _baseUri;
  final http.Client _client;
  final Duration timeout;
  final TokenProvider? _tokenProvider;
  final AppLogger _logger;

  @override
  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) =>
      _send('GET', path, queryParameters: queryParameters);

  @override
  Future<dynamic> post(String path, {Object? body}) => _send('POST', path, body: body);

  @override
  Future<dynamic> put(String path, {Object? body}) => _send('PUT', path, body: body);

  @override
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Uri _resolve(String path, Map<String, String>? queryParameters) {
    final uri = _baseUri.replace(
      path: '${_baseUri.path}${path.startsWith('/') ? path : '/$path'}',
      queryParameters: queryParameters,
    );
    return uri;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    final uri = _resolve(path, queryParameters);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };
    final token = await _tokenProvider?.call();
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

    final request = http.Request(method, uri)
      ..headers.addAll(headers)
      ..body = body == null ? '' : jsonEncode(body);

    http.StreamedResponse response;
    try {
      final streamed = await _client.send(request).timeout(timeout);
      response = streamed;
    } on TimeoutException {
      _logger.warn('API timeout: $method $uri');
      throw const NetworkException('Request timed out', kind: NetworkFailureKind.timeout);
    } on SocketException catch (e) {
      _logger.warn('API socket error: $method $uri', error: e);
      throw NetworkException('Network unreachable', kind: NetworkFailureKind.offline, cause: e);
    } on http.ClientException catch (e) {
      _logger.warn('API client error: $method $uri', error: e);
      throw NetworkException('Connection failed', kind: NetworkFailureKind.offline, cause: e);
    }

    final raw = await response.stream.bytesToString().timeout(timeout);
    final status = response.statusCode;

    if (status == 401 || status == 403) {
      throw UnauthorizedException('Unauthorized ($status)', statusCode: status);
    }
    if (status == 404) {
      throw NotFoundException('Not found', statusCode: status);
    }
    if (status == 400 || status == 422) {
      var fields = const <String, String>{};
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic> && decoded['errors'] is Map) {
          fields = (decoded['errors'] as Map).map((k, v) => MapEntry('$k', '$v'));
        }
      } catch (_) {} // ignore malformed validation body
      throw ValidationException('Validation failed', statusCode: status, fieldErrors: fields);
    }
    if (status >= 500) {
      throw ServerException('Server error ($status)', statusCode: status);
    }
    if (status < 200 || status >= 300) {
      throw ServerException('Unexpected status ($status)', statusCode: status);
    }

    if (raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } on FormatException catch (e) {
      throw ParseException('Invalid JSON in response', cause: e);
    }
  }

  void dispose() => _client.close();
}
