import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the state of selected ingredients.
class IngredientsSelectionNotifier extends StateNotifier<List<String>> {
  IngredientsSelectionNotifier() : super([]);

  /// Toggles the selection of an ingredient.
  void toggleIngredient(String ingredientName) {
    if (state.contains(ingredientName)) {
      state = state.where((i) => i != ingredientName).toList();
    } else {
      state = [...state, ingredientName];
    }
  }
}

/// Provider for the ingredients selection notifier.
final ingredientsSelectionNotifierProvider = 
    StateNotifierProvider<IngredientsSelectionNotifier, List<String>>((ref) {
  return IngredientsSelectionNotifier();
});
