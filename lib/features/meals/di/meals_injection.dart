
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_meal_app/core/network/network_info.dart';
import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_remote_datasource.dart';
import 'package:flutter_meal_app/features/meals/data/repositories_impl/meals_repository_impl.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_all_ingredients.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/find_matching_meals.dart';

// Infrastructure Layer
final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

// Data Layer
final mealDBRemoteDataSourceProvider = Provider<MealDBRemoteDataSource>((ref) {
  return MealDBRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  return MealsRepositoryImpl(
    remoteDataSource: ref.watch(mealDBRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Domain Layer (Use Cases)
final getAllIngredientsUseCaseProvider = Provider<GetAllIngredients>((ref) {
  return GetAllIngredients(ref.watch(mealsRepositoryProvider));
});

final findMatchingMealsUseCaseProvider = Provider<FindMatchingMeals>((ref) {
  return FindMatchingMeals(ref.watch(mealsRepositoryProvider));
});

// --- UI-facing Providers ---

/// Provider to fetch the list of all ingredient names.
final allIngredientsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final getAllIngredients = ref.watch(getAllIngredientsUseCaseProvider);
  final result = await getAllIngredients();
  
  if (result.failure != null) {
    throw result.failure!;
  }
  
  return result.ingredientNames ?? [];
});
