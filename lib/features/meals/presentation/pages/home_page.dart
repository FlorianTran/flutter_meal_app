import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifier/home_notifier.dart';
import '../notifier/home_state.dart';
import '../notifier/meal_of_day_notifier.dart';
import '../notifier/meal_of_day_state.dart';
import '../widgets/meal_of_day_card.dart';
import '../widgets/category_list.dart';
import '../widgets/meal_card.dart';
import '../notifier/recently_viewed_notifier.dart';
import '../notifier/favorites_notifier.dart';
import 'meal_catalog_page.dart';
import 'meal_details_page.dart';
import 'ingredients_selection_page.dart';
import 'recently_viewed_page.dart';
import 'favorites_page.dart';

/// Home page based on Figma design
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mealOfDayNotifierProvider.notifier).loadMealOfDay();
      ref.read(homeNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealOfDayState = ref.watch(mealOfDayNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(mealOfDayNotifierProvider.notifier).loadMealOfDay();
            await ref.read(homeNotifierProvider.notifier).loadCategories();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: "Find your next meal"
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 64,
                            height: 1,
                            color: AppTheme.textBlack,
                          ),
                      children: [
                        const TextSpan(text: 'Find your next\n'),
                        TextSpan(
                          text: 'meal',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontFamily:
                                AppTheme.getFontFamily(FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Meal of the Day Section
                _buildMealOfDaySection(mealOfDayState),

                const SizedBox(height: 24),

                // Ingredient Selection Section
                _buildIngredientSelectionSection(),

                const SizedBox(height: 32),

                // Categories Section
                _buildCategoriesSection(homeState),

                const SizedBox(height: 32),

                // Recently Viewed Section
                _buildRecentlyViewedSection(),

                const SizedBox(height: 32),

                // Favorites Section
                _buildFavoritesSection(),

                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMealOfDaySection(MealOfDayState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 280,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'Failed to load meal of the day',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref
                        .read(mealOfDayNotifierProvider.notifier)
                        .loadMealOfDay();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.meal == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Meal of the day',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final favoritesNotifier =
                ref.watch(favoritesNotifierProvider.notifier);
            final isFavorite = ref.watch(isFavoriteProvider(state.meal!.id));

            return MealOfDayCard(
              meal: state.meal!,
              isFavorite: isFavorite.value ?? false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MealDetailsPage(mealId: state.meal!.id),
                  ),
                );
              },
              onFavoriteTap: () async {
                await favoritesNotifier.toggleFavorite(state.meal!);
                // Refresh the favorite status
                ref.invalidate(isFavoriteProvider(state.meal!.id));
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildIngredientSelectionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "We'll suggest recipes that match what you have.",
            style: TextStyle(
              fontFamily: AppTheme.getFontFamily(null),
              fontSize: 16,
              color: AppTheme.textBlack,
              fontWeight: FontWeight.w100,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, IngredientsSelectionPage.route());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Select ingredients',
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(FontWeight.w100),
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(HomeState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'Failed to load categories',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(homeNotifierProvider.notifier).loadCategories();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(FontWeight.w600),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.grey[600],
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CategoryList(
          categories: state.categories,
          onCategoryTap: (category) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealCatalogPage(
                  initialCategory: category.name,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Home button (active - green background)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // List button (inactive - grey)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MealCatalogPage(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.list,
                          color: Colors.grey[700],
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedSection() {
    final state = ref.watch(recentlyViewedNotifierProvider);

    if (state.isLoading || state.meals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show only first 5 recently viewed meals
    final recentMeals = state.meals.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Viewed',
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(FontWeight.w600),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, RecentlyViewedPage.route());
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentMeals.length,
            itemBuilder: (context, index) {
              final meal = recentMeals[index];
              return Consumer(
                builder: (context, ref, child) {
                  final favoritesNotifier =
                      ref.watch(favoritesNotifierProvider.notifier);
                  final isFavorite = ref.watch(isFavoriteProvider(meal.id));

                  return SizedBox(
                    width: 170,
                    height: 230,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: MealCard(
                        meal: meal,
                        isFavorite: isFavorite.value ?? false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MealDetailsPage(mealId: meal.id),
                            ),
                          );
                        },
                        onFavoriteTap: () async {
                          await favoritesNotifier.toggleFavorite(meal);
                          // Refresh the favorite status
                          ref.invalidate(isFavoriteProvider(meal.id));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    final state = ref.watch(favoritesNotifierProvider);

    if (state.isLoading || state.meals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show only first 5 favorite meals
    final favoriteMeals = state.meals.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Favorites',
                style: TextStyle(
                  fontFamily: AppTheme.getFontFamily(FontWeight.w600),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, FavoritesPage.route());
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favoriteMeals.length,
            itemBuilder: (context, index) {
              final meal = favoriteMeals[index];
              return SizedBox(
                width: 170,
                height: 230,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: MealCard(
                    meal: meal,
                    isFavorite: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MealDetailsPage(mealId: meal.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
