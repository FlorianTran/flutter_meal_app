import '../../domain/entities/meal.dart';

/// State for recently viewed meals
class RecentlyViewedState {
  final List<Meal> meals;
  final bool isLoading;
  final String? error;

  const RecentlyViewedState({
    this.meals = const [],
    this.isLoading = false,
    this.error,
  });

  RecentlyViewedState copyWith({
    List<Meal>? meals,
    bool? isLoading,
    String? error,
  }) {
    return RecentlyViewedState(
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
