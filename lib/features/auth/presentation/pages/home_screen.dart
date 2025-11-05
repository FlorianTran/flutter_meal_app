
import 'package:flutter/material.dart';
import 'package:flutter_meal_app/features/meals/presentation/pages/ingredients_selection_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Home Screen!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IngredientsSelectionPage()),
                );
              },
              child: const Text('Select Ingredients'),
            ),
          ],
        ),
      ),
    );
  }
}
