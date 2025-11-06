import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/get_meal_details.dart';
import '../../di/meals_injection.dart';
import 'recently_viewed_state.dart';

/// Notifier for managing recently viewed meals
class RecentlyViewedNotifier extends StateNotifier<RecentlyViewedState> {
  static const String _storageKey = 'recently_viewed_meals';
  static const int _maxMeals = 50; // Limit to last 50 meals

  final GetMealDetails getMealDetails;

  RecentlyViewedNotifier({required this.getMealDetails})
      : super(const RecentlyViewedState()) {
    _loadRecentlyViewed();
  }

  /// Load recently viewed meals from local storage
  Future<void> _loadRecentlyViewed() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_storageKey) ?? [];

      if (mealsJson.isEmpty) {
        state = state.copyWith(isLoading: false, meals: []);
        return;
      }

      // Load full meal details for each recently viewed meal ID
      final meals = <Meal>[];
      for (final mealId in mealsJson) {
        final result = await getMealDetails(mealId);
        if (result.failure == null && result.meal != null) {
          meals.add(result.meal!);
        }
      }

      state = state.copyWith(isLoading: false, meals: meals);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load recently viewed meals: $e',
      );
    }
  }

  /// Add a meal to recently viewed
  Future<void> addMeal(Meal meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_storageKey) ?? [];

      // Remove if already exists (to move to front)
      mealsJson.remove(meal.id);

      // Add to front
      mealsJson.insert(0, meal.id);

      // Limit to max meals
      if (mealsJson.length > _maxMeals) {
        mealsJson.removeRange(_maxMeals, mealsJson.length);
      }

      await prefs.setStringList(_storageKey, mealsJson);

      // Update state
      final currentMeals = List<Meal>.from(state.meals);
      currentMeals.removeWhere((m) => m.id == meal.id);
      currentMeals.insert(0, meal);
      if (currentMeals.length > _maxMeals) {
        currentMeals.removeRange(_maxMeals, currentMeals.length);
      }

      state = state.copyWith(meals: currentMeals);
    } catch (e) {
      // Silently fail - don't block user experience
      print('Error adding meal to recently viewed: $e');
    }
  }

  /// Remove a meal from recently viewed
  Future<void> removeMeal(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_storageKey) ?? [];
      mealsJson.remove(mealId);
      await prefs.setStringList(_storageKey, mealsJson);

      // Update state
      final currentMeals = List<Meal>.from(state.meals);
      currentMeals.removeWhere((m) => m.id == mealId);
      state = state.copyWith(meals: currentMeals);
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove meal: $e');
    }
  }

  /// Clear all recently viewed meals
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      state = state.copyWith(meals: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear recently viewed: $e');
    }
  }

  /// Refresh recently viewed meals
  Future<void> refresh() async {
    await _loadRecentlyViewed();
  }
}

/// Provider for RecentlyViewedNotifier
final recentlyViewedNotifierProvider =
    StateNotifierProvider<RecentlyViewedNotifier, RecentlyViewedState>((ref) {
  final getMealDetails = ref.watch(getMealDetailsUseCaseProvider);
  return RecentlyViewedNotifier(getMealDetails: getMealDetails);
});
