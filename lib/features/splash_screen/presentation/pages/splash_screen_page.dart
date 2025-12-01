import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_meal_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_meal_app/features/auth/di/auth_injection.dart';
import 'package:flutter_meal_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_meal_app/features/meals/presentation/pages/home_page.dart';
import 'package:lottie/lottie.dart';

class SplashScreenPage extends ConsumerStatefulWidget {
  const SplashScreenPage({super.key});

  @override
  ConsumerState<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends ConsumerState<SplashScreenPage> {
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();

    // Forcer un minimum de 5 secondes avant de naviguer
    Future.delayed(const Duration(seconds: 5), () {
      _canNavigate = true;
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() {
    // Ensure the widget is still mounted before attempting to navigate
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    authState.whenOrNull(
      data: (user) {
        if (_canNavigate) {
          if (user != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        }
      },
      // Handle error case if needed
      error: (error, stackTrace) {
        if (_canNavigate) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Surveille l’état d’auth et navigue quand prêt + délai atteint
    ref.listen(authStateProvider, (_, __) => _checkAuthAndNavigate());

    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Lottie.asset(
          'lib/features/splash_screen/presentation/animations/animation.json',
          width: 250,
          height: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
