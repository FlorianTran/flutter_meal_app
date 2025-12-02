import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to get meals filtered by area/country
class GetMealsByArea {
  final MealsRepository repository;

  GetMealsByArea(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call(String area) async {
    if (area.isEmpty) {
      return (
        failure: const GeneralFailure('Area cannot be empty'),
        meals: null,
      );
    }
    return await repository.getMealsByArea(area);
  }
}
