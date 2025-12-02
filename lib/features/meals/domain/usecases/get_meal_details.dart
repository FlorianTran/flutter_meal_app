import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to get meal details by ID
class GetMealDetails {
  final MealsRepository repository;

  GetMealDetails(this.repository);

  Future<({Failure? failure, Meal? meal})> call(String id) async {
    if (id.isEmpty) {
      return (
        failure: const GeneralFailure('Meal ID cannot be empty'),
        meal: null,
      );
    }
    return await repository.getMealDetails(id);
  }
}
