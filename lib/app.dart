import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/presentation/notifier/auth_notifier.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'flutter_meal_app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: authState.isAuthenticated ? const HomeScreen() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
