import '../../domain/entities/meal.dart';

/// State for Meal of the Day
class MealOfDayState {
  final bool isLoading;
  final Meal? meal;
  final String? error;

  const MealOfDayState({
    this.isLoading = false,
    this.meal,
    this.error,
  });

  MealOfDayState copyWith({
    bool? isLoading,
    Meal? meal,
    String? error,
  }) {
    return MealOfDayState(
      isLoading: isLoading ?? this.isLoading,
      meal: meal ?? this.meal,
      error: error,
    );
  }
}

