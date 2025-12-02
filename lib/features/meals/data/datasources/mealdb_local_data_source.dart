import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';

abstract class MealDbLocalDataSource {
  Future<List<MealModel>?> getCachedMeals();
  Future<void> cacheMeals(List<MealModel> meals);
}

class MealDbLocalDataSourceImpl implements MealDbLocalDataSource {
  static const String cacheKey = 'cached_meals';

  @override
  Future<List<MealModel>?> getCachedMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(cacheKey);
      if (cachedString == null) return null;

      final decoded = json.decode(cachedString) as List;
      return decoded.map((e) => MealModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error reading cached meals: $e');
    }
  }

  @override
  Future<void> cacheMeals(List<MealModel> meals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(meals.map((m) => m.toJson()).toList());
      await prefs.setString(cacheKey, encoded);
    } catch (e) {
      throw Exception('Error saving cached meals: $e');
    }
  }
}
