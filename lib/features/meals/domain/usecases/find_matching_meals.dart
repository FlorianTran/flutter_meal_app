import 'dart:async';

import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';

class FindMatchingMeals {
  final MealsRepository repository;

  FindMatchingMeals(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      return (failure: null, meals: <Meal>[]);
    }

    // print('[DEBUG] Starting Fast Search with ingredients: $ingredients');

    // This list will contain meals with only partial data (id, name, thumb)
    List<Meal>? partialMeals;

    // Intersect meals from each ingredient
    for (final ingredient in ingredients) {
      final result = await repository.getMealsByIngredient(ingredient);

      if (result.failure != null) {
        return (failure: result.failure, meals: null);
      }

      final newMeals = result.meals;
      if (newMeals == null || newMeals.isEmpty) {
        // If any ingredient yields no results, the intersection is empty.
        return (failure: null, meals: <Meal>[]);
      }

      if (partialMeals == null) {
        partialMeals = newMeals;
      } else {
        final newMealIds = newMeals.map((m) => m.id).toSet();
        partialMeals.retainWhere((m) => newMealIds.contains(m.id));
      }

      if (partialMeals.isEmpty) {
        return (failure: null, meals: <Meal>[]);
      }
    }

    if (partialMeals == null || partialMeals.isEmpty) {
      return (failure: null, meals: <Meal>[]);
    }

    // Now, fetch full details for the matched meals
    final fullMeals = <Meal>[];
    Failure? firstFailure;

    // Use Future.wait for parallel fetching
    final detailFutures = partialMeals.map((partialMeal) => repository.getMealDetails(partialMeal.id));
    final detailResults = await Future.wait(detailFutures);

    for (final detailResult in detailResults) {
      if (detailResult.failure != null) {
        firstFailure ??= detailResult.failure;
        continue;
      }
      if (detailResult.meal != null) {
        fullMeals.add(detailResult.meal!);
      }
    }

    if (fullMeals.isEmpty && firstFailure != null) {
      return (failure: firstFailure, meals: null);
    }

    // print('[DEBUG] Fast Search found ${fullMeals.length} full meal details.');

    return (failure: null, meals: fullMeals);
  }
}
