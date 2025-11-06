import 'package:flutter_meal_app/features/meals/domain/entities/ingredient.dart';

import '../../domain/entities/meal.dart';

/// Meal data model
class MealModel extends Meal {
  MealModel({
    required super.id,
    required super.name,
    super.image,
    super.category,
    super.area,
    super.instructions,
    required super.ingredients,
    super.youtubeUrl,
    super.sourceUrl,
    super.thumbnailUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];

    // Check if ingredients are already parsed (from cache)
    if (json.containsKey('ingredients') && json['ingredients'] is List) {
      final ingredientsData = json['ingredients'] as List;
      for (final ingredientJson in ingredientsData) {
        if (ingredientJson is Map<String, dynamic>) {
          ingredients.add(Ingredient(
            name: ingredientJson['name'] ?? '',
            measurement: ingredientJson['measurement'],
          ));
        }
      }
    } else {
      // Fallback to parsing from strIngredient1-20 (from API)
      for (int i = 1; i <= 20; i++) {
        final ingredientName = json['strIngredient$i'] as String?;
        final measure = json['strMeasure$i'] as String?;

        if (ingredientName != null && ingredientName.trim().isNotEmpty) {
          ingredients.add(Ingredient(
            name: ingredientName.trim(),
            measurement: measure?.trim(),
          ));
        }
      }
    }

    return MealModel(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      image: json['strMealThumb']?.toString(),
      category: json['strCategory']?.toString(),
      area: json['strArea']?.toString(),
      instructions: json['strInstructions']?.toString(),
      ingredients: ingredients,
      youtubeUrl: json['strYoutube']?.toString(),
      sourceUrl: json['strSource']?.toString(),
      thumbnailUrl: json['strMealThumb']?.toString(),
    );
  }

  /// Parses a list of meals from a MealDB API JSON response.
  /// The API returns a map with a 'meals' key, which can be a list of meal objects.
  static List<MealModel> parseMealsListFromJson(Map<String, dynamic> json) {
    final mealsData = json['meals'];

    if (mealsData is List) {
      return mealsData
          .map((mealJson) => MealModel.fromJson(mealJson as Map<String, dynamic>))
          .toList();
    }

    // Return an empty list if 'meals' is null or not a list
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': image,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strYoutube': youtubeUrl,
      'strSource': sourceUrl,
      // Serialize ingredients
      'ingredients': ingredients
          .map((i) => {'name': i.name, 'measurement': i.measurement})
          .toList(),
    };
  }

  Meal toEntity() {
    return Meal(
      id: id,
      name: name,
      image: image,
      category: category,
      area: area,
      instructions: instructions,
      ingredients: ingredients,
      youtubeUrl: youtubeUrl,
      sourceUrl: sourceUrl,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
