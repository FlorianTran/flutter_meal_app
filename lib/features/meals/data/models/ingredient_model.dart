import '../../domain/entities/ingredient.dart';

/// Ingredient data model
class IngredientModel extends Ingredient {
  IngredientModel({
    required super.name,
    super.description,
    super.image,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['strIngredient']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image:
          json['strIngredientThumb']?.toString() ?? json['image']?.toString(),
    );
  }

  /// Create IngredientModel from MealDB list endpoint
  /// API returns: {"meals": [{"strIngredient": "..."}]} or simple list
  factory IngredientModel.fromMealDbJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return IngredientModel.fromJson(json);
    }
    if (json is String) {
      return IngredientModel(name: json);
    }
    throw Exception('Invalid ingredient format');
  }

  Map<String, dynamic> toJson() {
    return {
      'strIngredient': name,
      'description': description,
      'strIngredientThumb': image,
    };
  }

  Ingredient toEntity() {
    return Ingredient(
      name: name,
      description: description,
      image: image,
    );
  }
}
