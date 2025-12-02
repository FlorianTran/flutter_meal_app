import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to get meals from multiple categories (all meals view)
/// Fetches meals from popular categories to show a comprehensive catalog
class GetAllMeals {
  final MealsRepository repository;

  GetAllMeals(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call() async {
    // Popular categories to fetch from
    // These are the most common categories that will give a good variety
    const popularCategories = [
      'Beef',
      'Chicken',
      'Dessert',
      'Lamb',
      'Pasta',
      'Pork',
      'Seafood',
      'Vegetarian',
      'Breakfast',
      'Side',
    ];

    final allMeals = <Meal>[];
    Failure? firstFailure;

    // Fetch meals from each category
    for (final category in popularCategories) {
      final result = await repository.getMealsByCategory(category);

      if (result.failure != null) {
        // Keep first failure for reporting, but continue with other categories
        firstFailure ??= result.failure;
        continue;
      }

      if (result.meals != null) {
        // Add meals, avoiding duplicates by ID
        for (final meal in result.meals!) {
          if (!allMeals.any((m) => m.id == meal.id)) {
            allMeals.add(meal);
          }
        }
      }
    }

    // If we got some meals, return success even if some categories failed
    if (allMeals.isNotEmpty) {
      return (failure: null, meals: allMeals);
    }

    // If no meals found, return the first failure or empty list
    return (failure: firstFailure, meals: <Meal>[]);
  }
}
