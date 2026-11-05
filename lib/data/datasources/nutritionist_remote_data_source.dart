import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/nutritionist_entities.dart';
import '../models/nutritionist_dto.dart';

/// `GET /me/nutritionist` (API guide 9.1). Not consent-gated.
class NutritionistRemoteDataSource {
  NutritionistRemoteDataSource(this._api);

  final ApiClient _api;

  Future<NutritionistProfile> fetch() async {
    final raw = await _api.get('me/nutritionist');
    final profile = NutritionistDto.fromJson(raw);
    if (profile == null) {
      throw const ParseException('The nutritionist has no name');
    }
    return profile;
  }
}
