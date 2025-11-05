import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get appName => dotenv.env['APP_NAME'] ?? 'Meal App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
