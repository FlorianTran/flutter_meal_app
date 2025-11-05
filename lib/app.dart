import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/notifier/auth_notifier.dart';
import 'features/meals/presentation/pages/home_page.dart';
import 'core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'Meal App',
      theme: AppTheme.lightTheme,
      // TODO: Replace HomeScreen with HomePage once meal features are complete
      // For now, show HomePage for testing Phase 1.2
      home: authState.isAuthenticated
          ? const HomePage() // Using new HomePage from Phase 1.2
          : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
