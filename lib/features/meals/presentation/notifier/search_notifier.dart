import 'dart:async';
import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/search_meals.dart';
import '../../data/repositories_impl/meals_repository_impl.dart';
import '../../data/datasources/mealdb_remote_datasource.dart';
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/constants/app_constants.dart';
import 'search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchMeals searchMeals;
  Timer? _debounceTimer;

  SearchNotifier({required this.searchMeals}) : super(const SearchState());

  void search(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update query immediately
    state = state.copyWith(query: query, isLoading: false);

    // Debounce search API call
    if (query.isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    if (query.length < 2) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await searchMeals(query);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        results: result.meals ?? [],
      );
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for SearchNotifier
final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final apiClient = MealDbApiClient(baseUrl: AppConstants.mealdbApiUrl);
  final remoteDataSource = MealDbRemoteDataSourceImpl(apiClient: apiClient);
  final localDataSource = MealDbLocalDataSourceImpl();
  final repository = MealsRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);  final searchMeals = SearchMeals(repository);

  return SearchNotifier(searchMeals: searchMeals);
});
