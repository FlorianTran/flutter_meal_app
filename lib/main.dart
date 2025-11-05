import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await InjectionContainer.init();

  runApp(const MyApp());
}
