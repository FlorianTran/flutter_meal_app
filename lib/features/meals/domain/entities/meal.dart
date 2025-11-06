import 'package:flutter_meal_app/features/meals/domain/entities/ingredient.dart';

/// Meal entity representing a recipe
class Meal {
  final String id;
  final String name;
  final String? image;
  final String? category;
  final String? area;
  final String? instructions;
  final List<Ingredient> ingredients;
  final String? youtubeUrl;
  final String? sourceUrl;
  final String? thumbnailUrl;

  const Meal({
    required this.id,
    required this.name,
    this.image,
    this.category,
    this.area,
    this.instructions,
    required this.ingredients,
    this.youtubeUrl,
    this.sourceUrl,
    this.thumbnailUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
