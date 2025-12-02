import '../../domain/entities/category.dart';

/// Category data model
class CategoryModel extends Category {
  CategoryModel({
    required super.name,
    super.description,
    super.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['strCategory']?.toString() ?? json['name']?.toString() ?? '',
      description: json['strCategoryDescription']?.toString() ??
          json['description']?.toString(),
      image: json['strCategoryThumb']?.toString() ?? json['image']?.toString(),
    );
  }

  /// Create CategoryModel from MealDB list endpoint
  /// API returns: {"meals": [{"strCategory": "..."}]} or simple list
  factory CategoryModel.fromMealDbJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CategoryModel.fromJson(json);
    }
    if (json is String) {
      return CategoryModel(name: json);
    }
    throw Exception('Invalid category format');
  }

  Map<String, dynamic> toJson() {
    return {
      'strCategory': name,
      'strCategoryDescription': description,
      'strCategoryThumb': image,
    };
  }

  Category toEntity() {
    return Category(
      name: name,
      description: description,
      image: image,
    );
  }
}
