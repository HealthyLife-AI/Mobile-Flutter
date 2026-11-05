import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';

/// `GET /me/health-profile` (API guide 11.1). Returns the object as it came
/// from the server, so the repository can keep the same copy on the device.
class HealthProfileRemoteDataSource {
  HealthProfileRemoteDataSource(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetch() async {
    final raw = await _api.get('me/health-profile');
    if (raw is! Map) {
      throw const ParseException('The health profile is not an object');
    }
    return Map<String, dynamic>.from(raw);
  }

  /// `POST /me/proposals` (11.2). The answer is not needed: the profile is read
  /// again afterwards, and the new request appears in it.
  Future<void> propose(Map<String, dynamic> body) async {
    await _api.post('me/proposals', body: body);
  }

  /// `DELETE /me/proposals/{id}` (11.3). Answers 204.
  Future<void> withdraw(int proposalId) async {
    await _api.delete('me/proposals/$proposalId');
  }
}
