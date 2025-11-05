import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to get meals filtered by category
class GetMealsByCategory {
  final MealsRepository repository;

  GetMealsByCategory(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call(String category) async {
    if (category.isEmpty) {
      return (
        failure: const GeneralFailure('Category cannot be empty'),
        meals: null,
      );
    }
    return await repository.getMealsByCategory(category);
  }
}
