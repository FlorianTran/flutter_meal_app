
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_meal_app/core/constants/app_constants.dart';
import 'package:flutter_meal_app/core/error/exceptions.dart';
import 'package:flutter_meal_app/features/meals/data/models/meal_model.dart';
import 'package:flutter_meal_app/features/meals/data/models/ingredient_model.dart';

abstract class MealDBRemoteDataSource {
  Future<List<IngredientModel>> listIngredients();
  Future<List<MealModel>> getMealsByIngredient(String ingredient);
}

class MealDBRemoteDataSourceImpl implements MealDBRemoteDataSource {
  final http.Client client;

  MealDBRemoteDataSourceImpl({required this.client});

  String get baseUrl => '${AppConstants.mealdbBaseUrl}${AppConstants.mealdbApiKey}';

  @override
  Future<List<IngredientModel>> listIngredients() async {
    final response = await client.get(Uri.parse('$baseUrl/list.php?i=list'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ingredientsJson = data['meals'];
      return ingredientsJson
          .map((json) => IngredientModel.fromMealDbJson(json))
          .toList();
    } else {
      throw ServerException("");
    }
  }

  @override
  Future<List<MealModel>> getMealsByIngredient(String ingredient) async {
    final response = await client.get(Uri.parse('$baseUrl/filter.php?i=$ingredient'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // The API returns {"meals": null} if no meals are found
      if (data['meals'] == null) {
        return [];
      }
      final List<dynamic> mealsJson = data['meals'];
      return mealsJson.map((json) => MealModel.fromJson(json)).toList();
    } else {
      throw ServerException("");
    }
  }
}
