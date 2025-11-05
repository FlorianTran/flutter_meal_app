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
    // MealDB API returns meal data as a Map
    final mealData = json;

    final ingredients = <MealIngredient>[];

    // Extract ingredients from strIngredient1-20 and strMeasure1-20
    for (int i = 1; i <= 20; i++) {
      final ingredientName = mealData['strIngredient$i'] as String?;
      final measure = mealData['strMeasure$i'] as String?;

      if (ingredientName != null && ingredientName.trim().isNotEmpty) {
        ingredients.add(MealIngredient(
          name: ingredientName.trim(),
          measurement: measure?.trim(),
        ));
      }
    }

    return MealModel(
      id: mealData['idMeal']?.toString() ?? '',
      name: mealData['strMeal']?.toString() ?? '',
      image: mealData['strMealThumb']?.toString(),
      category: mealData['strCategory']?.toString(),
      area: mealData['strArea']?.toString(),
      instructions: mealData['strInstructions']?.toString(),
      ingredients: ingredients,
      youtubeUrl: mealData['strYoutube']?.toString(),
      sourceUrl: mealData['strSource']?.toString(),
      thumbnailUrl: mealData['strMealThumb']?.toString(),
    );
  }

  /// Create MealModel from MealDB API response
  /// API returns: {"meals": [...]} or {"meals": null}
  factory MealModel.fromMealDbJson(Map<String, dynamic> json) {
    final meals = json['meals'];
    if (meals == null || meals.isEmpty) {
      throw Exception('No meals found in response');
    }

    // Handle single meal object
    if (meals is Map<String, dynamic>) {
      return MealModel.fromJson(meals);
    }

    // Handle list of meals
    if (meals is List && meals.isNotEmpty) {
      return MealModel.fromJson(meals.first);
    }

    throw Exception('Invalid meals format in response');
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
