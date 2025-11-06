import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_meal_app/features/meals/di/meals_injection.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/ingredients_selection_notifier.dart';

final matchingMealsProvider =
    FutureProvider.autoDispose<List<Meal>>((ref) async {
  // WATCH instead of READ to ensure this provider re-runs on change.
  final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);

  if (selectedIngredients.isEmpty) {
    return [];
  }

  final (:failure, :meals, :possibleNextIngredients) = await ref
        .watch(findMatchingMealsExhaustiveUseCaseProvider)
        .call(selectedIngredients);

  if (failure != null) {
    throw failure;
  }

  return meals ?? [];
});


final allIngredientsFromMatchingMealsProvider =
    Provider.autoDispose<List<String>>((ref) {
  final matchingMeals = ref.watch(matchingMealsProvider);

  return matchingMeals.when(
    data: (meals) {
      if (meals.isEmpty) {
        return [];
      }
      final allIngredients = meals
          .expand((meal) => meal.ingredients.map((e) => e.name))
          .toSet()
          .toList();
      allIngredients.sort();
      return allIngredients;
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

final matchingMealsCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  final matchingMeals = ref.watch(matchingMealsProvider);
  return matchingMeals.when(
    data: (meals) => AsyncValue.data(meals.length),
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final filteredIngredientsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);
  final allIngredients = await ref.watch(allIngredientsProvider.future);

  if (selectedIngredients.isEmpty) {
    return allIngredients;
  }

  final matchingMeals = await ref.watch(matchingMealsProvider.future);

  if (matchingMeals.isEmpty) {
    // If there are no matching meals, return all ingredients so the user is not stuck
    // and can adjust their selection.
    return allIngredients;
  }

  final suggestedIngredients = matchingMeals
      .expand((meal) => meal.ingredients)
      .map((ingredient) => ingredient.name)
      .toSet();

  // print(suggestedIngredients);

  // The new list should contain both the selected ingredients and the new suggestions.
  final displayIngredients = {
    ...selectedIngredients,
    ...suggestedIngredients,
  };

  return displayIngredients.toList();
});

final suggestedIngredientsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final matchingMeals = await ref.watch(matchingMealsProvider.future);
  final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);

  if (matchingMeals.isEmpty) {
    return [];
  }

  final allIngredients = matchingMeals
      .expand((meal) => meal.ingredients)
      .map((ingredient) => ingredient.name)
      .toSet();

  allIngredients.removeAll(selectedIngredients);

  return allIngredients.toList();
});
