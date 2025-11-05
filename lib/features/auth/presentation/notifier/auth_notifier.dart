import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier({required this.repository}) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await repository.login(email, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: user.email,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: $e',
      );
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: 'Logout failed: $e');
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(repository: AuthRepositoryImpl());
});
