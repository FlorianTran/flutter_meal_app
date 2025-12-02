import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to search meals by name
class SearchMeals {
  final MealsRepository repository;

  SearchMeals(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call(String query) async {
    if (query.isEmpty) {
      return (
        failure: const GeneralFailure('Search query cannot be empty'),
        meals: null,
      );
    }

    if (query.length < 2) {
      return (
        failure:
            const GeneralFailure('Search query must be at least 2 characters'),
        meals: null,
      );
    }

    return await repository.searchMeals(query);
  }
}
