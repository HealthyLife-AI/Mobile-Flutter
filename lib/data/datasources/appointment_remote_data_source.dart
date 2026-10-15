import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/appointment_entities.dart';

/// `GET /me/appointments?scope=` (API guide 12.4). The answer is a plain array
/// of up to 50 appointments.
class AppointmentRemoteDataSource {
  AppointmentRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> fetch({
    required AppointmentScope scope,
  }) async {
    final raw = await _api.get(
      'me/appointments',
      query: {'scope': scope.apiValue},
    );
    if (raw is! List) {
      throw const ParseException('The appointments answer is not a list');
    }
    return [
      for (final item in raw)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }
}
