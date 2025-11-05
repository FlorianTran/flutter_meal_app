import 'dart:async';

import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';

class FindMatchingMeals {
  final MealsRepository repository;

  FindMatchingMeals(this.repository);

  Future<({Failure? failure, List? meals})> call(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      return (failure: null, meals: []);
    }

    List<Meal>? finalMeals;

    for (final ingredient in ingredients) {
      final result = await repository.getMealsByIngredient(ingredient);

      if (result.failure != null) {
        return (failure: result.failure, meals: null);
      }

      final newMeals = result.meals;
      if (newMeals == null || newMeals.isEmpty) {
        return (failure: null, meals: []);
      }

      if (finalMeals == null) {
        finalMeals = newMeals;
      } else {
        final newMealIds = newMeals.map((m) => m.id).toSet();
        finalMeals.retainWhere((m) => newMealIds.contains(m.id));
      }

      if (finalMeals.isEmpty) {
        return (failure: null, meals: []);
      }
    }

    return (failure: null, meals: finalMeals ?? []);
  }
}
