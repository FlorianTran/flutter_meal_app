import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_meal_app/features/meals/di/meals_injection.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/ingredients_selection_notifier.dart';

/// Provides the count of meals that match the selected ingredients.
final matchingMealsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);
  
  if (selectedIngredients.isEmpty) {
    return 0;
  }

  final findMatchingMeals = ref.watch(findMatchingMealsUseCaseProvider);
  final result = await findMatchingMeals(selectedIngredients);
  
  if (result.failure != null) {
    throw result.failure!;
  }
  
  return result.meals?.length ?? 0;
});
