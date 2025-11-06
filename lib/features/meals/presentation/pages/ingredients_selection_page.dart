import 'package:flutter_meal_app/features/meals/di/meals_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/ingredients_selection_notifier.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/matching_meals_notifier.dart';
import 'package:flutter_meal_app/features/meals/presentation/widgets/ingredient_card.dart';
import 'package:flutter_meal_app/features/meals/presentation/widgets/selection_summary_bar.dart';
import 'matching_meals_page.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class IngredientsSelectionPage extends ConsumerWidget {
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const IngredientsSelectionPage(),
    );
  }

  const IngredientsSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientFilterLogicProvider);
    final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);
    final matchingMealsCount = ref.watch(matchingMealsCountProvider);
    final searchQuery = ref.watch(_searchQueryProvider);

    // Pre-load all meals when the page opens
    ref.watch(allMealsPreloadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Ingredients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) =>
                  ref.read(_searchQueryProvider.notifier).state = query,
              decoration: const InputDecoration(
                labelText: 'Search Ingredients',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ingredientsAsync.when(
              data: (ingredients) {
                final filteredIngredients = ingredients
                    .where((i) =>
                        i.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                if (filteredIngredients.isEmpty) {
                  return const Center(child: Text('No ingredients found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = filteredIngredients[index];
                    final isSelected = selectedIngredients.contains(ingredient);
                    return IngredientCard(
                      ingredientName: ingredient,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(ingredientsSelectionNotifierProvider.notifier)
                            .toggleIngredient(ingredient);
                      },
                      onLongPress: () {
                        // TODO: Navigate to ingredient details page
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load ingredients.'),
                    ElevatedButton(
                      onPressed: () =>
                          ref.refresh(ingredientFilterLogicProvider),
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SelectionSummaryBar(
        selectionCount: selectedIngredients.length,
        mealCount: matchingMealsCount.when(
          data: (count) => count,
          loading: () => 0,
          error: (e, s) => 0,
        ),
        onActionPressed: () {
          Navigator.push(context, MatchingMealsPage.route());
        },
      ),
    );
  }
}
