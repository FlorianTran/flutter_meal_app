import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_meal_app/core/network/mealdb_api_client.dart';
import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_remote_datasource.dart';
import 'package:flutter_meal_app/features/meals/data/repositories_impl/meals_repository_impl.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_meal_of_day.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_categories.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_meals_by_category.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_meals_by_area.dart';

void main() {
  group('Phase 1.1: Repository & Use Cases Tests', () {
    late MealDbApiClient apiClient;
    late MealDbRemoteDataSource remoteDataSource;
    late MealsRepositoryImpl repository;

    setUpAll(() async {
      await dotenv.load(fileName: ".env");
    });

    setUp(() {
      apiClient = MealDbApiClient(
        baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
      );
      remoteDataSource = MealDbRemoteDataSourceImpl(apiClient: apiClient);
      repository = MealsRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    tearDown(() {
      apiClient.dispose();
    });

    test('GetMealOfDay use case should return meal', () async {
      final useCase = GetMealOfDay(repository);
      final result = await useCase();

      expect(result.failure, isNull);
      expect(result.meal, isNotNull);
      expect(result.meal!.id, isNotEmpty);
      expect(result.meal!.name, isNotEmpty);
    });

    test('GetCategories use case should return categories', () async {
      final useCase = GetCategories(repository);
      final result = await useCase();

      expect(result.failure, isNull);
      expect(result.categories, isNotNull);
      expect(result.categories!.isNotEmpty, isTrue);
      expect(result.categories!.first.name, isNotEmpty);
    });

    test('GetMealsByCategory use case should return meals', () async {
      final useCase = GetMealsByCategory(repository);
      final result = await useCase('Seafood');

      expect(result.failure, isNull);
      expect(result.meals, isNotNull);
      expect(result.meals!.isNotEmpty, isTrue);
      // Filter endpoint returns simplified meal objects without full details
      expect(result.meals!.first.id, isNotEmpty);
      expect(result.meals!.first.name, isNotEmpty);
    });

    test('GetMealsByArea use case should return meals', () async {
      final useCase = GetMealsByArea(repository);
      final result = await useCase('Canadian');

      expect(result.failure, isNull);
      expect(result.meals, isNotNull);
      expect(result.meals!.isNotEmpty, isTrue);
      // Filter endpoint returns simplified meal objects without full details
      expect(result.meals!.first.id, isNotEmpty);
      expect(result.meals!.first.name, isNotEmpty);
    });

    test('GetMealsByCategory should return failure for empty category',
        () async {
      final useCase = GetMealsByCategory(repository);
      final result = await useCase('');

      expect(result.failure, isNotNull);
      expect(result.meals, isNull);
    });

    test('GetMealsByArea should return failure for empty area', () async {
      final useCase = GetMealsByArea(repository);
      final result = await useCase('');

      expect(result.failure, isNotNull);
      expect(result.meals, isNull);
    });

    test('Repository should handle search meals', () async {
      final result = await repository.searchMeals('Arrabiata');

      expect(result.failure, isNull);
      expect(result.meals, isNotNull);
      if (result.meals!.isNotEmpty) {
        expect(
          result.meals!.first.name.toLowerCase(),
          contains('arrabiata'),
        );
      }
    });

    test('Repository should handle list categories', () async {
      final result = await repository.listCategories();

      expect(result.failure, isNull);
      expect(result.categoryNames, isNotNull);
      expect(result.categoryNames!.isNotEmpty, isTrue);
    });

    test('Repository should handle list areas', () async {
      final result = await repository.listAreas();

      expect(result.failure, isNull);
      expect(result.areaNames, isNotNull);
      expect(result.areaNames!.isNotEmpty, isTrue);
    });

    test('Repository should handle get meal details', () async {
      // First get a meal ID from random meal
      final mealOfDayResult = await repository.getMealOfDay();
      expect(mealOfDayResult.failure, isNull);
      expect(mealOfDayResult.meal, isNotNull);

      final mealId = mealOfDayResult.meal!.id;

      // Then get details
      final detailsResult = await repository.getMealDetails(mealId);

      expect(detailsResult.failure, isNull);
      expect(detailsResult.meal, isNotNull);
      expect(detailsResult.meal!.id, equals(mealId));
    });
  });
}
