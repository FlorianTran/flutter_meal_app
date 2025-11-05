import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/meals_repository.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/category.dart';
import '../datasources/mealdb_remote_datasource.dart';

/// Implementation of MealsRepository
/// Converts exceptions from data source to failures for domain layer
class MealsRepositoryImpl implements MealsRepository {
  final MealDbRemoteDataSource remoteDataSource;

  MealsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<({Failure? failure, Meal? meal})> getMealOfDay() async {
    try {
      final mealModel = await remoteDataSource.getRandomMeal();
      return (failure: null, meal: mealModel.toEntity());
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), meal: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), meal: null);
    }
  }

  @override
  Future<({Failure? failure, Meal? meal})> getMealDetails(String id) async {
    try {
      final mealModel = await remoteDataSource.getMealDetails(id);
      return (failure: null, meal: mealModel.toEntity());
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), meal: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), meal: null);
    }
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> searchMeals(
      String query) async {
    try {
      final mealModels = await remoteDataSource.searchMeals(query);
      final meals = mealModels.map((model) => model.toEntity()).toList();
      return (failure: null, meals: meals);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), meals: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), meals: null);
    }
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> searchMealsByLetter(
      String letter) async {
    try {
      final mealModels = await remoteDataSource.searchMealsByLetter(letter);
      final meals = mealModels.map((model) => model.toEntity()).toList();
      return (failure: null, meals: meals);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), meals: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), meals: null);
    }
  }

  @override
  Future<({Failure? failure, List<Category>? categories})>
      getCategories() async {
    try {
      final categoryModels = await remoteDataSource.getCategories();
      final categories =
          categoryModels.map((model) => model.toEntity()).toList();
      return (failure: null, categories: categories);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), categories: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), categories: null);
    }
  }

  @override
  Future<({Failure? failure, List<String>? categoryNames})>
      listCategories() async {
    try {
      final categoryNames = await remoteDataSource.listCategories();
      return (failure: null, categoryNames: categoryNames);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), categoryNames: null);
    } catch (e) {
      return (
        failure: ServerFailure('Unexpected error: $e'),
        categoryNames: null
      );
    }
  }

  @override
  Future<({Failure? failure, List<String>? areaNames})> listAreas() async {
    try {
      final areaNames = await remoteDataSource.listAreas();
      return (failure: null, areaNames: areaNames);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), areaNames: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), areaNames: null);
    }
  }

  @override
  Future<({Failure? failure, List<String>? ingredientNames})>
      listIngredients() async {
    try {
      final ingredientNames = await remoteDataSource.listIngredients();
      return (failure: null, ingredientNames: ingredientNames);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), ingredientNames: null);
    } catch (e) {
      return (
        failure: ServerFailure('Unexpected error: $e'),
        ingredientNames: null
      );
    }
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByCategory(
      String category) async {
    try {
      final mealModels = await remoteDataSource.getMealsByCategory(category);
      final meals = mealModels.map((model) => model.toEntity()).toList();
      return (failure: null, meals: meals);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), meals: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), meals: null);
    }
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByArea(
      String area) async {
    try {
      final mealModels = await remoteDataSource.getMealsByArea(area);
      final meals = mealModels.map((model) => model.toEntity()).toList();
      return (failure: null, meals: meals);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), meals: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), meals: null);
    }
  }

  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByIngredient(
      String ingredient) async {
    try {
      final mealModels =
          await remoteDataSource.getMealsByIngredient(ingredient);
      final meals = mealModels.map((model) => model.toEntity()).toList();
      return (failure: null, meals: meals);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), meals: null);
    } catch (e) {
      return (failure: ServerFailure('Unexpected error: $e'), meals: null);
    }
  }
}
