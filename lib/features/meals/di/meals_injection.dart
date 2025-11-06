import 'package:flutter_meal_app/features/meals/domain/usecases/get_all_meals_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_meal_app/core/network/network_info.dart';
import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_remote_datasource.dart';
import 'package:flutter_meal_app/features/meals/data/repositories_impl/meals_repository_impl.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_all_ingredients.dart';
import 'package:flutter_meal_app/core/network/mealdb_api_client.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/find_matching_meals_exhaustive.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_all_meals.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_categories.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_meal_details.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_meal_of_day.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_meals_by_area.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_meals_by_category.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/search_meals.dart';
import 'package:flutter_meal_app/features/meals/domain/usecases/get_similar_meals.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/ingredients_selection_notifier.dart';
import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_local_data_source.dart';

// Infrastructure Layer
final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final mealDbApiClientProvider = Provider<MealDbApiClient>((ref) {
  return MealDbApiClient(client: ref.watch(httpClientProvider));
});
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

// Data Layer
final mealDBRemoteDataSourceProvider = Provider<MealDbRemoteDataSource>((ref) {
  return MealDbRemoteDataSourceImpl(
      apiClient: ref.watch(mealDbApiClientProvider));
});

final mealDBLocalDataSourceProvider = Provider<MealDbLocalDataSource>((ref) {
  return MealDbLocalDataSourceImpl();
});

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  return MealsRepositoryImpl(
    remoteDataSource: ref.watch(mealDBRemoteDataSourceProvider),
    localDataSource: ref.watch(mealDBLocalDataSourceProvider),
  );
});

// Domain Layer (Use Cases)
final getAllIngredientsUseCaseProvider = Provider<GetAllIngredients>((ref) {
  return GetAllIngredients(ref.watch(mealsRepositoryProvider));
});

final findMatchingMealsExhaustiveUseCaseProvider =
    Provider<FindMatchingMealsExhaustive>((ref) {
  return FindMatchingMealsExhaustive(
    ref.watch(mealsRepositoryProvider),
    ref.watch(getCategoriesUseCaseProvider),
    ref.watch(getAllMeals2UseCaseProvider),
  );
});

final getAllMealsUseCaseProvider = Provider<GetAllMeals>((ref) {
  return GetAllMeals(ref.watch(mealsRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(mealsRepositoryProvider));
});

final getAllMeals2UseCaseProvider = Provider<GetAllMeals2>((ref) {
  return GetAllMeals2(ref.watch(mealsRepositoryProvider));
});

final getMealDetailsUseCaseProvider = Provider<GetMealDetails>((ref) {
  return GetMealDetails(ref.watch(mealsRepositoryProvider));
});

final getMealOfDayUseCaseProvider = Provider<GetMealOfDay>((ref) {
  return GetMealOfDay(ref.watch(mealsRepositoryProvider));
});

final getMealsByAreaUseCaseProvider = Provider<GetMealsByArea>((ref) {
  return GetMealsByArea(ref.watch(mealsRepositoryProvider));
});

final getMealsByCategoryUseCaseProvider = Provider<GetMealsByCategory>((ref) {
  return GetMealsByCategory(ref.watch(mealsRepositoryProvider));
});

final searchMealsUseCaseProvider = Provider<SearchMeals>((ref) {
  return SearchMeals(ref.watch(mealsRepositoryProvider));
});

final getSimilarMealsUseCaseProvider = Provider<GetSimilarMeals>((ref) {
  return GetSimilarMeals(ref.watch(mealsRepositoryProvider));
});

// --- UI-facing Providers ---

/// Provider to fetch the list of all ingredient names.
final allIngredientsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final getAllIngredients = ref.watch(getAllIngredientsUseCaseProvider);
  final result = await getAllIngredients();

  if (result.failure != null) {
    throw result.failure!;
  }

  return result.ingredientNames ?? [];
});

/// Provider to filter available ingredients based on the current selection.
final availableIngredientsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);
  final getAllMeals = ref.watch(getAllMealsUseCaseProvider);

  // If no ingredients are selected, show all ingredients.
  if (selectedIngredients.isEmpty) {
    final allIngredientsResult = await ref.watch(allIngredientsProvider.future);
    return allIngredientsResult;
  }

  final allMealsResult = await getAllMeals();
  if (allMealsResult.failure != null) {
    throw allMealsResult.failure!;
  }

  final allMeals = allMealsResult.meals ?? [];

  // 1. Find meals that contain all selected ingredients.
  final matchingMeals = allMeals.where((meal) {
    final mealIngredients =
        meal.ingredients.map((e) => e.name.toLowerCase()).toSet();
    return selectedIngredients
        .every((selected) => mealIngredients.contains(selected.toLowerCase()));
  }).toList();

  // 2. From those meals, get all their ingredients.
  final availableIngredients = matchingMeals
      .expand((meal) => meal.ingredients.map((e) => e.name))
      .toSet()
      .toList();

  // 3. Sort the ingredients alphabetically.
  availableIngredients.sort();

  return availableIngredients;
});

/// New, independent provider for the ingredient selection page logic.
final ingredientFilterLogicProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final selectedIngredients = ref.watch(ingredientsSelectionNotifierProvider);
  final allIngredientsFuture = ref.watch(allIngredientsProvider.future);

  // If nothing is selected, show all ingredients.
  if (selectedIngredients.isEmpty) {
    return await allIngredientsFuture;
  }

  // Fetch all meals to perform the filtering logic.
  final allMealsResult = await ref.watch(getAllMeals2UseCaseProvider).call();
  if (allMealsResult.failure != null || allMealsResult.meals == null) {
    // If fetching meals fails, fall back to showing all ingredients to not block the user.
    return await allIngredientsFuture;
  }
  final allMeals = allMealsResult.meals!;

  // Find meals that contain ALL selected ingredients.
  final matchingMeals = allMeals.where((meal) {
    final mealIngredients =
        meal.ingredients.map((e) => e.name.toLowerCase()).toSet();
    return selectedIngredients
        .every((selected) => mealIngredients.contains(selected.toLowerCase()));
  }).toList();

  // If no meals match, it means the user has selected an impossible combination.
  // We return ALL ingredients so they can change their selection.
  if (matchingMeals.isEmpty) {
    return await allIngredientsFuture;
  }

  // From the matching meals, get the superset of all their ingredients.
  final possibleIngredients = matchingMeals
      .expand((meal) => meal.ingredients.map((e) => e.name))
      .toSet();

  // Ensure the currently selected ingredients are always part of the set.
  possibleIngredients.addAll(selectedIngredients);

  // Sort selected ingredients and put them first.
  final sortedSelected = selectedIngredients..sort();

  // Get the remaining ingredients, sort them, and add them after.
  final remainingIngredients = possibleIngredients
      .where((ingredient) => !selectedIngredients.contains(ingredient))
      .toList()
    ..sort();

  return [...sortedSelected, ...remainingIngredients];
});
