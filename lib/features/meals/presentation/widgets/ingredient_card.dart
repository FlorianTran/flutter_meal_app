import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
    final imageUrl =
        'https://www.themealdb.com/images/ingredients/$ingredientName-small.png';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        margin: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main content column that fills the card
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image takes less space
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (c, o, s) =>
                          const Icon(Icons.fastfood, size: 24),
                    ),
                  ),
                ),
                // Text takes less space
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 2.0),
                    child: Text(
                      ingredientName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.getFontFamily(null),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Selection indicator
            if (isSelected)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle, color: Colors.green, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
