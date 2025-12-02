import '../../domain/entities/meal.dart';

/// State for search functionality
class SearchState {
  final bool isLoading;
  final String query;
  final List<Meal> results;
  final String? error;

  const SearchState({
    this.isLoading = false,
    this.query = '',
    this.results = const [],
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    String? query,
    List<Meal>? results,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      results: results ?? this.results,
      error: error,
    );
  }
}
