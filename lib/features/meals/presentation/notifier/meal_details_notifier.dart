import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_meal_details.dart';
import '../../data/repositories_impl/meals_repository_impl.dart';
import '../../data/datasources/mealdb_remote_datasource.dart';
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/constants/app_constants.dart';
import 'meal_details_state.dart';

class MealDetailsNotifier extends StateNotifier<MealDetailsState> {
  final GetMealDetails getMealDetails;

  MealDetailsNotifier({required this.getMealDetails})
      : super(const MealDetailsState());

  Future<void> loadMealDetails(String mealId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getMealDetails(mealId);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        meal: result.meal,
      );
    }
  }

  void toggleFavorite() {
    // TODO: Implement favorite functionality (will be done by Dev 2)
    // For now, just toggle the UI state
    state = state.copyWith(isFavorite: !state.isFavorite);
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
  final repository = MealsRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
    final getMealDetails = GetMealDetails(repository);

    final notifier = MealDetailsNotifier(getMealDetails: getMealDetails);
    notifier.loadMealDetails(mealId);
    return notifier;
  },
);
