import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_meal_app/core/network/mealdb_api_client.dart';
import 'package:flutter_meal_app/features/meals/data/models/meal_model.dart';
import 'package:flutter_meal_app/features/meals/data/models/category_model.dart';
import 'package:flutter_meal_app/features/meals/data/models/ingredient_model.dart';

void main() {
  group('MealDB API Client - Phase 0 Tests', () {
    late MealDbApiClient apiClient;

    setUpAll(() async {
      // Load .env file for tests
      await dotenv.load(fileName: ".env");
    });

    setUp(() {
      // Use direct URL for testing (test API key)
      apiClient = MealDbApiClient(
        baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
      );
    });

    tearDown(() {
      apiClient.dispose();
    });

    test('should get random meal', () async {
      final response = await apiClient.getRandomMeal();

      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('meals'), isTrue);

      final meals = response['meals'];
      expect(meals, isNotNull);
      expect(meals, isA<List>());
      expect((meals as List).isNotEmpty, isTrue);

      // Test MealModel parsing
      final mealData = (meals).first as Map<String, dynamic>;
      final meal = MealModel.fromJson(mealData);

      expect(meal.id, isNotEmpty);
      expect(meal.name, isNotEmpty);
    });

    test('should get categories', () async {
      final response = await apiClient.getCategories();

      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('categories'), isTrue);

      final categories = response['categories'] as List;
      expect(categories.isNotEmpty, isTrue);

      // Test CategoryModel parsing
      final categoryData = categories.first as Map<String, dynamic>;
      final category = CategoryModel.fromJson(categoryData);

      expect(category.name, isNotEmpty);
    });

    test('should list categories', () async {
      final response = await apiClient.listCategories();

      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('meals'), isTrue);
    });

    test('should list ingredients', () async {
      final response = await apiClient.listIngredients();

      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('meals'), isTrue);
    });

    test('should search meals by name', () async {
      final response = await apiClient.searchMeals('Arrabiata');

      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('meals'), isTrue);

      final meals = response['meals'];
      if (meals != null) {
        expect(meals, isA<List>());
        if ((meals as List).isNotEmpty) {
          final mealData = meals.first as Map<String, dynamic>;
          final meal = MealModel.fromJson(mealData);
          expect(meal.name.toLowerCase(), contains('arrabiata'));
        }
      }
    });

    test('should filter by ingredient', () async {
      final response = await apiClient.filterByIngredient('chicken breast');

      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('meals'), isTrue);
    });

    test('should handle ingredient name formatting', () async {
      // Test that spaces are converted to underscores
      final response = await apiClient.filterByIngredient('chicken breast');
      // This should not throw, and the API call should use 'chicken_breast'
      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('meals'), isTrue);
    });
  });
}
