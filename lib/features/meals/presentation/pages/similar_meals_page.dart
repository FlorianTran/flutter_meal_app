import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';
import '../notifier/similar_meals_notifier.dart';
import '../notifier/similar_meals_state.dart';
import '../widgets/similar_meal_card.dart';
import 'meal_details_page.dart';

/// Page displaying meals similar to a given meal
class SimilarMealsPage extends ConsumerStatefulWidget {
  final Meal meal;

  const SimilarMealsPage({
    super.key,
    required this.meal,
  });

  static Route<void> route(Meal meal) {
    return MaterialPageRoute(
      builder: (context) => SimilarMealsPage(meal: meal),
    );
  }

  @override
  ConsumerState<SimilarMealsPage> createState() => _SimilarMealsPageState();
}

class _SimilarMealsPageState extends ConsumerState<SimilarMealsPage> {
  @override
  void initState() {
    super.initState();
    // Load similar meals when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(similarMealsNotifierProviderForMeal.notifier)
          .loadSimilarMeals(widget.meal, limit: 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(similarMealsNotifierProviderForMeal);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Similar to ${widget.meal.name}'),
      ),
      body: _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, SimilarMealsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Error: ${state.error}',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(similarMealsNotifierProviderForMeal.notifier)
                      .loadSimilarMeals(widget.meal, limit: 20);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No similar meals found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try exploring meals from the same category or area',
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Calculate common ingredients for each meal
    final mealIngredientNames = widget.meal.ingredients
        .map((ing) => ing.name.toLowerCase().trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: state.meals.length,
      itemBuilder: (context, index) {
        final similarMeal = state.meals[index];
        final similarMealIngredientNames = similarMeal.ingredients
            .map((ing) => ing.name.toLowerCase().trim())
            .where((name) => name.isNotEmpty)
            .toSet();

        final commonIngredients =
            mealIngredientNames.intersection(similarMealIngredientNames);
        final totalIngredients =
            mealIngredientNames.union(similarMealIngredientNames).length;

        return SimilarMealCard(
          meal: similarMeal,
          commonIngredientsCount: commonIngredients.length,
          totalIngredientsCount: totalIngredients,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MealDetailsPage(mealId: similarMeal.id),
              ),
            );
          },
        );
      },
    );
  }
}
