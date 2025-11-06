import 'package:flutter/material.dart';

class IngredientCard extends StatelessWidget {
  final String ingredientName;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const IngredientCard({
    super.key,
    required this.ingredientName,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // This widget displays an ingredient with its image and name.
    // It shows a visual indicator when selected.
    // The image URL will be constructed based on the ingredient name.
    final imageUrl = 'https://www.themealdb.com/images/ingredients/$ingredientName-small.png';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(imageUrl, errorBuilder: (c, o, s) => const Icon(Icons.fastfood)),
                const SizedBox(height: 8),
                Text(ingredientName, textAlign: TextAlign.center),
              ],
            ),
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
