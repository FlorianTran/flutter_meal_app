import '../../domain/entities/meal.dart';

/// State for similar meals feature
class SimilarMealsState {
  final bool isLoading;
  final List<Meal> meals;
  final String? error;

  const SimilarMealsState({
    this.isLoading = false,
    this.meals = const [],
    this.error,
  });

  SimilarMealsState copyWith({
    bool? isLoading,
    List<Meal>? meals,
    String? error,
  }) {
    return SimilarMealsState(
      isLoading: isLoading ?? this.isLoading,
      meals: meals ?? this.meals,
      error: error,
    );
  }
}
