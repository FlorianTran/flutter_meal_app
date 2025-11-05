import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Dependency injection setup
/// Add your dependency injection configuration here
class InjectionContainer {
  /// Initialize dependencies
  static Future<void> init() async {
    // Initialize Supabase
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get supabase => Supabase.instance.client;
}
