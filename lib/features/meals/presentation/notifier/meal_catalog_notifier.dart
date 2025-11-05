import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_meals_by_category.dart';
import '../../domain/usecases/get_meals_by_area.dart';
import '../../domain/usecases/search_meals.dart';
import '../../data/repositories_impl/meals_repository_impl.dart';
import '../../data/datasources/mealdb_remote_datasource.dart';
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/constants/app_constants.dart';
import 'meal_catalog_state.dart';

class MealCatalogNotifier extends StateNotifier<MealCatalogState> {
  final GetMealsByCategory getMealsByCategory;
  final GetMealsByArea getMealsByArea;
  final SearchMeals searchMeals;

  MealCatalogNotifier({
    required this.getMealsByCategory,
    required this.getMealsByArea,
    required this.searchMeals,
  }) : super(const MealCatalogState());

  Future<void> loadMealsByCategory(String category) async {
    state = state.copyWith(
      isLoading: true,
      selectedCategory: category,
      selectedArea: null,
      searchQuery: null,
      error: null,
    );

    final result = await getMealsByCategory(category);

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

  Future<void> loadMealsByArea(String area) async {
    state = state.copyWith(
      isLoading: true,
      selectedArea: area,
      selectedCategory: null,
      searchQuery: null,
      error: null,
    );

    final result = await getMealsByArea(area);

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

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        meals: [],
        searchQuery: null,
        selectedCategory: null,
        selectedArea: null,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      selectedCategory: null,
      selectedArea: null,
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
    state = const MealCatalogState();
  }
}

/// Provider for MealCatalogNotifier
final mealCatalogNotifierProvider =
    StateNotifierProvider<MealCatalogNotifier, MealCatalogState>((ref) {
  final apiClient = MealDbApiClient(baseUrl: AppConstants.mealdbApiUrl);
  final remoteDataSource = MealDbRemoteDataSourceImpl(apiClient: apiClient);
  final repository = MealsRepositoryImpl(remoteDataSource: remoteDataSource);
  final getMealsByCategory = GetMealsByCategory(repository);
  final getMealsByArea = GetMealsByArea(repository);
  final searchMeals = SearchMeals(repository);

  return MealCatalogNotifier(
    getMealsByCategory: getMealsByCategory,
    getMealsByArea: getMealsByArea,
    searchMeals: searchMeals,
  );
});
