import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_meal_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_meal_app/features/auth/di/auth_injection.dart';
import 'package:flutter_meal_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_meal_app/features/meals/presentation/pages/home_page.dart';

class SplashScreenPage extends ConsumerStatefulWidget {
  const SplashScreenPage({super.key});

  @override
  ConsumerState<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends ConsumerState<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _knifeRotation;
  late Animation<double> _forkRotation;
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();

    // Animation de rotation (simple)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _knifeRotation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _forkRotation = Tween<double>(begin: 0.3, end: -0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // ⏳ Forcer un minimum de 5 secondes avant de naviguer
    Future.delayed(const Duration(seconds: 5), () {
      _canNavigate = true;
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Surveille l’état d’auth et navigue quand prêt + délai atteint
    ref.listen(authStateProvider, (_, __) => _checkAuthAndNavigate());

    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: _knifeRotation.value,
                child: Icon(Icons.restaurant, size: 80, color: Colors.white),
              ),
              const SizedBox(width: 30),
              Transform.rotate(
                angle: _forkRotation.value,
                child: Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
