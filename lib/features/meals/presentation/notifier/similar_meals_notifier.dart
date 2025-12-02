import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/get_similar_meals.dart';
import '../../di/meals_injection.dart';
import 'similar_meals_state.dart';

/// Notifier for managing similar meals state
class SimilarMealsNotifier extends StateNotifier<SimilarMealsState> {
  final GetSimilarMeals getSimilarMeals;

  SimilarMealsNotifier({required this.getSimilarMeals})
      : super(const SimilarMealsState());

  /// Load similar meals for a given meal
  Future<void> loadSimilarMeals(Meal meal, {int limit = 12}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getSimilarMeals(meal, limit: limit);

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

  /// Clear similar meals
  void clear() {
    state = const SimilarMealsState();
  }
}

/// Provider for SimilarMealsNotifier that takes a Meal directly
final similarMealsNotifierProviderForMeal =
    StateNotifierProvider.autoDispose<SimilarMealsNotifier, SimilarMealsState>(
  (ref) {
    final getSimilarMeals = ref.watch(getSimilarMealsUseCaseProvider);
    return SimilarMealsNotifier(getSimilarMeals: getSimilarMeals);
  },
);
