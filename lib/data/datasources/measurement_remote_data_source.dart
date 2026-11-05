import '../../core/network/api_client.dart';
import '../../domain/entities/measurement_entities.dart';
import '../models/measurement_dto.dart';

/// `GET /me/measurements` (API guide 7.2): every reading, clinic and
/// self-reported together, oldest first. The answer is a plain array and is
/// not paged.
class MeasurementRemoteDataSource {
  MeasurementRemoteDataSource(this._api);

  final ApiClient _api;

  Future<List<MeasurementEntry>> fetchReadings() async {
    final raw = await _api.get('me/measurements');
    return MeasurementDto.readingsFromJson(raw);
  }
<<<<<<< HEAD

  /// `DELETE /me/measurements/{id}` (7.3). Answers 204.
  Future<void> delete(String id) async {
    await _api.delete('me/measurements/${Uri.encodeComponent(id)}');
  }
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
}
