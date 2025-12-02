import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/ingredients_selection_notifier.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/matching_meals_notifier.dart';
import 'package:flutter_meal_app/features/meals/presentation/widgets/meal_card.dart';
import 'package:flutter_meal_app/features/meals/presentation/pages/meal_details_page.dart';

class MatchingMealsPage extends ConsumerWidget {
  const MatchingMealsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const MatchingMealsPage(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingMealsAsync = ref.watch(matchingMealsProvider);
    final allIngredients = ref.watch(allIngredientsFromMatchingMealsProvider);
    final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Meals'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (allIngredients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All necessary ingredients:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: allIngredients.map((ingredient) {
                        final isSelected =
                            selectedIngredients.contains(ingredient);
                        return Chip(
                          label: Text(ingredient),
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: matchingMealsAsync.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return const Center(
                    child: Text(
                        'No meals found with the selected ingredients.'),
                  );
                }

                return ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return MealCard(
                      meal: meal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MealDetailsPage(mealId: meal.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load matching meals.'),
                    ElevatedButton(
                      onPressed: () => ref.refresh(matchingMealsProvider),
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
