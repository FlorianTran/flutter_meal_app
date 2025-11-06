import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to get a random meal (Meal of the Day)
class GetMealOfDay {
  final MealsRepository repository;

  GetMealOfDay(this.repository);

  Future<({Failure? failure, Meal? meal})> call() async {
    return await repository.getMealOfDay();
  }
}
