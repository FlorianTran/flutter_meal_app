import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le fichier .env
  await dotenv.load(fileName: ".env");

  // Initialiser Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true, // 👈 Affiche les logs des requêtes Supabase dans la console
  );

  // Exécuter un test de connexion
  await _testSupabaseConnection();

  // Lancer ton app principale
  runApp(const ProviderScope(child: MyApp()));
}

/// Teste la connexion avec Supabase en essayant une requête simple
Future<void> _testSupabaseConnection() async {
  final supabase = Supabase.instance.client;

  print('Test de connexion Supabase...');

  try {
    // Essaie une requête simple sur une table (ex: profiles)
    await supabase.from('profiles').select().limit(1);

     /* print('Connexion Supabase OK : ${response.toString()}');*/
  } catch (e) {
    print('Erreur de connexion à Supabase : $e');
  }

  // Vérifie aussi l’auth si tu veux
  final user = supabase.auth.currentUser;
  if (user != null) {
    print('Utilisateur connecté : ${user.email}');
  } else {
    print('Aucun utilisateur connecté');
  }
}
