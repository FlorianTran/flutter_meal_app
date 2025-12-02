import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/get_meal_details.dart';
import '../../di/meals_injection.dart';
import 'favorites_state.dart';

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final GetMealDetails getMealDetails;
  static const _kFavoritesKey = 'favorite_meals';

  FavoritesNotifier({required this.getMealDetails})
      : super(const FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> mealIds = prefs.getStringList(_kFavoritesKey) ?? [];

      final List<Meal> loadedMeals = [];
      for (final id in mealIds) {
        final result = await getMealDetails(id);
        if (result.failure == null && result.meal != null) {
          loadedMeals.add(result.meal!);
        }
      }
      state = state.copyWith(isLoading: false, meals: loadedMeals);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> isFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> mealIds = prefs.getStringList(_kFavoritesKey) ?? [];
    return mealIds.contains(mealId);
  }

  Future<void> addFavorite(Meal meal) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> mealIds = prefs.getStringList(_kFavoritesKey) ?? [];

    // Add if not already present
    if (!mealIds.contains(meal.id)) {
      mealIds.add(meal.id);
      await prefs.setStringList(_kFavoritesKey, mealIds);
      // Reload the state to reflect changes
      await loadFavorites();
    }
  }

  Future<void> removeFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> mealIds = prefs.getStringList(_kFavoritesKey) ?? [];
    mealIds.remove(mealId);
    await prefs.setStringList(_kFavoritesKey, mealIds);
    // Reload the state to reflect changes
    await loadFavorites();
  }

  Future<void> toggleFavorite(Meal meal) async {
    final isCurrentlyFavorite = await isFavorite(meal.id);
    if (isCurrentlyFavorite) {
      await removeFavorite(meal.id);
    } else {
      await addFavorite(meal);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFavoritesKey);
    state = state.copyWith(meals: []);
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider.autoDispose<FavoritesNotifier, FavoritesState>(
  (ref) {
    final getMealDetails = ref.watch(getMealDetailsUseCaseProvider);
    return FavoritesNotifier(getMealDetails: getMealDetails);
  },
);

/// Provider to check if a meal is favorite
final isFavoriteProvider = FutureProvider.family<bool, String>(
  (ref, mealId) async {
    final favoritesNotifier = ref.read(favoritesNotifierProvider.notifier);
    return await favoritesNotifier.isFavorite(mealId);
  },
);
