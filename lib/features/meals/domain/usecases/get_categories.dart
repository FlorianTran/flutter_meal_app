import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/meals_repository.dart';

/// Use case to get all meal categories
class GetCategories {
  final MealsRepository repository;

  GetCategories(this.repository);

  Future<({Failure? failure, List<Category>? categories})> call() async {
    return await repository.getCategories();
  }
}
