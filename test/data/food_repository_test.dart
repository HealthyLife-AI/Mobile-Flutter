import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/data/datasources/food_remote_data_source.dart';
import 'package:healthylife_ai/data/repositories/food_repository_impl.dart';

/// Records each GET and answers with the scripted value, or throws the
/// scripted exception.
class _RecordingApi implements ApiClient {
  final List<({String path, Map<String, dynamic>? query})> gets = [];
  Object? answer;

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    gets.add((path: path, query: query));
    final next = answer;
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

Map<String, dynamic> _food(int id, String name) => {
      'id': id,
      'name_en': name,
      'name_ar': null,
      'calories_per_100g': 52,
      'protein_g_per_100g': 0.3,
      'carbs_g_per_100g': 14,
      'fat_g_per_100g': 0.2,
      'allergens': <String>[],
      'shopping_section': 'produce',
    };

void main() {
  late _RecordingApi api;
  late FoodRepositoryImpl repository;

  setUp(() {
    api = _RecordingApi();
    repository = FoodRepositoryImpl(FoodRemoteDataSource(api));
  });

  test('a search asks the server for that query, one page of 50', () async {
    api.answer = {
      'data': [_food(1, 'Apple'), _food(2, 'Apricot')],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 2},
    };

    final result = await repository.search('ap');

    expect(api.gets.single.path, 'foods/search');
    expect(api.gets.single.query, {'q': 'ap', 'per_page': 50});
    expect(result.valueOrNull?.map((food) => food.id).toList(), [1, 2]);
    expect(result.valueOrNull?.first.name, 'Apple');
  });

  test('an answer without a data list fails as an unexpected answer', () async {
    api.answer = {'meta': <String, dynamic>{}};

    final result = await repository.search('ap');

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  test('a refused query keeps the server code and status', () async {
    api.answer = const ApiException(
      'too short',
      statusCode: 422,
      code: 'validation_failed',
    );

    final result = await repository.search('a');

    final failure = result.failureOrNull;
    expect(failure, isA<ApiFailure>());
    final apiFailure = failure as ApiFailure;
    expect(apiFailure.statusCode, 422);
    expect(apiFailure.code, 'validation_failed');
  });

  test('offline, the search fails as a network problem', () async {
    api.answer = NetworkException(
      'no connection',
      kind: NetworkFailureKind.offline,
    );

    final result = await repository.search('apple');

    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}
