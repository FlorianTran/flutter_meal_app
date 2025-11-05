
import 'package:flutter_meal_app/core/error/exceptions.dart';
import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/core/network/network_info.dart';
import 'package:flutter_meal_app/features/meals/data/datasources/mealdb_remote_datasource.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/category.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';

class MealsRepositoryImpl implements MealsRepository {
  final MealDBRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MealsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<({Failure? failure, List<String>? ingredientNames})> listIngredients() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteIngredients = await remoteDataSource.listIngredients();
        final ingredientNames = remoteIngredients.map((e) => e.name).toList();
        return (failure: null, ingredientNames: ingredientNames);
      } on ServerException {
        return (failure: ServerFailure(""), ingredientNames: null);
      }
    } else {
      return (failure: ServerFailure(""), ingredientNames: null);
    }
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByIngredient(String ingredient) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMeals = await remoteDataSource.getMealsByIngredient(ingredient);
        return (failure: null, meals: remoteMeals);
      } on ServerException {
        return (failure: ServerFailure(""), meals: null);
      }
    } else {
      return (failure: ServerFailure(""), meals: null);
    }
  }

  // The following methods are not implemented as they are not required for the current task.
  @override
  Future<({Failure? failure, List<Category>? categories})> getCategories() {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, Meal? meal})> getMealDetails(String id) {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, Meal? meal})> getMealOfDay() {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByArea(String area) {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByCategory(String category) {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, List<String>? areaNames})> listAreas() {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, List<String>? categoryNames})> listCategories() {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> searchMeals(String query) {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> searchMealsByLetter(String letter) {
    throw UnimplementedError();
  }
}
