import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// MealDB API Client
class MealDbApiClient {
  final http.Client client;
  final String baseUrl;

  MealDbApiClient({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConstants.mealdbApiUrl;

  /// Perform GET request
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? queryParameters}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');

      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData;
      } else {
        throw ServerException(
          'Failed to load data: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error making API request: $e');
    }
  }

  /// Get random meal
  Future<Map<String, dynamic>> getRandomMeal() async {
    return await get(AppConstants.mealdbRandomEndpoint);
  }

  /// Search meals by name
  Future<Map<String, dynamic>> searchMeals(String query) async {
    return await get(
      AppConstants.mealdbSearchEndpoint,
      queryParameters: {'s': query},
    );
  }

  /// Search meals by first letter
  Future<Map<String, dynamic>> searchMealsByLetter(String letter) async {
    if (letter.length != 1) {
      throw ArgumentError('Letter must be a single character');
    }
    return await get(
      AppConstants.mealdbSearchEndpoint,
      queryParameters: {'f': letter.toLowerCase()},
    );
  }

  /// Lookup meal by ID
  Future<Map<String, dynamic>> lookupMeal(String id) async {
    return await get(
      AppConstants.mealdbLookupEndpoint,
      queryParameters: {'i': id},
    );
  }

  /// Get all categories
  Future<Map<String, dynamic>> getCategories() async {
    return await get(AppConstants.mealdbCategoriesEndpoint);
  }

  /// List categories (names only)
  Future<Map<String, dynamic>> listCategories() async {
    return await get(
      AppConstants.mealdbListEndpoint,
      queryParameters: {'c': 'list'},
    );
  }

  /// List areas (names only)
  Future<Map<String, dynamic>> listAreas() async {
    return await get(
      AppConstants.mealdbListEndpoint,
      queryParameters: {'a': 'list'},
    );
  }

  /// List ingredients (names only)
  Future<Map<String, dynamic>> listIngredients() async {
    return await get(
      AppConstants.mealdbListEndpoint,
      queryParameters: {'i': 'list'},
    );
  }

  /// Filter by category
  Future<Map<String, dynamic>> filterByCategory(String category) async {
    return await get(
      AppConstants.mealdbFilterEndpoint,
      queryParameters: {'c': category},
    );
  }

  /// Filter by area
  Future<Map<String, dynamic>> filterByArea(String area) async {
    return await get(
      AppConstants.mealdbFilterEndpoint,
      queryParameters: {'a': area},
    );
  }

  /// Filter by ingredient (single ingredient - free API limitation)
  Future<Map<String, dynamic>> filterByIngredient(String ingredient) async {
    // Replace spaces with underscores for API
    final formattedIngredient = ingredient.toLowerCase().replaceAll(' ', '_');
    return await get(
      AppConstants.mealdbFilterEndpoint,
      queryParameters: {'i': formattedIngredient},
    );
  }

  void dispose() {
    client.close();
  }
}
