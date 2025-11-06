import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';
import '../notifier/meal_details_notifier.dart';
import '../notifier/meal_details_state.dart';
import '../notifier/similar_meals_notifier.dart';
import '../notifier/recently_viewed_notifier.dart';
import '../widgets/meal_ingredients_list.dart';
import '../widgets/meal_instructions.dart';
import '../widgets/similar_meal_card.dart';
import 'similar_meals_page.dart';

/// Meal Details page showing complete recipe information
class MealDetailsPage extends ConsumerWidget {
  final String mealId;

  const MealDetailsPage({
    super.key,
    required this.mealId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealDetailsNotifierProvider(mealId));

    // Load similar meals when meal is loaded (only once)
    // Also add meal to recently viewed
    if (state.meal != null && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Load similar meals
        final similarMealsState = ref.read(similarMealsNotifierProviderForMeal);
        if (similarMealsState.meals.isEmpty && !similarMealsState.isLoading) {
          ref
              .read(similarMealsNotifierProviderForMeal.notifier)
              .loadSimilarMeals(state.meal!, limit: 6);
        }

        // Add to recently viewed
        ref
            .read(recentlyViewedNotifierProvider.notifier)
            .addMeal(state.meal!);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App bar with meal image
          _buildAppBar(context, ref, state),

          // Content
          SliverToBoxAdapter(
            child: state.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : state.error != null
                    ? _buildErrorState(context, ref, state)
                    : state.meal != null
                        ? _buildContent(context, ref, state)
                        : const SizedBox.shrink(),
          ),

          // Similar meals section
          if (state.meal != null && !state.isLoading)
            _buildSimilarMealsSection(context, ref, state.meal!),
        ],
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, WidgetRef ref, MealDetailsState state) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: state.meal?.image != null
            ? CachedNetworkImage(
                imageUrl: state.meal!.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 64),
              ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: state.meal != null
          ? [
              // Favorite button
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    state.isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    ref
                        .read(mealDetailsNotifierProvider(mealId).notifier)
                        .toggleFavorite();
                  },
                ),
              ),
              // Share button
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareMeal(context, state.meal!),
              ),
            ]
          : null,
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    MealDetailsState state,
  ) {
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
                    .read(mealDetailsNotifierProvider(mealId).notifier)
                    .refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MealDetailsState state,
  ) {
    final meal = state.meal!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal name
          Text(
            meal.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Category and Area tags
          if (meal.category != null || meal.area != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (meal.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.primaryGreen.withAlpha((255 * 0.6).round()),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      meal.category!,
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (meal.area != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      meal.area!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 24),

          // Ingredients section
          MealIngredientsList(meal: meal),

          const SizedBox(height: 32),

          // Instructions section
          MealInstructions(instructions: meal.instructions),

          const SizedBox(height: 32),

          // YouTube video link
          if (meal.youtubeUrl != null && meal.youtubeUrl!.isNotEmpty)
            _buildLinkButton(
              context,
              icon: Icons.play_circle_outline,
              label: 'Watch on YouTube',
              url: meal.youtubeUrl!,
            ),

          const SizedBox(height: 16),

          // Source link
          if (meal.sourceUrl != null && meal.sourceUrl!.isNotEmpty)
            _buildLinkButton(
              context,
              icon: Icons.link,
              label: 'View Source',
              url: meal.sourceUrl!,
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSimilarMealsSection(
      BuildContext context, WidgetRef ref, Meal meal) {
    final similarMealsState = ref.watch(similarMealsNotifierProviderForMeal);

    // Show loading indicator while loading
    if (similarMealsState.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'You might also like',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    }

    // Don't show section if no similar meals found
    if (similarMealsState.meals.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final mealIngredientNames = meal.ingredients
        .map((ing) => ing.name.toLowerCase().trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'You might also like',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (similarMealsState.meals.length > 6)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        SimilarMealsPage.route(meal),
                      );
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: similarMealsState.meals.length > 6
                  ? 6
                  : similarMealsState.meals.length,
              itemBuilder: (context, index) {
                final similarMeal = similarMealsState.meals[index];
                final similarMealIngredientNames = similarMeal.ingredients
                    .map((ing) => ing.name.toLowerCase().trim())
                    .where((name) => name.isNotEmpty)
                    .toSet();

                final commonIngredients = mealIngredientNames
                    .intersection(similarMealIngredientNames);
                final totalIngredients = mealIngredientNames
                    .union(similarMealIngredientNames)
                    .length;

                return SimilarMealCard(
                  meal: similarMeal,
                  commonIngredientsCount: commonIngredients.length,
                  totalIngredientsCount: totalIngredients,
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            MealDetailsPage(mealId: similarMeal.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppTheme.primaryGreen),
          foregroundColor: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareMeal(BuildContext context, Meal meal) {
    final text = 'Check out this recipe: ${meal.name}\n${meal.sourceUrl ?? ''}';
    Share.share(
      text,
      subject: meal.name,
    );
  }
}
