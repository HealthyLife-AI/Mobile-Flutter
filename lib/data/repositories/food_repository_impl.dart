import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_remote_data_source.dart';

class FoodRepositoryImpl implements FoodRepository {
  FoodRepositoryImpl(this._remote);

  final FoodRemoteDataSource _remote;

  @override
  Future<Result<List<SearchableFood>>> search(String query) => guard(
        () async =>
            (await _remote.search(query)).map((dto) => dto.toEntity()).toList(),
        context: 'FoodRepository.search',
      );
}
