import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/appointment_entities.dart';

<<<<<<< HEAD
/// The appointment endpoints (API guide 12). The list is a plain array of up
/// to 50 appointments (12.4); every write answers with the appointment.
=======
/// `GET /me/appointments?scope=` (API guide 12.4). The answer is a plain array
/// of up to 50 appointments.
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
class AppointmentRemoteDataSource {
  AppointmentRemoteDataSource(this._api);

  final ApiClient _api;

<<<<<<< HEAD
  /// `GET /me/appointments?scope=` (12.4).
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
<<<<<<< HEAD

  /// `GET /me/appointments/slots?type=` (12.1).
  Future<Map<String, dynamic>> fetchSlots(String type) async =>
      _object(await _api.get('me/appointments/slots', query: {'type': type}));

  /// `POST /me/appointments` (12.2). Answers 201 with the appointment.
  Future<Map<String, dynamic>> book(Map<String, Object?> body) async =>
      _object(await _api.post('me/appointments', body: body));

  /// `PATCH /me/appointments/{id}` with a new start (12.3).
  Future<Map<String, dynamic>> reschedule(int id, String startsAt) async =>
      _object(await _api
          .patch('me/appointments/$id', body: {'starts_at': startsAt}));

  /// `DELETE /me/appointments/{id}` (12.3). Answers with the appointment,
  /// now `cancelled`.
  Future<Map<String, dynamic>> cancel(int id) async =>
      _object(await _api.delete('me/appointments/$id'));

  static Map<String, dynamic> _object(Object? raw) {
    if (raw is! Map) {
      throw const ParseException('The appointment answer is not an object');
    }
    return Map<String, dynamic>.from(raw);
  }
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
}
