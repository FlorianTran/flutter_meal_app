// ignore_for_file: unnecessary_type_check

import 'package:flutter_meal_app/core/error/failures.dart';
import 'package:flutter_meal_app/features/meals/di/meals_injection.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/category.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/ingredient.dart';
import 'package:flutter_meal_app/features/meals/domain/entities/meal.dart';
import 'package:flutter_meal_app/features/meals/domain/repositories/meals_repository.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/ingredients_selection_notifier.dart';
import 'package:flutter_meal_app/features/meals/presentation/notifier/matching_meals_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Mock Data
final _mealA = Meal(
  id: '1',
  name: 'Chicken Stir-Fry',
  ingredients: [
    const Ingredient(name: 'Chicken'),
    const Ingredient(name: 'Broccoli'),
    const Ingredient(name: 'Carrot'),
  ],
);

final _mealB = Meal(
  id: '2',
  name: 'Chicken & Rice',
  ingredients: [
    const Ingredient(name: 'Chicken'),
    const Ingredient(name: 'Rice'),
    const Ingredient(name: 'Soy Sauce'),
  ],
);

final _mealC = Meal(
  id: '3',
  name: 'Beef Tacos',
  ingredients: [
    const Ingredient(name: 'Beef'),
    const Ingredient(name: 'Taco Shells'),
    const Ingredient(name: 'Cheese'),
    const Ingredient(name: 'Lettuce'),
  ],
);

final _allMeals = [_mealA, _mealB, _mealC];
final _allIngredients = ['Beef', 'Broccoli', 'Carrot', 'Cheese', 'Chicken', 'Lettuce', 'Rice', 'Soy Sauce', 'Taco Shells'];


// 2. Fake Repository
class FakeMealsRepository implements MealsRepository {
  @override
  Future<({Failure? failure, List<Meal>? meals})> getAllMeals() async {
    return (failure: null, meals: _allMeals);
  }
  
  @override
  Future<({Failure? failure, List<String>? ingredientNames})> listIngredients() async {
    return (failure: null, ingredientNames: _allIngredients);
  }

  // Unused methods
  @override
  Future<({Failure? failure, List<String>? areaNames})> listAreas() async => (failure: null, areaNames: <String>[]);
  @override
  Future<({Failure? failure, List<Category>? categories})> getCategories() async => (failure: null, categories: <Category>[]);
  @override
  Future<({Failure? failure, Meal? meal})> getMealDetails(String id) async => (failure: null, meal: null);
  @override
  Future<({Failure? failure, Meal? meal})> getMealOfDay() async => (failure: null, meal: null);
  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByArea(String area) async => (failure: null, meals: <Meal>[]);
  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByCategory(String category) async => (failure: null, meals: <Meal>[]);
  @override
  Future<({Failure? failure, List<Meal>? meals})> getMealsByIngredient(String ingredient) async => (failure: null, meals: <Meal>[]);
  @override
  Future<({Failure? failure, List<String>? categoryNames})> listCategories() async => (failure: null, categoryNames: <String>[]);
  @override
  Future<({Failure? failure, List<Meal>? meals})> searchMeals(String query) async => (failure: null, meals: <Meal>[]);
  @override
  Future<({Failure? failure, List<Meal>? meals})> searchMealsByLetter(String letter) async => (failure: null, meals: <Meal>[]);
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        // Override repository providers with our fake implementation
        mealsRepositoryProvider.overrideWithValue(FakeMealsRepository()),
        // Since getAllMeals2UseCaseProvider depends on the repository, it will use the fake one.
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Ingredients Selection Logic', () {
    test('IngredientsSelectionNotifier should add and remove ingredients', () {
      // Arrange
      final notifier = container.read(ingredientsSelectionNotifierProvider.notifier);

      // Act & Assert
      expect(notifier.state, isEmpty);

      notifier.toggleIngredient('Chicken');
      expect(notifier.state, ['Chicken']);

      notifier.toggleIngredient('Beef');
      expect(notifier.state, ['Chicken', 'Beef']);

      notifier.toggleIngredient('Chicken');
      expect(notifier.state, ['Beef']);
    });

    test('ingredientFilterLogicProvider: should return all ingredients when none are selected', () async {
      // Act
      final result = await container.read(ingredientFilterLogicProvider.future);

      // Assert
      expect(result, _allIngredients);
    });

    test('ingredientFilterLogicProvider: should filter possible ingredients when one is selected', () async {
      // Arrange: Select 'Chicken'
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Chicken');

      // Act
      final result = await container.read(ingredientFilterLogicProvider.future);

      // Assert: Should contain selected ingredient first, then ingredients from matching meals (_mealA, _mealB)
      // Expected: [Chicken, Broccoli, Carrot, Rice, Soy Sauce] sorted correctly
      expect(result, ['Chicken', 'Broccoli', 'Carrot', 'Rice', 'Soy Sauce']);
    });

    test('ingredientFilterLogicProvider: should return all ingredients for an impossible combination', () async {
      // Arrange: Select 'Chicken' and 'Beef' (no meal has both)
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Chicken');
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Beef');

      // Act
      final result = await container.read(ingredientFilterLogicProvider.future);

      // Assert: Should fall back to showing all ingredients
      expect(result, _allIngredients);
    });

    test('ingredientFilterLogicProvider: selected ingredients should appear first', () async {
      // Arrange: Select 'Rice' and 'Chicken'
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Rice');
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Chicken');

      // Act
      final result = await container.read(ingredientFilterLogicProvider.future);

      // Assert: Selected ingredients are first, then the rest, all sorted alphabetically
      // MealB matches. Possible ingredients: Chicken, Rice, Soy Sauce
      // Selected: Chicken, Rice. Remaining: Soy Sauce
      expect(result, ['Chicken', 'Rice', 'Soy Sauce']);
    });
  });

  group('Matching Meals Logic', () {
    test('matchingMealsProvider should return correct meals', () async {
      // Arrange: Select 'Chicken'
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Chicken');

      // Act
      final result = await container.read(matchingMealsProvider.future);

      // Assert: Should return mealA and mealB
      expect(result, containsAll([_mealA, _mealB]));
      expect(result.length, 2);
    });

    test('matchingMealsProvider should return empty list for impossible combination', () async {
      // Arrange: Select 'Chicken' and 'Beef'
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Chicken');
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Beef');

      // Act
      final result = await container.read(matchingMealsProvider.future);

      // Assert
      expect(result, isEmpty);
    });

    test('allIngredientsFromMatchingMealsProvider should extract unique ingredients', () async {
      // Arrange: Select 'Chicken'
      container.read(ingredientsSelectionNotifierProvider.notifier).toggleIngredient('Chicken');

      // Act
      // Wait for matchingMealsProvider to compute, then read the dependent provider
      await container.read(matchingMealsProvider.future);
      final result = container.read(allIngredientsFromMatchingMealsProvider);

      // Assert: Should contain unique ingredients from mealA and mealB, sorted
      expect(result, ['Broccoli', 'Carrot', 'Chicken', 'Rice', 'Soy Sauce']);
    });
  });
}
