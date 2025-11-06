import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/notifier/auth_notifier.dart';
import 'features/meals/presentation/pages/home_page.dart';
import 'core/theme/app_theme.dart';

import 'features/splash_screen/presentation/pages/splash_screen_page.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _buildHome(),
      // Prevent viewport resizing on web when scrolling
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // Lock viewport size to prevent resizing when scrolling
        // Store initial size to prevent changes
        return MediaQuery(
          data: mediaQuery.copyWith(
            // Use fixed viewport size - don't allow it to change
            size: Size(
              mediaQuery.size.width,
              mediaQuery.size.height,
            ),
            viewPadding: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
            // Use device pixel ratio to maintain consistent sizing
            devicePixelRatio: mediaQuery.devicePixelRatio,
          ),
          child: child!,
        );
      },
    );
  }

  Widget _buildHome() {
    if (_showSplash) {
      return const SplashScreenPage();
    }

    final authState = ref.watch(authNotifierProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return authState.isAuthenticated ? const HomePage() : const LoginPage();
  }
}
