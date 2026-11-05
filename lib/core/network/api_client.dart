import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// `RequestOptions.extra` key. `false` marks a request that must not carry a
/// bearer token: login, refresh and logout (API guide section 1.1).
const String kAuthRequiredKey = 'auth_required';

/// Set on a request once it has been replayed after a token refresh, so a
/// second 401 is surfaced instead of looping.
const String kAuthRetriedKey = 'auth_retried';

/// Number of automatic retries already made for a GET request.
const String kRetryAttemptKey = 'retry_attempt';

/// Transport-independent HTTP surface. Repositories and data sources depend on
/// this interface only, so tests can substitute a fake.
///
/// [path] is relative to `AppConfig.apiBaseUrl`, with no leading slash
/// (for example `auth/login`).
abstract interface class ApiClient {
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true});

  Future<dynamic> post(String path, {Object? body, bool auth = true});

  Future<dynamic> put(String path, {Object? body, bool auth = true});

  Future<dynamic> patch(String path, {Object? body, bool auth = true});

  Future<dynamic> delete(String path, {Object? body, bool auth = true});
}

/// Binary transfers: downloading a file the patient owns and uploading one
/// with progress (medical reports). Kept apart from [ApiClient] so the many
/// test fakes of the JSON surface stay unchanged.
abstract interface class FileTransferClient {
  /// The raw body of a GET, with the user's token. Never cached on disk.
  Future<Uint8List> getBytes(String path);

  /// A `multipart/form-data` POST: [fields] plus one file under [fileField].
  /// [onProgress] gets the bytes sent and the total.
  Future<dynamic> upload(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required List<int> bytes,
    required String filename,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  });
}

/// [ApiClient] backed by Dio. Interceptors (auth, retry, logging) are attached
/// by `createApiClient`; this class only sends requests and maps failures.
class DioApiClient implements ApiClient, FileTransferClient {
  DioApiClient(this._dio);

  final Dio _dio;

  @override
  Future<dynamic> get(String path,
          {Map<String, dynamic>? query, bool auth = true}) =>
      _run(() => _dio.get<dynamic>(path,
          queryParameters: query, options: _options(auth)));

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _run(() => _dio.post<dynamic>(path, data: body, options: _options(auth)));

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      _run(() => _dio.put<dynamic>(path, data: body, options: _options(auth)));

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) => _run(
      () => _dio.patch<dynamic>(path, data: body, options: _options(auth)));

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) => _run(
      () => _dio.delete<dynamic>(path, data: body, options: _options(auth)));

  @override
  Future<Uint8List> getBytes(String path) async {
    final data = await _run(() => _dio.get<dynamic>(path,
        options: Options(
          responseType: ResponseType.bytes,
          extra: {kAuthRequiredKey: true},
        )));
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    throw const ParseException('The file has no body');
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
  }) =>
      _run(() => _dio.post<dynamic>(
            path,
            data: FormData.fromMap({
              ...fields,
              fileField: MultipartFile.fromBytes(
                bytes,
                filename: filename,
                contentType: DioMediaType.parse(contentType),
              ),
            }),
            options: Options(
              contentType: Headers.multipartFormDataContentType,
              // A 10 MB file on a slow line takes longer than a JSON write.
              sendTimeout: const Duration(minutes: 3),
              extra: {kAuthRequiredKey: true},
            ),
            onSendProgress: onProgress,
          ));

  Options _options(bool auth) => Options(extra: {kAuthRequiredKey: auth});

  Future<dynamic> _run(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      // 204 No Content arrives as null or an empty string: both mean "no body".
      return response.data;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Closes the underlying Dio client. Call only when the app is shutting down.
  void dispose() => _dio.close(force: true);
}

/// Converts a [DioException] into the app's exception hierarchy.
///
/// An [AppException] already carried in `error` (for example a refresh failure
/// raised inside the auth interceptor) is passed through unchanged.
AppException mapDioException(DioException e) {
  final inner = e.error;
  if (inner is AppException) return inner;

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      NetworkException('Request timed out',
          kind: NetworkFailureKind.timeout, cause: e),
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.unknown =>
      NetworkException(
        'Network unreachable',
        kind: NetworkFailureKind.offline,
        cause: e,
      ),
    DioExceptionType.badResponse => _fromResponse(e),
    DioExceptionType.cancel ||
    DioExceptionType.badCertificate ||
    DioExceptionType.transformTimeout =>
      NetworkException(e.message ?? 'Request failed', cause: e),
  };
}

AppException _fromResponse(DioException e) {
  final response = e.response;
  final status = response?.statusCode ?? 0;
  final data = response?.data;
  final body =
      data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};
  final message =
      body['message'] is String ? body['message'] as String : 'HTTP $status';

  if (status >= 500) {
    return ServerException(message, statusCode: status);
  }
  final code = body['code'] is String ? body['code'] as String : null;
  // An uncoded 404 is the resource missing, or not this patient's (guide 15).
  // A coded 404 stays an [ApiException], because the consumer branches on code.
  if (status == 404 && code == null) {
    return NotFoundException(message);
  }
  return ApiException(
    message,
    statusCode: status,
    code: code,
    body: body,
    retryAfter: retryAfterOf(response),
  );
}

/// Parses the `Retry-After` header as whole seconds (the form the API uses).
Duration? retryAfterOf(Response<dynamic>? response) {
  final seconds = int.tryParse(response?.headers.value('retry-after') ?? '');
  return seconds == null ? null : Duration(seconds: seconds);
}
