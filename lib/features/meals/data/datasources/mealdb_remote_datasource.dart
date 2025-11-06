
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/meal_model.dart';
import '../models/category_model.dart';

/// Remote data source for MealDB API
abstract class MealDbRemoteDataSource {
  Future<MealModel> getRandomMeal();
  Future<MealModel> getMealDetails(String id);
  Future<List<MealModel>> searchMeals(String query);
  Future<List<MealModel>> searchMealsByLetter(String letter);
  Future<List<CategoryModel>> getCategories();
  Future<List<String>> listCategories();
  Future<List<String>> listAreas();
  Future<List<String>> listIngredients();
  Future<List<MealModel>> getMealsByCategory(String category);
  Future<List<MealModel>> getMealsByArea(String area);
  Future<List<MealModel>> getMealsByIngredient(String ingredient);
  Future<List<MealModel>> getAllMeals();
}

class MealDbRemoteDataSourceImpl implements MealDbRemoteDataSource {
  final MealDbApiClient apiClient;

  MealDbRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MealModel> getRandomMeal() async {
    try {
      final response = await apiClient.getRandomMeal();
      final meals = response['meals'] as List?;

      if (meals == null || meals.isEmpty) {
        throw const ServerException('No meal found');
      }

      return MealModel.fromJson(meals.first as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get random meal: $e');
    }
  }

  @override
  Future<MealModel> getMealDetails(String id) async {
    try {
      final response = await apiClient.lookupMeal(id);
      final meals = response['meals'] as List?;

      if (meals == null || meals.isEmpty) {
        throw ServerException('Meal with id $id not found');
      }

      return MealModel.fromJson(meals.first as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get meal details: $e');
    }
  }

  @override
  Future<List<MealModel>> searchMeals(String query) async {
    try {
      final response = await apiClient.searchMeals(query);
      return MealModel.parseMealsListFromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to search meals: $e');
    }
  }

  @override
  Future<List<MealModel>> searchMealsByLetter(String letter) async {
    try {
      final response = await apiClient.searchMealsByLetter(letter);
      return MealModel.parseMealsListFromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to search meals by letter: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.getCategories();
      final categories = response['categories'] as List?;

      if (categories == null) {
        return [];
      }

      return categories
          .map((category) =>
              CategoryModel.fromJson(category as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get categories: $e');
    }
  }

  @override
  Future<List<String>> listCategories() async {
    try {
      final response = await apiClient.listCategories();
      final meals = response['meals'] as List?;

      if (meals == null) {
        return [];
      }

      return meals
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['strCategory']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((name) => name.isNotEmpty)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to list categories: $e');
    }
  }

  @override
  Future<List<String>> listAreas() async {
    try {
      final response = await apiClient.listAreas();
      final meals = response['meals'] as List?;

      if (meals == null) {
        return [];
      }

      return meals
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['strArea']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((name) => name.isNotEmpty)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to list areas: $e');
    }
  }

  @override
  Future<List<String>> listIngredients() async {
    try {
      final response = await apiClient.listIngredients();
      final meals = response['meals'] as List?;

      if (meals == null) {
        return [];
      }

      return meals
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['strIngredient']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((name) => name.isNotEmpty)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to list ingredients: $e');
    }
  }

  @override
  Future<List<MealModel>> getMealsByCategory(String category) async {
    try {
      final response = await apiClient.filterByCategory(category);
      return MealModel.parseMealsListFromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get meals by category: $e');
    }
  }

  @override
  Future<List<MealModel>> getMealsByArea(String area) async {
    try {
      final response = await apiClient.filterByArea(area);
      return MealModel.parseMealsListFromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get meals by area: $e');
    }
  }

  @override
  Future<List<MealModel>> getMealsByIngredient(String ingredient) async {
    try {
      final response = await apiClient.filterByIngredient(ingredient);
      return MealModel.parseMealsListFromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get meals by ingredient: $e');
    }
  }

  @override
  Future<List<MealModel>> getAllMeals() async {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    final allMeals = <MealModel>[];
    final seenIds = <String>{};

    for (final letter in letters.split('')) {
      try {
        final jsonData = await apiClient.get(
          '/search.php',
          queryParameters: {'f': letter},
        );

        final meals = MealModel.parseMealsListFromJson(jsonData);
        if (meals.isEmpty) continue;

        for (final meal in meals) {
          if (!seenIds.contains(meal.id)) {
            seenIds.add(meal.id);
            allMeals.add(meal);
          }
        }
      } catch (e) {
        // En cas d'erreur sur une lettre, on continue avec les suivantes
        print('Erreur lors du chargement des plats de la lettre $letter : $e');
      }

      // Évite le rate-limit de l’API
      await Future.delayed(const Duration(milliseconds: 150));
    }

    if (allMeals.isEmpty) {
      throw const ServerException('No meals found in TheMealDB');
    }

    return allMeals;
  }
}
