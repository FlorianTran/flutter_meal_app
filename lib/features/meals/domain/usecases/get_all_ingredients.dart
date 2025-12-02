import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';

class GetAllIngredients {
  final MealsRepository repository;

  GetAllIngredients(this.repository);

  Future<({Failure? failure, List<String>? ingredientNames})> call() async {
    return await repository.listIngredients();
  }
}
