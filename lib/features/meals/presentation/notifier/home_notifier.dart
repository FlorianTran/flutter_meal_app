import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_categories.dart';
import '../../data/repositories_impl/meals_repository_impl.dart';
import '../../data/datasources/mealdb_remote_datasource.dart';
import '../../../../core/network/mealdb_api_client.dart';
import '../../../../core/constants/app_constants.dart';
import 'home_state.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  final GetCategories getCategories;

  HomeNotifier({required this.getCategories})
      : super(const HomeState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getCategories();

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        categories: result.categories ?? [],
      );
    }
  }

  void refresh() {
    loadCategories();
  }
}

/// Provider for HomeNotifier
final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final apiClient = MealDbApiClient(baseUrl: AppConstants.mealdbApiUrl);
  final remoteDataSource = MealDbRemoteDataSourceImpl(apiClient: apiClient);
  final repository = MealsRepositoryImpl(remoteDataSource: remoteDataSource);
  final getCategories = GetCategories(repository);

  return HomeNotifier(getCategories: getCategories);
});

