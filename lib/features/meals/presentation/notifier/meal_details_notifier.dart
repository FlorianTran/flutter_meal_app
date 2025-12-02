import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_meal_details.dart';
import '../../data/repositories_impl/meals_repository_impl.dart';
import '../../data/datasources/mealdb_remote_datasource.dart';
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/constants/app_constants.dart';
import 'meal_details_state.dart';
import 'favorites_notifier.dart';

class MealDetailsNotifier extends StateNotifier<MealDetailsState> {
  final GetMealDetails getMealDetails;
  final FavoritesNotifier? favoritesNotifier;

  MealDetailsNotifier({
    required this.getMealDetails,
    this.favoritesNotifier,
  }) : super(const MealDetailsState());

  Future<void> loadMealDetails(String mealId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getMealDetails(mealId);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      // Check if meal is favorite
      bool isFavorite = false;
      if (favoritesNotifier != null) {
        isFavorite = await favoritesNotifier!.isFavorite(mealId);
      }

      state = state.copyWith(
        isLoading: false,
        meal: result.meal,
        isFavorite: isFavorite,
      );
    }
  }

  Future<void> toggleFavorite() async {
    if (state.meal == null) return;

    if (favoritesNotifier != null) {
      await favoritesNotifier!.toggleFavorite(state.meal!);
      // Update state with new favorite status
      final isFavorite = await favoritesNotifier!.isFavorite(state.meal!.id);
      state = state.copyWith(isFavorite: isFavorite);
    } else {
      // Fallback: just toggle UI state
      state = state.copyWith(isFavorite: !state.isFavorite);
    }
  }

  void refresh() {
    if (state.meal != null) {
      loadMealDetails(state.meal!.id);
    }
  }
}

/// Provider for MealDetailsNotifier
/// Takes mealId as parameter
final mealDetailsNotifierProvider =
    StateNotifierProvider.family<MealDetailsNotifier, MealDetailsState, String>(
  (ref, mealId) {
    final apiClient = MealDbApiClient(baseUrl: AppConstants.mealdbApiUrl);
    final remoteDataSource = MealDbRemoteDataSourceImpl(apiClient: apiClient);
    final localDataSource = MealDbLocalDataSourceImpl();
    final repository = MealsRepositoryImpl(
        remoteDataSource: remoteDataSource, localDataSource: localDataSource);
    final getMealDetails = GetMealDetails(repository);
    final favoritesNotifier = ref.read(favoritesNotifierProvider.notifier);

    final notifier = MealDetailsNotifier(
      getMealDetails: getMealDetails,
      favoritesNotifier: favoritesNotifier,
    );
    notifier.loadMealDetails(mealId);
    return notifier;
  },
);
