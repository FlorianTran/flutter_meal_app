import 'dart:async';

import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_categories.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_all_meals_2.dart';

class FindMatchingMealsExhaustive {
  final MealsRepository repository;
  final GetCategories getCategories;
  final GetAllMeals2 getAllMeals2;

  FindMatchingMealsExhaustive(
      this.repository, this.getCategories, this.getAllMeals2);

  Future<
      ({
        Failure? failure,
        List<Meal>? meals,
        List<String>? possibleNextIngredients,
      })> call(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      return (failure: null, meals: <Meal>[], possibleNextIngredients: null);
    }
    
    // print('[DEBUG] Starting Exhaustive Search with ingredients: $ingredients');

    final allMeals2 = await getAllMeals2();

    // print('[DEBUG] Exhaustive Search: getAllMeals2 completed.');

    if (allMeals2.failure != null || allMeals2.meals == null) {
    //  print('[DEBUG] Exhaustive Search failed or returned no meals.');
      return (
        failure: allMeals2.failure,
        meals: null,
        possibleNextIngredients: null
      );
    }
    
  //  print('[DEBUG] Found ${allMeals2.meals!.length} total meals to filter from.');

    // 3. Filter meals matching selected ingredients
    final matchingMeals = allMeals2.meals!.where((meal) {
      final mealIngredients =
          meal.ingredients.map((e) => e.name.toLowerCase()).toSet();
      return ingredients.every(
        (selectedIngredient) =>
            mealIngredients.contains(selectedIngredient.toLowerCase()),
      );
    }).toList();

    if (matchingMeals.isEmpty) {
    //  print('[DEBUG] Aucun repas correspondant trouvé.');
    } else {
      for (final meal in matchingMeals) {
        final ingredientNames = meal.ingredients.map((i) => i.name).join(', ');
      //  print('[DEBUG] Ingrédients pour "${meal.name}": $ingredientNames');
      }
    }

    // 4. Find other possible ingredients among these meals
    final allMatchingIngredients = matchingMeals
        .expand((meal) => meal.ingredients.map((e) => e.name.toLowerCase()))
        .toSet();

    // Remove already selected ones
    final possibleNextIngredients = allMatchingIngredients
        .difference(ingredients.map((e) => e.toLowerCase()).toSet())
        .toList()
      ..sort();

    return (
      failure: null,
      meals: matchingMeals,
      possibleNextIngredients: possibleNextIngredients,
    );
  }
}
