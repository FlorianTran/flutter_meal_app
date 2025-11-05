import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static String get appName => dotenv.env['APP_NAME'] ?? 'Meal App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // Supabase (existing - may be removed if not needed)
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // MealDB API Configuration
  static String get mealdbApiKey => dotenv.env['MEALDB_API_KEY'] ?? '1';
  static String get mealdbBaseUrl =>
      dotenv.env['MEALDB_BASE_URL'] ?? 'https://www.themealdb.com/api/json/v1/';
  static String get mealdbApiUrl => '$mealdbBaseUrl$mealdbApiKey/';

  // MealDB API Endpoints
  static String get mealdbSearchEndpoint => 'search.php';
  static String get mealdbLookupEndpoint => 'lookup.php';
  static String get mealdbRandomEndpoint => 'random.php';
  static String get mealdbCategoriesEndpoint => 'categories.php';
  static String get mealdbListEndpoint => 'list.php';
  static String get mealdbFilterEndpoint => 'filter.php';

  // MealDB Image URLs
  static String get mealdbImageBaseUrl => 'https://www.themealdb.com/images/';
  static String get mealdbMealImageUrl => '${mealdbImageBaseUrl}media/meals/';
  static String get mealdbIngredientImageUrl =>
      '${mealdbImageBaseUrl}ingredients/';
}
