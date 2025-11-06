import 'dart:async';
import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/get_meals_by_category.dart';
import '../../domain/usecases/get_meals_by_area.dart';
import '../../domain/usecases/search_meals.dart';
import '../../domain/usecases/get_meal_details.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_all_meals.dart';
import '../../data/repositories_impl/meals_repository_impl.dart';
import '../../data/datasources/mealdb_remote_datasource.dart';
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/constants/app_constants.dart';
import 'meal_catalog_state.dart';

class MealCatalogNotifier extends StateNotifier<MealCatalogState> {
  final GetMealsByCategory getMealsByCategory;
  final GetMealsByArea getMealsByArea;
  final SearchMeals searchMeals;
  final GetMealDetails getMealDetails;
  final GetCategories getCategories;
  final GetAllMeals getAllMeals;

  // Cache for full meal details to avoid repeated API calls
  final Map<String, Meal> _mealDetailsCache = {};

  MealCatalogNotifier({
    required this.getMealsByCategory,
    required this.getMealsByArea,
    required this.searchMeals,
    required this.getMealDetails,
    required this.getCategories,
    required this.getAllMeals,
  }) : super(const MealCatalogState());

  Future<void> loadMealsByCategory(String category) async {
    // Clear search query when applying filter
    state = state.copyWith(
      isLoading: true,
      selectedCategory: category,
      clearSelectedArea: true,
      clearSearchQuery: true, // Clear search when filter is applied
      error: null,
    );

    final result = await getMealsByCategory(category);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      final meals = result.meals ?? [];
      state = state.copyWith(
        isLoading: false,
        meals: meals,
      );

      // Fetch full details for meals in background (for ingredient count)
      _fetchMealsDetailsInBackground(meals);
    }
  }

  Future<void> loadMealsByArea(String area) async {
    // Clear search query when applying filter
    state = state.copyWith(
      isLoading: true,
      selectedArea: area,
      clearSelectedCategory: true,
      clearSearchQuery: true, // Clear search when filter is applied
      error: null,
    );

    final result = await getMealsByArea(area);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      final meals = result.meals ?? [];
      state = state.copyWith(
        isLoading: false,
        meals: meals,
      );

      // Fetch full details for meals in background (for ingredient count)
      _fetchMealsDetailsInBackground(meals);
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      // When search is empty, load all meals
      state = state.copyWith(
        clearSearchQuery: true,
        clearSelectedCategory: true,
        clearSelectedArea: true,
      );
      loadAllMeals();
      return;
    }

    // Clear filters when searching
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      clearSelectedCategory: true, // Clear category filter when searching
      clearSelectedArea: true, // Clear area filter when searching
      error: null,
    );

    final result = await searchMeals(query);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        meals: result.meals ?? [],
      );
    }
  }

  void toggleView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void clearFilters() {
    state = state.copyWith(
      meals: [],
      clearSelectedCategory: true,
      clearSelectedArea: true,
      clearSearchQuery: true,
      isLoading: false,
    );
    // Load all meals when filters are cleared
    loadAllMeals();
  }

  /// Load meals from all popular categories (no filter view)
  Future<void> loadAllMeals() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getAllMeals();

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      final meals = result.meals ?? [];
      state = state.copyWith(
        isLoading: false,
        meals: meals,
      );

      // Fetch full details for meals in background (for ingredient count)
      _fetchMealsDetailsInBackground(meals);
    }
  }

  /// Loads a default set of meals, typically from the first category.
  /// Optionally accepts a category name to use directly (to avoid fetching categories again)
  Future<void> loadDefaultMeals({String? categoryName}) async {
    // If category is provided, use it directly
    if (categoryName != null) {
      await loadMealsByCategory(categoryName);
      return;
    }

    // Otherwise, fetch categories first
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categoriesResult = await getCategories();
      if (categoriesResult.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: categoriesResult.failure!.message,
        );
        return;
      }

      final categories = categoriesResult.categories ?? [];
      if (categories.isNotEmpty) {
        final defaultCategory = categories.first.name;
        await loadMealsByCategory(defaultCategory);
      } else {
        state = state.copyWith(isLoading: false, meals: []);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        meals: [],
        error: 'Failed to load default meals: $e',
      );
    }
  }

  /// Fetch full meal details in background to update ingredient counts
  /// This is called after loading simplified meals from filter endpoint
  void _fetchMealsDetailsInBackground(List<Meal> meals) {
    // Only fetch details for meals that don't have ingredients yet
    final mealsToFetch = meals
        .where((meal) =>
            meal.ingredients.isEmpty && !_mealDetailsCache.containsKey(meal.id))
        .take(10)
        .toList(); // Limit to first 10 to avoid too many API calls

    if (mealsToFetch.isEmpty) return;

    // Fetch details in batches to avoid overwhelming the API
    for (final meal in mealsToFetch) {
      getMealDetails(meal.id).then((detailsResult) {
        if (detailsResult.failure == null && detailsResult.meal != null) {
          _mealDetailsCache[meal.id] = detailsResult.meal!;

          // Update state with full meal details
          final updatedMeals = state.meals.map((m) {
            if (m.id == meal.id) {
              return detailsResult.meal!;
            }
            return m;
          }).toList();

          state = state.copyWith(meals: updatedMeals);
        }
      }).catchError((e) {
        // Silently fail - we'll show "Tap to view details" instead
      });
    }
  }
}

/// Provider for MealCatalogNotifier
final mealCatalogNotifierProvider =
    StateNotifierProvider<MealCatalogNotifier, MealCatalogState>((ref) {
  final apiClient = MealDbApiClient(baseUrl: AppConstants.mealdbApiUrl);
  final remoteDataSource = MealDbRemoteDataSourceImpl(apiClient: apiClient);
  final localDataSource = MealDbLocalDataSourceImpl();
  final repository = MealsRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
  final getMealsByCategory = GetMealsByCategory(repository);
  final getMealsByArea = GetMealsByArea(repository);
  final searchMeals = SearchMeals(repository);
  final getMealDetails = GetMealDetails(repository);
  final getCategories = GetCategories(repository);
  final getAllMeals = GetAllMeals(repository);

  return MealCatalogNotifier(
    getMealsByCategory: getMealsByCategory,
    getMealsByArea: getMealsByArea,
    searchMeals: searchMeals,
    getMealDetails: getMealDetails,
    getCategories: getCategories,
    getAllMeals: getAllMeals,
  );
});
