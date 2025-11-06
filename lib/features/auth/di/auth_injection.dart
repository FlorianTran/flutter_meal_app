import 'package:flutter_meal_app/features/auth/data/repositories_impl/auth_repository_impl.dart';
import 'package:flutter_meal_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_meal_app/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data Layer
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Domain Layer
final authStateProvider = StreamProvider.autoDispose<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.onAuthStateChange;
});
