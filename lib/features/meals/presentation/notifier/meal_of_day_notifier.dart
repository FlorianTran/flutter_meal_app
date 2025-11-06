import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_meal_of_day.dart';
import '../../data/repositories_impl/meals_repository_impl.dart';
import '../../data/datasources/mealdb_remote_datasource.dart';
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/constants/app_constants.dart';
import 'meal_of_day_state.dart';

class MealOfDayNotifier extends StateNotifier<MealOfDayState> {
  final GetMealOfDay getMealOfDay;

  MealOfDayNotifier({required this.getMealOfDay})
      : super(const MealOfDayState());

  Future<void> loadMealOfDay() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getMealOfDay();

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

  void refresh() {
    loadMealOfDay();
  }
}

/// Provider for MealOfDayNotifier
final mealOfDayNotifierProvider =
    StateNotifierProvider<MealOfDayNotifier, MealOfDayState>((ref) {
  final apiClient = MealDbApiClient(baseUrl: AppConstants.mealdbApiUrl);
  final remoteDataSource = MealDbRemoteDataSourceImpl(apiClient: apiClient);
  final localDataSource = MealDbLocalDataSourceImpl();
  final repository = MealsRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);  final getMealOfDay = GetMealOfDay(repository);

  return MealOfDayNotifier(getMealOfDay: getMealOfDay);
});

