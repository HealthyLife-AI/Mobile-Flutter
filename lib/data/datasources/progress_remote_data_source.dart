import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/time/date_only.dart';

/// `GET /me/progress` (API guide 8).
class ProgressRemoteDataSource {
  ProgressRemoteDataSource(this._api);

  final ApiClient _api;

  /// Both dates are sent as `YYYY-MM-DD`. The server reads them as clinic dates
  /// (1.2), so the window is the clinic's, not the device's.
  Future<Map<String, dynamic>> fetch({
    required DateTime from,
    required DateTime to,
  }) async {
    final raw = await _api.get(
      'me/progress',
      query: {'from': dateOnly(from), 'to': dateOnly(to)},
    );
    if (raw is! Map) {
      throw const ParseException('The progress answer is not an object');
    }
    return Map<String, dynamic>.from(raw);
  }
}
