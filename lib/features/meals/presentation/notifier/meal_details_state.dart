import '../../domain/entities/meal.dart';

/// State for meal details page
class MealDetailsState {
  final bool isLoading;
  final Meal? meal;
  final String? error;
  final bool isFavorite;

  const MealDetailsState({
    this.isLoading = false,
    this.meal,
    this.error,
    this.isFavorite = false,
  });

  MealDetailsState copyWith({
    bool? isLoading,
    Meal? meal,
    String? error,
    bool? isFavorite,
  }) {
    return MealDetailsState(
      isLoading: isLoading ?? this.isLoading,
      meal: meal ?? this.meal,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
