import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';

class GetMealsByIngredient {
  final MealsRepository repository;

  GetMealsByIngredient(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call(String ingredient) async {
    return await repository.getMealsByIngredient(ingredient);
  }
}
