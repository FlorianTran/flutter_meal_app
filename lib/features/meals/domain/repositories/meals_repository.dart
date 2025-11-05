import '../entities/meal.dart';
import '../entities/category.dart';
import '../../../../core/error/failures.dart';

/// Abstract repository interface for meals
/// Implementations should handle data fetching from API and local storage
abstract class MealsRepository {
  /// Get a random meal (Meal of the Day)
  Future<({Failure? failure, Meal? meal})> getMealOfDay();

  /// Get meal details by ID
  Future<({Failure? failure, Meal? meal})> getMealDetails(String id);

  /// Search meals by name
  Future<({Failure? failure, List<Meal>? meals})> searchMeals(String query);

  /// Search meals by first letter
  Future<({Failure? failure, List<Meal>? meals})> searchMealsByLetter(String letter);

  /// Get all categories
  Future<({Failure? failure, List<Category>? categories})> getCategories();

  /// List category names only
  Future<({Failure? failure, List<String>? categoryNames})> listCategories();

  /// List area names only
  Future<({Failure? failure, List<String>? areaNames})> listAreas();

  /// List ingredient names only
  Future<({Failure? failure, List<String>? ingredientNames})> listIngredients();

  /// Filter meals by category
  Future<({Failure? failure, List<Meal>? meals})> getMealsByCategory(String category);

  /// Filter meals by area
  Future<({Failure? failure, List<Meal>? meals})> getMealsByArea(String area);

  /// Filter meals by ingredient (single ingredient - free API limitation)
  Future<({Failure? failure, List<Meal>? meals})> getMealsByIngredient(String ingredient);
}

