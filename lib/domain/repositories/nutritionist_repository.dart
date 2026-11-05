import '../../core/errors/result.dart';
import '../entities/nutritionist_entities.dart';

/// The patient's nutritionist, as the server describes her.
abstract interface class NutritionistRepository {
  /// The server's answer, or the last one kept on this device when there is no
  /// connection.
  Future<Result<NutritionistProfile>> getProfile();
}
