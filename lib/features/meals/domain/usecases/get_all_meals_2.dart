import '../../../../core/error/failures.dart';
import '../entities/meal.dart';
import '../repositories/meals_repository.dart';

/// Use case to get meals from multiple categories (all meals view)
/// Fetches meals from popular categories to show a comprehensive catalog
class GetAllMeals2 {
  final MealsRepository repository;

  GetAllMeals2(this.repository);

  Future<({Failure? failure, List<Meal>? meals})> call() async {
    return repository.getAllMeals();
  }
}
