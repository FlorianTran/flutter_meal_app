import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';

class GetIngredientDetails {
  final MealsRepository repository;

  GetIngredientDetails(this.repository);

  /// Fetches meals that contain the given ingredient.
  /// The IngredientDetailsPage requires this list.
  /// The full Ingredient object (with name, image, and null description)
  /// can be constructed in the presentation layer, as there is no
  /// dedicated API endpoint for ingredient details.
  Future<({Failure? failure, List<Meal>? meals})> call(String ingredientName) async {
    return await repository.getMealsByIngredient(ingredientName);
  }
}
