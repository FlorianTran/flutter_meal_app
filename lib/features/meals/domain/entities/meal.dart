/// Meal entity representing a recipe
class Meal {
  final String id;
  final String name;
  final String? image;
  final String? category;
  final String? area;
  final String? instructions;
  final List<MealIngredient> ingredients;
  final String? youtubeUrl;
  final String? sourceUrl;
  final String? thumbnailUrl;

  Meal({
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

/// Meal ingredient with measurement
class MealIngredient {
  final String name;
  final String? measurement;

  MealIngredient({
    required this.name,
    this.measurement,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealIngredient &&
        other.name == name &&
        other.measurement == measurement;
  }

  @override
  int get hashCode => Object.hash(name, measurement);
}
