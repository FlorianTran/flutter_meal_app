import '../../domain/entities/meal.dart';

/// State for meal catalog page
class MealCatalogState {
  final bool isLoading;
  final List<Meal> meals;
  final String? selectedCategory;
  final String? selectedArea;
  final String? searchQuery;
  final String? error;
  final bool isGridView;

  const MealCatalogState({
    this.isLoading = false,
    this.meals = const [],
    this.selectedCategory,
    this.selectedArea,
    this.searchQuery,
    this.error,
    this.isGridView = true,
  });

  MealCatalogState copyWith({
    bool? isLoading,
    List<Meal>? meals,
    String? selectedCategory,
    String? selectedArea,
    String? searchQuery,
    String? error,
    bool? isGridView,
    bool clearSelectedCategory = false,
    bool clearSelectedArea = false,
    bool clearSearchQuery = false,
  }) {
    return MealCatalogState(
      isLoading: isLoading ?? this.isLoading,
      meals: meals ?? this.meals,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedArea: clearSelectedArea ? null : (selectedArea ?? this.selectedArea),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      error: error,
      isGridView: isGridView ?? this.isGridView,
    );
  }
}
