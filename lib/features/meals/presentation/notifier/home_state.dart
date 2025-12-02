import '../../domain/entities/category.dart';

/// State for Home page
class HomeState {
  final bool isLoading;
  final List<Category> categories;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Category>? categories,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error,
    );
  }
}

