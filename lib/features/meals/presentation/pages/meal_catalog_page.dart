import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/meal_catalog_notifier.dart';
import '../notifier/meal_catalog_state.dart';
import '../notifier/home_notifier.dart';
import '../notifier/favorites_notifier.dart';
import '../widgets/meal_card.dart';
import '../widgets/search_bar.dart' show MealSearchBar;
import '../widgets/filter_chips.dart';
import 'meal_details_page.dart';
import '../../domain/entities/meal.dart';

/// Meal Catalog page with search, filter, and sort
class MealCatalogPage extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialArea;

  const MealCatalogPage({
    super.key,
    this.initialCategory,
    this.initialArea,
  });

  @override
  ConsumerState<MealCatalogPage> createState() => _MealCatalogPageState();
}

class _MealCatalogPageState extends ConsumerState<MealCatalogPage> {
  @override
  void initState() {
    super.initState();
    // Load initial data based on category or area
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategory != null) {
        ref
            .read(mealCatalogNotifierProvider.notifier)
            .loadMealsByCategory(widget.initialCategory!);
      } else if (widget.initialArea != null) {
        ref
            .read(mealCatalogNotifierProvider.notifier)
            .loadMealsByArea(widget.initialArea!);
      } else {
        // If no initial filter, load all meals (from multiple categories)
        ref.read(mealCatalogNotifierProvider.notifier).loadAllMeals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(mealCatalogNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);

    // Load categories if not already loaded
    if (homeState.categories.isEmpty && !homeState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeNotifierProvider.notifier).loadCategories();
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Meal Catalog'),
        actions: [
          // Grid/List view toggle
          IconButton(
            icon: Icon(
              catalogState.isGridView ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: () {
              ref.read(mealCatalogNotifierProvider.notifier).toggleView();
            },
          ),
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background food images
          Positioned(
            top: 400,
            right: 250,
            child: Transform.rotate(
              angle: 0.3,
              child: Image.asset(
                'assets/images/food_image.png',
                width: 500,
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 350,
            right: -100,
            child: Transform.rotate(
              angle: -0.2,
              child: Image.asset(
                'assets/images/food_image_1.png',
                width: 230,
                height: 230,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 600,
            right: -70,
            child: Transform.rotate(
              angle: 0.15,
              child: Image.asset(
                'assets/images/food_image_2.png',
                width: 290,
                height: 290,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Search bar
                MealSearchBar(
                  key: const ValueKey(
                      'meal_search_bar'), // Stable key to prevent rebuilds
                  initialValue: catalogState.searchQuery,
                  onChanged: (query) {
                    ref
                        .read(mealCatalogNotifierProvider.notifier)
                        .search(query);
                  },
                  onClear: () {
                    ref
                        .read(mealCatalogNotifierProvider.notifier)
                        .clearFilters();
                  },
                ),

                // Filter chips for categories
                if (homeState.categories.isNotEmpty)
                  FilterChips(
                    items: homeState.categories.map((c) => c.name).toList(),
                    selectedItem: catalogState.selectedCategory,
                    onItemSelected: (category) {
                      // Toggle: if clicking the same category, clear filter
                      if (catalogState.selectedCategory == category) {
                        ref
                            .read(mealCatalogNotifierProvider.notifier)
                            .clearFilters();
                      } else {
                        // Clear search when applying filter
                        ref
                            .read(mealCatalogNotifierProvider.notifier)
                            .loadMealsByCategory(category);
                      }
                    },
                  ),

                const SizedBox(height: 8),

                // Meals list/grid
                Expanded(
                  child: _buildMealsContent(catalogState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsContent(MealCatalogState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
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
                if (state.selectedCategory != null) {
                  ref
                      .read(mealCatalogNotifierProvider.notifier)
                      .loadMealsByCategory(state.selectedCategory!);
                } else if (state.selectedArea != null) {
                  ref
                      .read(mealCatalogNotifierProvider.notifier)
                      .loadMealsByArea(state.selectedArea!);
                } else if (state.searchQuery != null) {
                  ref
                      .read(mealCatalogNotifierProvider.notifier)
                      .search(state.searchQuery!);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              state.searchQuery != null
                  ? 'No meals found for "${state.searchQuery}"'
                  : 'No meals found',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state.isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.meals.length,
        itemBuilder: (context, index) {
          final meal = state.meals[index];
          return _buildMealCardWithFavorites(meal);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.meals.length,
        itemBuilder: (context, index) {
          final meal = state.meals[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMealCardWithFavorites(meal),
          );
        },
      );
    }
  }

  Widget _buildMealCardWithFavorites(Meal meal) {
    final favoritesState = ref.watch(favoritesNotifierProvider);
    final isFavorite = favoritesState.meals.any((m) => m.id == meal.id);

    return MealCard(
      meal: meal,
      isFavorite: isFavorite,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailsPage(mealId: meal.id),
          ),
        );
      },
      onFavoriteTap: () async {
        final favoritesNotifier = ref.read(favoritesNotifierProvider.notifier);
        await favoritesNotifier.toggleFavorite(meal);
      },
    );
  }
}
